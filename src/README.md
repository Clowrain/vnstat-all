# NAS 流量监控与自动平衡工具 (NAS Traffic Monitor & Balancer)

这是一个轻量级的 NAS 网络流量监控与平衡解决方案。它结合了 `vnstat`、Python Web 服务和自动挂机脚本，旨在帮助 NAS 用户实时监控网络流量，并自动维护上传/下载比例（适用于 PCDN 或 PT 场景）。

## 功能特性

*   **📊 实时可视化仪表盘**: 基于 Web 的监控界面，使用 ECharts 展示 24 小时流量趋势和 30 天流量统计。
*   **🤖 智能接口识别**: 自动检测当前主要的上网网卡（基于 114.114.114.114 路由），无需手动配置接口名称。
*   **⚖️ 流量自动平衡 (`balancer.sh`)**: 
    *   自动监控上传与下载比例。
    *   当上传量过高（超过下载量的 2 倍，可配置）时，自动触发下载脚本。
    *   智能补量，从 Cloudflare 等高速节点下载数据以平衡比例，降低被运营商判定为异常流量的风险。
*   **🔌 RESTful API**: 提供 `/api/stats` 接口，直接返回 `vnstat` 的 JSON 数据，方便二次开发或集成到 Homepage/Dashy 等仪表盘。
*   **🖼️ 静态图表生成**: 自动生成 `vnstat` 的流量统计图（PNG格式），方便快速预览。

## 文件结构

*   `server.py`: Python 编写的轻量级 Web 服务器，提供静态页面服务和 API 接口。
*   `index.html`: 前端监控面板，自适应布局，支持移动端访问。
*   `balancer.sh`: 核心平衡脚本，监控流量比例并执行自动下载。
*   `gen_images.sh`: 辅助脚本，定时调用 `vnstati` 生成 PNG 流量图。
*   `Dockerfile`: (可选) 容器化部署配置。
*   `docker-compose.yml`: (可选) Docker Compose 编排文件。

## 快速开始

### 方式一：Docker 部署 (推荐)

本项目包含 `docker-compose.yml`，可以直接启动。

```bash
docker-compose up -d
```

启动后，访问浏览器 `http://<NAS_IP>:80` 即可查看监控面板。

### 方式二：手动运行

前提条件：
*   Linux 环境
*   已安装 `vnstat` 并配置好守护进程
*   Python 3
*   `jq`, `curl` (用于脚本)

1.  **启动 Web 服务**
    ```bash
    # 默认监听 80 端口
    sudo python3 server.py
    ```

2.  **启动流量平衡脚本** (建议放入后台或 screen)
    ```bash
    sudo ./balancer.sh
    ```

3.  **启动图表生成脚本** (可选)
    ```bash
    sudo ./gen_images.sh
    ```

## 配置说明

### 端口配置
在 `server.py` 或环境变量中修改监听端口：
- `HTTP_PORT`: 默认为 `80`。

### 平衡脚本配置 (`balancer.sh`)
您可以修改脚本顶部的配置区：
- `TARGET_URL`: 用于刷下载流量的文件地址（建议使用 Cloudflare 或阿里云等不计费或高速的测速连接）。
- `SAFE_RATIO`: 安全比例阈值。默认为 `2`，即当 **上传量 > 下载量 * 2** 时触发补量下载。

## API 文档

**获取流量统计**
- **URL**: `/api/stats`
- **Method**: `GET`
- **Response**: 返回 `vnstat --json` 的完整原始数据。

## 注意事项

*   本工具依赖宿主机的 `vnstat` 数据库。在 Docker 模式下，请确保正确挂载了 `/var/lib/vnstat` 目录。
*   流量平衡脚本会产生真实的网络下载流量，请根据自身宽带情况谨慎调整 `SAFE_RATIO` 和 `TARGET_URL`。

## License

MIT
