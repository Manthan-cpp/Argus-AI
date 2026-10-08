#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../argus/argus_flutter"
echo "Starting Argus Flutter web client..."
flutter run -d chrome
