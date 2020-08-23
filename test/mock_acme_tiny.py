
import sys
import subprocess
import os

assert 7==len(sys.argv)

assert '--account-key' == sys.argv[1]
accountkeyfilepath = sys.argv[2]
assert '--csr' == sys.argv[3]
csr = sys.argv[4]
assert '--acme-dir' == sys.argv[5]
acme_dir = sys.argv[6]

outstream = sys.stdout
signkey = os.path.join(os.path.dirname(csr), "key.pem")

subprocess.check_call([
    "openssl",
    "x509",
    "-req",
    "-sha256",
    "-days", "10",
    "-in", csr,
    "-signkey", signkey
    ],
    stdout=outstream,
    stderr=sys.stderr)
