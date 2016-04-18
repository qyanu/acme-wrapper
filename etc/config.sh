# re-request 3 days before expiry
# value is in seconds
RESUBMIT_BEFORE=$((3*24*60*60))

# rsa key pairs (user account and certificate private keys) should have
# that many number of bits
RSA_KEY_BITS=4096

# don't re-retrieve intermediate and ca certificates if file was modified
# as recent as these many seconds
RETRIEVE_COOLDOWN=2592000 # seconds: 30 days

# directory to write acme-challenge files into and that will be
# publicly available at http://<domain>/.well-known/acme-challenge
ACME_CHALLENGE_DIR="/var/www/acme-challenge"
