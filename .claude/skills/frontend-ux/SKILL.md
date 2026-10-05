---
name: frontend-ux
description: UX, accessibility, and frontend checklist for MiniRaise. Use when creating, editing, or reviewing Svelte components, ERB views, or CSS in this project.
paths:
  - "app/frontend/**"
  - "app/views/**"
---

Apply this checklist to every change in frontend files, for the whole task.

## Before writing code
1. List the UI states this change touches (loading, loaded, load failed, submitting,
   success, validation error, network error) and say how each one looks.
2. Reuse the CSS custom properties defined in `:root`. Add a new one only if needed.

## While writing code
- Semantic HTML before ARIA. Add ARIA only where HTML has no native equivalent.
- Every input has a linked visible label, correct `type`, `inputmode`, and `autocomplete`.
- Errors: next to the field, linked with `aria-describedby`, field marked `aria-invalid`.
- Status messages go through one `aria-live` region.
- Keyboard: every action reachable, focus visible, focus moved to the first invalid
  field after a failed submit.
- No layout shift between loading and loaded states.
- Money through `Intl.NumberFormat`. No hand-built currency strings.
- Derived values use `$derived`, not duplicated `$state`.
- Keep the component small. Extract a child component only when a block is reused or
  the file passes roughly 150 lines.

## Before finishing
Report a table with one row per item of section 7 of SPEC.md that this change touches:
item, pass or fail, and the file and line that proves it. Fix every fail, and every
Svelte compiler accessibility warning, before saying the work is done.
