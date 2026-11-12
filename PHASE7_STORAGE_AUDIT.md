# PHASE 7 STORAGE AUDIT REPORT
**Project:** ANSHIILY (أنشئلي)  
**Subject:** Storage Bucket Consistency, Remote Audit & Canonical Architecture  
**Date:** November 12, 2026  
**Auditor:** Senior Software Architect & Lead Security Engineer  

---

## 1. Remote Supabase Storage Inspection

Every candidate bucket was queried directly against `https://wwfhoogtnwyavyvuabbw.supabase.co/storage/v1/bucket/<id>` using the verified API key:

| Queried Bucket Name | Remote HTTP Response | Reality |
|---|---|---|
| `designs` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `avatars` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `brand-assets` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `templates` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `project-assets` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `generated-images` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `exports` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `user-uploads` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `project-previews` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |
| `exported-designs` | 404 (`NoSuchBucket`) | Not provisioned on remote Supabase |

**Finding:** The remote Supabase instance currently hosts **zero storage buckets**. No customer assets exist yet in remote storage; therefore, resolving the naming architecture presents **zero risk of data loss**.

---

## 2. Codebase Reference Audit

### A. Flutter Mobile Application (`lib/`)
The active Flutter implementation references:
- `StorageService.designsBucket = 'designs'` ([storage_service.dart](file:///Users/omnia/Downloads/vs_projects/anshiily/lib/features/projects/services/storage_service.dart#L9))
- `StorageService.avatarsBucket = 'avatars'` ([storage_service.dart](file:///Users/omnia/Downloads/vs_projects/anshiily/lib/features/projects/services/storage_service.dart#L10))

### B. Admin Web Dashboard (`admin/`)
The Next.js Admin Dashboard references:
- `avatars` (Public)
- `user-uploads` (Private)
- `project-previews` (Public)
- `exported-designs` (Private)
- `templates` (Public)

### C. Migration History
1. `20261111000001_phase2_backend_schema.sql`: Provisioned `designs` (public) and `avatars` (public).
2. `20261111000003_phase4_complete_schema_and_ai.sql`: Provisioned `avatars`, `user-uploads`, `project-previews`, `exported-designs`.
3. `20261112000002_phase7_admin_and_storage.sql`: Provisioned `avatars`, `user-uploads`, `project-previews`, `exported-designs`, `templates`.

---

## 3. The Canonical Bucket Architecture

To achieve full compatibility across Flutter, the Admin Dashboard, and future cloud extensions without code breakage, the canonical bucket architecture is defined as follows:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      ANSHIILY CANONICAL STORAGE                        │
├────────────────────┬──────────┬──────────────────────┬─────────────────┤
│ Bucket Name        │ Access   │ Purpose              │ Primary Client  │
├────────────────────┼──────────┼──────────────────────┼─────────────────┤
│ 1. designs         │ Public   │ Canvas designs/saves │ Flutter Mobile  │
│ 2. avatars         │ Public   │ User profile photos  │ Flutter & Admin │
│ 3. templates       │ Public   │ Master design covers │ Flutter & Admin │
│ 4. project-previews│ Public   │ Web/social previews  │ Admin & Share   │
│ 5. user-uploads    │ Private  │ Custom brand assets  │ Flutter & Web   │
│ 6. exported-designs│ Private  │ High-res exports/PDF │ Export Engine   │
└────────────────────┴──────────┴──────────────────────┴─────────────────┘
```

### Legacy Name Consolidation Mapping:
- `brand-assets` ➔ Consolidated into `user-uploads` (Private, user-isolated)
- `project-assets` ➔ Consolidated into `designs` (Public)
- `generated-images` ➔ Consolidated into `project-previews` (Public)
- `exports` ➔ Consolidated into `exported-designs` (Private, 300 DPI exports)

---

## 4. Final Access & RLS Policy Rules

### Public Read Buckets (`designs`, `avatars`, `templates`, `project-previews`):
- `SELECT`: `true` (Anonymous and authenticated users can view images via public URL).
- `INSERT`: `auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text` (Users only upload into their own folder).
- `UPDATE/DELETE`: `auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text`.
- For `templates`: Only admins may insert or update.

### Private Read Buckets (`user-uploads`, `exported-designs`):
- `SELECT`: `auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text`.
- `INSERT`: `auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text`.
- `UPDATE/DELETE`: `auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text`.
