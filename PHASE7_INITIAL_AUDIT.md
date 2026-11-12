# PHASE 7 INITIAL AUDIT REPORT
**Project:** ANSHIILY (أنشئلي)  
**Date:** November 12, 2026  
**Auditor:** Senior Software Architect & Lead Security Engineer  
**Repository:** https://github.com/omniaashraf8088/ANSHIILY  
**Production Admin URL:** https://anshiily-admin.vercel.app  
**Supabase Project ID:** wwfhoogtnwyavyvuabbw  

---

## 1. Executive Audit Overview
This initial audit assesses the genuine operational state of Phase 7 (Master Integration, Online Admin Dashboard, Supabase Backend, and Storage Architecture) prior to implementing final fixes and security closures.

---

## 2. Component Verification Status

| Component | Status | Reality vs Reported State |
|---|---|---|
| **Flutter Mobile App** | **VERIFIED** | Clean compilation (`flutter analyze` 0 warnings), 23/23 unit and integration tests passing. Phases 1-6 fully preserved. |
| **GitHub Synchronization** | **VERIFIED** | Remote `main` at `https://github.com/omniaashraf8088/ANSHIILY` matches local HEAD at `78081cb98607af184961d4ac7b134bb1cfca7921`. Clean working tree. |
| **Vercel Production Deployment** | **VERIFIED (PARTIAL)** | Deployed and answering HTTP 200 at `https://anshiily-admin.vercel.app`. Environment variables configured. However, authentication gate is missing. |
| **Supabase Remote Tables** | **VERIFIED (PARTIAL)** | `profiles`, `design_categories` (10 rows), `design_templates` (12 rows), `designs`, `subscriptions`, `export_jobs`, `ai_generation_logs` exist and respond. `admin_users` and `system_audit_logs` are missing remotely. |
| **Supabase Storage Buckets** | **CONFIRMED DEFECT** | All queried buckets return `NoSuchBucket` (HTTP 404). Buckets have not been provisioned remotely. |
| **Storage Naming Consistency** | **CONFIRMED DEFECT** | Inconsistency between legacy proposal (`brand-assets`, `project-assets`, etc.) and active code (`designs`, `avatars`, `templates`, `user-uploads`, `project-previews`, `exported-designs`). |
| **SQL Migration Safety** | **SECURITY RISK** | 18 occurrences of `EXCEPTION WHEN others THEN NULL;` silently suppressing policy execution errors across migrations. |
| **SECURITY DEFINER search_path** | **SECURITY RISK** | Function `public.handle_new_user()` is missing `SET search_path = public, pg_temp;`. |
| **Administrator RBAC** | **CONFIRMED DEFECT** | Role selector in Admin Dashboard is purely a client-side React simulation without server-side session checks or `/login` barrier. |
| **Supabase Edge Functions** | **CONFIRMED DEFECT** | `generate-design` and `revenuecat-webhook` return HTTP 404 (`Requested function was not found`). Not deployed to remote environment. |
| **Server-Side AI Secrets** | **CONFIRMED DEFECT** | `OPENAI_API_KEY` is not configured in remote Edge Function Secrets. Client Flutter code remains safe (no hardcoded keys). |
| **Audit Logging System** | **CONFIRMED DEFECT** | Admin operations do not record audit entries to `system_audit_logs`. |

---

## 3. Confirmed Defects & Discrepancies

### Defect 1: Missing Authentication Gate & Login Flow
- **Description:** The online Admin Dashboard renders directly without checking if the user is authenticated via Supabase Auth (`supabase.auth.getUser()`).
- **Risk:** Unauthenticated visitors can view dashboard modules and attempt client-side mutations.
- **Required Fix:** Implement a dedicated `/login` page with Supabase Auth, session verification, automatic redirection, and a clear `[وضع المحاكاة التجريبي - Demo / Simulation Mode]` indicator for sandbox exploration.

### Defect 2: Storage Buckets Not Provisioned Remotely
- **Description:** Direct REST calls to `https://wwfhoogtnwyavyvuabbw.supabase.co/storage/v1/bucket/<name>` for `designs`, `avatars`, `templates`, etc. return `NoSuchBucket`.
- **Risk:** Mobile and web file uploads (such as avatars and project exports) will fail with 404.
- **Required Fix:** Establish the canonical bucket mapping and provide an idempotent, clean SQL migration script.

### Defect 3: Storage Bucket Naming Discrepancy
- **Description:** Flutter codebase calls `designs` and `avatars`. Legacy documentation referenced `brand-assets`, `project-assets`, `generated-images`, `exports`. Phase 7 web dashboard referenced `avatars`, `user-uploads`, `project-previews`, `exported-designs`, `templates`.
- **Risk:** Divergence leads to broken uploads or missed assets.
- **Required Fix:** Harmonize the bucket architecture: support canonical buckets `designs`, `avatars`, `templates`, `user-uploads`, `project-previews`, and `exported-designs`.

### Defect 4: Unsafe Error Suppression in SQL Migrations
- **Description:** Multiple migrations employ `EXCEPTION WHEN others THEN NULL;`.
- **Risk:** Schema or policy errors fail silently during migration runs, creating false impressions of database security.
- **Required Fix:** Remove all `EXCEPTION WHEN others THEN NULL;` and replace with standard, explicit `DROP POLICY IF EXISTS ...; CREATE POLICY ...;`.

### Defect 5: Insecure `SECURITY DEFINER` Function
- **Description:** `handle_new_user()` lacks `SET search_path = public, pg_temp;`.
- **Risk:** Known PostgreSQL vulnerability enabling search_path hijacking.
- **Required Fix:** Alter `handle_new_user()` to specify explicit search_path.

### Defect 6: Missing Remote `admin_users` & `system_audit_logs`
- **Description:** Remote PostgREST queries return `PGRST205` for both tables.
- **Risk:** RBAC checks and audit trail cannot persist.
- **Required Fix:** Create tables with RLS and seed initial admin structure.

### Defect 7: Edge Functions Not Deployed Remotely
- **Description:** Pinging `/functions/v1/generate-design` returns 404.
- **Risk:** Mobile app AI generation relies on local fallback rather than edge runtime.
- **Required Fix:** Document exact deployment steps and ensure the function fallback remains bulletproof.

---

## 4. Required Action Plan

1. **Storage Harmonization:** Create `PHASE7_STORAGE_AUDIT.md` defining canonical bucket names and access rules.
2. **SQL Remediation:** Clean `supabase/migrations/20261112000002_phase7_admin_and_storage.sql` of all silent error suppressions and add search_path hardening.
3. **RBAC Hardening:** Create `PHASE7_RBAC_SECURITY_AUDIT.md`, implement `/login` page, add sign out button, session check, and server-side verification endpoint `/api/admin/verify-role`.
4. **Audit Logging Integration:** Wire up mutations in Admin Dashboard to log to `system_audit_logs`.
5. **SUPER_ADMIN Bootstrap Procedure:** Define deterministic SQL query to assign `SUPER_ADMIN` to verified user email.
6. **Regression Verification:** Run `flutter analyze`, `flutter test`, and `npm run build` in `/admin`.
7. **Redeploy & Git Sync:** Deploy hardened admin to Vercel and push changes to GitHub.
