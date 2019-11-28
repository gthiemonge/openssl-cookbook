#!/bin/sh

curl --cacert ca-cert.pem \
    -E client-key-and-cert.pem:mypassphrase3 \
    https://localhost:5000/
