#!/usr/bin/env python

from flask import Flask, request
import werkzeug
import ssl
from cryptography import x509
from cryptography.hazmat.backends import default_backend

app = Flask(__name__)

def verify_request(self, request, client_address):
    data = request.getpeercert(True)
    cert = x509.load_der_x509_certificate(data, default_backend())
    print(cert)
    return True

werkzeug.serving.BaseWSGIServer.verify_request = verify_request

@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.verify_mode = ssl.CERT_REQUIRED
    context.verify_flags = ssl.VERIFY_CRL_CHECK_LEAF

    context.load_verify_locations(cafile="ca-cert-crl.pem")
    context.load_cert_chain(certfile="server.crt",
                            keyfile="server.pem", password='mypassphrase2')

    app.run("0.0.0.0", ssl_context=context, debug=True)
