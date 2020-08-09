#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

./configure-global.sh
./configure-user.sh

echo
echo '==> All done!'
