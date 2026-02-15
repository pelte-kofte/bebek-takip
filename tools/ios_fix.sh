#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"
flutter clean
flutter pub get

cd ios
bundle install
bundle exec pod deintegrate
rm -rf Pods Podfile.lock
bundle exec pod install
