#!/bin/bash
##
# add the latest package to the aptly repository at http://apt-repo.qyanu.net/qyanu/
##
set -eu
MYDIR="$(test -L "$0" \
    && echo "$(dirname -- "$(realpath -- "$(dirname -- "$0")/$(readlink -- "$0")")")" \
    || echo "$(realpath -- "$(dirname -- "$0")")")"
umask 077

PACKAGE="$(dpkg-parsechangelog -S Source)"
VERSION="$(dpkg-parsechangelog -S Version)"
PROJECTDIR="$(realpath "${MYDIR}/..")"


# need variable "APTLY_BASEDIR"
. "${MYDIR}/.env"

echo "[INFO] aptly-importing changes file into: ${APTLY_BASEDIR}" >&2

_aptly="${APTLY_BASEDIR}/aptly"

"${_aptly}" repo include \
    -repo=qyanu-bookworm \
    -no-remove-files \
    -keyring="${APTLY_BASEDIR}/keyring.gpg" \
    "${PROJECTDIR}/../${PACKAGE}_${VERSION}_"*".changes"

"${_aptly}" publish update \
    bookworm \
    filesystem:apt-repo.qyanu.net:qyanu/ \
    #
