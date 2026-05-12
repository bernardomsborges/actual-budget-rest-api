# Guia de Deploy na Porta 3010

Este documento descreve como configurar e fazer o deploy da API Actual Budget REST na porta 3010.

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Variáveis de ambiente configuradas
- Acesso ao servidor Actual Budget
- Conectividade de rede

## 🚀 Opções de Deploy

### Opção 1: SQLite (Recomendado para Começar)

Para uma configuração mais leve sem dependências externas:

```bash
docker-compose -f docker-compose.prod.sqlite.yml up -d
```

**Arquivo**: `docker-compose.prod.sqlite.yml`
- ✅ Sem dependência de banco de dados externo
- ✅ Mais rápido de iniciar
- ✅ Ideal para desenvolvimento/teste
- ⚠️ Melhor performance com Redis para caching

### Opção 2: PostgreSQL (Recomendado para Produção)

Para uma configuração robusta com banco de dados dedicado:

```bash
docker-compose -f docker-compose.prod.postgres.yml up -d
```

**Arquivo**: `docker-compose.prod.postgres.yml`
- ✅ Melhor escalabilidade
- ✅ Dados persistentes e backup
- ✅ Melhor para múltiplas instâncias
- ⚠️ Requer configuração PostgreSQL

## ⚙️ Configuração Necessária

### 1. Preparar Variáveis de Ambiente

Crie um arquivo `.env` baseado em `.env.example`:

```bash
cp .env.example .env
```

Edite o `.env` com seus valores:

```env
# Segurança
NODE_ENV=production
PORT=3010
ADMIN_USER=seu_usuario
ADMIN_PASSWORD=sua_senha_segura
JWT_SECRET=sua_chave_secreta_minimo_32_caracteres
JWT_REFRESH_SECRET=sua_chave_refresh_minimo_32_caracteres
SESSION_SECRET=sua_sessao_secreta_minimo_32_caracteres

# Actual Budget
ACTUAL_SERVER_URL=https://seu-servidor-actual.com
ACTUAL_PASSWORD=sua_senha_actual
ACTUAL_SYNC_ID=seu_sync_id

# Opcional: Redis
REDIS_PASSWORD=sua_senha_redis_opcional

# Apenas PostgreSQL
POSTGRES_PASSWORD=sua_senha_postgres
```

### 2. Criar Diretórios de Dados

```bash
mkdir -p data/prod/actual-api
mkdir -p data/prod/redis
mkdir -p data/prod/postgres  # Apenas para PostgreSQL
chmod 755 data/prod/*
```

### 3. Validar Variáveis de Ambiente

Antes de fazer deploy:

```bash
# Verificar se todas as variáveis obrigatórias estão definidas
grep -E "^\w+=" .env | wc -l

# Verificar comprimento das chaves de segurança
echo "JWT_SECRET length: ${#JWT_SECRET}"
echo "SESSION_SECRET length: ${#SESSION_SECRET}"
```

## 🔧 Comandos Utilizados

### Iniciar o Deploy

```bash
# SQLite
docker-compose -f docker-compose.prod.sqlite.yml --env-file .env up -d

# PostgreSQL
docker-compose -f docker-compose.prod.postgres.yml --env-file .env up -d
```

### Monitorar Logs

```bash
# SQLite
docker-compose -f docker-compose.prod.sqlite.yml logs -f

# PostgreSQL
docker-compose -f docker-compose.prod.postgres.yml logs -f

# Apenas API
docker-compose -f docker-compose.prod.sqlite.yml logs -f actual-rest-api
```

### Verificar Status

```bash
# SQLite
docker-compose -f docker-compose.prod.sqlite.yml ps

# PostgreSQL
docker-compose -f docker-compose.prod.postgres.yml ps

# Health check de manual
curl http://localhost:3010/v2/health
```

### Parar o Deploy

