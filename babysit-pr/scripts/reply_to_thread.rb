#!/usr/bin/env ruby
# frozen_string_literal: true

# Reply to PR review threads.
#
# Usage:
#   ruby reply_to_thread.rb THREAD_ID BODY [THREAD_ID BODY ...]
#
# Accepts one or more (thread_id, body) pairs as positional arguments.
# Batches all replies into a single GraphQL mutation for efficiency.
#
# Example:
#   ruby reply_to_thread.rb PRRT_abc "Fixed the issue."
#   ruby reply_to_thread.rb PRRT_abc "Fixed." PRRT_def "Also fixed."

require "json"
require "open3"

module ReplyToThread
  class << self
    def reply_to_threads(pairs)
      mutations = pairs.each_with_index.map do |(thread_id, body), i|
        escaped_thread_id = JSON.generate(thread_id)
        escaped_body = JSON.generate(body)
        "  r#{i}: addPullRequestReviewThreadReply(input: {" \
          "pullRequestReviewThreadId: #{escaped_thread_id}, " \
          "body: #{escaped_body}" \
          "}) { clientMutationId }"
      end

      query = "mutation {\n#{mutations.join("\n")}\n}"

      stdout, stderr, status = Open3.capture3("gh", "api", "graphql", "-f", "query=#{query}")

      unless status.success?
        warn "GraphQL error: #{stderr}"
        return pairs.map { |tid, _| { "thread_id" => tid, "status" => "failed" } }
      end

      response = JSON.parse(stdout)
      data = response["data"] || {}
      errors = response["errors"] || []

      error_aliases = errors.flat_map { |e| (e["path"] || []).grep(/\Ar\d+\z/) }.to_set

      pairs.each_with_index.map do |(tid, _), i|
        alias_key = "r#{i}"
        ok = !error_aliases.include?(alias_key) && !data[alias_key].nil?
        { "thread_id" => tid, "status" => ok ? "ok" : "failed" }
      end
    rescue JSON::ParserError => e
      warn "Failed to parse GraphQL response: #{e.message}"
      pairs.map { |tid, _| { "thread_id" => tid, "status" => "failed" } }
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length < 2 || ARGV.length.odd?
    warn "Usage: ruby reply_to_thread.rb THREAD_ID BODY [THREAD_ID BODY ...]"
    exit 1
  end

  pairs = ARGV.each_slice(2).to_a
  results = ReplyToThread.reply_to_threads(pairs)

  replied = results.count { |r| r["status"] == "ok" }
  failed = results.count { |r| r["status"] == "failed" }

  output = {
    "replied" => replied,
    "failed" => failed,
    "operations" => results,
  }

  puts JSON.pretty_generate(output)
  exit 1 if failed > 0
end
