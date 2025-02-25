#!/bin/bash

# Criar diretórios para logs
mkdir -p /var/log/postgresql /var/log/redis /var/log/evolution

# Iniciar PostgreSQL
su - postgres -c "pg_ctl -D /var/lib/postgresql/data -l /var/log/postgresql/postgresql.log start"

# Aguardar o PostgreSQL iniciar
sleep 5

# Criar banco de dados evolution se não existir
su - postgres -c "psql -c \"CREATE DATABASE evolution;\" || true"
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'Anapolis21';\" || true"

# Iniciar Redis
redis-server --daemonize yes

# Iniciar a Evolution API
cd /app/evolution-api
node dist/server.js