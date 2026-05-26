#!/usr/bin/env ruby
# frozen_string_literal: true

# Monitor PR checks until they reach a terminal state.
#
# Usage:
#   ruby monitor_pr_checks.rb [--pr NUMBER] [--poll-seconds 30] [--no-checks-seconds 15] [--no-checks-timeout-seconds 180]
#
# Output:
#   - ALL_CHECKS_PASSED when all checks finish without failures
#   - CHECKS_DONE_WITH_FAILURES when checks finish with failures
#   - NO_CHECKS_REGISTERED when checks do not appear after the grace period
#   - DRAFT_PR_WITH_NO_CHECKS when a draft PR has no checks after the grace period
#   - CHECKS_BLOCKED_BY_REVIEW_GATE when only human review/approval gates remain
#   - Tab-separated check summary after the terminal marker

require "json"
require "open3"

module MonitorPrChecks
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

  class << self
    def run_gh_json(args, allowed_codes: [0], empty_value: nil)
      stdout, _stderr, status = Open3.capture3("gh", *args)
      return nil unless allowed_codes.include?(status.exitstatus)
      return empty_value if stdout.strip.empty?

      JSON.parse(stdout)
    rescue JSON::ParserError
      nil
    end

    def get_pr_info(pr_number = nil)
      if pr_number
        run_gh_json(["pr", "view", pr_number.to_s, "--json", "number,url,isDraft,reviewDecision"])
      else
        run_gh_json(["pr", "view", "--json", "number,url,isDraft,reviewDecision"])
      end
    end

    def get_checks(pr_number)
      run_gh_json(
        ["pr", "checks", pr_number.to_s, "--json", "name,bucket,link,workflow,state,description"],
        allowed_codes: [0, 1, 8, 16],
        empty_value: []
      )
    end

    def human_gate_check?(check)
      haystack = %w[name state description workflow].map { |field| check[field].to_s }.join(" ")
      HUMAN_GATE_PATTERNS.any? { |pattern| haystack.match?(pattern) }
    end

    def print_summary(checks, max_lines: 20)
      checks.first(max_lines).each do |check|
        name = check["name"] || "unknown"
        bucket = check["bucket"] || "unknown"
        link = check["link"] || ""
        puts "#{name}\t#{bucket}\t#{link}".rstrip
      end
      $stdout.flush
    end

    def print_no_checks_summary(pr_info)
      number = pr_info["number"] || "unknown"
      url = pr_info["url"] || ""
      is_draft = !!pr_info["isDraft"]
      review_decision = pr_info["reviewDecision"] || ""
      puts "PR ##{number}\tno_checks\t#{url}".rstrip
      puts "is_draft\t#{is_draft}"
      puts "review_decision\t#{review_decision}" unless review_decision.empty?
      $stdout.flush
    end

    def run(pr_number: nil, poll_seconds: 30, no_checks_seconds: 15, no_checks_timeout_seconds: 180)
      pr_info = get_pr_info(pr_number)
      unless pr_info && pr_info["number"]
        warn "No PR found for current branch"
        exit 1
      end

      pr_num = pr_info["number"]
      no_checks_started_at = nil

      loop do
        checks = get_checks(pr_num)

        if checks.nil?
          sleep(poll_seconds)
          next
        end

        if checks.empty?
          no_checks_started_at ||= Process.clock_gettime(Process::CLOCK_MONOTONIC)
          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - no_checks_started_at

          if elapsed >= no_checks_timeout_seconds
            marker = pr_info["isDraft"] ? "DRAFT_PR_WITH_NO_CHECKS" : "NO_CHECKS_REGISTERED"
            puts marker
            print_no_checks_summary(pr_info)
            return
          end

          sleep(no_checks_seconds)
          next
        end

        no_checks_started_at = nil

        pending_checks = checks.select { |c| c["bucket"] == "pending" }
        failed = checks.count { |c| c["bucket"] == "fail" }
        actionable_pending = pending_checks.reject { |c| human_gate_check?(c) }

        if actionable_pending.any?
          sleep(poll_seconds)
          next
        end

        if failed > 0
          puts "CHECKS_DONE_WITH_FAILURES"
        elsif pending_checks.any?
          puts "CHECKS_BLOCKED_BY_REVIEW_GATE"
        else
          puts "ALL_CHECKS_PASSED"
        end
        $stdout.flush

        print_summary(checks)
        return
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  pr_number = nil
  poll_seconds = 30
  no_checks_seconds = 15
  no_checks_timeout_seconds = 180

  args = ARGV.dup
  while args.any?
    case args.shift
    when "--pr"
      pr_number = args.shift&.to_i
    when "--poll-seconds"
      poll_seconds = args.shift&.to_i || 30
    when "--no-checks-seconds"
      no_checks_seconds = args.shift&.to_i || 15
    when "--no-checks-timeout-seconds"
      no_checks_timeout_seconds = args.shift&.to_i || 180
    end
  end

  MonitorPrChecks.run(
    pr_number: pr_number,
    poll_seconds: poll_seconds,
    no_checks_seconds: no_checks_seconds,
    no_checks_timeout_seconds: no_checks_timeout_seconds
  )
end
