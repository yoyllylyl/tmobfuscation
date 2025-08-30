FROM alpine:latest

# Установка необходимых пакетов
RUN apk add --no-cache ca-certificates wget unzip

# Скачивание и установка Xray
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip && \
    mv xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf Xray-linux-64.zip

# Создание директории для конфигурации
RUN mkdir -p /etc/xray

# Копирование конфигурации и стартового скрипта
COPY config.json /etc/xray/config.json
COPY start.sh /usr/local/bin/start.sh

# Делаем скрипт исполняемым
RUN chmod +x /usr/local/bin/start.sh

# Создание пользователя
RUN adduser -D -s /bin/sh xray

# Переключение на пользователя xray
USER xray

# Открытие порта
EXPOSE 8080

# Запуск через стартовый скрипт
CMD ["/usr/local/bin/start.sh"]
