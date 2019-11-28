#!/usr/bin/env python

import socket, ssl

context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.verify_mode = ssl.CERT_REQUIRED
#context.verify_mode = ssl.CERT_OPTIONAL
context.verify_flags = ssl.VERIFY_CRL_CHECK_LEAF

context.load_verify_locations(cafile="ca-cert-crl.pem")
context.load_cert_chain(certfile="server.crt",
                        keyfile="server.pem", password='mypassphrase2')

bindsocket = socket.socket()
bindsocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
bindsocket.bind(('0.0.0.0', 10023))
bindsocket.listen(5)

while True:
    newsocket, fromaddr = bindsocket.accept()
    try:
        connstream = context.wrap_socket(newsocket, server_side=True)
        print(connstream.getpeercert())
        try:
            data = connstream.recv(1024)
            connstream.send(b"FOO\n")
        finally:
            connstream.shutdown(socket.SHUT_RDWR)
            connstream.close()
    except Exception as e:
        print(e)
