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

# Показать созданный конфиг
echo "Generated config:"
cat /tmp/config.json

# Проверить что xray работает
echo "Checking xray binary:"
/usr/local/bin/xray version

# Тест конфига
echo "Testing config:"
/usr/local/bin/xray test -config /tmp/config.json

# Запуск Xray
echo "Starting Xray..."
exec /usr/local/bin/xray run -config /tmp/config.json
