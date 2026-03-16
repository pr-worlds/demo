-- PR Worlds Demo Schema
-- A project management SaaS — universally understood, rich in relationships.
--
-- This schema is designed to demonstrate all 7 layers of data coherence:
--   1. Structure    — FK hierarchy: orgs → users → projects → tasks → comments
--   2. Semantics    — emails, names, slugs, prices, statuses, roles, plans
--   3. Distribution — Pareto FK skew, weighted enums, realistic proportions
--   4. Time         — created_at <= updated_at, recency curves, soft deletes
--   5. Math         — total = qty * unit_price (verified post-seed)
--   6. Identity     — unique emails, unique slugs, deterministic UUIDs
--   7. Determinism  — same PR + same schema = same data, always

CREATE TABLE organizations (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  slug          text NOT NULL UNIQUE,
  plan          text NOT NULL DEFAULT 'free'
                  CHECK (plan IN ('free', 'pro', 'enterprise')),
  billing_email text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id        uuid NOT NULL REFERENCES organizations(id),
  email         text NOT NULL UNIQUE,
  full_name     text NOT NULL,
  role          text NOT NULL DEFAULT 'member'
                  CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
  avatar_url    text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  deleted_at    timestamptz
);

CREATE TABLE projects (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id        uuid NOT NULL REFERENCES organizations(id),
  name          text NOT NULL,
  slug          text NOT NULL,
  description   text,
  status        text NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active', 'archived', 'paused')),
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (org_id, slug)
);

CREATE TABLE tasks (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id    uuid NOT NULL REFERENCES projects(id),
  assignee_id   uuid REFERENCES users(id),
  title         text NOT NULL,
  description   text,
  status        text NOT NULL DEFAULT 'todo'
                  CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'cancelled')),
  priority      text NOT NULL DEFAULT 'medium'
                  CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  qty           integer DEFAULT 1 CHECK (qty >= 0),
  unit_price    numeric(10,2) CHECK (unit_price >= 0),
  total         numeric(10,2),
  due_date      date,
  remind_at     timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE comments (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id       uuid NOT NULL REFERENCES tasks(id),
  author_id     uuid NOT NULL REFERENCES users(id),
  content       text NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  deleted_at    timestamptz
);

CREATE TABLE files (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id    uuid NOT NULL REFERENCES projects(id),
  uploader_id   uuid NOT NULL REFERENCES users(id),
  filename      text NOT NULL,
  path          text NOT NULL,
  kind          text NOT NULL DEFAULT 'document'
                  CHECK (kind IN ('document', 'image', 'spreadsheet', 'archive', 'other')),
  size_bytes    integer NOT NULL CHECK (size_bytes >= 0),
  created_at    timestamptz NOT NULL DEFAULT now()
);
