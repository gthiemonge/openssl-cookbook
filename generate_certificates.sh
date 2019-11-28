#!/bin/sh

set -xe

CA_PASSPHRASE=mypassphrase
SERVER_PASSPHRASE=mypassphrase2
CLIENT_PASSPHRASE=mypassphrase3

SUBJECT="/C=FR/L=Paris/O=myorg"
CA_SUBJECT="$SUBJECT/CN=CA/"
SERVER_SUBJECT="$SUBJECT/CN=localhost/"
CLIENT_SUBJECT="$SUBJECT/CN=user1/"

# CA
# Generate CA key
openssl genrsa -aes128 -out ca-key.pem -passout pass:$CA_PASSPHRASE 1024

# Generate self-signed CA certificate
openssl req -key ca-key.pem -new -x509 -sha256 -extensions v3_ca -days 365 -subj "$CA_SUBJECT" -passin pass:$CA_PASSPHRASE -out ca-cert.pem

# Server
# Generate server key
openssl genrsa -aes128 -out server.pem -passout pass:$SERVER_PASSPHRASE 1024

# Generate ceritificate sign request for server
openssl req -key server.pem -new -subj "$SERVER_SUBJECT" -passin pass:$SERVER_PASSPHRASE -out server.csr

# Generate self-signed certificate for server
openssl req -key server.pem -new -x509 -days 365 -subj "$SERVER_SUBJECT" -passin pass:$SERVER_PASSPHRASE -out server-self-signed.crt

# Sign server certificate with CA
openssl x509 -req -in server.csr -CA ca-cert.pem  -CAkey ca-key.pem -CAcreateserial -days 365 -passin pass:$CA_PASSPHRASE -out server.crt

# Cert Revocation list

openssl ca -gencrl -config ./crl_openssl.conf -keyfile ca-key.pem -cert ca-cert.pem -passin pass:$CA_PASSPHRASE -out intermediate.crl.pem

cat ca-cert.pem intermediate.crl.pem > ca-cert-crl.pem

cat ca-cert.pem server.pem > ca-bundle.crt

cat server.pem server.crt > server-key-and-cert.pem

# Client
openssl genrsa -aes128 -out client.pem -passout pass:$CLIENT_PASSPHRASE 1024

openssl req -key client.pem -new -subj "$CLIENT_SUBJECT" -passin pass:$CLIENT_PASSPHRASE -out client.csr

openssl x509 -req -in client.csr -CA ca-cert.pem  -CAkey ca-key.pem -CAcreateserial -days 365 -passin pass:$CA_PASSPHRASE -out client.crt

cat client.pem client.crt > client-key-and-cert.pem
