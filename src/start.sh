#!/bin/bash

# 获取端口环境变量
export HTTP_PORT=${HTTP_PORT:-80}
echo ">>> 正在启动 API 服务器端口: $HTTP_PORT"

# 从模板复制配置文件 (避免挂载时的文件锁定问题)
cp /etc/supervisord.conf.tpl /etc/supervisord.conf

echo ">>> 启动所有服务..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