```bash
# SQLite
docker-compose -f docker-compose.prod.sqlite.yml down

# PostgreSQL
docker-compose -f docker-compose.prod.postgres.yml down

# Com volume cleanup
docker-compose -f docker-compose.prod.sqlite.yml down -v
```

### Atualizar para Nova Versão

```bash
# SQLite
docker-compose -f docker-compose.prod.sqlite.yml down
docker-compose -f docker-compose.prod.sqlite.yml pull
docker-compose -f docker-compose.prod.sqlite.yml up -d

# PostgreSQL
docker-compose -f docker-compose.prod.postgres.yml down
docker-compose -f docker-compose.prod.postgres.yml pull
docker-compose -f docker-compose.prod.postgres.yml up -d
```

## 🔍 Verificações de Saúde

### Health Check Endpoint

```bash
curl -v http://localhost:3010/v2/health
```

Resposta esperada (200 OK):
```json
{
  "status": "ok",
  "timestamp": "2024-05-12T10:30:00Z"
}
```

### Logs da Aplicação

```bash
# Verificar erros de inicialização
docker-compose -f docker-compose.prod.sqlite.yml logs actual-rest-api | grep -i error

# Ver variáveis de ambiente lidas
docker-compose -f docker-compose.prod.sqlite.yml logs actual-rest-api | grep -i "configuration\|config"
```

## 🔐 Segurança

### Variáveis de Segurança Importantes

1. **Secrets (32+ caracteres em produção)**
   - `JWT_SECRET`
   - `JWT_REFRESH_SECRET`
   - `SESSION_SECRET`

2. **Redis Password**
   - Sempre defina `REDIS_PASSWORD` em produção

3. **PostgreSQL Password**
   - Use `POSTGRES_PASSWORD` forte em produção

4. **Volumes de Dados**
   - Proteja `data/prod/` com permissões corretas (755)
   - Faça backup regular

### Network Security

Se usar Traefik:

```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.actual-api-web.middlewares=redirect-to-https@file
```

## 📊 Monitoramento e Logging

### Logs Estruturados

```bash
# Seguir logs em real-time
docker-compose -f docker-compose.prod.sqlite.yml logs -f --tail=100

# Com timestamp
docker-compose -f docker-compose.prod.sqlite.yml logs -f --timestamps

# Apenas últimas 50 linhas
docker-compose -f docker-compose.prod.sqlite.yml logs --tail=50
```

### Verificar Uso de Recursos

```bash
docker stats
```

## 🐛 Troubleshooting

### API não está respondendo

1. Verificar se containers estão rodando:
   ```bash
   docker-compose -f docker-compose.prod.sqlite.yml ps
   ```

2. Verificar logs de erro:
   ```bash
   docker-compose -f docker-compose.prod.sqlite.yml logs actual-rest-api
   ```

3. Validar variáveis de ambiente:
   ```bash
   docker-compose -f docker-compose.prod.sqlite.yml config | grep -A 20 "environment:"
   ```

### Redis falha ao conectar

```bash
# Verificar se Redis está rodando
docker-compose -f docker-compose.prod.sqlite.yml logs actual-rest-api-redis

# Testar conexão com Redis
docker exec actual-rest-api-redis redis-cli ping
```

### PostgreSQL falha ao iniciar

```bash
# Verificar se PostgreSQL está rodando
docker-compose -f docker-compose.prod.postgres.yml logs actual-rest-api-postgres

# Testar conexão
docker exec actual-rest-api-postgres pg_isready -U postgres
```

## 📝 Notas Importantes

- ✅ A porta 3010 está configurada em ambos os arquivos
- ✅ Redis é obrigatório em ambas as configurações
- ✅ Traefik labels estão configurados para proxy reverso
- ✅ Health checks estão configurados para monitoramento automático
- ⚠️ Always use strong passwords in production
- ⚠️ Backup seus dados regularmente
- ⚠️ Mantenha as imagens Docker atualizadas

## 🔗 Recursos

- [Documentação Actual Budget](https://actualbudget.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Traefik Documentation](https://doc.traefik.io/)
