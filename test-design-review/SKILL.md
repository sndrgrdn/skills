---
name: test-design-review
description: Review selected tests for design quality against a detailed test-design rubric.
disable-model-invocation: true
---

# Test Design Review

Review the specified tests against every rule below. When the caller supplies a diff instead of files, also read the application code it exercises so each rule can be judged.

## Process

1. **Pin the scope.** Take the files, diff, revisions, or pull request the caller named. When none is named, ask for a target; never infer one from a branch or a default ref.
2. **Assess every rule.** Work through Specification, Ends, not means, Essence, Abstraction level, Tests are not programs, and Determinism, including every distinct rule inside each. Keep a ledger marking every rule `finding`, `clear`, or `not applicable`. Done when every rule carries one of those states.
3. **Record findings.** Each material violation gets its location, the behavior or design risk it hides, and a specific remedy. Combine findings only when they share one cause and one remedy. Rank by severity.
4. **Report.** Always publish the ledger (no rule goes unmentioned) and list findings *location → risk → remedy*, most severe first. If the caller asked for fixes, apply them and re-run the affected tests. Otherwise stop after the report.

## Core Principle

A test is an executable specification. It answers exactly one question: "In scenario X, what should happen?" Every rule below is a way of honoring that question.

## Specification

**A test names the behavior it specifies, in "When X, then Y" form.**

Good:

- "When the user submits an empty form, display a validation error."
- "When the API returns 500, show a graceful error message."
- "When no records exist, display 'No results found'."

Bad: "It works correctly." (What does 'correctly' mean?), "It handles errors." (Which? How?), "It validates input." (What validation? What happens on failure?).

Name a scenario by its essence, not by the mechanism that triggers it.

Bad: `describe "scope=failed"`

Good: `describe "rerunning only failed tests"`

## Ends, not means

**Assert the outcome, never the mechanism.** A test should survive the implementation being replaced (a different class, method, flag, or cache) so long as what the user or the system observes stays the same. Mock-recording assertions (`have_received`), reads of cache store keys, and reach-ins to internals all test *means*; assert the observable *end* instead, and stub only what you must (external services), so the real code runs against the real outcome.

Assert the end result, not the pose that produced it:

```ruby
it "marks the particle's position blue" do
  world = World.new(10, 10)
  world.tick
  expect(world.color_at(5, 0)).to eq(0x0000FF)
end
```

