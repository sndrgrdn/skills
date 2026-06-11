# Review Examples

Curated real examples from Tjalling's code reviews, organized by category. Use these to calibrate tone, depth, and specificity.

## Consistency Enforcement

> "This function breaks the pattern: There are no other functions in `../orders/requests/*` that take a handler as parameter."

> "I'd use the same style for asserting these errors as the existing tests use. That means asserting the full hash."

> "`ApplicationWorker` would be nicely symmetric with `ApplicationController` and `ApplicationRecord`."

> "I think `validate_item` has little value. The only thing it does, is asserting the same trivial attributes over and over again. I assume you followed the style from `create_spec.rb`, but I've just completely rewritten that file."

## Architecture & Layer Placement

> "In my opinion, `lib/` should not contain regular business logic. This belongs under `app/interactors/`."

> "I don't think we should use class inheritance to share logic between interactors. We use interactors to reuse logic, so simply introduce a new interactor that does the claiming."

> "Introducing `isDelivery` here makes the modal dependent on its parent component. `isDelivery` does not belong here. Conceptually it is a completely different thing from the existing props."

> "Since the interactor should be (mostly) independent of the order or downtime, putting it in `Item::` makes sense to me."

> "ugh (4) -- changes to the model, only to facilitate loading/serialization logic of Graphiti"

> "Having extra (but straightforward) frontend logic might be better than a resource that behaves slightly different from other resources, behaves slightly different from the AR model with the same name, and is asymmetrical wrt reading/updating."

## Questioning Complexity

> "Would anything break when [simpler approach]?"

> "Is this really needed?"

> "Actually, it is much simpler: Only `draft` orders need to be reindexed. Not all orders. This probably has a much bigger performance impact than the exact mechanism used."

> "Maybe it is just this? **The frontend should submit `owner_type: 'product_groups'` instead of `owner_type: 'ProductGroup'`**"

> "This reimplements `DepositHold::Create`. Maybe just call the interactor?"

> "Can we just do this? IMO `described_class` is an unnecessary abstraction that makes tests only harder to read."

## Testing Feedback

> "All these scenarios are way too important to be mocked. I think every test in this file should create inventory (stockcounts), and perform real availability checks."

> "Why is this a request test? This does not test anything in the controller, or test anything that cannot be covered by the interactor specs."

> "I think `include` would succeed when there are extra elements."
> ```suggestion
>       expect(order.plannings.pluck(:stopped)).to contain_exactly(5, 2)
> ```

> "The combination `acts_as_archivable`+`accepts_nested_attributes_for` needs an integration test."

> "A unit test of the interactors cannot catch errors caused by the interaction of interactors. Therefore this error requires an integration test."

> "Adding a toast message that can be asserted is often a simple way to make feature tests stable without having to resort to waiting/sleeping."

> "Both the changes and the assertions are done in the backend. Why is this tested using a slow feature test?"

## Performance Awareness

> "`items.each(&:release_slug!)` does a query _for each record_ and then `items.archive_all` does another query to archive the whole collection."

> "This instance of `line` is never used for the response, so it doesn't need the `include` param."

> "`LOWER(?)` not needed because the tag is already downcased in Ruby."

> "Ideally this would all be done in bulk, so that this works performantly for big lists of customers."

> "Doesn't `searchkick_import` create background jobs?"

## Direct Pushback With Reasoning

> "Making such a fundamental relation optional doesn't really feel good."

> "I don't think we need these indices and foreign keys."

> "The method `detect_ar_association_mismatch` blocks defining relations that correspond to an ActiveRecord through-relation. That code was added because using through-relations in resources caused confusion and performance problems. I think for long-term quality/maintainability, we better **not** add this semi-support."

> "Sets are so rarely used in Ruby, that using them when not needed is confusing."

> "Time travel needs to happen before any data is created, otherwise the ORM will reject any changes because the original `updated_at` comes from the future."

> "If the `due_date` exists, shouldn't it always be shown? From a legal PoV, Invoices aren't supposed to changed. So even when the feature is disabled, an invoice date that has been shown to the customer should never disappear."

## Teaching Through Context

> "This implements in SQL what is implemented in Ruby for the rendering of emails."

> "Relying on the side-effect of `Hash.delete` makes code hard to read."

> "Does `0.tap(&:to_d)` do anything? `0.to_d` returns `0.0`, but `0.tap(&:to_d)` returns `0`."

> "Aren't `summary` and `data` already parsed when ActiveRecord loads the record?"

> "Injecting the stdout/stderr streams as dependency means you don't have to stub it in tests."

## Concrete Alternatives With Code

> "I think you can let the browser do the real work here:"
> ```js
> const url = "/orders"
> new URL(url, window.location).origin != new URL(window.location).origin
> // => false
> ```

> "Conceptually, this mixes 'products' and 'images'. Suggestions:"
> ```jsx
> <VCard type="product-image" id={product.id}>
> <VCard type="photo" id={photo.id}>
> ```

> "I would do this, because it is closer to how we would explain it to a user:"
> ```suggestion
>   validates :quantity, numericality: { equal_to: 1 }, if: :trackable_product?
>   validates :quantity, numericality: { greater_than: 0 }, if: :bulk_product?
> ```

## Worker & Backfill Patterns

> "All the workers should inherit from `ApplicationWorker` instead, not include `Sidekiq::Worker` directly."

> "Consider using the `maintenance` queue instead of the `default`."

> "This backfill migration doesn't follow the established `backfiller` pattern. It should loop over the collection and pass each record to the worker. The worker only deals with one item at a time. We can easily queue millions of jobs and still be fine."

> "Use `call!` for proper exception handling with Sidekiq retries."

> ```ruby
> # Batch queueing with perform_bulk:
> pending_payments.in_batches do |batch|
>   Payment::ExpireAuthorizationWorker.perform_bulk(batch.ids.zip)
> end
> ```

## Blocking / Non-Blocking Structure

> **Blocking:**
> - All the workers should inherit from `ApplicationWorker` instead, not include `Sidekiq::Worker` directly.
>
> **Non blocking:**
> - Consider using the `maintenance` queue instead of the `default`
> - Abstract the ProbelySecurityScan logic into its own interactor
> - You could consider bumping the retries for cleanup to at least 3 too.

## Terse Approval

> "Looks good 👍"

> "Nice cleanup"

> ":shipit:"

> "Looks good. Just a few remarks."

> "Didn't try it out, but the code looks nice and straightforward."

> "Another open pull request less. Nice cleanup!"

> "Nice upgrade. I'm surprised how little changes were needed."

> "This doesn't destruct anything, and is easily reverted. Just let the user do silly things 🐺"

> "I'm still a little itchy wrt. **generic vs specific** and **duplication vs simplicity**. Approving because original comments have been addressed, and this solution is better than the one before."

## Scoping Feedback

> "I find it hard to grasp all changes here. Maybe the changes to this interactor can be extracted to an independent pull request."

> "Let's first see if we can clean up existing usages before deciding if we want to make it an error."

> "Not sure how important it is to keep this file up-to-date. We could add a check to the `migrate` CI job to break the build when this happens."

## Evidence-Backed Feedback

> "~423_201 records"
>
> "Processed 999 rows in 0.02s / Total: 3156327"
>
> "== 20251021072807 ReindexPlannings: migrated (342.7784s)"

> "Based on the screenshot, I would think the feature is enabled for basically every company? `(development + essential + pro + premium) == all`?? I think it would be better to remove all logic here, and just always persist all activity logs."
