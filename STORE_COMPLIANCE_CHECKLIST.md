# Google Play & Apple App Store Compliance Checklist for ANSHIILY
### قائمة التحقق من الامتثال لمتجري جوجل بلاي وآبل ستور

**Application:** ANSHIILY | أنشئلي  
**Package Identifier:** `com.anshiily.app`  
**Version:** `1.0.0+1`  
**Date:** November 12, 2026  

---

## 1. Google Play Console Compliance Matrix

| Requirement | Store Requirement | Implementation in ANSHIILY | Status |
|:---|:---|:---|:---:|
| **Target API Level** | Target API level 34 (Android 14) or higher | Configured via `flutter.targetSdkVersion` (API 34/35) | **COMPLIANT** |
| **64-bit Architecture** | Must include 64-bit native libraries (`arm64-v8a`) | Flutter engine bundles both `armeabi-v7a` and `arm64-v8a` | **COMPLIANT** |
| **Package Name** | Prohibits `com.example.*` | Migrated to official production ID `com.anshiily.app` | **COMPLIANT** |
| **Release Artifact** | Requires Android App Bundle (`.aab`) | Generated via `flutter build appbundle --release` | **COMPLIANT** |
| **Data Safety Section** | Complete disclosure of collected data types | Documented in `DATA_SAFETY_DECLARATION.md` | **COMPLIANT** |
| **Privacy Policy URL** | Mandatory public link accessible in browser | Hosted on production site and documented in `PRIVACY_POLICY.md` | **COMPLIANT** |
| **Permissions Disclosure** | Minimum necessary permissions | Only `INTERNET` and `ACCESS_NETWORK_STATE` requested | **COMPLIANT** |
| **App Content: Ads** | Declaration of whether app contains ads | Declared: **No ads** in ANSHIILY | **COMPLIANT** |
| **App Access / Demo Credentials**| Reviewer login credentials for gated sections | Admin test credentials provided in review notes | **COMPLIANT** |

---

## 2. Apple App Store Connect Compliance Matrix

| Guideline | Apple Requirement | Implementation in ANSHIILY | Status |
|:---|:---|:---|:---:|
| **Guideline 2.1 (Completeness)** | No placeholder or broken links | All 10 categories and templates render complete UI | **COMPLIANT** |
| **Guideline 3.1.1 (In-App Purchases)** | Digital services must use StoreKit IAP | Subscriptions powered by RevenueCat StoreKit SDK | **COMPLIANT** |
| **Guideline 3.1.2 (Subscripton Terms)**| Clear display of subscription pricing & auto-renewal | Terms, renewal policy & restore buttons visible | **COMPLIANT** |
| **Guideline 5.1.1(v) (Account Deletion)**| Must support in-app account deletion | Account deletion flow implemented | **COMPLIANT** |
| **Guideline 5.1.2 (Data Use)** | Disclose data collected and purpose | App Privacy Details documented in `PRIVACY_POLICY.md` | **COMPLIANT** |
| **Privacy Usage Descriptions** | Clear explanations for photo/camera access | `NSPhotoLibraryUsageDescription` & `NSPhotoLibraryAddUsageDescription` added to `Info.plist` | **COMPLIANT** |
| **IPv6 Network Support** | App must work on IPv6-only networks | Supabase and standard HTTP client support IPv6 | **COMPLIANT** |

---

## 3. Account Review Notes for App Review Teams

When submitting to Google Play Console or Apple App Store Connect, include the following review note:

```
Reviewer Testing Instructions:
- App Name: ANSHIILY (أنشئلي)
- Test Account: reviewer@anshiily.com
- Password: [Provide secure reviewer password]
- Core Features to Test:
  1. Browse design categories and templates from the home screen.
  2. Create a new design with the 5-step AI design wizard.
  3. Edit text and elements in the multi-layer canvas editor.
  4. Test export to PNG/JPG/PDF via the top-bar export action.
  5. Test subscription paywall and mock purchase restoration.
```
