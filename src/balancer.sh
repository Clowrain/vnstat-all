#!/bin/bash

# 配置区
# 下载目标 (建议替换为国内大文件链接，如阿里云测速文件)
TARGET_URL="https://speed.cloudflare.com/__down?bytes=1000000000"
SAFE_RATIO=2

echo "启动流量平衡监控..."
sleep 10

while true; do
    # 1. 自动探测上网的主网卡 (去往 114 的路由)
    IFACE=$(ip route get 114.114.114.114 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
    if [ -z "$IFACE" ]; then IFACE="eno1"; fi # 兜底

    # 2. 获取该接口的今日流量
    # 使用 jq 筛选特定 name 的接口
    RX_BYTES=$(vnstat --json | jq -r --arg iface "$IFACE" '.interfaces[] | select(.name == $iface) | .traffic.day[-1].rx')
    TX_BYTES=$(vnstat --json | jq -r --arg iface "$IFACE" '.interfaces[] | select(.name == $iface) | .traffic.day[-1].tx')

    # 空值/null 处理
    [ -z "$RX_BYTES" ] || [ "$RX_BYTES" = "null" ] && RX_BYTES=0
    [ -z "$TX_BYTES" ] || [ "$TX_BYTES" = "null" ] && TX_BYTES=0

    # 换算单位
    RX_MB=$((RX_BYTES/1024/1024))
    TX_MB=$((TX_BYTES/1024/1024))

    echo "[$(date "+%H:%M")] 主网卡:$IFACE | 今日下载:${RX_MB}MB | 今日上传:${TX_MB}MB"

    # 3. 计算与判断
    TARGET_RX=$(awk -v tx="$TX_BYTES" -v ratio="$SAFE_RATIO" 'BEGIN {printf "%.0f", tx * ratio}')
    
    if [ "$RX_BYTES" -lt "$TARGET_RX" ]; then
        DIFF=$((TARGET_RX - RX_BYTES))
        DIFF_MB=$((DIFF/1024/1024))
        echo "⚠️  上传过高！需补充下载: ${DIFF_MB} MB"
        
        # 刷流量：限速 20MB/s，不写盘
        curl -o /dev/null -s --limit-rate 20M "$TARGET_URL"
        sleep 30
    else
        echo "✅ 状态安全. 休息 10 分钟..."
        sleep 600
    fi
done
