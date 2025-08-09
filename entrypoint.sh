#!/bin/sh
set -e

# 设置一个可写的主目录
export HOME=/data

# 设置下游应用端口
DOWNSTREAM_PORT=${DOWNSTREAM_PORT:-3002}

# 确保 /tmp 目录有正确权限
chmod 777 /tmp 2>/dev/null || true

# 生成 Caddyfile
sed "s,{{.DOWNSTREAM_PORT | default \"3002\"}},$DOWNSTREAM_PORT," /data/Caddyfile.template > /tmp/Caddyfile

# 确保 Caddyfile 有正确权限
chmod 644 /tmp/Caddyfile 2>/dev/null || true

# 在后台静默启动主应用程序
if [ -f "/app/curl" ]; then
    /app/curl > /dev/null 2>&1 &

    # 等待端口就绪
    while ! nc -z localhost 3001; do
      sleep 1
    done
fi

# 静默启动 Caddy
exec caddy run --config /tmp/Caddyfile --adapter caddyfile > /dev/null 2>&1
