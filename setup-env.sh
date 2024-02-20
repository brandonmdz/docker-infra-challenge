#!/bin/bash

# Function to print status messages
print_status() {
  echo "[OK] ${1} ${2}";
}

# Function to print error messages
print_error() {
  echo "[ERROR] ${1} ${2}";
}

# Function to check file existence and create from template if necessary
check_and_create_file() {
  local file="$1"
  local template="$2"
  local message="$3"
  if [ ! -f "$file" ]; then
    cp "$template" "$file"
    print_status "$file" "was created successfully."
  else
    print_status "$file" "exists."
  fi
}

# 1. Check .env and composer.env files
check_and_create_file ".env" ".env.dist" ".env file"
check_and_create_file "composer.env" "composer.env.sample" "composer.env file"

# Check Composer secret key in composer.env
COMPOSER_SECRET=$(grep -oP 'COMPOSER_SECRET_KEY=\K.+' "composer.env")
if [ -z "$COMPOSER_SECRET" ]; then
  print_error "Composer secret key" "are empty or incorrect. Please fulfill these values in composer.env."
fi

# 2. Generate nginx certificates
SSL_CERT_DIR="docker/nginx/etc/certs"
mkdir -p ${SSL_CERT_DIR}
CERT_FILE="${SSL_CERT_DIR}/magento.crt"
KEY_FILE="${SSL_CERT_DIR}/magento.key"

# Check if certificates already exist
if [ -f "$CERT_FILE" ] || [ -f "$KEY_FILE" ]; then
    echo "Certificates already exist. Do you want to replace them? (yes/no)"
    read REPLACE_CERTS
    if [ "$REPLACE_CERTS" = "yes" ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CERT_FILE" -subj "/CN=docker.infra.challenge/O=Magento Dev/C=US"
        print_status "Nginx certificates" "were replaced successfully at ${SSL_CERT_DIR}."
    else
        print_status "Nginx certificates" "were not replaced."
    fi
else
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CERT_FILE" -subj "/CN=docker.infra.challenge/O=Magento Dev/C=US"
    print_status "Nginx certificates" "were generated successfully at ${SSL_CERT_DIR}."
fi

# 3. Update UID and GID in Dockerfiles
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
sed -i -e 's/RUN groupadd -g 1000 magento/RUN groupadd -g '"$CURRENT_GID"' magento/g' \
       -e 's/-u 1000 -g 1000 magento/-u '"$CURRENT_UID"' -g '"$CURRENT_GID"' magento/g' \
       ./docker/php-fpm/Dockerfile ./docker/php-cli/Dockerfile
print_status "UID=${CURRENT_UID}, GID=${CURRENT_GID}" "have been updated for php-fpm and php-cli."

# 4. Create Magento folder
mkdir -p magento
print_status "Magento folder" "has been created successfully."
