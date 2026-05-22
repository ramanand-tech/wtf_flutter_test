#!/usr/bin/env bash
# Phase 11 — run all Flutter tests + analyze
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> shared: test + analyze"
cd "$ROOT/shared"
flutter pub get
flutter test
flutter analyze --no-fatal-infos

echo "==> guru_app: test + analyze"
cd "$ROOT/guru_app"
flutter pub get
flutter test
flutter analyze --no-fatal-infos

echo "==> trainer_app: test + analyze"
cd "$ROOT/trainer_app"
flutter pub get
flutter test
flutter analyze --no-fatal-infos

echo "==> All quality gates passed."
