#!/bin/sh

PORT=${PORT:-443}
echo "Starting server on port: $PORT"
echo "Environment variables:"
printenv | grep PORT
echo "Testing port binding..."

cat > /tmp/config.json << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "ee2d677b-ddc4-494a-8db5-7a751332ac19",
            "flow": ""
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 8081
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/Google",
          "headers": {
            "Host": "translate.google.cat"
          }
        },
        "security": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    },
    {
      "port": 8081,
      "protocol": "http",
      "settings": {
        "timeout": 0,
        "accounts": []
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF

# Показать созданный конфиг
echo "Generated config:"
cat /tmp/config.json

# Проверить что xray работает
echo "Checking xray binary:"
/usr/local/bin/xray version

# Тест конфига
echo "Testing config:"
/usr/local/bin/xray test -config /tmp/config.json

# Запуск простого HTTP сервера для health check в фоне
echo "Starting health check server on port 8081..."
cat > /tmp/health_server.py << 'HEALTH_EOF'
import http.server
import socketserver
import threading

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'OK')
    
    def log_message(self, format, *args):
        pass

def start_server():
    with socketserver.TCPServer(("", 8081), HealthHandler) as httpd:
        httpd.serve_forever()

if __name__ == "__main__":
    start_server()
HEALTH_EOF

python3 /tmp/health_server.py &

# Запуск Xray
echo "Starting Xray..."
exec /usr/local/bin/xray run -config /tmp/config.json
