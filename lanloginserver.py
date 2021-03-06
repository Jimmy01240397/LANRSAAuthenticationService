import os.path
import os
import glob
import base64
import yaml
import ipaddress

from doonloginandlogout import *

from datetime import datetime

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_v1_5 as Cipher_pkcs1_v1_5
from Crypto.Signature import PKCS1_v1_5 as Signature_pkcs1_v1_5
from Crypto.Hash import SHA

from flask import Flask,request,redirect,Response,make_response

app = Flask(__name__)


dir="/var/www/lanlogin/"

def gettime(formating):
    return datetime.utcnow().strftime(formating)

print(gettime("%H:%M"))

with open('config.yaml', 'r') as f:
    config = yaml.load(f, Loader=yaml.FullLoader)

signers = []
signernames = []
for filename in glob.glob(os.path.join("allowkey", '*.pem')):
    with open(filename,'rb') as f:
        pubkey = RSA.importKey(f.read())
        signers.append(Signature_pkcs1_v1_5.new(pubkey))
        signernames.append(filename.replace('allowkey/', '').replace('.pem', ''))

def v6tov4(nowip):
    ipdata = ipaddress.ip_address(nowip).exploded.split(":");
    if len(ipdata) < 8:
        return nowip
    elif ipdata[:6] != ['0000', '0000', '0000', '0000', '0000', 'ffff']:
        return nowip
    return '.'.join(map(str,bytes.fromhex(ipdata[6]+ipdata[7])))

def isv6(nowip):
    ipdata = ipaddress.ip_address(nowip).exploded.split(":");
    return len(ipdata) == 8

@app.route('/',methods=['GET'])
def host():
    data = ""
    digest = SHA.new(str(v6tov4(request.remote_addr) + "," + str(gettime("%H"))).encode())
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
    data = str(gettime("%H:%M"))
    getip = v6tov4(request.remote_addr)
    digest = SHA.new(str(SHA.new(str(getip + "," + str(gettime("%H"))).encode()).hexdigest() + "," + data).encode())

    is_verify = False
    cont = 0
    for signer in signers:
        is_verify = signer.verify(digest, base64.b64decode(request.form["sign"].encode("UTF-8")))
        if is_verify:
            break
        cont += 1

    if is_verify:
        runfunc = lambda nowip : "ipset add lanallow" + ("6 " if isv6(nowip) else " ") + nowip
        run = runfunc(getip)
        mac = ""
        if config['Layer2auth']:
            mac = os.popen("ip neigh | grep " + getip + " | awk '{print $5}'").read().strip()
            if config['AllowAllIPAtSameMac']:
                getip = list(map(str.strip, os.popen("ip neigh | grep " + mac + " | awk '{print $1}'").read().split()))
                run = ""
                for thisip in getip:
                    run+= runfunc(thisip) + "," + mac + ";"
            else:
                run+="," + mac
        
        doonlogin(signernames[cont], getip, mac)
        os.system(run)
        return """<style>.data {font-weight: bold;font-size: 500%;left: 0;width: 100%;top: 20%;}</style> <span class="data">success</span>"""
    else:
        return """<style>.data {font-weight: bold;font-size: 500%;left: 0;width: 100%;top: 20%;}</style> <span class="data">fail</span>"""

@app.route('/generate_204/login',methods=['POST'])
def login2():
    return login()

@app.route('/logout',methods=['GET'])
def logout():
    getip = v6tov4(request.remote_addr)
    runfunc = lambda nowip : "ipset del lanallow" + ("6 " if isv6(nowip) else " ") + nowip
    run = runfunc(getip)
    if config['Layer2auth']:
        mac = os.popen("ip neigh | grep " + getip + " | awk '{print $5}'").read().strip()
        if config['AllowAllIPAtSameMac']:
            getip = list(map(str.strip, os.popen("ip neigh | grep " + mac + " | awk '{print $1}'").read().split()))
            run = ""
            for thisip in getip:
                run+= runfunc(thisip) + "," + mac + ";"
        else:
            run+="," + mac
    
    doonlogout(getip, mac)
    os.system(run)
    return """<style>.data {font-weight: bold;font-size: 500%;left: 0;width: 100%;top: 20%;}</style> <span class="data">logout success</span>"""


@app.route('/<path:path>',methods=['GET'])
def hostpath(path):
    data = ""
    digest = SHA.new(str(v6tov4(request.remote_addr) + "," + str(gettime("%H"))).encode())
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
