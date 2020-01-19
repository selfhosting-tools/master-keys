#!/bin/sh

# Copyright (C) 2020 FL42

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# VERSION: 20200119-1

TRUSTED_GPG_KEYS="CA2B146D7407C0932B96AA8756CD3255CE0673F6"  # space-separated
REPO="nsd-docker"  # example
CLONE_DIRECTORY="$(pwd)/source"  # example


echo "$REPO will be stored in $CLONE_DIRECTORY..."
docker run \
    -i --rm \
    -e REPO="$REPO" \
    -e TRUSTED_GPG_KEYS="$TRUSTED_GPG_KEYS" \
    -v "$CLONE_DIRECTORY":/source \
    alpine:latest sh -x -e << \EOF
# Install deps
apk add --no-cache git gnupg curl

# Clone or pull
cd /source || exit 3
if [ -d ".git" ]; then
    # Ensure the repository is $REPO (naive verification)
    if ! grep -q "$REPO" .git/config; then
        echo "$CLONE_DIRECTORY is not empty and is not $REPO"
        exit 2
    fi
    git pull
else
    git clone \
        --depth 1 --branch master \
        "https://github.com/selfhosting-tools/${REPO}.git" \
        .
fi

# Verify signature
VALID_SIG="false"
for KEY_FP in $TRUSTED_GPG_KEYS
do
    curl -s \
        "https://raw.githubusercontent.com/selfhosting-tools/master-keys/master/${KEY_FP}.asc" | \
        gpg --import || continue
    [ \
        "$KEY_FP" \
        = \
        "$(git verify-commit HEAD 2>&1 | grep '^Primary key fingerprint:' | \
        cut -d: -f 2 | sed s/' '//g)" \
    ] && VALID_SIG="true" && break; \
done
if [ "$VALID_SIG" = "true" ]; then
    echo "[OK] Valid signature found"
    exit 0
else
    echo "[ERROR] Invalid signature, not signed with TRUSTED_GPG_KEYS, or not signed"
    exit 1
fi

EOF
