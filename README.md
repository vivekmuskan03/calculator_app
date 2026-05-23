# NexaCalc

NexaCalc is a Flutter calculator app focused on exact decimal arithmetic, Indian number formatting, offline voice input stubs, and on-device LLM/regex NLP fallbacks.

Requirements
- Flutter >= 3.22.0
- Dart SDK matching Flutter

Local setup

1. Install Flutter (https://flutter.dev/docs/get-started/install).
2. From the project root, fetch dependencies:

```bash
flutter pub get
```

Run the app

```bash
flutter run
```

Run tests

```bash
flutter test
```

CI

A GitHub Actions workflow is included at `.github/workflows/flutter.yml` which runs `flutter test` on push and pull requests targeting `main`.

Notes
- Some components use local stubs (`lib/core/stubs/*`) for packages not published on pub.dev. Replace these stubs with real packages when available.
- The repository includes a basic implementation of the Decimal engine and UI; further polish, production purchase validation, and native model integrations are still required before release.
