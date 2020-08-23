#!/bin/bash
set -eu -o pipefail

cat > /etc/opt/acme-wrapper/domains.list <<"EOF"
example.com www.example.com
EOF

sudo -u acme-wrapper /opt/acme-wrapper/bin/acme-wrapper --loglevel debug --automatic-selfsign --all-domains
