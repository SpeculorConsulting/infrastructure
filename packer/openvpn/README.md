# Credential creation using easy-rsa
curl -O https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz
tar -zxvf EasyRSA-3.0.7.tgz
cd EasyRSA-3.0.7
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req speculor-server nopass
./easyrsa sign-req server speculor-server
./easyrsa gen-req client01 nopass
./easyrsa sign-req client client01
./easyrsa gen-dh

# Created artifacts
./pki/ca.crt
./pki/issued/speculor-server.crt
./pki/private/speculor-server.key
./pki/issued/client01.crt
./pki/private/client01.key
