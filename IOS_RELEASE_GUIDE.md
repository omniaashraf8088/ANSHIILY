# iOS Production Release & App Store Deployment Guide
### دليل نشر وتجهيز تطبيق أنشئلي لمتجر آبل ستور

**Application:** ANSHIILY (أنشئلي)  
**Bundle Identifier:** `com.anshiily.app`  
**Deployment Target:** iOS 14.0+  
**IDE:** Xcode 27+ / macOS  

---

## 1. Prerequisites & Resolving Local Environment Blockers

Before generating an iOS `.ipa` or Xcode Archive on your Mac, execute the following one-time administrator commands in a terminal window:

### Step 1: Accept the Apple SDK License Agreement
```bash
sudo xcodebuild -license
# Press space to read, then type 'agree' and press enter
```

### Step 2: Install Required Xcode System Packages
```bash
sudo xcodebuild -runFirstLaunch
```

### Step 3: Ensure CocoaPods is Working
```bash
sudo gem install cocoapods
cd ios && pod repo update && pod install && cd ..
```

---

## 2. Apple Developer Account & Certificate Setup

1. **Register App ID:**
   - Log into [Apple Developer Portal](https://developer.apple.com).
   - Navigate to **Certificates, Identifiers & Profiles > Identifiers**.
   - Register a new App ID:
     - Description: `ANSHIILY`
     - Bundle ID (Explicit): `com.anshiily.app`
     - Capabilities: **In-App Purchase** (StoreKit), **Associated Domains**.
2. **Distribution Certificate:**
   - Create an **Apple Distribution** certificate under your Apple Developer account.
3. **App Store Provisioning Profile:**
   - Create an **App Store** distribution provisioning profile linked to `com.anshiily.app` and your distribution certificate.

---

## 3. Building the iOS Release Archive

Once prerequisites are satisfied, build the release bundle from the project root:

### Option A: Using Flutter CLI (Generates App Store IPA)
```bash
flutter build ipa --release
```
*The resulting archive will be placed in: `build/ios/archive/Runner.xcarchive` and `build/ios/ipa/`.*

### Option B: Using Xcode GUI
1. Open the workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Select target device: **Any iOS Device (arm64)**.
3. Go to **Product > Archive**.
4. Once archiving finishes, the **Xcode Organizer** will appear.
5. Click **Distribute App > App Store Connect > Upload**.

---

## 4. App Store Connect Submission Workflow

1. **Create New App Record:**
   - Log into [App Store Connect](https://appstoreconnect.apple.com).
   - Go to **My Apps > Add New App (+)**.
   - Platform: **iOS**.
   - Name: `ANSHIILY | أنشئلي`.
   - Primary Language: Arabic or English.
   - Bundle ID: Choose `com.anshiily.app`.
   - SKU: `anshiily-ios-001`.
2. **TestFlight Internal Testing:**
   - When the uploaded build finishes processing in App Store Connect, it will appear under the **TestFlight** tab.
   - Add internal testers to test on physical iPhones and iPads.
3. **Store Listing Information:**
   - Title & Subtitle: Refer to [STORE_LISTING_AR.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_LISTING_AR.md) and [STORE_LISTING_EN.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_LISTING_EN.md).
   - Upload 6.7" iPhone and 12.9" iPad screenshots according to [STORE_SCREENSHOT_PLAN.md](file:///Users/omnia/Downloads/vs_projects/anshiily/STORE_SCREENSHOT_PLAN.md).
4. **App Privacy (Nutrition Labels):**
   - Disclose data types: Contact Info (Email, Name), User Content (Designs/Photos), Purchases, and Diagnostics.
5. **In-App Subscriptions (RevenueCat):**
   - Create an In-App Purchase group: `ANSHIILY Pro`.
   - Add two Auto-Renewable Subscriptions:
     - `anshiily_pro_monthly`
     - `anshiily_pro_annual`
   - Generate an **App Store Connect Shared Secret** and input it into your RevenueCat project dashboard.
