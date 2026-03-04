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
# Generate CA key (4096-bit for CA)
openssl genrsa -aes128 -out ca-key.pem -passout pass:$CA_PASSPHRASE 4096

# Generate self-signed CA certificate
openssl req -key ca-key.pem -new -x509 -sha256 -extensions v3_ca -days 365 -subj "$CA_SUBJECT" -passin pass:$CA_PASSPHRASE -out ca-cert.pem

# Server
# Generate server key (2048-bit)
openssl genrsa -aes128 -out server-key.pem -passout pass:$SERVER_PASSPHRASE 2048

# Generate certificate sign request for server
openssl req -key server-key.pem -new -subj "$SERVER_SUBJECT" -passin pass:$SERVER_PASSPHRASE -out server.csr

# Generate self-signed certificate for server
openssl req -key server-key.pem -new -x509 -days 365 -subj "$SERVER_SUBJECT" -passin pass:$SERVER_PASSPHRASE -out server-self-signed-cert.pem

# Sign server certificate with CA
openssl x509 -req -in server.csr -CA ca-cert.pem  -CAkey ca-key.pem -CAcreateserial -days 365 -passin pass:$CA_PASSPHRASE -out server-cert.pem

# Cert Revocation list

openssl ca -gencrl -config ./crl_openssl.conf -keyfile ca-key.pem -cert ca-cert.pem -passin pass:$CA_PASSPHRASE -out intermediate.crl.pem

cat ca-cert.pem intermediate.crl.pem > ca-cert-crl.pem

cat server-key.pem server-cert.pem > server-key-and-cert.pem

# Client
# Generate client key (2048-bit)
openssl genrsa -aes128 -out client-key.pem -passout pass:$CLIENT_PASSPHRASE 2048

openssl req -key client-key.pem -new -subj "$CLIENT_SUBJECT" -passin pass:$CLIENT_PASSPHRASE -out client.csr

openssl x509 -req -in client.csr -CA ca-cert.pem  -CAkey ca-key.pem -CAcreateserial -days 365 -passin pass:$CA_PASSPHRASE -out client-cert.pem

cat client-key.pem client-cert.pem > client-key-and-cert.pem

# Generate a PKCS12 file for Octavia (server key + cert + CA chain)
openssl pkcs12 -export -inkey server-key.pem -in server-cert.pem -certfile ca-cert.pem -passin pass:$SERVER_PASSPHRASE -passout pass: -out server.p12
