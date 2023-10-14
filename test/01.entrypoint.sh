#!/bin/bash
set -eu -o pipefail

cat > /etc/acme-wrapper/domains.list <<"EOF"
example.com www.example.com
EOF

runuser -u acme-wrapper -- \
    /usr/bin/acme-wrapper \
    --loglevel debug \
    --automatic-selfsign \
    --all-domains \
    #
