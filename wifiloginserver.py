import os.path
import os
import glob

import time

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_v1_5 as Cipher_pkcs1_v1_5
from Crypto.Signature import PKCS1_v1_5 as Signature_pkcs1_v1_5
from Crypto.Hash import SHA

from flask import Flask,request,redirect,Response,make_response

app = Flask(__name__)


dir="/var/www/wifilogin/"

print(time.strftime("%H:%M", time.localtime()))

signers = []
for filename in glob.glob(os.path.join("allowkey", '*.pem')):
    with open(filename,'rb') as f:
        pubkey = RSA.importKey(f.read())
        signers.append(Signature_pkcs1_v1_5.new(pubkey))

@app.route('/',methods=['GET'])
def host():
    data = ""
    digest = SHA.new(str(request.remote_addr + "," + str(time.strftime("%H", time.localtime()))).encode())
    with open(dir + "index.html", "r", encoding='UTF-8') as f:
        data = f.read()
    resp = make_response(data)
    resp.set_cookie(key='token', value=digest.hexdigest())
    print(digest.hexdigest())
    return resp

@app.route('/generate_204',methods=['GET'])
def host2():
    return host()

@app.route('/login',methods=['POST'])
def login():
    data = str(time.strftime("%H:%M", time.localtime()))
    digest = SHA.new(str(SHA.new(str(request.remote_addr + "," + str(time.strftime("%H", time.localtime()))).encode()).hexdigest() + "," + data).encode())

    is_verify = False
    for signer in signers:
        is_verify = signer.verify(digest, bytes.fromhex(request.form["sign"]))
        if is_verify:
            break

    if is_verify:
        mac = os.popen("arp | grep " + request.remote_addr + " | awk '{print $3}'").read().strip()
        os.system("ipset add wifiallow " + request.remote_addr +"," + mac)
        return """<style>.data {font-weight: bold;font-size: 500%;left: 0;width: 100%;top: 20%;}</style> <span class="data">success</span>"""
    else:
        return """<style>.data {font-weight: bold;font-size: 500%;left: 0;width: 100%;top: 20%;}</style> <span class="data">fail</span>"""

@app.route('/generate_204/login',methods=['POST'])
def login2():
    return login()

@app.route('/<path:path>',methods=['GET'])
def hostpath(path):
    data = ""
    digest = SHA.new(str(request.remote_addr + "," + str(time.strftime("%H", time.localtime()))).encode())
    try:
        with open(dir + path, "r", encoding='UTF-8') as f:
            data = f.read()
    except:
            data = "error"
    resp = make_response(data)
    resp.set_cookie(key='token', value=digest.hexdigest())
    return resp

if __name__ == "__main__":
    app.run(host="0.0.0.0",port=443,ssl_context=('server.crt', 'server.key'))
