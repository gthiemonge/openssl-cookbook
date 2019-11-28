#!/usr/bin/env python

import socket, ssl

verify = True
auth = True

if verify:
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    context.load_verify_locations("ca-cert.pem")
    if auth:
        context.load_cert_chain("client.crt", keyfile="client.pem",
                                password='mypassphrase3')
else:
    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.check_hostname = False
    context.load_default_certs()

conn = context.wrap_socket(socket.socket(socket.AF_INET),
                           server_hostname="localhost")
conn.connect(('localhost', 10023))

conn.sendall(b"data\n")
data = conn.recv(1024)
print(data)
