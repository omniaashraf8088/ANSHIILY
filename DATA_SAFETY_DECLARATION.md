# Google Play Data Safety Declaration for ANSHIILY
### إقرار أمان البيانات لمتجر جوجل بلاي

This document provides the exact answers required to complete the **Data Safety** form in the **Google Play Console** for **ANSHIILY (أنشئلي)**.

---

## 1. Overview of Data Practices

| Question | Answer | Details |
|:---|:---:|:---|
| Does your app collect or share any of the required user data types? | **Yes** | Account info, user design media, and diagnostic data. |
| Is all of the user data collected by your app encrypted in transit? | **Yes** | All endpoints enforce HTTPS with TLS 1.3 encryption. |
| Do you provide a way for users to request that their data be deleted? | **Yes** | In-app deletion and email-based deletion requests are supported. |

---

## 2. Detailed Data Types & Disclosures

### A. Personal Information
- **Name:**
  - **Collected:** Yes.
  - **Shared:** No.
  - **Purpose:** App functionality, account personalization, and profile identification.
  - **Ephemeral:** No (stored in Supabase `profiles` table).
  - **Optional or Required:** Required for account creation.
- **Email Address:**
  - **Collected:** Yes.
  - **Shared:** No.
  - **Purpose:** Account management, authentication via GoTrue, security alerts, password recovery.
  - **Ephemeral:** No.
  - **Optional or Required:** Required.
- **User IDs:**
  - **Collected:** Yes (UUID generated upon Supabase registration).
  - **Shared:** No.
  - **Purpose:** App functionality and data association.

### B. Photos and Videos
- **Photos / Images:**
  - **Collected:** Yes.
  - **Shared:** No.
  - **Purpose:** App functionality (uploading custom brand logos, photos, and importing graphics into the canvas editor).
  - **Ephemeral:** No (stored in private user-isolated cloud bucket `user-uploads`).
  - **Optional or Required:** Optional (only when the user chooses to add personal images).

### C. Financial Information
- **Purchase History:**
  - **Collected:** Yes (Subscription status and receipt tokens via RevenueCat).
  - **Shared:** No.
  - **Purpose:** App functionality, fraud prevention, and Pro tier feature access.
  - **Note:** Credit card and banking information is processed directly by Google Play and is **never** collected or stored by ANSHIILY.

### D. App Info and Performance
- **Crash Logs & Diagnostics:**
  - **Collected:** Yes (Anonymous stack traces on unhandled exceptions).
  - **Shared:** No.
  - **Purpose:** Analytics and app stability improvement.

---

## 3. Security & Deletion Mechanisms
- **Encryption in Transit:** Enforced across all network requests (Supabase, RevenueCat).
- **Encryption at Rest:** Managed by Supabase PostgreSQL (AES-256 cloud encryption).
- **Deletion Request URL:** `https://anshiily-admin.vercel.app` (or email: `support@anshiily.com`).
