# PR Description Samples

> While looking at the migrated payments we found some refunds that don't seem to have a payment attached to it. This should no be possible due to it being a delegated type. We found refunds with the same payment_charge_id on them, but only one is correct.
>
> We think it has to do with concurrency and it trying to persist a refund at close to the same time. This is because the created_at is a couple msec apart from each other.

> We need to handle the new payment flow for requested payments
>
> This has the following:
> - Flippable routes for `pay/`
> - Simplified payment status pages
> - Migrates payment when has no owner yet
> - Handles the payments flows
> - Missing edge cases remain

The useful shape is problem, current theory, concrete change, unresolved edge cases. Clean the grammar without adding narrative drama.
