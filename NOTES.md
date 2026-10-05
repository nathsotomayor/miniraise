# NOTES

## Slice 1 — Scaffold and CI
- Time spent: (author to fill in)
- What the AI did well: generated the Rails app with the skip flags from the plan; kept the generated Dockerfile, CI, RuboCop and Brakeman; verified the Vite and Svelte build before writing CI.
- What I had to correct or reject: `db:test:prepare` fails with no `db/schema.rb` (before slice 2), so CI uses `RAILS_ENV=test bin/rails db:prepare`. The generated lint job had a hand-written RuboCop cache step, removed per SPEC 9.1. Rails `.keep` placeholders in `log/`, `tmp/` and `storage/` are allowed by the export script.
- What the skill, tooling, or CI caught that I would have missed: RuboCop reported 12 offenses in generated files (comment indentation, array spacing), autocorrected. Brakeman and bundler-audit both clean.
- What I learned: (author to fill in)

## Slice 2 — Backend read path
- Time spent: (author to fill in)
- What the AI did well: matched the GET response to the exact JSON shape in SPEC section 6 and pinned it with a request spec; made the seeds idempotent with `find_or_create_by!` and proved it with a spec that loads them twice.
- What I had to correct or reject: the spec left `investor_count` ambiguous (investments vs. investors); resolved in SPEC section 5 as distinct investor emails, with emails stripped and downcased before validation.
- What the skill, tooling, or CI caught that I would have missed: an integer column silently truncates `25000.5` to `25000`; the `only_integer` validation checks the raw value, and a spec now covers it.
- What I learned: (author to fill in)

## Slice 3 — Frontend read path
- Time spent: (author to fill in)
- What the AI did well: planned the three states and the 360px layout before any code; kept the same markup for loading and loaded so placeholders sit exactly where the content lands; moved focus to the heading after "Try again" so keyboard users are not dropped on the page body.
- What I had to correct or reject: the Hello scaffold page was removed instead of kept; the progress bar uses `role="progressbar"` instead of a native `<progress>` so it can animate.
- What the skill, tooling, or CI caught that I would have missed: the frontend-ux skill flagged the component past 150 lines, so the summary moved to `OfferingSummary.svelte`; a browser check at 360px measured a 4.8px jump in the stats row between loading and loaded, fixed with `min-height: 1lh`; the page was missing `lang="en"`.
- What I learned: (author to fill in)

## Slice 4 — Write path
- Time spent: (author to fill in)
- What the AI did well: designed all four new states (submitting, success, validation error, network error) before writing code; tracked touched fields per-field so errors only appear on submit, then re-validate on input; kept a single `aria-live` region above the form so both success and network error messages are announced without screen-reader noise.
- What I had to correct or reject: (author to fill in)
- What the skill, tooling, or CI caught that I would have missed: RuboCop flagged array bracket spacing in the spec; Playwright revealed the `page.route()` glob needs a leading `**` to match URLs with multiple path segments; the submitting state is brief enough that it can only be caught by polling rather than a fixed delay.
- What I learned: (author to fill in)
