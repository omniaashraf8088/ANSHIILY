# Android Production Release & Google Play Deployment Guide
### دليل نشر وتجهيز تطبيق أنشئلي لمتجر جوجل بلاي

**Application:** ANSHIILY (أنشئلي)  
**Package Identifier:** `com.anshiily.app`  
**Target API:** Android 14+ (API 34/35)  
**Build Tool:** Gradle 9.0+ / Android Gradle Plugin  

---

## 1. Overview of Release Artifacts

The ANSHIILY Android build pipeline produces two primary distribution artifacts:
1. **Android App Bundle (`.aab`)**:
   - Location: `build/app/outputs/bundle/release/app-release.aab`
   - Purpose: **Required** for official submission to the Google Play Store. Google Play uses dynamic feature delivery to serve optimized APKs to each device.
2. **Universal Release APK (`.apk`)**:
   - Location: `build/app/outputs/flutter-apk/app-release.apk`
   - Purpose: Ideal for internal QA testing, direct sideloading, and enterprise distribution.

---

## 2. Production Keystore & Signing Setup

Google Play requires all production release builds to be cryptographically signed.

### Step 1: Generate Release Keystore
Run the following command on your local machine to create a 2048-bit RSA keystore:
```bash
keytool -genkey -v -keystore anshiily-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias anshiily
```
*(Keep this keystore file and its passwords in a secure password manager. NEVER commit `.jks` or `.keystore` files to Git).*

### Step 2: Configure `key.properties`
1. Copy the template:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
2. Populate `android/key.properties` with your private credentials:
   ```properties
   keyAlias=anshiily
   keyPassword=YOUR_SECURE_KEY_PASSWORD
   storeFile=../anshiily-release-key.jks
   storePassword=YOUR_SECURE_KEYSTORE_PASSWORD
   ```
*(Note: `android/key.properties` is strictly ignored by `.gitignore` to prevent secret leaks).*

---

## 3. Building for Production

### To Build Android App Bundle (.aab) for Google Play:
```bash
flutter build appbundle --release
```

### To Build Standalone Release APK (.apk) for Testing:
```bash
flutter build apk --release
```

---

## 4. Google Play Console Submission Steps

1. **Create New App:**
   - Log into [Google Play Console](https://play.google.com/console).
   - Click **Create App**.
   - App Name: `ANSHIILY | أنشئلي`
   - Default Language: Arabic (`ar`) or English (`en-US`).
   - App or Game: **App**. Free or Paid: **Free** (with in-app subscriptions).
2. **Internal Testing Track:**
   - Navigate to **Testing > Internal testing**.
   - Click **Create new release**.
   - Upload `build/app/outputs/bundle/release/app-release.aab`.
   - Release Name: `1.0.0 (1)`.
   - Release Notes: Copy contents from `STORE_LISTING_AR.md` or `STORE_LISTING_EN.md`.
3. **Store Listing Setup:**
   - Main Store Listing: Populate Short Description, Full Description, and App Icon (`assets/brand/app_icon.png`).
   - Upload screenshots according to [STORE_SCREENSHOT_PLAN.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_SCREENSHOT_PLAN.md).
4. **App Content & Compliance:**
   - **Privacy Policy:** Link to `https://anshiily-admin.vercel.app` (or your hosted privacy policy).
   - **Data Safety:** Follow the field-by-field answers in [DATA_SAFETY_DECLARATION.md](file:///Users/omnia/Downloads/vs_projects/anshiily/DATA_SAFETY_DECLARATION.md).
   - **Ads:** Select "No, my app does not contain ads".
   - **Target Audience:** Select 18 and older.
5. **Monetization & In-App Subscriptions:**
   - Navigate to **Monetize > Products > Subscriptions**.
   - Create subscription IDs matching RevenueCat:
     - `anshiily_pro_monthly`
     - `anshiily_pro_annual`
   - Connect Google Play Service Account JSON to RevenueCat.
