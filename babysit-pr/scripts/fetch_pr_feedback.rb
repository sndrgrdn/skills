#!/usr/bin/env ruby
# frozen_string_literal: true

# Fetch and categorize PR review feedback.
#
# Usage:
#   ruby fetch_pr_feedback.rb [--pr PR_NUMBER]
#
# Output: JSON to stdout with categorized feedback.
#
# Categories:
# - high: Must address before merge (blockers, security, changes requested)
# - medium: Should address (standard feedback)
# - low: Optional suggestions (nit, style, consider)
# - bot: Informational automated comments (skip silently)
# - resolved: Already resolved threads

require "json"
require "open3"

module FetchPrFeedback
  # Bots that provide actionable code review feedback.
  # Categorized by content into high/medium/low with review_bot: true.
  REVIEW_BOT_PATTERNS = [
    /\Acopilot/i,
    /\Adevin/i,
    /\Acursor/i,
    /\Abugbot/i,
    /\Acodeql/i,
    /\Agithub-advanced-security/i,
  ].freeze

  # Bots that post informational status reports. Skipped silently.
  INFO_BOT_PATTERNS = [
    /\Agithub-actions/i,
    /\Adependabot/i,
    /\Arenovate/i,
    /\Amergify/i,
    /\Acodecov/i,
    /\Asonarcloud/i,
    /\Asnyk/i,
    /bot\z/i,
    /\[bot\]\z/i,
  ].freeze

  HIGH_PATTERNS = [
    /must\s+(fix|change|update|address)/i,
    /this\s+(is\s+)?(wrong|incorrect|broken|buggy)/i,
    /security\s+(issue|vulnerability|concern)/i,
    /will\s+(break|cause|fail)/i,
    /critical/i,
    /blocker/i,
  ].freeze

  LOW_PATTERNS = [
    /nit[:\s]/i,
    /nitpick/i,
    /suggestion[:\s]/i,
    /consider\s+/i,
    /could\s+(also\s+)?/i,
    /might\s+(want\s+to|be\s+better)/i,
    /optional[:\s]/i,
    /minor[:\s]/i,
    /style[:\s]/i,
    /prefer\s+/i,
    /what\s+do\s+you\s+think/i,
    /up\s+to\s+you/i,
    /take\s+it\s+or\s+leave/i,
    /fwiw/i,
  ].freeze

  class << self
    def run_gh(args)
      stdout, _stderr, status = Open3.capture3("gh", *args)
      return nil unless status.success? && !stdout.strip.empty?

      JSON.parse(stdout)
    rescue JSON::ParserError
      nil
    end

    def get_repo_info
      result = run_gh(["repo", "view", "--json", "owner,name"])
      return nil unless result

      owner = result.dig("owner", "login")
      name = result["name"]
      [owner, name] if owner && name
    end

    def get_pr_info(pr_number = nil)
      args = ["pr", "view", "--json", "number,url,headRefName,author,reviews,reviewDecision"]
      args.insert(2, pr_number.to_s) if pr_number
      run_gh(args)
    end

    def review_bot?(username)
      REVIEW_BOT_PATTERNS.any? { |p| p.match?(username) }
    end

    def info_bot?(username)
      INFO_BOT_PATTERNS.any? { |p| p.match?(username) }
    end

    def categorize_comment(body, author)
      return "bot" if info_bot?(author) && !review_bot?(author)
      return "high" if HIGH_PATTERNS.any? { |p| p.match?(body) }
      return "low" if LOW_PATTERNS.any? { |p| p.match?(body) }

      "medium"
    end

    def build_item(body:, author:, path: nil, line: nil, url: nil, resolved: false, outdated: false, review_bot: false, thread_id: nil)
      summary = body.length > 200 ? "#{body[0...200]}..." : body
      summary = summary.gsub("\n", " ").strip

      item = { "author" => author, "body" => summary, "full_body" => body }
      item["path"] = path if path
      item["line"] = line if line
      item["url"] = url if url
      item["resolved"] = true if resolved
      item["outdated"] = true if outdated
      item["review_bot"] = true if review_bot
      item["thread_id"] = thread_id if thread_id
      item
    end

    def get_review_threads(owner, repo, pr_number)
      query = <<~GRAPHQL
        query($owner: String!, $repo: String!, $pr: Int!) {
          repository(owner: $owner, name: $repo) {
            pullRequest(number: $pr) {
              reviewThreads(first: 100) {
                nodes {
                  id
                  isResolved
                  isOutdated
                  path
                  line
                  comments(first: 10) {
                    nodes {
                      id
                      body
                      author { login }
                      createdAt
                    }
                  }
                }
              }
            }
          }
        }
      GRAPHQL

      stdout, _stderr, status = Open3.capture3(
        "gh", "api", "graphql",
        "-f", "query=#{query}",
        "-F", "owner=#{owner}",
        "-F", "repo=#{repo}",
        "-F", "pr=#{pr_number}"
      )
      return [] unless status.success?

      data = JSON.parse(stdout)
      data.dig("data", "repository", "pullRequest", "reviewThreads", "nodes") || []
    rescue StandardError
      []
    end

    def get_issue_comments(owner, repo, pr_number)
      result = run_gh(["api", "repos/#{owner}/#{repo}/issues/#{pr_number}/comments", "--paginate"])
      result.is_a?(Array) ? result : []
    end

    def run(pr_number: nil)
      repo_info = get_repo_info
      unless repo_info
        puts JSON.generate({ "error" => "Could not determine repository" })
        exit 1
      end
      owner, repo = repo_info

      pr_info = get_pr_info(pr_number)
      unless pr_info
        puts JSON.generate({ "error" => "No PR found for current branch" })
        exit 1
      end

      pr_num = pr_info["number"]
      pr_author = pr_info.dig("author", "login") || ""
      review_decision = pr_info["reviewDecision"] || ""

      feedback = { "high" => [], "medium" => [], "low" => [], "bot" => [], "resolved" => [] }

      # Process reviews for changes_requested
      (pr_info["reviews"] || []).each do |review|
        next unless review["state"] == "CHANGES_REQUESTED"

        author = review.dig("author", "login") || ""
        body = review["body"] || ""
        next if body.empty? || author == pr_author

        item = build_item(body: body, author: author)
        item["type"] = "changes_requested"
        feedback["high"] << item
      end

      # Process review threads
      threads = get_review_threads(owner, repo, pr_num)
      threads.each do |thread|
        comments = thread.dig("comments", "nodes") || []
        next if comments.empty?

        first = comments.first
        author = first.dig("author", "login") || ""
        body = first["body"] || ""
        next if author == pr_author || body.strip.length < 3

        is_resolved = thread["isResolved"] || false
        is_outdated = thread["isOutdated"] || false
        thread_id = thread["id"]

        item = build_item(
          body: body, author: author,
          path: thread["path"], line: thread["line"],
          resolved: is_resolved, outdated: is_outdated,
          thread_id: thread_id
        )

        if is_resolved
          feedback["resolved"] << item
        elsif review_bot?(author)
          category = categorize_comment(body, author)
          item["review_bot"] = true
          feedback[category] << item
        elsif info_bot?(author)
          feedback["bot"] << item
        else
          category = categorize_comment(body, author)
          feedback[category] << item
        end
      end

      # Process issue comments
      issue_comments = get_issue_comments(owner, repo, pr_num)
      issue_comments.each do |comment|
        author = comment.dig("user", "login") || ""
        body = comment["body"] || ""
        next if author == pr_author || body.strip.length < 3

        item = build_item(body: body, author: author, url: comment["html_url"])

        if review_bot?(author)
          category = categorize_comment(body, author)
          item["review_bot"] = true
          feedback[category] << item
        elsif info_bot?(author)
          feedback["bot"] << item
        else
          category = categorize_comment(body, author)
          feedback[category] << item
        end
      end

      review_bot_count = %w[high medium low].sum { |b| feedback[b].count { |i| i["review_bot"] } }

      output = {
        "pr" => {
          "number" => pr_num,
          "url" => pr_info["url"] || "",
          "author" => pr_author,
          "review_decision" => review_decision,
        },
        "summary" => {
          "high" => feedback["high"].length,
          "medium" => feedback["medium"].length,
          "low" => feedback["low"].length,
          "bot_comments" => feedback["bot"].length,
          "resolved" => feedback["resolved"].length,
          "review_bot_feedback" => review_bot_count,
          "needs_attention" => feedback["high"].length + feedback["medium"].length,
        },
        "feedback" => feedback,
      }

      output["action_required"] = if feedback["high"].any?
        "Address high-priority feedback before merge"
      elsif feedback["medium"].any?
        "Address medium-priority feedback"
      elsif feedback["low"].any?
        "Review low-priority suggestions - ask user which to address"
      end

      puts JSON.pretty_generate(output)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  pr_number = nil
  if (idx = ARGV.index("--pr"))
    pr_number = ARGV[idx + 1]&.to_i
  end
  FetchPrFeedback.run(pr_number: pr_number)
end
