#!/bin/bash
set -eu -o pipefail
MYDIR="$(realpath "$(dirname "$0")")"


#
# upload the latest package to qyanu.net/software
#
PACKAGE=acme-wrapper


# need variable "OPERATIONS_BASEDIR"
. "$MYDIR/.env"


# check validity of existing checksum
(
    cd "$OPERATIONS_BASEDIR/source/_packages/${PACKAGE}"
    gpg --decrypt SHA256SUM.signed \
        | sha256sum --check
)


# add new package to webpage
cd "$MYDIR/.."

VERSION="$(<./VERSION)"


make package

install --mode=a=rX,u+w \
    -t "$OPERATIONS_BASEDIR/source/_packages/${PACKAGE}/" \
    "${PACKAGE}_$VERSION.tar.bz2"

(
    cd "$OPERATIONS_BASEDIR/source/_packages/${PACKAGE}/"
    rm -f SHA256SUM.signed SHA256SUM
    find . \! -name 'SHA256SUM*' -type f -printf '%P\0' \
        | sort -V -z \
        | xargs -0 sha256sum --binary \
        > SHA256SUM
    gpg --clearsign --output SHA256SUM.signed SHA256SUM
    chmod a=rX,u+w SHA256SUM.signed SHA256SUM
)
(
    cd "$OPERATIONS_BASEDIR"
    sed -re "s/${PACKAGE}_([0-9]+\.){3}/${PACKAGE}_${VERSION}./g" \
        -i "source/${PACKAGE}/index.rst"
    git diff HEAD
    read -p "accept and commit changes? (Ctrl+C to abort, any key to continue)"
    git add -A
    git commit -m "publish ${PACKAGE} v${VERSION}"
    make clean html
    git add -A
    git commit -m 'exec `make clean html`'
    bash support/sync-to-live.sh
)
