#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../argus/argus_server"
echo "Starting Argus Serverpod backend..."
serverpod start
