#!/bin/bash
set -eu -o pipefail

cat > /etc/opt/acme-wrapper/domains.list <<"EOF"
example.com
EOF

sudo -u acme-wrapper /opt/acme-wrapper/bin/acme-wrapper --loglevel debug --automatic-letsencrypt --all-domains
