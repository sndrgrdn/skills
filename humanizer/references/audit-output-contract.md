# Audit And Output Contract

Use this before returning the result.

## Anti-AI audit checklist

Check the draft rewrite for:

- [ ] generic significance, legacy, or broader-landscape claims
- [ ] promotional or press-release adjectives
- [ ] unsupported -ing analysis
- [ ] vague authorities or inflated source quantity
- [ ] high-density AI vocabulary clusters
- [ ] copula avoidance where `is/has` is clearer
- [ ] negative parallelisms and fake contrasts
- [ ] forced rule-of-three structure
- [ ] synonym cycling instead of natural repetition
- [ ] filler, hedging, and generic conclusion residue
- [ ] title-case headings, bold label lists, unnecessary tables
- [ ] em dash overuse, curly quote mismatch, emoji mismatch
- [ ] Markdown or markup leakage for the target venue
- [ ] chatbot correspondence phrases
- [ ] cutoff/source-gap speculation
- [ ] citation artifacts, UTM leakage, placeholder refs
- [ ] voice mismatch with supplied sample
- [ ] fake specificity introduced during rewriting

## Response contract

Return exactly these sections unless the user explicitly asks for only a final version:

1. **Draft rewrite**
2. **Anti-AI audit**
3. **Final rewrite**
4. **Changes made**

## Audit language

Keep audit bullets brief and actionable:

- "Still has one generic contrast: 'not just X but Y'."
- "The ending is too neat and motivational."
- "The source claim is unverifiable from the supplied text; I kept it broad."
- "The rhythm is still too uniform: three similar medium-length sentences in a row."

## If the user asks for detection only

Return:

1. **Assessment** — cautious confidence level: low/medium/high.
2. **Tells** — pattern clusters with examples.
3. **False-positive notes** — plausible human explanations.
4. **Fixes** — highest-impact rewrites or checks.

Never return "this is definitely AI" unless the text includes explicit tool artifacts or known provenance.

## If the user asks for a quick version

Return only:

1. **Final rewrite**
2. **Main fixes**

Still do the audit internally.
