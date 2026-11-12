# PHASE 7 RBAC SECURITY AUDIT REPORT
**Project:** ANSHIILY (أنشئلي)  
**Subject:** Role-Based Access Control, Server-Side Enforcement & Simulation Sandbox  
**Date:** November 12, 2026  
**Auditor:** Senior Software Architect & Lead Security Engineer  

---

## 1. Five-Tier Role Matrix & Permission Scope

The ANSHIILY platform implements an explicit 5-tier role hierarchy:

| Role | Hierarchy Level | Database Permissions (Server-Side) | Admin Dashboard UI Scope | Read-Only |
|---|---|---|---|:---:|
| **SUPER_ADMIN** | 5 | Full system control: modify `admin_users`, execute administrative SQL, alter billing, delete data, and view revenue. | Unrestricted access across all 10 modules. | No |
| **ADMIN** | 4 | Operations: user moderation, credits adjustment, template publication, storage object inspection. | Access to Users, Categories, Templates, Designs, Subscriptions, Storage, and Audit. | No |
| **CONTENT_MANAGER** | 3 | Creative Assets: CRUD on `design_categories` and `design_templates`. Inspect `designs`. Cannot touch users or billing. | Access restricted to Categories, Templates, and Designs. | No |
| **SUPPORT** | 2 | Customer Support: View user profiles, grant promotional/compensatory credits, view error logs. Cannot delete or alter billing. | Access to Users (limited to credit adjustments) and AI error logs. | No |
| **ANALYST** | 1 | Business Intelligence: Read-only access to metrics, generation logs, and subscription statistics. No write permissions. | Overview, Subscriptions, AI Analytics (Read-Only). All action buttons hidden. | **Yes** |

---

## 2. Server-Side vs Client-Side Separation

### Security Principle
1. **Zero Client Trust:** Browser state (e.g. React context `AdminContext`) controls ONLY visual UI rendering (which tabs and buttons are visible to the user).
2. **Server-Side Enforcement:** Every database modification (`INSERT`, `UPDATE`, `DELETE`) is guarded by PostgreSQL Row Level Security (RLS) policies:
   - `public.check_is_admin(auth.uid())`: Ensures the requesting authenticated user has an active record in `public.admin_users`.
   - `public.check_is_super_admin(auth.uid())`: Restricts sensitive mutations (such as changing admin roles) strictly to verified `SUPER_ADMIN` accounts.
3. **Simulation Mode Isolation:**
   - The role-switcher in the Admin Dashboard header is designated as **[وضع المحاكاة التجريبي - UI Simulation Mode]**.
   - Switching the dropdown allows administrators or developers to test the visual interface experience of each role.
   - However, switching the dropdown **never elevates database permissions**. If a non-super-admin tries to mutate protected records, Supabase RLS rejects the operation at the database engine level with a 403 / 401 error.

---

## 3. Vulnerability Mitigation Checklist

- [x] **Client-Side Promotion Prevention:** `admin_users` table has RLS policy `Only Super Admins can insert admin users` checking `check_is_super_admin(auth.uid())`. Ordinary users cannot insert themselves.
- [x] **User Metadata Decoupling:** Administrator roles are NOT stored in user-editable `raw_user_meta_data`. They reside exclusively in the protected `public.admin_users` table.
- [x] **Immutable Audit Trail:** `public.system_audit_logs` has no `UPDATE` or `DELETE` policies, guaranteeing that security logs cannot be tampered with or erased.
- [x] **Analyst Read-Only Guarantee:** The UI completely disables mutation forms when `ANALYST` role is active, and server RLS rejects write requests.
- [x] **Support Restraint:** Support agents cannot alter database schemas or view API secrets.
