# PR Worlds Demo

This repo demonstrates [PR Worlds](https://github.com/pr-worlds/action) — deterministic preview data for every Pull Request.

**Open a PR and a world of realistic data appears. Close it and the world disappears.**

## What happens when you open a PR

PR Worlds reads your database schema, understands the structure, and generates a complete dataset — deterministic, realistic, and isolated per PR.

No faker noise. No manual seeds. No copying production.

Every PR gets a comment like this:

> **PR World ready for #4**
>
> | | |
> |---|---|
> | Schema | `pr_4` |
> | Fingerprint | `a3c17e9bd82f0145` |
> | Rows | **135** across **6** tables |
> | Integrity | 0 violations |
>
> PII Masking: 5 columns auto-detected
> Scenarios: trial_expiring, payment_failed, edge_cases

## The schema

This demo uses a project management SaaS schema ([schema.sql](schema.sql)):

```
organizations → users → projects → tasks → comments
                                         → files
```

It was designed to showcase all 7 layers of data coherence:

| Layer | What it means | How PR Worlds handles it |
|---|---|---|
| **Structure** | Foreign keys form a real hierarchy | Topological sort — parents seeded before children, zero orphans |
| **Semantics** | An email looks like an email, a price looks like a price | 50+ semantic types inferred from column names and types |
| **Distribution** | Not all users have the same number of tasks | Pareto distribution for FKs, weighted enums for statuses/roles |
| **Time** | `created_at` is always before `updated_at` | Coherent timestamp pairs, recency curves, Clock Freeze support |
| **Math** | `total = qty * unit_price` | Derived columns calculated and verified post-seed |
| **Identity** | No duplicate emails, no UUID collisions | Deterministic unique generation that respects constraints |
| **Determinism** | Same PR + same schema = same data | `seed = hash(pr + table + row)` — reproducible always |

## Try it

1. Open any PR in this repo
2. Watch the PR Worlds comment appear
3. Go to the database and see the `pr_N` schema with realistic data
4. Close the PR — the data is cleaned up automatically

## Install PR Worlds in your project

Add this workflow to `.github/workflows/prworlds.yml`:

```yaml
name: PR Worlds

on:
  pull_request:
    types: [opened, reopened, synchronize, closed]

permissions:
  pull-requests: write

jobs:
  world:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pr-worlds/action@v1
        with:
          database_url: ${{ secrets.DATABASE_URL }}
```

Set `DATABASE_URL` as a GitHub Secret. That's it.

Works with any PostgreSQL — Supabase, Neon, RDS, Railway, or self-hosted.

## Learn more

- [PR Worlds Action](https://github.com/pr-worlds/action) — installation, configuration, and docs
- [pr-worlds.com](https://pr-worlds.com) — pricing and quick start
