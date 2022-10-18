#!/bin/bash

set -euo pipefail

COUNT="${1:-4000}" # Default to 4000

RES=scripts

rm -rf output
mkdir output
USR=${SUDO_USER:-$USER}

chown -R "$USR" output

pushd "$RES" > /dev/null

./one-time-setup.sh
./setup-network-taps.sh 0 "$COUNT" 100

popd > /dev/null
