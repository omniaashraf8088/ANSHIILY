# ANSHIILY Admin Architecture

## System Diagram

```mermaid
flowchart TD
    subgraph ClientLayer["Clients & Interfaces"]
        FLUTTER["Flutter Mobile App (iOS / Android)"]
        WEB_ADMIN["Next.js 16 Admin Dashboard (Vercel)"]
    end

    subgraph SupabaseCloud["Supabase Managed Cloud (wwfhoogtnwyavyvuabbw)"]
        AUTH["Supabase Auth (GoTrue)"]
        REST["PostgREST API Engine"]
        STORAGE["Storage S3 Buckets (5 Buckets)"]
        EDGE["Edge Functions (generate-design, revenuecat-webhook)"]
        DB[(PostgreSQL 15 Database)]
    end

    subgraph ExternalServices["External Cloud Providers"]
        OPENAI["AI Provider API (OpenAI / Gemini)"]
        RC["RevenueCat In-App Purchases Engine"]
    end

    FLUTTER -->|JWT Auth & REST| REST
    FLUTTER -->|Store / Fetch Assets| STORAGE
    FLUTTER -->|Call AI Generation| EDGE
    WEB_ADMIN -->|SSR & Client Sync| REST
    WEB_ADMIN -->|Inspect & Audit| DB
    EDGE -->|Secure Server-Side Call| OPENAI
    RC -->|Webhook Updates| EDGE
    EDGE -->|Update Subscription State| DB
```

## Security & Decoupled Architecture
1. **Server-Side AI Secrets:**
   - The Flutter mobile application never stores any OpenAI or AI model secret key.
   - All AI requests trigger the Supabase Edge Function `generate-design` via bearer JWT.
   - The server parses the prompt, generates the multi-layered document format, and stores it in `designs` & `ai_generation_logs`.
2. **Unified Data Layer:**
   - Both Flutter and Next.js connect to the single authoritative Supabase project `wwfhoogtnwyavyvuabbw`.
   - Edits made in the Admin Dashboard (e.g. creating a new category or updating credits) are instantly reflected in the Flutter app.

