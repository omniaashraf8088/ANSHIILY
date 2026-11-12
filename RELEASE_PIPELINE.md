# ANSHIILY Production Release Pipeline
### خطة وتوثيق خط البناء والنشر الآلي للإنتاج

**Application:** ANSHIILY (أنشئلي)  
**Repository:** `omniaashraf8088/ANSHIILY`  
**CI/CD Engine:** GitHub Actions  

---

## 1. Pipeline Architecture

```mermaid
flowchart TD
    Trigger["Release Trigger (Tag v*.*.* or Manual Dispatch)"] --> Gate["Job 1: Pre-Release Quality Gates"]
    
    subgraph QualityGates["Quality & Verification"]
        Gate --> Dep["flutter pub get"]
        Dep --> Fmt["dart format --set-exit-if-changed"]
        Fmt --> Lnt["flutter analyze (0 Errors)"]
        Lnt --> Tst["flutter test (All 23 Tests)"]
    end
    
    Tst --> BuildJob["Job 2: Android Release Builder"]
    
    subgraph ArtifactGeneration["Production Artifact Generation"]
        BuildJob --> Sign["Decode Keystore & Configure key.properties"]
        Sign --> AAB["flutter build appbundle --release (.aab)"]
        Sign --> APK["flutter build apk --release (.apk)"]
        AAB --> ArtAAB["Upload Artifact: anshiily-app-release-bundle"]
        APK --> ArtAPK["Upload Artifact: anshiily-app-release-apk"]
    end
```

---

## 2. Triggering a Production Release

### Method A: Manual Trigger via GitHub Actions UI
1. Navigate to **Actions > ANSHIILY Production Release Pipeline**.
2. Click **Run workflow**.
3. Specify release tag (e.g. `v1.0.0`).
4. Click **Run workflow** (Requires repository write/admin permission).

### Method B: Git Tag Release
Pushing an annotated Git tag matching `v*.*.*` automatically triggers the release workflow:
```bash
git tag -a v1.0.0 -m "Release v1.0.0: Initial Production Launch"
git push origin v1.0.0
```

---

## 3. GitHub Secrets Configuration for Production Signing

To enable automated cryptographic signing of App Bundles in GitHub Actions, configure the following repository secrets under **Settings > Secrets and variables > Actions**:

| Secret Name | Description | Format / Example |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded release `.jks` file | `base64 -i anshiily-release-key.jks \| pbcopy` |
| `ANDROID_KEYSTORE_PASSWORD` | Master password for the keystore file | String |
| `ANDROID_KEY_ALIAS` | Key alias name defined when creating key | `anshiily` |
| `ANDROID_KEY_PASSWORD` | Password for the specific key alias | String |

---

## 4. Security & Safety Rules

1. **No Production Credentials Committed**: Never store `.jks`, `.keystore`, or plain passwords in Git.
2. **Pull Request Isolation**: The release workflow is restricted strictly to manual dispatch or protected release tags; it cannot be triggered by arbitrary pull requests.
3. **Artifact Retention**: Generated `.aab` and `.apk` artifacts are archived securely for 14 days for direct download and store upload.
