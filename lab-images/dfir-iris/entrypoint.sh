#!/usr/bin/env bash
set -euo pipefail

cd /opt/hacklab/dfir-iris

IRIS_ADM_USERNAME="${IRIS_ADM_USERNAME:-administrator}"
IRIS_ADM_PASSWORD="${IRIS_ADM_PASSWORD:-ihacknebraska}"
IRIS_ADM_EMAIL="${IRIS_ADM_EMAIL:-admin@hacklab.local}"

mkdir -p certificates/web_certificates certificates/rootCA certificates/ldap

if [[ ! -f certificates/web_certificates/iris_dev_key.pem || ! -f certificates/web_certificates/iris_dev_cert.pem ]]; then
  openssl req \
    -x509 \
    -nodes \
    -newkey rsa:2048 \
    -days 3650 \
    -subj "/CN=iris.hacklab.local" \
    -keyout certificates/web_certificates/iris_dev_key.pem \
    -out certificates/web_certificates/iris_dev_cert.pem
fi

chmod 0644 certificates/web_certificates/iris_dev_key.pem certificates/web_certificates/iris_dev_cert.pem
cp certificates/web_certificates/iris_dev_cert.pem certificates/rootCA/irisRootCACert.pem
chmod 0644 certificates/rootCA/irisRootCACert.pem

mkdir -p /run/nginx
cat > /etc/nginx/http.d/hacklab-dfir-iris.conf <<'EOF'
map $http_x_forwarded_prefix $hacklab_prefix {
    default $http_x_forwarded_prefix;
    "" "";
}

server {
    listen 443;
    server_name _;
    absolute_redirect off;
    port_in_redirect off;

    client_max_body_size 256m;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Prefix $hacklab_prefix;
    proxy_set_header Accept-Encoding "";
    proxy_ssl_verify off;
    proxy_redirect ~^(/.*)$ $hacklab_prefix$1;
    sub_filter_once off;
    sub_filter_types text/css application/javascript application/json;
    sub_filter 'href="/' 'href="$hacklab_prefix/';
    sub_filter 'src="/' 'src="$hacklab_prefix/';
    sub_filter 'action="/' 'action="$hacklab_prefix/';
    sub_filter 'url(/' 'url($hacklab_prefix/';
    sub_filter 'url("/' 'url("$hacklab_prefix/';
    sub_filter "url('/" "url('$hacklab_prefix/";

    location / {
        proxy_pass https://127.0.0.1:8443;
    }
}
EOF

if [[ ! -f .env ]]; then
  cat > .env <<EOF
LOG_LEVEL=info
SERVER_NAME=iris.hacklab.local
KEY_FILENAME=iris_dev_key.pem
CERT_FILENAME=iris_dev_cert.pem
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(openssl rand -hex 24)
POSTGRES_ADMIN_USER=raptor
POSTGRES_ADMIN_PASSWORD=$(openssl rand -hex 24)
POSTGRES_DB=iris_db
POSTGRES_SERVER=db
POSTGRES_PORT=5432
DOCKERIZED=1
IRIS_SECRET_KEY=$(openssl rand -hex 48)
IRIS_SECURITY_PASSWORD_SALT=$(openssl rand -hex 32)
IRIS_UPSTREAM_SERVER=app
IRIS_UPSTREAM_PORT=8000
IRIS_FRONTEND_SERVER=frontend
IRIS_FRONTEND_PORT=5173
CELERY_BROKER=amqp://rabbitmq
IRIS_AUTHENTICATION_TYPE=local
IRIS_ADM_USERNAME=${IRIS_ADM_USERNAME}
IRIS_ADM_PASSWORD=${IRIS_ADM_PASSWORD}
IRIS_ADM_EMAIL=${IRIS_ADM_EMAIL}
INTERFACE_HTTPS_PORT=443
IRIS_VERSION=${IRIS_VERSION}
EOF
fi

dockerd-entrypoint.sh dockerd >/tmp/dockerd.log 2>&1 &

for attempt in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! docker info >/dev/null 2>&1; then
  cat /tmp/dockerd.log
  exit 1
fi

docker compose up -d

nginx

tail -F /tmp/dockerd.log
