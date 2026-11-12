# ANSHIILY | أنشئلي
### AI-Powered Graphic Design Platform for the Arabic & Global Market
**Production Admin Dashboard**: [https://anshiily-admin.vercel.app](https://anshiily-admin.vercel.app)  
**Backend**: Supabase PostgreSQL 15 (`wwfhoogtnwyavyvuabbw`)  
**Mobile**: Flutter 3.24+ (iOS & Android)  

---

## 🌟 Overview

**ANSHIILY (أنشئلي)** is a graphic design and content generation suite providing native Arabic (RTL) and English (LTR) experiences. It combines a 5-step AI design wizard, an interactive multi-layer canvas editor, high-resolution 300 DPI export engines (PDF, PNG, JPG), a tiered subscription system, and an online Next.js 16 Admin Dashboard.

```
┌──────────────────────────────────────────────────────────┐
│                   ANSHIILY ARCHITECTURE                  │
├──────────────────────────┬───────────────────────────────┤
│ Client Layer             │ Flutter Mobile (iOS & Android)│
│                          │ Next.js 16 Web Admin (Vercel) │
├──────────────────────────┼───────────────────────────────┤
│ Database & Backend       │ Supabase PostgreSQL 15        │
│                          │ Row Level Security (RLS)      │
│                          │ 5-Tier RBAC Access Control    │
│                          │ Deno Edge Functions           │
├──────────────────────────┼───────────────────────────────┤
│ Storage (6 Buckets)      │ 3 Private: designs, uploads,  │
│                          │            exports            │
│                          │ 3 Public:  templates, avatars,│
│                          │            previews           │
└──────────────────────────┴───────────────────────────────┘
```

---

## 🚀 Completed Phases (Phases 1–7)

1. **Phase 1 — Foundation & Brand Identity**: Typography (Cairo, Tajawal, Poppins), luxury navy & gold design system, RTL/LTR localization.
2. **Phase 2 — Backend Infrastructure**: Supabase authentication, 14 database tables, initial Row Level Security (RLS).
3. **Phase 3 — Home & Library**: 10 design categories, curated template browser, recent projects management.
4. **Phase 4 — AI Design Engine**: 5-step prompt generation wizard, multi-layer JSON document model (`DesignDocument`), Deno Edge Function pipeline.
5. **Phase 5 — Professional Design Editor**: Interactive layered canvas, matrix transform tools, typography controls, layer reordering (bring forward / send backward).
6. **Phase 6 — Professional Export & Subscriptions**: 300 DPI print-ready rendering, PDF v1.5 and high-res PNG/JPG export, RevenueCat paywall and Pro tier unlocking.
7. **Phase 7 — Online Admin Dashboard & Security Remediation**:
   - Next.js 16 (App Router), Tailwind CSS v4, Lucide icons, deployed to Vercel.
   - 5-Tier RBAC: `SUPER_ADMIN`, `ADMIN`, `CONTENT_MANAGER`, `SUPPORT`, `ANALYST`.
   - Hardened `bootstrap_super_admin` with revoked public privileges.
   - Private storage architecture for user designs with signed URL access.
   - Anti-forgery protection on immutable `system_audit_logs`.

---

## 🛠️ Local Development & Quick Start

### Flutter Mobile App
```bash
# 1. Install dependencies
flutter pub get

# 2. Check formatting & static analysis
dart format --output=none --set-exit-if-changed lib/ test/
flutter analyze

# 3. Run test suite
flutter test

# 4. Launch on emulator / connected device
flutter run
```

### Next.js 16 Admin Dashboard
```bash
# 1. Navigate to admin directory
cd admin

# 2. Install dependencies
npm ci

# 3. Run ESLint inspection
npm run lint

# 4. Build for production (Turbopack)
npm run build

# 5. Start local development server
npm run dev
# Dashboard will be available at http://localhost:3000
```

---

## 🔒 Security & Code Review Guidelines

- **External Collaborators**: Please refer to [COLLABORATOR_GUIDE.md](file:///Users/omnia/Downloads/vs_projects/anshiily/COLLABORATOR_GUIDE.md) for branch naming conventions, PR guidelines, and testing checklists.
- **Zero Committed Secrets**: Never commit `.env`, `.env.local`, API keys, or `service_role` credentials.
- **Pull Requests**: Pull requests targeting `main` automatically run continuous integration checks via GitHub Actions.

---

## 📄 License & Attribution
Developed for **ANSHIILY (أنشئلي)**. All rights reserved.
