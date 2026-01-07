# 📦 Project Reincarnation Kit

**Project Name:** Halı Yıkamacı
**Package Name:** `com.hali_yikamaci.app`
**Organization:** `com.hali_yikamaci`

## 🔑 Critical Security Files (Found in this folder)
1.  `google-services.json` (Firebase Configuration)
2.  `upload-keystore.jks` (Google Play Signing Key)
3.  `release.properties` (Passwords & Aliases for the Keystore)

## 📱 Configuration Details
- **AdMob App ID:** `ca-app-pub-7843501870103872~2169874477`

## 📝 Instructions for New Agent
1.  **Initialize Mobile App:**
    - Create new Flutter project: `flutter create --org com.hali_yikamaci app`
    - Copy `google-services.json` to `android/app/`.
    - Copy `upload-keystore.jks` and `release.properties` to `android/`.
    - Configure `build.gradle` to use the signing config.
    - Set `applicationId` to `com.hali_yikamaci.app` in `build.gradle`.

## ⚠️ Important
**DO NOT LOSE** `upload-keystore.jks`. If this is lost, the app cannot be updated on Play Store.
