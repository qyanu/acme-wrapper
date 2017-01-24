#!/bin/bash
umask 077

PACKAGE="$1"

[[ -n "$PACKAGE" ]] || {
    echo "Usage: $0 PACKAGE" >&2
    exit 1
}

id "${PACKAGE}" > /dev/null 2>&1 
[[ "$?" -eq 0 ]] || {
    echo "creating user/group: ${PACKAGE}/${PACKAGE}"
    mkdir -p "/var/opt/${PACKAGE}/home"
    adduser --system \
        --home "/var/opt/${PACKAGE}/home" \
        --no-create-home \
        --shell /bin/false \
        --group \
        --disabled-password \
        --disabled-login \
        --gecos "user for automatic ssl-certificate updater and database" \
        "${PACKAGE}"
}
