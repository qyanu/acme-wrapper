#!/bin/bash
##
# upload the latest package to webpage qyanu.net/software
##
set -eu
MYDIR="$(test -L "$0" \
    && echo "$(dirname -- "$(realpath -- "$(dirname -- "$0")/$(readlink -- "$0")")")" \
    || echo "$(realpath -- "$(dirname -- "$0")")")"
umask 077

cd "${MYDIR}/.."

PACKAGE="$(dpkg-parsechangelog -S Source)"
VERSION="$(dpkg-parsechangelog -S Version)"


# need variable "OPERATIONS_BASEDIR"
. "$MYDIR/.env"


install --mode=a=rX,u+w \
    -t "${OPERATIONS_BASEDIR}/source/_packages/${PACKAGE}/" \
    "../${PACKAGE}_${VERSION}.tar.xz" \
    "../${PACKAGE}_${VERSION}_all.deb" \
    "../${PACKAGE}_${VERSION}.dsc" \
    #

(
    cd "${OPERATIONS_BASEDIR}/source/_packages/${PACKAGE}/"
    rm -f SHA256SUM.signed SHA256SUM
    find . \! -name 'SHA256SUM*' -type f -printf '%P\0' \
        | sort -V -z \
        | xargs -0 sha256sum --binary \
        > SHA256SUM
    gpg --clearsign --output SHA256SUM.signed SHA256SUM
    chmod a=r,u+w SHA256SUM.signed SHA256SUM
)
(
    cd "${OPERATIONS_BASEDIR}"
    sed -re "s/${PACKAGE}_[0-9]+\.[0-9]+\.[0-9]+/${PACKAGE}_${VERSION}/g" \
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
