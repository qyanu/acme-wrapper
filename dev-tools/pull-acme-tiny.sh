#!/bin/bash

#
# pulls (latest) version of "acme-tiny" from https://github.com/diafygi/acme-tiny
#
#
# command line parameters
#   $1 ... what version to pull (default="master")
#

set -eu
umask 077

baseurl="https://codeload.github.com/diafygi/acme-tiny"
version="${1:-master}"
downloadurl="$baseurl/tar.gz/${version}"

# find out the directory of this script
MYDIR="$(dirname "$0")"
# and thus the directory of the project
PROJECTDIR="$MYDIR/.."

# a temp file that is immediately deleted after open to ensure cleanup
TEMPFILE="$(mktemp)"
ls -alhi "$TEMPFILE"
exec 3<>"${TEMPFILE}"
rm -f "${TEMPFILE}"
TEMPFILE="/proc/self/fd/3"


extractdir="$PROJECTDIR/libexec/acme-tiny"

# download zip
rm -Rf "$extractdir"
mkdir "$extractdir"
curl "$downloadurl" \
    | tar -zx --overwrite --verbose --strip-components=1 -C \
        "$extractdir"

# add changes to index
git add "$extractdir"
