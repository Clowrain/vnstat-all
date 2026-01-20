import http.server
import socketserver
import subprocess
import json
import os

# 获取端口，默认为 80
PORT = int(os.environ.get('HTTP_PORT', 80))
WEB_DIR = "/www"

class VnStatHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # API 接口：返回 vnstat 的 JSON 数据
        if self.path == '/api/stats':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            try:
                # 调用系统命令获取数据
                result = subprocess.check_output(['vnstat', '--json'], text=True)
                self.wfile.write(result.encode('utf-8'))
            except Exception as e:
                error_msg = json.dumps({"error": str(e)})
                self.wfile.write(error_msg.encode('utf-8'))
        # 普通请求：返回 HTML/JS/CSS
        else:
            super().do_GET()

# 切换到网页目录
os.chdir(WEB_DIR)

print(f"Starting API/Web Server on port {PORT}...")
# 允许地址复用，防止重启时端口被占
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", PORT), VnStatHandler) as httpd:
    httpd.serve_forever()
