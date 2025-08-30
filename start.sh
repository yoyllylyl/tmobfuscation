#!/bin/sh

# Получаем порт из переменной окружения, по умолчанию 8080
PORT=${PORT:-8080}

echo "=== Xray Container Starting ==="
echo "PORT environment variable: $PORT"
echo "User: $(whoami)"
echo "Working directory: $(pwd)"
echo "Files in /etc/xray:"
ls -la /etc/xray/

# Создаем временный конфиг с правильным портом
cat > /tmp/config.json << EOF
{
  "log": {
    "loglevel": "info"
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
        "decryption": "none"
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
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    }
  ]
}
EOF

echo "=== Generated config ==="
cat /tmp/config.json

echo "=== Starting Xray ==="
exec /usr/local/bin/xray -config /tmp/config.json
