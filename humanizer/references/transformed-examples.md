# Transformed Examples

Use this to imitate quality and avoid common failures.

## Happy path: marketing-ish paragraph

Input:
> Nestled in the heart of Leeuwarden, our platform serves as a groundbreaking solution for teams seeking to streamline collaboration, enhance productivity, and unlock innovation. It is not just a tool; it is a catalyst for modern work.

Draft rewrite:
> Our platform helps teams in Leeuwarden coordinate work, share updates, and keep decisions in one place.

Audit:
- Too flat; it removed slop but also removed all sales intent.
- The location may not matter unless the user wants it.

Final rewrite:
> Our platform gives teams one place to plan work, share updates, and see decisions without digging through chat threads. It is built in Leeuwarden, but the problem is familiar everywhere: people lose time when the work lives in too many places.

Fixes:
- Promotional language, copula avoidance, rule of three, negative parallelism, generic significance.

## Robust/secure variant: suspicious citation artifacts

Input:
> The company was founded in 2019 and has become a pivotal player in the fintech landscape, according to industry reports. Its growth highlights increasing demand for secure digital banking solutions. citeturn0search0 Learn more at https://example.com/report?utm_source=chatgpt.com

Draft rewrite:
> The company was founded in 2019. It says demand for digital banking tools has grown, but the supplied citation artifact is not a usable source.

Audit:
- Good: does not preserve the fake citation.
- Needs clearer handling of the unsupported growth claim.

Final rewrite:
> The company was founded in 2019. I removed the unsupported claim that it is a "pivotal player" and stripped the ChatGPT tracking/citation artifact. If you want to keep the growth claim, supply the actual report and I can tie the sentence to what it says.

Fixes:
- Significance inflation, vague attribution, citation artifact, UTM leakage, fake specificity avoidance.

## Anti-pattern and correction: over-humanizing

Input:
> The new policy aims to improve response times and reduce confusion during incident handoffs.

Bad rewrite:
> Honestly, this policy is kind of a lifesaver. Nobody wants to be awake at 3am wondering who owns the incident, and this finally cuts through the chaos.

Why it fails:
- Adds unsupported emotion and scenario.
- Changes neutral internal-policy tone into personal commentary.
- Invents context.

Correct rewrite:
> The new policy should make incident handoffs clearer and help teams respond faster.

Fixes:
- Keeps meaning, improves flow, avoids fake human texture.

## Source-bound rewrite

Input:
> The new dashboard stands as a testament to the team's commitment to transparency, with real-time charts reflecting broader organizational momentum.

Final rewrite:
> The new dashboard shows revenue, churn, and support volume in one place. If the team wants to claim it improves transparency, tie that to a specific user need or metric.

Fixes:
- Removes significance inflation and unsupported analysis while preserving observable fact.
