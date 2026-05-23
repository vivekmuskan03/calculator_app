# Release & Signing Notes

This file documents steps to prepare a release build for Android and CI adjustments.

1) Android app signing
- Generate a signing key (keystore) and store it securely (CI secrets recommended).
- Update `android/app/build.gradle` signingConfigs to reference environment variables or local `key.properties`.

2) Build for release
- Locally:
  - `flutter build apk --release`
  - `flutter build appbundle --target-platform android-arm,android-arm64 --release`

3) CI publishing
- Add secure storage of signing keystore and passwords in CI provider (GitHub Actions secrets).
- Update `.github/workflows/flutter.yml` to inject the keystore and run `flutter build appbundle` and optionally upload artifacts or call Play Console API.

4) Play Store checklist
- Privacy policy URL
- Accurate store listing, screenshots
- VersionCode incrementing and semantic versioning

5) Post-release
- Monitor crashes (Firebase Crashlytics) and analytics.
