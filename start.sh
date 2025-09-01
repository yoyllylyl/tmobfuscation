#!/bin/sh

PORT=${PORT:-443}
echo "Starting server on port: $PORT"

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

# Запуск Xray в фоне
/usr/local/bin/xray -config /tmp/config.json &
XRAY_PID=$!

# Ожидание запуска
sleep 5

# Проверка что Xray запустился
if kill -0 $XRAY_PID 2>/dev/null; then
    echo "Xray started successfully on port $PORT"
    wait $XRAY_PID
else
    echo "Failed to start Xray"
    exit 1
fi