The test above locks in two accidents: the particle happens to sit on cell (5, 0) and stays blue. It breaks the moment either changes, though the behavior (a touched cell takes the particle's color) never did. Read the real values instead:

```ruby
it "turns the touched cell into the particle's color" do
  world = World.new(10, 10)
  particle_color = world.particle_color
  particle_position = world.particle_position

  world.tick

  expect(world.color_at(particle_position[0], particle_position[1])).to eq(particle_color)
end
```

Assert observable behavior, not method calls:

```ruby
it "queues the task" do
  worker_pool = instance_double(WorkerPool, queue_task: nil)
  allow(WorkerPool).to receive(:new).and_return(worker_pool)

  QueueUnqueuedTasksJob.new.perform

  expect(worker_pool).to have_received(:queue_task).with(task)
end
```

The same test, as an observable end:

```ruby
it "records a queued event for the task" do
  expect { QueueUnqueuedTasksJob.new.perform }
    .to change { TaskEvent.where(name: "queued").count }.by(1)
end
```

Performance semantics too: test the effect, not the cache's key:

```ruby
it "caches the result" do
  test_suite_run.duration
  expect(Rails.cache.read("test_suite_run/#{test_suite_run.id}/duration")).not_to be_nil
end
```

The bad version reads the cache implementation; a future switch to memoization or a database column breaks it for no behavioral change. Test the observable contract: no redundant work on a second call.

```ruby
it "does not query the database on subsequent calls" do
  test_suite_run.duration

  query_count = 0
  callback = ->(*) { query_count += 1 }
  ActiveSupport::Notifications.subscribe("sql.active_record", callback)
  test_suite_run.duration
  ActiveSupport::Notifications.unsubscribe(callback)

  expect(query_count).to eq(0)
end
```

Assert what the user sees, not the route they were routed through:

```ruby
it "redirects to the repositories page" do
  visit root_path
  expect(page).to have_current_path(repositories_path)
end
```

The bad version is a routing check. The user-visible claim is richer:

```ruby
it "redirects to the repositories page" do
  visit root_path
  expect(page).to have_content("Repositories")
end
```

Drive the public seam, not a flag deep inside the code; here, making the task *finish* (an exit code) instead of installing the internal json it happens to read:

```ruby
task.update!(json_output: { "summary" => { "failure_count" => 0 } }.to_json)
```

→

```ruby
task.update!(exit_code: 0)
```

And read an email with a parser, not a hand-rolled regex that only knows yesterday's markup:

```ruby
def unsubscribe_path_from(sent_email)
  url = sent_email.body[/href="([^"]*notification_email_subscription[^"]*)"/, 1]
  URI.parse(url).path
end
```

→

```ruby
def unsubscribe_path_from(sent_email)
  doc = Nokogiri::HTML(sent_email.body)
  url = doc.at("a:contains('Stop receiving these emails')")["href"]
  URI.parse(url).path
end
```

Reach the public surface, never the object's insides. Do not use `.send`, `.public_send`, or `instance_variable_set` to touch a private method or variable. If a private method genuinely needs its own test, make it public; that is usually a small, honest price. And `instance_variable_set` is a confession of poor design: when it feels like the only option, name the design flaw and propose the concrete refactor instead of installing the test.

## Essence

**Assert only what matters.** Skip claims the response body already implies: if a body assertion fails, the response was not successful, so a separate `be_successful` check adds nothing but noise:

```ruby
expect(response).to be_successful  # implied by the body check
expect(response.body).not_to include("deleted_item")
```

→

```ruby
expect(response.body).not_to include("deleted_item")
```

Do not write tests that cannot fail; they answer "Is the code I wrote the code I wrote?" and the answer is always yup. A test that repeats the fixture's answer back into an expectation is autobiography, not a specification:

```ruby
it "renders a labeled checkbox for each github account" do
  first_github_account = create(:github_account, account_name: "first-account")
  second_github_account = create(:github_account, account_name: "second-account")

  get admin_job_runs_path

  document = Nokogiri::HTML(response.body)
  expect(labeled_checkbox_value(document, "first-account")).to eq(first_github_account.id)
  expect(labeled_checkbox_value(document, "second-account")).to eq(second_github_account.id)
end
```

Prefer a few concrete cases over one packed abstraction. The abstract version spends all its naming energy on the setup and still obscures the only claim under test:

```ruby
describe "#matches?" do
  context "when the root job run's status is one of the filter's statuses" do
    let!(:failed_job_run) { create(:job_run) }
    let!(:failed_task) { create(:task, :failed, job_run: failed_job_run) }

    it "is a match" do
      job_run_tree = JobRunTree.new(failed_job_run)
      filter_criteria = JobRunListFilterCriteria.new(branch_name: nil, statuses: ["Failed"])
      expect(job_run_tree.matches?(filter_criteria)).to eq(true)
    end
  end
end
```

Split the same claim into two concrete cases that read at a glance:

```ruby
describe "#matches?" do
  context "when filtering for failed job runs" do
    let!(:filter_criteria) { JobRunListFilterCriteria.new(branch_name: nil, statuses: ["Failed"]) }

    context "and the root job run failed" do
      let!(:root_job_run) { create(:job_run) }
      let!(:failed_task) { create(:task, :failed, job_run: root_job_run) }

      it "matches the tree" do
        expect(JobRunTree.new(root_job_run).matches?(filter_criteria)).to eq(true)
      end
    end

    context "and the root job run passed" do
      let!(:root_job_run) { create(:job_run) }
      let!(:passed_task) { create(:task, :passed, job_run: root_job_run) }

      it "does not match the tree" do
        expect(JobRunTree.new(root_job_run).matches?(filter_criteria)).to eq(false)
      end
    end
  end
end
```

And name the class under test rather than hiding it behind `described_class`; the indirection obscures the very subject and is rarely worth the confusion it causes.

## Abstraction level

**Keep a test at one level of abstraction, read top-to-bottom.**

Do not bury the scenario in a `describe` that re-states the whole suite. Name the scenario at its own level:

```ruby
describe "Rerun test suite run", type: :system do
  ...
  describe "Rerun Failed button" do
    context "when the test suite run has failed tests" do
      let!(:test_suite_run) { create(:test_suite_run, :with_task) }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("NOVA_K8S_API_URL").and_return("https://k8s.example.com")
        allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
        login_as(test_suite_run.repository.user)
      end

      it "displays the Rerun Failed button" do
        visit repository_test_suite_run_path(id: test_suite_run.id, repository_id: test_suite_run.repository.id)
        expect(page).to have_button("Rerun Failed")
      end
    end
  end
end
```

The description wraps the button test in the whole-suite frame that has nothing to say about it. Test the scene as its own scene:

```ruby
describe "Rerun Failed button", type: :system do
  context "when the test suite run has failed tests" do
    let!(:test_suite_run) { create(:test_suite_run, :with_task) }
    let!(:test_case_run) { create(:test_case_run, task: test_suite_run.tasks.first, status: "failed") }

    before do
      login_as(test_suite_run.repository.user)
    end

    it "displays the Rerun Failed button" do
      visit repository_test_suite_run_path(id: test_suite_run.id, repository_id: test_suite_run.repository.id)
      expect(page).to have_button("Rerun Failed")
    end
  end
end
```

Note what the rewrite dropped: the `before` no longer fabricates the entire k8s environment the suite needed; the scene itself does not need it, so it did not belong at this level.

### Shape each test Arrange, Act, Assert

Separate setup from the trigger from the expected outcome: let the `let!` hold the Arrange, the `before` the Act, and the `it` the Assert:

```ruby
it "shows only job runs belonging to the selected account" do
  selected_account = create(:github_account)
  selected_job_run = create(:job_run, repository: create(:repository, github_account: selected_account))
  other_job_run = create(:job_run, repository: create(:repository, github_account: create(:github_account)))

  get admin_job_runs_path(github_account_ids: [selected_account.id])

  expect(response.body).to include(selected_job_run.id)
  expect(response.body).not_to include(other_job_run.id)
end
```

→

```ruby
context "when filtered by github account" do
  let!(:selected_account) { create(:github_account) }
  let!(:selected_job_run) { create(:job_run, repository: create(:repository, github_account: selected_account)) }
  let!(:other_job_run) { create(:job_run, repository: create(:repository, github_account: create(:github_account))) }

  before { get admin_job_runs_path(github_account_ids: [selected_account.id]) }

  it "shows only job runs belonging to the selected account" do
    expect(response.body).to include(selected_job_run.id)
    expect(response.body).not_to include(other_job_run.id)
  end
end
```

### Push incidental ceremony below the test

A dense test drowns the point in machinery. Hide the machinery in a helper that sits *below* the test, since the helper is an incidental detail, not part of the test's meaning:

```ruby
it "queries the database only once" do
  dispatcher = TestSuiteExecution::TestSuiteRunDispatcher.new(cluster_cpu_headroom_millicores: 72000)

  query_count = 0
  callback = ->(*, _) { query_count += 1 }
  ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
    dispatcher.test_suite_runs_with_undispatched_tasks
    query_count_after_first_call = query_count
    dispatcher.test_suite_runs_with_undispatched_tasks
    expect(query_count).to eq(query_count_after_first_call)
  end
end
```

→

```ruby
it "queries the database only once" do
  dispatcher = TestSuiteExecution::TestSuiteRunDispatcher.new(cluster_cpu_headroom_millicores: 72000)

  first_call_count = count_queries { dispatcher.test_suite_runs_with_undispatched_tasks }
  second_call_count = count_queries { dispatcher.test_suite_runs_with_undispatched_tasks }

  expect(second_call_count).to eq(0)
end

def count_queries(&block)
  count = 0
  callback = ->(*) { count += 1 }
  ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &block)
  count
end
```

### Write setup top-to-bottom, and hard-code what you can

Read order matters: a mock that names `task_id` before `task_id` is defined reads backwards. Define the thing first, or skip the let entirely and write the literal:

```ruby
let!(:executor) { instance_double(Executor, task_id: '123') }
let!(:worker) { Worker.new(executor) }
```

The literal is better still: when nothing else references the value, a `let` is ceremony, so hard-code it.

## Tests are not programs

**Specs are flat and static.** The minute a test gains control flow (a loop, a counter, a poll, a branching stub) it stops specifying and starts implementing. It raises more questions than it answers and its failures are cryptic. Consider:

```ruby
it 'treats a timed-out job run as finished' do
  timed_out_response = double(body: '{"status": "Timed Out"}')
  client = double
  poll_count = 0
  allow(client).to receive(:get) do
    poll_count += 1
    raise 'polled again after a terminal status' if poll_count > 1

    timed_out_response
  end

  job_run = SaturnCI::JobRun.new(id: 'abc123', client: client)
  allow(job_run).to receive(:sleep)

  job_run.wait_for_completion

  expect(job_run.status).to eq('Timed Out')
end
```

A reader must unwrap a stateful stub to trust a single status change. Keep the test a plain Arrange-Act-Assert.

The quiet cousin of that failure is behavior the test never earns: a `wait:` someone cargo-culted in, a sleep, a retry. Ask whether it is fixing a real race you found or just covering for one you imagine:

```ruby
expect(page).to have_content("Passed", wait: 3)
```

Add `wait:` only where a later assertion genuinely races an asynchronous step; otherwise the extra wait trades a passing-but-leaky suite today for a mystifying failure later.

## Determinism

**Ask for the record you want, not the first or last record there happens to be.** `.first` and `.last` depend on record order, which silently changes; a test that relies on it fails for reasons unrelated to the behavior under test. Turn the incidental read into an explicit query with `where`:

```ruby
post repositories_path, params: { repo_full_name: "example-org/sample-app" }
repository = Repository.last
expect(repository.github_account).to eq(github_account)
```

→

```ruby
expect { post repositories_path, params: { repo_full_name: "example-org/sample-app" } }
  .to change { Repository.where(github_account: github_account).count }.by(1)
```
