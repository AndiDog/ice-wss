#!/usr/bin/env bash
set -eu -o pipefail

error() {
	>&2 echo "$@"
	exit 1
}

if [ $# != 2 ]; then
	error "Usage: ${0} CA_NAME COMMON_NAME"
fi

ca_name="${1}"
ca_config_file="${ca_name}.openssl.cnf"
cn="${2}"
output_key_file="${cn}.key"
output_crt_file="${cn}.crt"
output_csr_file="${cn}.csr"
output_p12_file="${cn}.p12"
if [ -e "${output_key_file}" ] || [ -e "${output_crt_file}" ] || [ -e "${output_csr_file}" ] || [ -e "${output_p12_file}" ]; then
	error "Output file already exists"
fi

openssl genrsa -out "${output_key_file}" 2048

openssl req -new -key "${output_key_file}" -config "${ca_config_file}" \
	-subj "/C=DE/ST=BY/L=Munich/O=AndiDog/OU=AbsoluteUnit/CN=${cn}" \
	-out "${output_csr_file}"

openssl ca -config "${ca_config_file}" -extensions server_cert -in "${output_csr_file}" -out "${output_crt_file}"

openssl pkcs12 -export -certfile "${ca_name}/ca.crt" -in "${output_crt_file}" -inkey "${output_key_file}" \
	-out "${output_p12_file}" -name "${cn}" -passout pass:dummy
