# Deploy da Actual Budget REST API no Dokploy

Guia passo a passo para fazer deployment da aplicação no Dokploy com suporte a SQLite ou PostgreSQL.

## 📋 Pré-requisitos

- Conta/Instância Dokploy ativa
- Repositório GitHub conectado ao Dokploy
- Domínio configurado (ex: `api-budget.fluxzone.com.br`)
- Traefik configurado no Dokploy

## 🔧 Configuração no Dokploy

### Passo 1: Adicionar Novo Projeto

1. Acesse seu painel Dokploy
2. Clique em **"Projects"** → **"New Project"**
3. Preencha:
   - **Project Name**: `actual-budget-api`
   - **Description**: `Actual Budget REST API`

### Passo 2: Criar Novo Serviço (Service)

No projeto criado:

1. Clique em **"Services"** → **"New Service"**
2. Escolha: **"Docker Compose"**
3. Configure:
   - **Service Name**: `actual-rest-api` (ou outro nome de sua preferência)
   - **Branch**: `main` (ou sua branch)

### Passo 3: Selecionar Arquivo Docker Compose

No painel do serviço:

1. **Compose File Path**: 
   - Para SQLite: `docker-compose.prod.sqlite.yml`
   - Para PostgreSQL: `docker-compose.prod.postgres.yml`

2. Clique em **"Load Compose File"** ou similar (variar conforme versão)

### Passo 4: Configurar Variáveis de Ambiente

No Dokploy, vá para a seção **"Environment Variables"** e adicione:

```env
# ============= Server ============
NODE_ENV=production
PORT=3010
TRUST_PROXY=true

# ============= Security ============
ADMIN_USER=<seu_usuario>
ADMIN_PASSWORD=<sua_senha_forte>
JWT_SECRET=<gerar_32_caracteres_aleatorios>
JWT_REFRESH_SECRET=<gerar_32_caracteres_aleatorios>
SESSION_SECRET=<gerar_32_caracteres_aleatorios>

JWT_ACCESS_TTL=1h
JWT_REFRESH_TTL=24h

# ============= Actual Budget ============
ACTUAL_SERVER_URL=https://seu-servidor-actual.com
ACTUAL_PASSWORD=<sua_senha_actual>
ACTUAL_SYNC_ID=<seu_sync_id>

# ============= Networking ============
ALLOWED_ORIGINS=https://api-budget.fluxzone.com.br,https://seu-frontend.com

# ============= Logging ============
LOG_LEVEL=info

# ============= Redis ============
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=<gerar_senha_redis_forte>

# ======= PostgreSQL (apenas se usar postgres.yml) =========
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=actual_rest_api
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<gerar_senha_postgres_forte>

# ============= Database ============
DB_TYPE=sqlite  # ou postgres
```

### Passo 5: Configurar Traefik/Proxy (Se Necessário)

Se os labels Traefik não forem aplicados automaticamente:

1. Vá para **"Network"** ou **"Bindings"**
2. Configure:
   - **Domain**: `api-budget.fluxzone.com.br`
   - **Port**: `3010`
   - **Protocol**: `HTTPS` (com SSL automático se disponível)

Ou adicione as labels manualmente no painel de **Advanced Settings**:

```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.actual-rest-api-web.rule=Host(`api-budget.fluxzone.com.br`)
  - traefik.http.routers.actual-rest-api-web.entrypoints=web
  - traefik.http.routers.actual-rest-api-web.middlewares=redirect-to-https@file
  - traefik.http.routers.actual-rest-api-websecure.rule=Host(`api-budget.fluxzone.com.br`)
  - traefik.http.routers.actual-rest-api-websecure.entrypoints=websecure
  - traefik.http.routers.actual-rest-api-websecure.tls.certresolver=letsencrypt
  - traefik.http.services.actual-rest-api.loadbalancer.server.port=3010
```

### Passo 6: Volumes/Persistência

Configure os volumes para dados persistentes:

1. Vá para **"Volumes"** ou **"Storage"**
2. Adicione:

**Para SQLite:**
- Source: `data/prod/actual-api`
- Mount Path: `/app/.actual-cache`

**Para PostgreSQL:**
- Source: `data/prod/actual-api` → Mount Path: `/app/.actual-cache`
- Source: `data/prod/redis` → Mount Path: `/data` (Redis)
- Source: `data/prod/postgres` → Mount Path: `/var/lib/postgresql/data` (PostgreSQL)

### Passo 7: Deploy Inicial

1. Clique em **"Deploy"** ou **"Start Service"**
2. Aguarde o build e inicialização
3. Verifique os logs em **"Logs"**

## 🚀 Opções de Implantação

### Opção A: SQLite (Mais Simples)

**Quando usar:**
- ✅ Ambiente de teste/staging
- ✅ Baixa concorrência esperada
- ✅ Configuração rápida

**Arquivo**: `docker-compose.prod.sqlite.yml`

**Variáveis mínimas:**
```env
NODE_ENV=production
ADMIN_PASSWORD=xxxxx
JWT_SECRET=xxxxx_min_32_chars
SESSION_SECRET=xxxxx_min_32_chars
ACTUAL_SERVER_URL=https://xxx
ACTUAL_PASSWORD=xxxxx
ACTUAL_SYNC_ID=xxxxx
REDIS_PASSWORD=xxxxx
```

