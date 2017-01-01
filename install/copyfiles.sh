#!/bin/bash
umask 077

CURDIR="$1"
PACKAGE="$2"

[[ -n "$CURDIR"
&& -d "$CURDIR"
&& -n "$PACKAGE"
]] || {
    echo "Usage: $0 CURDIR PACKAGE" >&2
    exit 1
}

echo "installing into /opt/${PACKAGE}, /var/opt/${PACKAGE} and /etc/opt/${PACKAGE}"

mkdir -p "/opt/${PACKAGE}"
mkdir -p "/etc/opt/${PACKAGE}"
mkdir -p "/var/opt/${PACKAGE}"

cp -rT "${CURDIR}/bin"     "/opt/${PACKAGE}/bin"
cp -rT "${CURDIR}/lib"     "/opt/${PACKAGE}/lib"
cp -rT "${CURDIR}/libexec" "/opt/${PACKAGE}/libexec"
cp -rT "${CURDIR}/doc"     "/opt/${PACKAGE}/doc"
cp -rT "${CURDIR}/share"   "/opt/${PACKAGE}/share"
cp -rT "${CURDIR}/etc"     "/etc/opt/${PACKAGE}"
cp -rT "${CURDIR}/var"     "/var/opt/${PACKAGE}"

touch "/var/opt/${PACKAGE}/home/.rnd"

chown -R root:acme-wrapper "/opt/${PACKAGE}"
chown -R acme-wrapper:acme-wrapper "/var/opt/${PACKAGE}"
chown -R :www-data "/var/opt/${PACKAGE}/www"

chmod -R u=rX,g=rX,o= "/opt/${PACKAGE}"
chmod u+x "/opt/${PACKAGE}/bin/acme-wrapper"
chmod u+x "/opt/${PACKAGE}/libexec/acme-tiny/acme_tiny.py"
chmod u+w "/opt/${PACKAGE}/.rnd"
chmod -R u=rwX,g=rX,o= "/var/opt/${PACKAGE}"
chmod -R g+rsX         "/var/opt/${PACKAGE}/www"

# use default configuration if no config exists from before
if [[ -e "/etc/opt/${PACKAGE}/acme-wrapper.conf" ]]; then
    echo "leaving existing configuration file untouched"
    echo "/etc/opt/${PACKAGE}/acme-wrapper.conf"
else
    cp "/etc/opt/${PACKAGE}/acme-wrapper.conf-dist" \
       "/etc/opt/${PACKAGE}/acme-wrapper.conf"
fi

# use empty domains.list if no list exists from before
if [[ -e "/etc/opt/${PACKAGE}/domains.conf" ]]; then
    echo "leaving existing domain list untouched"
    echo "/etc/opt/${PACKAGE}/domains.conf"
else
    cp "/etc/opt/${PACKAGE}/domains.list-dist" \
       "/etc/opt/${PACKAGE}/domains.list"
fi
