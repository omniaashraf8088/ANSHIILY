# PHASE 8 — INITIAL RELEASE & STORE READINESS AUDIT
**Application:** ANSHIILY (أنشئلي)  
**Tagline:** من فكرة إلى تصميم | From Idea to Design  
**Date:** November 12, 2026  
**Auditor:** Lead Flutter Release Engineer & DevOps Architect  

---

## 1. Executive Summary & Release Scope
This audit report provides an exhaustive, evidence-based pre-release inspection of the **ANSHIILY** ecosystem to assess readiness for distribution on the **Google Play Store** (Android) and **Apple App Store** (iOS).

All core application features from Phases 1–7 (Brand Foundation, Supabase Authentication, Design Categories & Library, AI Design Engine, Multi-Layer Editor, Export Engine, and Subscription Paywall) were verified as functional.

---

## 2. Platform Identity & Configuration Audit

| Configuration Item | Current Value | Production Requirement | Status / Action Needed |
|:---|:---|:---|:---:|
| **App Name (Default/Display)** | `ANSHIILY \| أنشئلي` | `ANSHIILY \| أنشئلي` | **VERIFIED** |
| **Package Name (Android)** | `com.example.anshiily` | `com.anshiily.app` | **BLOCKER (Must be changed; Google Play rejects com.example.*)** |
| **Bundle ID (iOS)** | `com.example.anshiily` | `com.anshiily.app` | **BLOCKER (Must match registered App ID in Apple Developer)** |
| **Version & Build Number** | `1.0.0+1` | `1.0.0+1` | **VERIFIED** |
| **App Launcher Icons** | Generated via `flutter_launcher_icons` | Multi-density mipmap & iOS AppIcon sets | **VERIFIED** |
| **Splash Screen** | Branded navy/gold luxury theme | Native splash & launch screen | **VERIFIED** |
| **Bilingual Localization** | Arabic (RTL) & English (LTR) | Cairo, Tajawal, Poppins fonts bundled | **VERIFIED** |

---

## 3. Android Platform Readiness

### A. Toolchain & SDK Compatibility
- **Flutter Version**: `3.44.0` (Channel stable, Dart `3.12.0`).
- **Android SDK Version**: `36.1.0` (Platform `android-36.1`, build-tools `36.1.0`).
- **Java Runtime**: OpenJDK 21 bundled with Android Studio.
- **Android Licenses**: All 8 SDK licenses verified and accepted.

### B. Permissions & Manifest Inspection
- **Current State**: `android/app/src/main/AndroidManifest.xml` lacked explicit release permissions for network operations.
- **Remediation**: Explicitly declare:
  - `<uses-permission android:name="android.permission.INTERNET"/>`
  - `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`

### C. Release Signing Configuration
- **Current State**: `build.gradle.kts` release buildType uses default debug keystore.
- **Store Requirement**: Google Play requires release builds to be signed with a secure private keystore (or Google Play App Signing).
- **Security Rule**: Keystore files and passwords must never be committed to Git. A `key.properties` pattern is required with fallback to debug for local builds.

---

## 4. iOS Platform Readiness & Environment Blockers

### A. Environment Audit
- **Xcode Version**: Xcode 27.2 is installed at `/Applications/Xcode.app`.
- **Blocker 1 (EULA Agreement)**: `xcodebuild` requires accepting the Apple SDK license agreement (`sudo xcodebuild -license`), which requires root/administrator privileges in interactive terminal.
- **Blocker 2 (Xcode First Launch Components)**: `sudo xcodebuild -runFirstLaunch` is required to install system frameworks.
- **Blocker 3 (CocoaPods)**: CocoaPods environment is out of sync with the current system Ruby runtime.
- **Assessment**: An automated Xcode Archive `.ipa` cannot be built in this specific CLI session without sudo credentials. Full instructions and configurations are documented for owner execution in [IOS_RELEASE_GUIDE.md](file:///Users/omnia/Downloads/vs_projects/anshiily/IOS_RELEASE_GUIDE.md).

### B. Info.plist & Privacy Usage Descriptions
- Must add photo library and media save permissions for saving exported high-res PNG/JPG files to the iOS Photos library:
  - `NSPhotoLibraryUsageDescription`: "ANSHIILY requires access to save your exported designs and artwork to your photo library."
  - `NSPhotoLibraryAddUsageDescription`: "ANSHIILY requires permission to save generated graphic designs."

---

## 5. Backend & Cloud Integration

- **Supabase Production Project**: `wwfhoogtnwyavyvuabbw` (`https://wwfhoogtnwyavyvuabbw.supabase.co`).
- **Client Key**: Safe public publishable/anon key configured.
- **Database Schema**: 14 tables verified with strict Row Level Security (RLS).
- **Storage Privacy**: 3 Private buckets (`designs`, `user-uploads`, `exported-designs`) and 3 Public buckets (`templates`, `project-previews`, `avatars`).

---

## 6. RevenueCat & Subscription Readiness

- **SDK**: `purchases_flutter: ^8.6.0`.
- **Plans Supported**: Free (10 starter credits) and Pro Subscription (Monthly and Annual unlimited access).
- **External Store Setup Requirement**:
  - Google Play Console: Create subscription base plans with product IDs `anshiily_pro_monthly` and `anshiily_pro_annual`.
  - App Store Connect: Create In-App Subscriptions group with product IDs `anshiily_pro_monthly` and `anshiily_pro_annual`.
  - RevenueCat Dashboard: Connect Google Service Account JSON and App Store Connect Shared Secret, then map products to entitlement `pro_access`.

---

## 7. Store Compliance & Privacy Requirements

- **Privacy Policy**: Required by Google Play & Apple. Created in `PRIVACY_POLICY.md`.
- **Terms of Service**: Required for subscription in-app purchases. Created in `TERMS_OF_SERVICE.md`.
- **Google Play Data Safety**: Detailed declaration of collected data types (Account Email, User Designs, Crash logs). Created in `DATA_SAFETY_DECLARATION.md`.
- **Account Deletion**: App Store Guideline 5.1.1(v) requires an in-app mechanism for users to request account deletion.
