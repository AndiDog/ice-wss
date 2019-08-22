#!/usr/bin/env bash

# CA
ca_name=ice-ca
for n in certs crl newcerts private; do mkdir -p ${ca_name}/${n} && touch ${ca_name}/${n}/.gitkeep; done
touch ${ca_name}/index.txt
[ -e ${ca_name}/serial ] || echo 1000 >${ca_name}/serial
openssl genrsa -out ${ca_name}/private/ca.key 2048
chmod 0400 ${ca_name}/private/ca.key
openssl req -config ${ca_name}.openssl.cnf -key ${ca_name}/private/ca.key -new -x509 -days 3650 -sha256 -extensions v3_ca \
	-subj "/C=DE/ST=BY/L=Munich/O=AndiDog/OU=AbsoluteUnit/CN=${ca_name}" \
	-out ${ca_name}/ca.crt

# Server/client certificates (script currently does not distinguish these or use subjectAltName; do not use in
# production like this!)
./create-ice-cert.sh "${ca_name}" the-server
./create-ice-cert.sh "${ca_name}" the-server2 # for playing around with `IceSSL.TrustOnly*`
./create-ice-cert.sh "${ca_name}" the-client

# Java (key store requires password of at least 6 characters)
openssl pkcs12 -export -certfile ice-ca.crt -in the-client.crt -inkey the-client.key -out the-client.longpassword.p12 -passin pass:dummy -passout pass:longpassword
echo yes | keytool -v -importcert -file ice-ca.crt -destkeystore ice-ca-trust.jks -storepass longpassword
echo longpassword | keytool -v -importkeystore -srckeystore the-client.longpassword.p12 -srcstoretype PKCS12 -destkeystore the-client.jks -deststoretype JKS -storepass longpassword
