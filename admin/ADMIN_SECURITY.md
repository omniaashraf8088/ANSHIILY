# ANSHIILY Admin Security Guidelines

## 1. Zero Client-Side Secret Exposure
- All server-side privileges (`service_role` keys, `OPENAI_API_KEY`, RevenueCat shared secrets) must never be prefixed with `NEXT_PUBLIC_` or compiled into client JavaScript bundles.
- All communications are encrypted over HTTPS/TLS 1.3 with HSTS enabled.

## 2. Row Level Security (RLS)
- Supabase PostgreSQL enforces RLS on all tables:
  - `profiles`: Users update only their own profile; admins can query and update via authorized policies.
  - `designs`: Users only view and modify their own projects.
  - `subscriptions`: Strict read/write isolation based on authenticated `auth.uid()`.
  - `export_jobs`: Read/insert constrained to owner.

## 3. Storage Protection
- Private buckets (`user-uploads`, `exported-designs`) enforce object-level ownership checks preventing unauthorized access.

