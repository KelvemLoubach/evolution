# Usar imagem Alpine para o servidor principal
FROM alpine:latest

# Instalar pacotes necessários
RUN apk add --no-cache \
    redis \
    postgresql \
    postgresql-contrib \
    supervisor \
    nodejs \
    npm \
    curl \
    bash

# Diretórios de trabalho
WORKDIR /app

# Baixar e configurar a Evolution API
RUN mkdir -p /app/evolution /data /var/lib/postgresql/data

# Inicializar banco de dados PostgreSQL
RUN mkdir -p /run/postgresql && chown -R postgres:postgres /run/postgresql && \
    mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql/data

USER postgres
RUN initdb -D /var/lib/postgresql/data
RUN echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf && \
    echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf
USER root

# Extrair e configurar a Evolution API
RUN curl -L https://github.com/EvolutionAPI/evolution-api/archive/refs/tags/v2.1.1.tar.gz -o evolution.tar.gz && \
    tar -xzf evolution.tar.gz -C /app && \
    mv /app/evolution-api-* /app/evolution-api && \
    cd /app/evolution-api && \
    npm install && \
    npm run build

# Copiar configuração do supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Variáveis de ambiente para a Evolution API
ENV SERVER_URL=http://localhost:8080
ENV AUTHENTICATION_TYPE=apikey
ENV AUTHENTICATION_API_KEY=KFZOm3Hc3GSNWwHBywEm67xYgjN8xGTH
ENV AUTHENTICATION_EXPOSE_IN_FETCH_INSTANCES=true
ENV LANGUAGE=pt-BR
ENV CONFIG_SESSION_PHONE_CLIENT=InovaBoost
ENV CONFIG_SESSION_PHONE_NAME=chrome
ENV CONFIG_SESSION_PHONE_VERSION=2.3000.1015901307
ENV WA_BUSINESS_TOKEN_WEBHOOK=evolution
ENV WA_BUSINESS_URL=https://graph.facebook.com
ENV WA_BUSINESS_VERSION=v20.0
ENV WA_BUSINESS_LANGUAGE=pt_BR
ENV QRCODE_LIMIT=1902
ENV QRCODE_COLOR=#000000
ENV DATABASE_ENABLED=true
ENV DATABASE_PROVIDER=postgresql
ENV DATABASE_CONNECTION_URI=postgresql://postgres:Anapolis21@localhost:5432/evolution
ENV DATABASE_CONNECTION_CLIENT_NAME=evolution
ENV DATABASE_SAVE_DATA_INSTANCE=true
ENV DATABASE_SAVE_DATA_NEW_MESSAGE=true
ENV DATABASE_SAVE_MESSAGE_UPDATE=true
ENV DATABASE_SAVE_DATA_CONTACTS=true
ENV DATABASE_SAVE_DATA_CHATS=true
ENV OPENAI_ENABLED=false
ENV DIFY_ENABLED=false
ENV S3_ENABLED=false
ENV CACHE_REDIS_ENABLED=true
ENV CACHE_REDIS_URI=redis://localhost:6379/2
ENV CACHE_REDIS_PREFIX_KEY=evolution
ENV CACHE_REDIS_SAVE_INSTANCES=false
ENV CACHE_LOCAL_ENABLED=false
ENV DEL_INSTANCE=2
ENV DEL_TEMP_INSTANCES=false
ENV TYPEBOT_ENABLED=true
ENV TYPEBOT_API_VERSION=latest
ENV CHATWOOT_ENABLED=false
ENV CHATWOOT_MESSAGE_READ=true
ENV CHATWOOT_MESSAGE_DELETE=true
ENV RABBITMQ_ENABLED=false
ENV WEBHOOK_GLOBAL_ENABLED=false

# Configurar script de inicialização
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Criar diretórios para logs
RUN mkdir -p /var/log/supervisor /var/log/postgresql /var/log/redis

# Expor portas
EXPOSE 8080 5432 6379 5433

# Comando para iniciar todos os serviços
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]