# Multi-stage build for a comprehensive service including Redis, PostgreSQL, pgAdmin, and Evolution API

# Start with Redis stage
FROM redis:latest as redis
# Redis configuration
EXPOSE 6379
CMD ["redis-server", "--appendonly", "yes", "--port", "6379"]

# PostgreSQL stage
FROM postgres:14.13 as postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=Anapolis21
EXPOSE 5432

# pgAdmin stage
FROM dpage/pgadmin4:latest as pgadmin
ENV PGADMIN_DEFAULT_EMAIL=kelvem21@gmail.com
ENV PGADMIN_DEFAULT_PASSWORD=Anapolis21
EXPOSE 80

# Main Evolution API stage
FROM atendai/evolution-api:v2.1.1-homolog

# Copy necessary files
WORKDIR /evolution

# Volume directories
RUN mkdir -p /evolution/instances /data /var/lib/postgresql/data

# Set environment variables
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

# Install necessary packages
RUN apt-get update && apt-get install -y \
    postgresql \
    postgresql-contrib \
    redis-server \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 8080 5432 6379 5433

# Command to run supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]