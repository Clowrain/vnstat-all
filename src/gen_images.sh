#!/bin/bash

OUT_DIR="/www"
echo "启动图片生成器..."
sleep 5

while true; do
    # ===【自动化核心】===
    # 问系统：去往 114.114.114.114 走的是哪个设备(dev)？
    # 这一行会自动提取出 eno1 或者 eth0
    IFACE=$(ip route get 114.114.114.114 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
    
    # 防止获取失败，兜底判断
    if [ -z "$IFACE" ]; then IFACE="eno1"; fi 
    # ===================

    if [ -n "$IFACE" ]; then
        # 强制指定接口 -i $IFACE
        vnstati -s -i "$IFACE" -o "$OUT_DIR/summary.png"
        vnstati -h -i "$IFACE" -o "$OUT_DIR/hourly.png"
        vnstati -d -i "$IFACE" -o "$OUT_DIR/daily.png"
        
        echo "[$(date "+%H:%M")] 图片已更新 (接口: $IFACE)"
    else
        echo "等待网络就绪..."
    fi

    sleep 300
done
