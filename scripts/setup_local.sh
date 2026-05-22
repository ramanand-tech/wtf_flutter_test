#!/usr/bin/env bash
# One-time local setup from wtf_flutter_test/
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> token_server .env"
if [[ ! -f "$ROOT/token_server/.env" ]]; then
  cp "$ROOT/.env.example" "$ROOT/token_server/.env"
  echo "Created token_server/.env — edit with 100ms credentials."
else
  echo "token_server/.env already exists."
fi

echo "==> hms_secrets.dart"
SECRETS="$ROOT/shared/lib/config/hms_secrets.dart"
if [[ ! -f "$SECRETS" ]]; then
  cp "$ROOT/shared/lib/config/hms_secrets.example.dart" "$SECRETS"
  echo "Created hms_secrets.dart — set kDefaultHmsRoomId to match .env."
else
  echo "hms_secrets.dart already exists."
fi

echo "==> npm install (token_server)"
(cd "$ROOT/token_server" && npm install)

echo "==> flutter pub get"
(cd "$ROOT/shared" && flutter pub get)
(cd "$ROOT/guru_app" && flutter pub get)
(cd "$ROOT/trainer_app" && flutter pub get)

echo "==> Done. Next: cd token_server && npm start"
echo "    Then: cd guru_app && flutter run  (and trainer_app in another terminal)"
