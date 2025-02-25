#!/bin/bash

# Iniciar PostgreSQL
su - postgres -c "pg_ctl -D /var/lib/postgresql/14/data -l /var/log/postgresql/postgresql.log start"

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