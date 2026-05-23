# Testing & CI

How to run tests locally

Prerequisites
- Flutter SDK installed and on PATH.

Run tests

```bash
flutter test
```

Notes
- The repository includes unit tests under `test/` for `AdManagerNotifier` and `ProUpgradeNotifier`. The `ProUpgradeNotifier` test uses `SharedPreferences.setMockInitialValues`.
- If `flutter` isn't available in your environment (like this agent's environment), run tests locally or rely on CI.

CI
- A GitHub Actions workflow `.github/workflows/flutter.yml` is present to run `flutter test` on push and PRs. Ensure runners have Flutter available (standard ubuntu-latest runners in Actions have Flutter preinstalled via actions-setup-flutter in the workflow).

Fixing failures
- If tests fail in CI, open logs and fix failing assertions or missing mocks. I can help iterate on failures you paste here.

Local debugging tips

- To run a single test file:

```bash
flutter test test/core/ads/ad_manager_notifier_test.dart
```

- To run tests with verbose output:

```bash
flutter test --reporter expanded
```

