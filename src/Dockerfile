FROM alpine:latest

# 安装依赖
# python3: 运行 Web/API 服务
# vnstat: 流量统计核心
# supervisor: 进程管理
# curl/jq: 流量平衡脚本需要
RUN apk add --no-cache \
    vnstat \
    supervisor \
    curl jq bash tzdata \
    python3

ENV TZ=Asia/Shanghai

# 准备目录
RUN mkdir -p /www /var/lib/vnstat && \
    chmod -R 777 /var/lib/vnstat

# 复制文件
COPY supervisord.conf /etc/supervisord.conf.tpl
COPY index.html /www/index.html
COPY balancer.sh /balancer.sh
COPY server.py /server.py
COPY start.sh /start.sh

# 赋予执行权限
RUN chmod +x /balancer.sh /start.sh

# 启动命令
CMD ["/start.sh"]
