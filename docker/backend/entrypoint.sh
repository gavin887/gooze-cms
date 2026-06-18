#!/bin/sh
set -e

CONFIG_FILE="/app/configs/admin.yaml"

set_yaml_string() {
    local path="$1"
    local value="$2"
    if [ -n "$value" ]; then
        yq -i "$path = \"$value\"" "$CONFIG_FILE"
    fi
}

set_yaml_number() {
    local path="$1"
    local value="$2"
    if [ -n "$value" ]; then
        yq -i "$path = $value" "$CONFIG_FILE"
    fi
}

set_yaml_string '.app.name' "$APP_NAME"
set_yaml_string '.app.env' "$APP_ENV"
set_yaml_string '.app.addr' "$APP_ADDR"
set_yaml_number '.app.timeout' "$APP_TIMEOUT"
set_yaml_string '.app.routerPrefix' "$APP_ROUTER_PREFIX"

set_yaml_string '.databases[0].driver' "$DB_DRIVER"
set_yaml_string '.databases[0].dsn' "$DB_DSN"
set_yaml_number '.databases[0].maxIdleConn' "$DB_MAX_IDLE_CONN"
set_yaml_number '.databases[0].maxConn' "$DB_MAX_CONN"
set_yaml_number '.databases[0].logLevel' "$DB_LOG_LEVEL"

set_yaml_string '.redis.addr' "$REDIS_ADDR"
set_yaml_string '.redis.password' "$REDIS_PASSWORD"
set_yaml_number '.redis.db' "$REDIS_DB"

set_yaml_string '.jwt.secretKey' "$JWT_SECRET_KEY"
set_yaml_number '.jwt.expire' "$JWT_EXPIRE"

set_yaml_string '.oss.type' "$OSS_TYPE"
set_yaml_string '.oss.url' "$OSS_URL"
set_yaml_string '.oss.accessKey' "$OSS_ACCESS_KEY"
set_yaml_string '.oss.secretKey' "$OSS_SECRET_KEY"
set_yaml_string '.oss.bucketName' "$OSS_BUCKET_NAME"

set_yaml_string '.log.path' "$LOG_PATH"
set_yaml_string '.log.mode' "$LOG_MODE"

echo "Starting Gooze Admin API..."
exec /app/admin --config="/app/configs/admin.yaml" --show=false
