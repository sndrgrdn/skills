#!/usr/bin/env ruby
# frozen_string_literal: true

# Fetch PR CI checks and extract failure snippets from logs.
#
# Usage:
#   ruby fetch_pr_checks.rb [--pr PR_NUMBER]
#
# Output: JSON to stdout with structured check data.

require "json"
require "open3"

module FetchPrChecks
  HUMAN_GATE_PATTERNS = [
    /review\s+required/i,
    /required\s+review/i,
    /requires\s+review/i,
    /required\s+approving\s+review/i,
    /approval\s+required/i,
    /waiting\s+for\s+approval/i,
    /manual\s+approval/i,
    /draft\s+(pull\s+request|pr)/i,
  ].freeze

  FAILURE_PATTERNS = [
    # Ruby / RSpec
    /Failure\/Error/i,
    /expected .* got/i,
    /RSpec::/,
    /Failures:/,
    /# \.\/spec\//,
    # Cucumber
    /Failing Scenarios:/i,
    /Cucumber::/,
    # Ruby exceptions
    /NoMethodError/,
    /NameError/,
    /ArgumentError/,
    /ActiveRecord::/,
    /RuntimeError/,
    /SyntaxError/,
    /LoadError/,
    /TypeError/,
    /StandardError/,
    # JS / pnpm
    /FAIL/,
    /✕/,
    /npm ERR!/,
    /ReferenceError/,
    # Lint
    /offenses detected/i,
    /Confidence: High/i,
    /Security Warnings/i,
    # General
    /error[:\s]/i,
    /failed[:\s]/i,
    /failure[:\s]/i,
    /traceback/i,
    /exception/i,
    /panic:/i,
    /fatal:/i,
  ].freeze

  class << self
    def run_gh(args, allowed_codes: [0])
      stdout, _stderr, status = Open3.capture3("gh", *args)
      return nil unless allowed_codes.include?(status.exitstatus) && !stdout.strip.empty?

      JSON.parse(stdout)
    rescue JSON::ParserError
      nil
    end

    def human_gate_check?(check)
      haystack = %w[name state description workflow].map { |field| check[field].to_s }.join(" ")
      HUMAN_GATE_PATTERNS.any? { |pattern| haystack.match?(pattern) }
    end

    def get_pr_info(pr_number = nil)
      args = ["pr", "view", "--json", "number,url,headRefName,baseRefName,isDraft,reviewDecision,headRefOid"]
      args.insert(2, pr_number.to_s) if pr_number
      run_gh(args)
    end

    def get_checks(pr_number = nil)
      args = ["pr", "checks"]
      args << pr_number.to_s if pr_number
      args.concat(["--json", "name,bucket,link,workflow,state,description,event"])

      stdout, _stderr, status = Open3.capture3("gh", *args)
      return [] if stdout.strip.empty?

      begin
        checks = JSON.parse(stdout)
        return checks if checks.is_a?(Array)
      rescue JSON::ParserError
        # fall through to tab parsing
      end

      stdout.strip.split("\n").filter_map do |line|
        parts = line.split("\t")
        next if parts.length < 2

        {
          "name" => parts[0]&.strip,
          "bucket" => parts[1]&.strip,
          "link" => parts[3]&.strip || "",
          "workflow" => "",
        }
      end
    rescue StandardError
      []
    end

    def get_failed_runs(branch)
      result = run_gh([
        "run", "list",
        "--branch", branch,
        "--limit", "10",
        "--json", "databaseId,name,status,conclusion,headSha",
      ])
      return [] unless result.is_a?(Array)

      result.select { |r| r["conclusion"] == "failure" }
    end

    def extract_failure_snippet(log_text, max_lines: 50)
      lines = log_text.split("\n")

      failure_indices = lines.each_with_index.filter_map do |line, i|
        i if FAILURE_PATTERNS.any? { |pat| pat.match?(line) }
      end

      if failure_indices.empty?
        return lines.last(max_lines).join("\n")
      end

      first = failure_indices.first
      start_idx = [0, first - 5].max
      end_idx = [lines.length, first + max_lines - 5].min

      snippet = lines[start_idx...end_idx]

      remaining = failure_indices.count { |i| i >= end_idx }
      snippet << "\n... (#{remaining} more error(s) follow)" if remaining > 0

      snippet.join("\n")
    end

    def get_run_logs(run_id)
      stdout, _stderr, _status = Open3.capture3(
        "gh", "run", "view", run_id.to_s, "--log-failed",
        timeout: 60
      )
      stdout.empty? ? nil : stdout
    rescue StandardError
      nil
    end

    def get_repo_nwo
      stdout, _stderr, status = Open3.capture3("gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")
      return nil unless status.exitstatus == 0
      nwo = stdout.strip
      nwo.empty? ? nil : nwo
    rescue StandardError
      nil
    end

    def extract_check_run_id(link)
      return nil if link.to_s.empty?
      return nil if link.include?("/actions/runs/")
      m = link.match(%r{/runs/(\d+)})
      m ? m[1].to_i : nil
    end

    def get_annotations(repo_nwo, check_run_id)
      return [] unless repo_nwo && check_run_id
      result = run_gh(["api", "repos/#{repo_nwo}/check-runs/#{check_run_id}/annotations"])
      result.is_a?(Array) ? result : []
    rescue StandardError
      []
    end

    def format_annotation_snippet(annotations)
      lines = annotations.map do |a|
        location = "#{a['path']}:#{a['start_line']}"
        title = a["title"] || "Error"
        message = (a["message"] || "").split("\n").first(3).join("\n")
        "\u2717 #{title}\n  #{location}\n  #{message}"
      end
      lines.join("\n\n")
    end

    def action_required(pr_info:, processed:, summary:)
      if pr_info["isDraft"] && processed.empty?
        "Draft PR has no registered checks; do not wait for CI indefinitely"
      elsif processed.empty?
        "No registered checks; monitor before reporting NO_CHECKS_REGISTERED"
      elsif summary["actionable_pending"] > 0
        "Wait for actionable checks to finish; poll feedback while waiting"
      elsif summary["failed"] > 0
        "Address failed checks"
      elsif summary["pending"] > 0 && summary["actionable_pending"] == 0
        "Only human review or approval gates remain pending"
      end
    end

    def run(pr_number: nil)
      pr_info = get_pr_info(pr_number)
      unless pr_info
        puts JSON.generate({ "error" => "No PR found for current branch" })
        exit 1
      end

      pr_num = pr_info["number"]
      branch = pr_info["headRefName"]
      sha = pr_info["headRefOid"]
      checks = get_checks(pr_num)
      failed_runs = nil
      repo_nwo = nil

      processed = checks.map do |check|
        status = check["bucket"] || check["state"] || "unknown"
        human_gate = status == "pending" && human_gate_check?(check)

        result = {
          "name" => check["name"] || "unknown",
          "status" => status,
          "link" => check["link"] || "",
          "workflow" => check["workflow"] || "",
        }
        result["state"] = check["state"] if check["state"]
        result["description"] = check["description"] if check["description"]
        result["human_gate"] = true if human_gate

        if result["status"] == "fail"
          # Fast path: structured annotations from the check run API
          check_run_id = extract_check_run_id(result["link"])
          if check_run_id
            repo_nwo ||= get_repo_nwo
            if repo_nwo
              annotations = get_annotations(repo_nwo, check_run_id)
              failure_annotations = annotations.select { |a| a["annotation_level"] == "failure" }
              if failure_annotations.any?
                result["annotations"] = failure_annotations.map do |a|
                  {
                    "path" => a["path"],
                    "line" => a["start_line"],
                    "title" => a["title"],
                    "message" => a["message"],
                  }
                end
                result["log_snippet"] = format_annotation_snippet(failure_annotations)
                result["check_run_id"] = check_run_id
              end
            end
          end

          # Fallback: parse logs when annotations unavailable
          unless result["log_snippet"]
            failed_runs ||= get_failed_runs(branch)
            workflow_name = result["workflow"].to_s.empty? ? result["name"] : result["workflow"]
            matching = failed_runs.find { |r| workflow_name.include?(r["name"]) || r["name"].include?(workflow_name) }
            if matching
              logs = get_run_logs(matching["databaseId"])
              if logs
                result["log_snippet"] = extract_failure_snippet(logs)
                result["run_id"] = matching["databaseId"]
              end
            end
          end
        end

        result
      end

      summary = {
        "total" => processed.length,
        "passed" => processed.count { |c| c["status"] == "pass" },
        "failed" => processed.count { |c| c["status"] == "fail" },
        "pending" => processed.count { |c| c["status"] == "pending" },
        "actionable_pending" => processed.count { |c| c["status"] == "pending" && !c["human_gate"] },
        "human_gate_pending" => processed.count { |c| c["status"] == "pending" && c["human_gate"] },
        "skipped" => processed.count { |c| %w[skipping cancel].include?(c["status"]) },
      }

      output = {
        "pr" => {
          "number" => pr_num,
          "url" => pr_info["url"] || "",
          "branch" => branch,
          "base" => pr_info["baseRefName"] || "",
          "is_draft" => !!pr_info["isDraft"],
          "review_decision" => pr_info["reviewDecision"] || "",
        },
        "summary" => summary,
        "checks" => processed,
      }

      required = action_required(pr_info: pr_info, processed: processed, summary: summary)
      output["action_required"] = required if required

      puts JSON.pretty_generate(output)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  pr_number = nil
  if (idx = ARGV.index("--pr"))
    pr_number = ARGV[idx + 1]&.to_i
  end
  FetchPrChecks.run(pr_number: pr_number)
end
