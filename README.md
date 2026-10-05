# MiniRaise

A tiny learning project: an investment checkout page built with Ruby on Rails and
Svelte. It is a personal demo inspired by online capital-raising platforms. It is not
affiliated with any company, and it handles no real money.

See [`SPEC.md`](SPEC.md) for the full spec and [`CLAUDE.md`](CLAUDE.md) for local setup
and the day-to-day commands (specs, lint, security scans).

## Run it in a GitHub Codespace

The repository ships a dev container (`.devcontainer/devcontainer.json`), so a Codespace
comes up with Ruby, Node, the gems, the npm packages, and a seeded database already in
place.

1. On GitHub, open **Code → Codespaces → Create codespace on main**. Wait for the setup
   to finish — it installs everything and prepares the database.
2. In the Codespace terminal, start the app:

   ```sh
   bin/dev
   ```

3. When the **Ports** panel shows port **3000**, click its "Open in Browser" (globe)
   icon, then add `/offerings/1` to the URL. The app has no page at `/`, so open
   `.../offerings/1` directly.

Edit code and the page reloads on the next request. Run the specs and linters with the
commands in [`CLAUDE.md`](CLAUDE.md).

## Running the production image

The image is built from the Rails-generated `Dockerfile`: a multi-stage build where
Node and `node_modules` exist only in the build stage, so the final image ships no
Node, no specs, and no development or test gems. It runs as a non-root user and
listens on port 80.

1. Build the image:

   ```sh
   docker build -t miniraise .
   ```

2. Run it with a generated `SECRET_KEY_BASE`, SSL enforcement turned off for a local
   HTTP run, and a named volume so the SQLite database survives restarts:

   ```sh
   docker run -d -p 3000:80 \
     -e SECRET_KEY_BASE=$(openssl rand -hex 32) \
     -e FORCE_SSL=false \
     -v miniraise-storage:/rails/storage \
     --name miniraise miniraise
   ```

   `FORCE_SSL` defaults to on (the generated production config assumes a
   SSL-terminating reverse proxy). Set it to `false` only for a local run without one.

3. Confirm the container is healthy:

   ```sh
   curl http://localhost:3000/up
   ```

4. Open [http://localhost:3000/offerings/1](http://localhost:3000/offerings/1) — the
   entrypoint seeds the database on first boot, so the offering is there already — and
   submit an investment.

5. Restart the container and confirm the investment is still there:

   ```sh
   docker restart miniraise
   curl http://localhost:3000/offerings/1
   ```

The `image` job in CI builds the same image and runs steps 1–3 on every pull request,
and additionally pushes it to `ghcr.io/<owner>/miniraise` on every push to `main`.

## Using the app

The app shows a single offering (a company raising capital) and lets you invest in it.

1. Open `/offerings/1`. You'll see the offering name, how much has been raised versus
   the goal, a progress bar, and the number of investors.
2. Fill in the form: your name, your email, and an amount in dollars (at or above the
   minimum shown under the amount field).
3. Submit. On success the progress bar and totals update immediately — no page reload —
   the form clears, and a confirmation message appears.
4. If something is off, it's flagged inline: an amount below the minimum, a missing
   name, or an incomplete email show next to the field; a network problem shows a
   message above the form and keeps what you typed.

The page works down to 360px wide and with the keyboard alone.

## API

Money is always integer cents.

### `GET /api/offerings/:id`

Returns the offering and its live totals.

```sh
curl http://localhost:3000/api/offerings/1
```

```json
{
  "id": 1,
  "name": "Solar Kettle Co.",
  "target_amount_cents": 50000000,
  "min_investment_cents": 10000,
  "raised_amount_cents": 12500000,
  "investor_count": 4
}
```

Returns `404` with `{ "error": "Not found" }` if the offering does not exist.

### `POST /api/offerings/:id/investments`

Creates an investment and returns the updated offering (same shape as the GET above).
CSRF verification is skipped for JSON requests, so no token is needed from `curl`.

```sh
curl -X POST http://localhost:3000/api/offerings/1/investments \
  -H 'Content-Type: application/json' \
  -d '{ "investment": { "investor_name": "Ana", "investor_email": "ana@example.com", "amount_cents": 25000 } }'
```

- `201` with the updated offering JSON on success.
- `422` with per-field errors when the investment is invalid, for example:

  ```json
  { "errors": { "amount_cents": ["must be at least 100.00"] } }
  ```

- `404` if the offering does not exist.
