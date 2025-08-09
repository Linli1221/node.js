#!/bin/sh
set -e

# 设置一个可写的主目录
export HOME=/data

# 生成 Caddyfile (运行在用户模式下)
cp /data/Caddyfile.template /tmp/Caddyfile
# 在后台启动主应用程序并显示日志
if [ -f "/app/curl" ]; then
    echo "Starting one-api service (curl)..."
    /app/curl &

    # 等待端口就绪
    echo "Waiting for one-api service to start on port 3001..."
    while ! nc -z localhost 3001; do
      sleep 1
    done
    echo "one-api service is ready on port 3001"
fi

# 启动 Caddy 并显示日志
echo "Starting Caddy reverse proxy..."
echo "Caddy configuration:"
cat /tmp/Caddyfile
echo "================================"
exec caddy run --config /tmp/Caddyfile --adapter caddyfile
