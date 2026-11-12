# ANSHIILY (أنشئلي) — Release Handover Package
## Official Verification & Handover Dossier for Hesham Ghareeb (@heshamghareeb)

**Project:** ANSHIILY | أنشئلي  
**Owner:** @omniaashraf8088  
**Lead Collaborator & Reviewer:** @heshamghareeb  
**Production Admin Dashboard:** [https://anshiily-admin.vercel.app](https://anshiily-admin.vercel.app)  
**Backend:** Supabase PostgreSQL (`wwfhoogtnwyavyvuabbw`)  
**Package Identifier:** `com.anshiily.app`  
**Version:** `1.0.0` (Build `1`)  
**Verification Date:** November 12, 2026  
**Status:** VERIFIED & READY FOR HANDOVER (PENDING OWNER APPROVAL)  

---

### 1. Release Artifacts & Physical Verification

Both production Android release artifacts have been compiled, verified, and checked on the local build machine:

| Artifact | File Format | Exact Filesystem Path | Byte Size | SHA-256 Checksum |
|:---|:---:|:---|:---:|:---|
| **Android App Bundle** | `.aab` | `build/app/outputs/bundle/release/app-release.aab` | `64,574,076` (61.6 MB) | `4e47be54bc66fadb582fb2e75a15908a6d0e6d6102b59c2e4858e7123d5118a6` |
| **Universal Release APK** | `.apk` | `build/app/outputs/flutter-apk/app-release.apk` | `66,588,952` (63.5 MB) | `e0fece772a2f327b8957dcb4efb91efae6d6118bfd2919144c75a98f267cd60a` |

---

### 2. Deep Technical Inspection (AAPT & APKSigner Evidence)

#### A. Package & Manifest Metadata (`aapt dump badging`)
- **Package Name**: `com.anshiily.app`
- **Version Code**: `1`
- **Version Name**: `1.0.0`
- **Min SDK**: `24` (Android 7.0+)
- **Target SDK**: `36` (Android 15 / 16 - fully exceeds Google Play minimum requirement of API 34)
- **Application Label**: `ANSHIILY | أنشئلي`
- **Launchable Activity**: `com.anshiily.app.MainActivity`
- **Native ABI Architecture**: `arm64-v8a`, `armeabi-v7a`, `x86_64` (Full 64-bit and 32-bit coverage)

#### B. Permissions Declared in Release Manifest
1. `android.permission.INTERNET` (Required for Supabase Auth, Storage, and AI generation)
2. `android.permission.ACCESS_NETWORK_STATE` (Network connectivity detection)
3. `com.android.vending.BILLING` (Google Play In-App Billing for RevenueCat Pro subscriptions)
4. `com.anshiily.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

#### C. Cryptographic Signature Verification (`apksigner verify --verbose`)
- **Verification Status**: `Verifies: TRUE`
- **APK Signature Scheme v2**: `true`
- **Number of Signers**: 1
- **Local Development Cert Fingerprint**: `05e3e1d62be1e10acac137760a73d781ba16b7fc21e8a2e3f6ee34b18bf75bf2`
- **Production Upload Signing**: Configured via `android/app/build.gradle.kts` to automatically use `android/key.properties` when provided, falling back to debug signature for local builds.

#### D. Android App Bundle (AAB) Internal Structure
- Verified 429 entries in container:
  - `BUNDLE-METADATA/com.android.tools.build.obfuscation/proguard.map`
  - `BUNDLE-METADATA/com.android.tools.build.debugsymbols/arm64-v8a/`
  - `base/dex/classes.dex`
  - `base/manifest/AndroidManifest.xml`
  - `base/assets/flutter_assets/` (Fonts: Cairo, Tajawal, Poppins, brand assets)

---

### 3. Signing Security & Protection Rules

1. **No Keystore in Git**: Keystore files (`*.jks`, `*.keystore`) are strictly ignored by `.gitignore`.
2. **No Passwords Committed**: Plaintext passwords are not stored in any tracked files.
3. **Template Provided**: `android/key.properties.example` serves as the safe template for configuring the production upload key.
4. **Automated Pipeline Security**: `.github/workflows/release.yml` decodes `ANDROID_KEYSTORE_BASE64` exclusively within protected runner environments.

---

### 4. iOS Release & Xcode Status

- **Bundle Identifier**: Migrated to `com.anshiily.app` across all targets in `ios/Runner.xcodeproj/project.pbxproj`.
- **Permissions (Info.plist)**: `NSPhotoLibraryUsageDescription` and `NSPhotoLibraryAddUsageDescription` added with bilingual Arabic/English explanations.
- **IPA Archive Status**: **BLOCKED (Environment License Gate)**
  - `xcodebuild` requires accepting the Apple SDK license agreement (`sudo xcodebuild -license`) and running `sudo xcodebuild -runFirstLaunch`.
  - Step-by-step instructions for the owner to generate the `.ipa` or Xcode Archive are documented in [IOS_RELEASE_GUIDE.md](file:///Users/omnia/Downloads/vs_projects/anshiily/IOS_RELEASE_GUIDE.md).

---

### 5. Store Review & Handover Deliverables Included

The repository contains all required operational documents for submission:

| Deliverable Document | Purpose |
|:---|:---|
| [PHASE8_RELEASE_READINESS_REPORT.md](file:///Users/omnia/Downloads/vs_projects/anshiily/PHASE8_RELEASE_READINESS_REPORT.md) | 20-point comprehensive release audit |
| [ANDROID_RELEASE_GUIDE.md](file:///Users/omnia/Downloads/vs_projects/anshiily/ANDROID_RELEASE_GUIDE.md) | Step-by-step Google Play Console upload guide |
| [IOS_RELEASE_GUIDE.md](file:///Users/omnia/Downloads/vs_projects/anshiily/IOS_RELEASE_GUIDE.md) | Step-by-step App Store Connect submission guide |
| [STORE_LISTING_AR.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_LISTING_AR.md) | Arabic title, short/full description, keywords, what's new |
| [STORE_LISTING_EN.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_LISTING_EN.md) | English store listing copy and metadata |
| [STORE_SCREENSHOT_PLAN.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_SCREENSHOT_PLAN.md) | 9-frame screenshot narrative for phone and tablet |
| [PRIVACY_POLICY.md](file:///Users/omnia/Downloads/vs_projects/anshiily/PRIVACY_POLICY.md) | Privacy policy URL content for store review |
| [TERMS_OF_SERVICE.md](file:///Users/omnia/Downloads/vs_projects/anshiily/TERMS_OF_SERVICE.md) | Subscription terms and user rights |
| [DATA_SAFETY_DECLARATION.md](file:///Users/omnia/Downloads/vs_projects/anshiily/DATA_SAFETY_DECLARATION.md) | Complete Google Play Data Safety answers |
| [STORE_COMPLIANCE_CHECKLIST.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_COMPLIANCE_CHECKLIST.md) | Store guidelines compliance checklist |
| [RELEASE_PIPELINE.md](file:///Users/omnia/Downloads/vs_projects/anshiily/RELEASE_PIPELINE.md) | Automated GitHub Actions release pipeline guide |

---

### 6. Remaining External Requirements Prior to Public Launch

1. **Google Play Console**:
   - Log in and upload `build/app/outputs/bundle/release/app-release.aab` to **Internal testing**.
   - Fill in Data Safety from `DATA_SAFETY_DECLARATION.md`.
   - Paste store listing copy from `STORE_LISTING_AR.md` and `STORE_LISTING_EN.md`.
2. **Apple App Store Connect**:
   - Run `sudo xcodebuild -license` on Mac, open `ios/Runner.xcworkspace`, and archive to TestFlight.
3. **RevenueCat Dashboard**:
   - Link Google Play Service Account JSON and Apple Shared Secret to sync subscriptions (`anshiily_pro_monthly`, `anshiily_pro_annual`).
