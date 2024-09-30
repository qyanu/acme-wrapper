#!/bin/bash
##
# upload the latest package to webpage qyanu.net/software
##
set -eu
MYDIR="$(test -L "$0" \
    && echo "$(dirname -- "$(realpath -- "$(dirname -- "$0")/$(readlink -- "$0")")")" \
    || echo "$(realpath -- "$(dirname -- "$0")")")"
umask 077

PACKAGE="$(dpkg-parsechangelog -S Source)"
VERSION="$(dpkg-parsechangelog -S Version)"
PROJECTDIR="$(realpath "${MYDIR}/..")"


# need variable "OPERATIONS_BASEDIR"
. "${MYDIR}/.env"

if [[ ! -e "${PROJECTDIR}/../${PACKAGE}_${VERSION}_all.deb.sig" ]] \
|| [[ "${PROJECTDIR}/../${PACKAGE}_${VERSION}_all.deb.sig" -ot "${PROJECTDIR}/../${PACKAGE}_${VERSION}_all.deb" ]];
then
    echo "[INFO] making (new) detached signature of ${PACKAGE}_${VERSION}_all.deb" >&2
    gpg --detach-sig \
        --output "${PROJECTDIR}/../${PACKAGE}_${VERSION}_all.deb.sig" \
        "${PROJECTDIR}/../${PACKAGE}_${VERSION}_all.deb" \
        #
fi

echo "[INFO] copying files into: ${OPERATIONS_BASEDIR}/source/_packages/${PACKAGE}/" >&2
install --mode=a=rX,u+w \
    -t "${OPERATIONS_BASEDIR}/source/_packages/${PACKAGE}/" \
    "${PROJECTDIR}/../${PACKAGE}_${VERSION}.tar.xz" \
    "${PROJECTDIR}/../${PACKAGE}_${VERSION}_all.deb" \
    "${PROJECTDIR}/../${PACKAGE}_${VERSION}_all.deb.sig" \
    "${PROJECTDIR}/../${PACKAGE}_${VERSION}.dsc" \
    #

(
    cd "${OPERATIONS_BASEDIR}/source/_packages/${PACKAGE}/"
    rm -f SHA256SUM.signed SHA256SUM
    find . \! -name 'SHA256SUM*' -type f -printf '%P\0' \
        | sort -V -z \
        | xargs -0 sha256sum --binary \
        > SHA256SUM
    echo "[INFO] signing SHA256SUM into: SHA256SUM.signed" >&2
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