### Opção B: PostgreSQL (Recomendado para Produção)

**Quando usar:**
- ✅ Produção com múltiplos usuários
- ✅ Dados críticos
- ✅ Backup automático

**Arquivo**: `docker-compose.prod.postgres.yml`

**Variáveis adicionais:**
```env
DB_TYPE=postgres
POSTGRES_PASSWORD=xxxxx_forte
```

## 📊 Monitoramento no Dokploy

### Logs

```bash
# Via UI: Dokploy → Service → Logs → Follow
# Monitorar em tempo real os logs da aplicação
```

### Health Check

```bash
# Verificar saúde via curl
curl -v https://api-budget.fluxzone.com.br/v2/health

# Resposta esperada (200 OK):
# {"status":"ok","timestamp":"2024-05-12T10:30:00Z"}
```

### Métricas

Se configurado em **docker-compose**:

```bash
curl https://api-budget.fluxzone.com.br/v2/metrics
```

### Restart Automático

O Dokploy permite configurar:
- **Auto-restart on failure**: ✅ Habilitado
- **Health check**: `/v2/health`
- **Restart delay**: 10s

## 🔄 Atualizações e Deployment Contínuo

### Atualizar Aplicação

**Opção 1: Via UI do Dokploy**
1. Vá para o serviço
2. Clique em **"Redeploy"** ou **"Update"**
3. Selecione a branch/tag desejada
4. Clique em **"Deploy"**

**Opção 2: Webhook (CI/CD Automático)**

Se quiser deploy automático ao fazer push:

1. No Dokploy, vá para o serviço
2. Procure por **"Webhooks"** ou **"CI/CD"**
3. Copie a URL do webhook
4. No GitHub:
   - Vá para: `Settings` → `Webhooks` → `Add webhook`
   - Cole a URL do Dokploy
   - Events: `Push events`
   - Ativo: ✅

Assim, todo push para a branch configurada fará deploy automático!

### Rollback

Se precisar voltar para versão anterior:

1. No Dokploy: **"Deployments"** → Histórico
2. Selecione versão anterior
3. Clique em **"Rollback"**

## 🔐 Segurança

### Secrets & Variables

✅ **Fazendo certo:**
```env
# Gerar secrets fortes (mínimo 32 caracteres)
JWT_SECRET=$(openssl rand -base64 32)
SESSION_SECRET=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 24)
```

⚠️ **Precauções:**
- Nunca commit `.env` no GitHub
- Use apenas variáveis de ambiente do Dokploy
- Rotate secrets periodicamente em produção

### SSL/TLS

- Dokploy geralmente oferece SSL automático (Let's Encrypt)
- Configure **"Auto HTTPS"** ou similar no painel
- Verifique certificado: `https://api-budget.fluxzone.com.br`

## 🐛 Troubleshooting

### Aplicação não inicia

**Verificar:**
1. Logs no Dokploy → Service → Logs
2. Variáveis de ambiente completas?
3. Volumes criados corretamente?

```bash
# No log deve aparecer:
# ✓ Configuration loaded
# ✓ Database initialized
# ✓ Server listening on port 3010
```

### Estes conectão com Redis/PostgreSQL

```bash
# Debug de conectividade - adicione ao LOG_LEVEL=debug nos environment variables

# Verificar se Redis está rodando:
docker ps | grep redis

# Verificar conexão PostgreSQL:
docker ps | grep postgres
```

### CORS errors

Confirmar `ALLOWED_ORIGINS`:
```env
ALLOWED_ORIGINS=https://api-budget.fluxzone.com.br,https://seu-frontend.com
```

### Limite de recursos

Se aplicação lenta:
1. Verifique CPU/Memória no Dokploy
2. Considere aumentar limites se disponível
3. Para PostgreSQL, configure parameters no Dokploy

## 📞 Support & Resources

- **Dokumentasi Dokploy**: https://dokploy.com/docs
- **Actual Budget**: https://actualbudget.org/
- **Docker Compose**: https://docs.docker.com/compose/
- **Traefik**: https://doc.traefik.io/

## ✅ Checklist de Deploy

- [ ] Variáveis de ambiente configuradas
- [ ] Domínio configurado e apontando para Dokploy
- [ ] SSL/HTTPS habilitado
- [ ] Volumes criados e mapeados
- [ ] Health check testado
- [ ] Logs monitorados sem erros
- [ ] Acesso via `https://api-budget.fluxzone.com.br/v2/health`
- [ ] Traefik labels aplicados corretamente
- [ ] Backup strategy definida (para dados persistentes)
- [ ] Plano de monitoramento/alertas

## 🎯 Próximos Passos

1. **Teste**: Faça requisição de teste à API
   ```bash
   curl -X GET https://api-budget.fluxzone.com.br/v2/health
   ```

2. **Integração**: Conecte seu frontend à API

3. **Monitoramento**: Configure alertas se disponível

4. **Backup**: Implemente backup regular de dados

Sucesso no deploy! 🚀
