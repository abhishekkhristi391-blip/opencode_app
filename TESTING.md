# CI & Testing Setup

## GitHub Actions CI
A workflow is set up at `.github/workflows/ci.yml` that runs on every push and pull request to `main`/`master`:

1. Checkout code
2. Set up Flutter (stable) with caching via `subosito/flutter-action@v2`
3. Run `flutter pub get`
4. Run `flutter analyze --no-fatal-infos --no-fatal-warnings`
5. Run `flutter test`
6. Build debug APK with `flutter build apk --debug`
7. Upload debug APK as artifact `app-debug-apk`

## Baseline Tests
Simple tests added (no app behavior changes):

- `test/unit/json_parsing_test.dart` - validates `asMap`, `asList`, `asStr`, `asInt`, `asBool` helpers and basic model parsing (`ModelInfo`, `Session`)
- `test/unit/chat_db_test.dart` - tests ChatDB open/write/read/clear using `sqflite_common_ffi` (for CI environment without Android device)
- `test/widget/home_test.dart` - basic smoke test that app renders
- `test/helpers/fake_client.dart` - simple `FakeOcClient` for future widget tests

Note: `sqflite_common_ffi` is added as a dev dependency for desktop/CI SQLite support.

## How to Push to GitHub

1. Initialize repo if needed: `git init` (already a git repo)
2. Add remote if not set: `git remote add origin <your-github-repo-url>`
3. Create/checkout main branch: `git checkout -b main` (or use existing)
4. Stage and commit:
   ```bash
   git add .github/workflows/ci.yml pubspec.yaml test/ test.sh
   git commit -m "ci: add GitHub Actions workflow and baseline tests"
   ```
5. Push:
   ```bash
   git push -u origin main
   ```

## Where to See Results & Download APK

1. Go to your repository on GitHub
2. Click **Actions** tab to see CI runs
3. Click the latest workflow run (push/PR) to see logs for `analyze`, `test`, `build`
4. Under **Artifacts** section at the bottom of the run summary, download `app-debug-apk` (contains `app-debug.apk`)
