# MiniRaise

Investment checkout demo: Rails 8.1 + SQLite, one Svelte 5 component inside an ERB view via `vite_rails`.
Source of truth: `SPEC.md`. Read it before any change.

## Run
- Setup: `bundle install && npm install`
- App: `bin/dev` (Rails on http://localhost:3000; Vite builds on demand in development)
- Frontend build: `bin/vite build`

## Check
- Specs: `bundle exec rspec`
- Lint: `bin/rubocop`
- Security: `bin/brakeman --no-pager` and `bin/bundler-audit`
- Test bundle: `RAILS_ENV=test bin/vite build`
- Before a PR, all of the above must pass.

## Stack
- Rails (latest stable), SQLite, RSpec, RuboCop, Brakeman.
- Svelte 5 runes (`$state`, `$derived`, `$props`) with `@sveltejs/vite-plugin-svelte`.
- Plain CSS custom properties in `app/frontend/entrypoints/application.css`. No Tailwind, no component library.
- Money stored as integer cents.

## Rules
- Frontend changes follow `.claude/skills/frontend-ux/SKILL.md`.
- No git remote: do not run `git push`, `git remote`, or `gh`.
- Keep changes inside the current slice in `SPEC.md` section 10.
