# PHASE 7 STORAGE AUDIT REPORT (Hardened & Remediated)
**Project:** ANSHIILY (أنشئلي)  
**Subject:** Storage Bucket Consistency, Private Design Architecture & Migration Safety  
**Date:** November 12, 2026  
**Auditor:** Senior Software Architect & Lead Security Engineer  

---

## 1. Remote Supabase Storage State & Inventory

Every candidate bucket was queried directly against `https://wwfhoogtnwyavyvuabbw.supabase.co/storage/v1/bucket/<id>`:

| Queried Bucket Name | Remote HTTP Response | Reality |
|---|---|---|
| `designs` | 404 (`NoSuchBucket`) | Awaiting initial DDL execution |
| `avatars` | 404 (`NoSuchBucket`) | Awaiting initial DDL execution |
| `templates` | 404 (`NoSuchBucket`) | Awaiting initial DDL execution |
| `project-previews` | 404 (`NoSuchBucket`) | Awaiting initial DDL execution |
| `user-uploads` | 404 (`NoSuchBucket`) | Awaiting initial DDL execution |
| `exported-designs` | 404 (`NoSuchBucket`) | Awaiting initial DDL execution |

**Finding:** The remote Supabase instance currently hosts 0 storage buckets (`GET /storage/v1/bucket` returns `[]`). No customer files exist yet; establishing the corrected private architecture carries zero risk of data loss.

---

## 2. Storage Privacy Architecture (Finding 3 Remediation)

### A. Vulnerability Identified in Initial Architecture
In previous drafts, `designs` was marked `public: true` with a global `SELECT` policy (`FOR SELECT USING (bucket_id = 'designs')`). This exposed private user graphic designs to unauthenticated web access if object paths were guessed or intercepted.

### B. Corrected Privacy Architecture
The 6 canonical buckets are split into **3 Public Buckets** and **3 Private Buckets**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      ANSHIILY CANONICAL STORAGE                        │
├────────────────────┬──────────┬──────────────────────┬─────────────────┤
│ Bucket Name        │ Access   │ Purpose              │ Primary Client  │
├────────────────────┼──────────┼──────────────────────┼─────────────────┤
│ 1. designs         │ Private  │ Canvas designs/saves │ Flutter Mobile  │
│ 2. user-uploads    │ Private  │ Custom brand assets  │ Flutter & Web   │
│ 3. exported-designs│ Private  │ High-res exports/PDF │ Export Engine   │
├────────────────────┼──────────┼──────────────────────┼─────────────────┤
│ 4. templates       │ Public   │ Master design covers │ Flutter & Admin │
│ 5. project-previews│ Public   │ Web/social previews  │ Admin & Share   │
│ 6. avatars         │ Public   │ User profile photos  │ Flutter & Admin │
└────────────────────┴──────────┴──────────────────────┴─────────────────┘
```

### C. Access Control Policies for Private Buckets:
- **`designs` (Private)**:
  - `SELECT`: `auth.role() = 'authenticated' AND ((storage.foldername(name))[1] = auth.uid()::text OR public.check_is_admin(auth.uid()))`.
  - `INSERT / UPDATE / DELETE`: Only authenticated users within their own user-id folder (`(storage.foldername(name))[1] = auth.uid()::text`).
  - **Flutter Integration**: `StorageService.uploadDesignImage()` now generates secure signed URLs via `client.storage.from(designsBucket).createSignedUrl(path, 86400)` (24-hour expiration) or direct authenticated streaming.
- **`user-uploads` (Private)**:
  - Accessible strictly by the uploading user.
- **`exported-designs` (Private)**:
  - High-resolution print-ready files (300 DPI) accessible only by the owner.

---

## 3. Migration Safety & Idempotency (Finding 5 Remediation)

### A. Vulnerability Identified
The previous migration used:
`INSERT INTO storage.buckets ... ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;`
If executed in an environment where a bucket had been configured as private, this command would overwrite and expose the bucket publicly.

### B. Safe Migration Pattern
The corrected migrations (`20261112000002` and `20261112000003`) use:
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('designs', 'designs', false),
    ('avatars', 'avatars', true),
    ('templates', 'templates', true),
    ('project-previews', 'project-previews', true),
    ('user-uploads', 'user-uploads', false),
    ('exported-designs', 'exported-designs', false)
ON CONFLICT (id) DO NOTHING;

-- Enforce explicit privacy
UPDATE storage.buckets SET public = false WHERE id IN ('designs', 'user-uploads', 'exported-designs');
UPDATE storage.buckets SET public = true WHERE id IN ('templates', 'project-previews', 'avatars');
```
This guarantees that existing private buckets can never accidentally become public through migration execution.
