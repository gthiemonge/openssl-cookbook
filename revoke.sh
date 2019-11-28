#!/bin/sh

set -xe

CA_PASSPHRASE=mypassphrase

openssl ca -revoke client.crt -keyfile ca-key.pem -cert ca-cert.pem -config crl_openssl.conf -passin pass:$CA_PASSPHRASE

openssl ca -gencrl -config ./crl_openssl.conf -keyfile ca-key.pem -cert ca-cert.pem -passin pass:$CA_PASSPHRASE -out intermediate.crl.pem

cat ca-cert.pem intermediate.crl.pem > ca-cert-crl.pem
