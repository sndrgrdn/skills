#!/usr/bin/env ruby
# frozen_string_literal: true

# Monitor PR checks until they reach a terminal state.
#
# Usage:
#   ruby monitor_pr_checks.rb [--pr PR_NUMBER] [--poll-seconds 30] [--no-checks-seconds 15]
#
# Output:
#   - ALL_CHECKS_PASSED when all checks finish without failures
#   - CHECKS_DONE_WITH_FAILURES when checks finish with failures
#   - Tab-separated check summary after the terminal marker
#
# Stays quiet while polling. Retries transient gh failures.
# Waits for checks to register after a fresh push.

require "json"
require "open3"

module MonitorPrChecks
  class << self
    def get_pr_number(pr_number = nil)
      return pr_number if pr_number

      stdout, _stderr, status = Open3.capture3("gh", "pr", "view", "--json", "number")
      return nil unless status.success?

      data = JSON.parse(stdout)
      data["number"]
    rescue StandardError
      nil
    end

    def get_checks(pr_number)
      stdout, _stderr, status = Open3.capture3(
        "gh", "pr", "checks", pr_number.to_s,
        "--json", "name,bucket,link"
      )
      # gh pr checks exits 1 when there are failures, 8 when no checks
      return nil unless [0, 1, 8].include?(status.exitstatus)
      return nil if stdout.strip.empty?

      JSON.parse(stdout)
    rescue StandardError
      nil
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

    def run(pr_number: nil, poll_seconds: 30, no_checks_seconds: 15)
      pr_num = get_pr_number(pr_number)
      unless pr_num
        warn "No PR found for current branch"
        exit 1
      end

      loop do
        checks = get_checks(pr_num)

        if checks.nil?
          sleep(poll_seconds)
          next
        end

        if checks.empty?
          sleep(no_checks_seconds)
          next
        end

        pending = checks.count { |c| c["bucket"] == "pending" }
        if pending > 0
          sleep(poll_seconds)
          next
        end

        failed = checks.count { |c| c["bucket"] == "fail" }
        if failed > 0
          puts "CHECKS_DONE_WITH_FAILURES"
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

  args = ARGV.dup
  while args.any?
    case args.shift
    when "--pr"
      pr_number = args.shift&.to_i
    when "--poll-seconds"
      poll_seconds = args.shift&.to_i || 30
    when "--no-checks-seconds"
      no_checks_seconds = args.shift&.to_i || 15
    end
  end

  MonitorPrChecks.run(
    pr_number: pr_number,
    poll_seconds: poll_seconds,
    no_checks_seconds: no_checks_seconds
  )
end
