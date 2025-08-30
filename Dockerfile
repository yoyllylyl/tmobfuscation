FROM alpine:latest

# Установка необходимых пакетов
RUN apk add --no-cache ca-certificates wget unzip curl

# Скачивание и установка Xray
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip && \
    mv xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf Xray-linux-64.zip

# Создание директории для конфигурации
RUN mkdir -p /etc/xray

# Копирование конфигурации
COPY config.json /etc/xray/config.json

# Создание пользователя
RUN adduser -D -s /bin/sh xray

# Переключение на пользователя xray
USER xray

# Открытие порта (Cloud Run автоматически проксирует 443 на этот порт)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Запуск Xray
CMD ["/usr/local/bin/xray", "-config", "/etc/xray/config.json"]
