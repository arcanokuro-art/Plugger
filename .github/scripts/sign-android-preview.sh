#!/usr/bin/env bash
set -euo pipefail

: "${PLUGGER_ANDROID_KEYSTORE_BASE64:?Configura el secreto PLUGGER_ANDROID_KEYSTORE_BASE64}"
: "${PLUGGER_ANDROID_KEYSTORE_PASSWORD:?Configura el secreto PLUGGER_ANDROID_KEYSTORE_PASSWORD}"
: "${PLUGGER_ANDROID_CERT_SHA256:?Configura la variable PLUGGER_ANDROID_CERT_SHA256}"

input_apk=$1
output_apk=$2
expected_cert=$(printf '%s' "$PLUGGER_ANDROID_CERT_SHA256" | tr -d ':' | tr '[:upper:]' '[:lower:]')
if [[ ! $expected_cert =~ ^[0-9a-f]{64}$ ]]; then
  echo 'La huella esperada debe ser un SHA-256 de 64 caracteres.' >&2
  exit 1
fi

apksigner=$(find "$ANDROID_HOME/build-tools" -name apksigner -type f | sort -V | tail -n 1)
if [[ -z $apksigner ]]; then
  echo 'No se encontró apksigner en el SDK de Android.' >&2
  exit 1
fi

umask 077
keystore=$(mktemp)
trap 'rm -f "$keystore"' EXIT
printf '%s' "$PLUGGER_ANDROID_KEYSTORE_BASE64" | base64 --decode > "$keystore"

"$apksigner" sign \
  --ks "$keystore" \
  --ks-type PKCS12 \
  --ks-key-alias plugger \
  --ks-pass env:PLUGGER_ANDROID_KEYSTORE_PASSWORD \
  --key-pass env:PLUGGER_ANDROID_KEYSTORE_PASSWORD \
  --out "$output_apk" "$input_apk"

verification=$("$apksigner" verify --print-certs "$output_apk")
actual_cert=$(printf '%s\n' "$verification" | awk '
  /^[[:space:]]*Signer.*certificate SHA-256 digest:/ {
    sub(/^.*certificate SHA-256 digest:[[:space:]]*/, "")
    gsub(/[:[:space:]]/, "")
    print tolower($0)
  }
' | sort -u)
if [[ $actual_cert != "$expected_cert" ]]; then
  printf '%s\n' "$verification" >&2
  rm -f "$output_apk"
  echo 'La firma del APK no coincide con el certificado fijo de Plugger.' >&2
  exit 1
fi
