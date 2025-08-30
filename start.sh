#!/bin/sh

# Получаем порт из переменной окружения, по умолчанию 8080
PORT=${PORT:-8080}

# Заменяем порт в конфигурации
sed -i "s/\"env:PORT\"/$PORT/g" /etc/xray/config.json

# Выводим информацию для отладки
echo "Starting Xray on port: $PORT"
echo "Config file:"
cat /etc/xray/config.json

# Запускаем Xray
exec /usr/local/bin/xray -config /etc/xray/config.json
