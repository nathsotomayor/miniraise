# MiniRaise

A tiny learning project: an investment checkout page built with Ruby on Rails and
Svelte. It is a personal demo inspired by online capital-raising platforms. It is not
affiliated with any company, and it handles no real money.

See [`SPEC.md`](SPEC.md) for the full spec and [`CLAUDE.md`](CLAUDE.md) for local setup
and the day-to-day commands (specs, lint, security scans).

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
