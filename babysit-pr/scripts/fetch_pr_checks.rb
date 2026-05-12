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
    /panic:/i,
    /fatal:/i,
  ].freeze

  class << self
    def run_gh(args)
      stdout, stderr, status = Open3.capture3("gh", *args)
      return nil unless status.success? && !stdout.strip.empty?

      JSON.parse(stdout)
    rescue JSON::ParserError
      nil
    end

    def run_gh_raw(args, allowed_codes: [0])
      stdout, stderr, status = Open3.capture3("gh", *args)
      return stdout if allowed_codes.include?(status.exitstatus)

      nil
    end

    def get_pr_info(pr_number = nil)
      args = ["pr", "view", "--json", "number,url,headRefName,baseRefName"]
      args.insert(2, pr_number.to_s) if pr_number
      run_gh(args)
    end

    def get_checks(pr_number = nil)
      args = ["pr", "checks"]
      args << pr_number.to_s if pr_number

      stdout, _stderr, _status = Open3.capture3("gh", *args)
      return [] if stdout.strip.empty?

      stdout.strip.split("\n").filter_map do |line|
        parts = line.split("\t")
        next if parts.length < 2

        {
          "name" => parts[0]&.strip,
          "bucket" => parts[1]&.strip,
          "link" => parts[3]&.strip || "",
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

    def run(pr_number: nil)
      pr_info = get_pr_info(pr_number)
      unless pr_info
        puts JSON.generate({ "error" => "No PR found for current branch" })
        exit 1
      end

      pr_num = pr_info["number"]
      branch = pr_info["headRefName"]

      checks = get_checks(pr_num)
      failed_runs = nil

      processed = checks.map do |check|
        result = {
          "name" => check["name"] || "unknown",
          "status" => check["bucket"] || "unknown",
          "link" => check["link"] || "",
        }

        if result["status"] == "fail"
          failed_runs ||= get_failed_runs(branch)

          matching = failed_runs.find { |r| (result["name"]).include?(r["name"]) || r["name"].include?(result["name"]) }
          if matching
            logs = get_run_logs(matching["databaseId"])
            if logs
              result["log_snippet"] = extract_failure_snippet(logs)
              result["run_id"] = matching["databaseId"]
            end
          end
        end

        result
      end

      output = {
        "pr" => {
          "number" => pr_num,
          "url" => pr_info["url"] || "",
          "branch" => branch,
          "base" => pr_info["baseRefName"] || "",
        },
        "summary" => {
          "total" => processed.length,
          "passed" => processed.count { |c| c["status"] == "pass" },
          "failed" => processed.count { |c| c["status"] == "fail" },
          "pending" => processed.count { |c| c["status"] == "pending" },
          "skipped" => processed.count { |c| ["skipping", "cancel"].include?(c["status"]) },
        },
        "checks" => processed,
      }

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
