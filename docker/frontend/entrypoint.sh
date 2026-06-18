#!/bin/sh
set -e

HTML_DIR="/usr/share/nginx/html"
INDEX_FILE="${HTML_DIR}/index.html"
API_URL="${API_URL:-/api/v1}"
API_BASE_URL="${API_BASE_URL:-http://backend:18002}"

cp /etc/nginx/conf.d/default.conf.template /etc/nginx/conf.d/default.conf
sed -i "s|__API_BASE_URL__|${API_BASE_URL}|g" /etc/nginx/conf.d/default.conf

if [ -f "$INDEX_FILE" ]; then
    CONFIG_SCRIPT="<script>window._VBEN_ADMIN_PRO_APP_CONF_ = { VITE_GLOB_API_URL: '${API_URL}' };</script>"
    sed -i "s|</head>|${CONFIG_SCRIPT}</head>|" "$INDEX_FILE"
fi

echo "Frontend starting with API_URL=${API_URL}"
echo "API proxy to ${API_BASE_URL}"

exec "$@"
