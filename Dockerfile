FROM alpine:latest

# Установка необходимых пакетов
RUN apk add --no-cache ca-certificates wget unzip

# Скачивание и установка Xray
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip && \
    mv xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf Xray-linux-64.zip

# Копирование стартового скрипта
COPY start.sh /usr/local/bin/start.sh

# Делаем скрипт исполняемым
RUN chmod +x /usr/local/bin/start.sh

# Создание пользователя (но оставляем root для отладки)
# RUN adduser -D -s /bin/sh xray
# USER xray

# Открытие порта
EXPOSE 443

# Запуск через стартовый скрипт
CMD ["/usr/local/bin/start.sh"]
