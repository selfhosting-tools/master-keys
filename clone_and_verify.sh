#!/bin/sh
# V20200101-1

TRUSTED_GPG_KEYS="CA2B146D7407C0932B96AA8756CD3255CE0673F6"  # space-separated
REPO="nsd-docker"
SOURCE_DIRECTORY="$(pwd)/source"


echo "$REPO will be stored in $SOURCE_DIRECTORY..."
docker run \
    -i --rm \
    -e REPO="$REPO" \
    -e TRUSTED_GPG_KEYS="$TRUSTED_GPG_KEYS" \
    -v "$SOURCE_DIRECTORY":/source \
    alpine:latest sh -x -e << \EOF
# Install deps
apk add --no-cache git gnupg curl

# Clone or pull
cd /source || exit 3
if [ -d ".git" ]; then
    # Ensure the repository is $REPO (naive verification)
    if ! grep -q "$REPO" .git/config; then
        echo "$SOURCE_DIRECTORY is not empty and is not $REPO"
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
        == \
        "$(git verify-commit HEAD 2>&1 | grep "Primary key fingerprint:" | \
        cut -d: -f 2 | sed s/' '//g)" \
    ] && VALID_SIG="true" && break; \
done
if [ "$VALID_SIG" == "true" ]; then
    echo "[OK] Valid signature found"
    exit 0
else
    echo "[ERROR] Invalid signature or not signed"
    exit 1
fi

EOF
