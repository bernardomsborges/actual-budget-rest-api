# Quick Start - Deploy Dokploy em 5 Minutos

## 🚀 Deploy Rápido - SQLite (Recomendado para Começar)

### 1. Preparar Variáveis de Ambiente

Copie as variáveis abaixo e configure no painel Dokploy:

```env
NODE_ENV=production
PORT=3010
TRUST_PROXY=true
ADMIN_USER=admin
ADMIN_PASSWORD=SenhaSegura123!@#
JWT_SECRET=gerar_uma_chave_aleatoria_com_32_caracteres_minimo_ABC123!@#$%^&*()
JWT_REFRESH_SECRET=outra_chave_aleatoria_com_32_caracteres_minimo_XYZ789!@#$%^&*()
SESSION_SECRET=terceira_chave_aleatoria_com_32_caracteres_minimo_DEF456!@#$%^&*()
JWT_ACCESS_TTL=1h
JWT_REFRESH_TTL=24h
ACTUAL_SERVER_URL=https://seu-servidor-actual.com
ACTUAL_PASSWORD=SenhaActual123!
ACTUAL_SYNC_ID=seu_sync_id_aqui
ALLOWED_ORIGINS=https://api-budget.fluxzone.com.br
LOG_LEVEL=info
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=SenhaRedis123!@#
DB_TYPE=sqlite
```

### 2. No Painel Dokploy - Configurar Serviço

**Profile:**
- Compose File Path: `docker-compose.prod.sqlite.yml`
- Branch: `main`

**Networking:**
- Domain: `api-budget.fluxzone.com.br`
- Port: `3010`
- HTTPS: `Sim` (Auto-SSL com Let's Encrypt)

**Volumes:**
- Source: `data/prod/actual-api` → Mount: `/app/.actual-cache`
- Source: `data/prod/redis` → Mount: `/data`

### 3. Deploy

1. Clique em **Deploy** no Dokploy
2. Aguarde build (3-5 min)
3. Teste: `https://api-budget.fluxzone.com.br/v2/health`

---

## 🗄️ Deploy com PostgreSQL (Produção)

### Passos Adicionais

**Variáveis Extras:**
```env
DB_TYPE=postgres
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=actual_rest_api
POSTGRES_USER=postgres
POSTGRES_PASSWORD=SenhaPostgres123!@#
```

**Arquivo:**
- Compose File Path: `docker-compose.prod.postgres.yml`

**Volumes Adicionais:**
- Source: `data/prod/postgres` → Mount: `/var/lib/postgresql/data`

---

## 🔍 Testar Deploy

```bash
# 1. Health Check
curl https://api-budget.fluxzone.com.br/v2/health

# 2. Response Esperada
{
  "status": "ok",
  "timestamp": "2024-05-12T10:36:00Z"
}

# 3. Verifica Logs no Dokploy
# Dashboard → Service → Logs
```

---

## 🔧 Gerar Secrets Fortes

Se precisar gerar chaves aleatórias:

```bash
# Linux/Mac
openssl rand -base64 32

# Resultado exemplo:
# aBcD1234eFgH5678iJkL9012mNoPqRs3TuVwXyZ=
```

Copie o resultado e use nas variáveis.

---

## 📋 Checklist

- [ ] Criar projeto no Dokploy
- [ ] Conectar repositório GitHub
- [ ] Selecionar arquivo docker-compose correto
- [ ] Configurar variáveis de ambiente
- [ ] Mapear volumes
- [ ] Configurar domínio + SSL
- [ ] Clicar Deploy
- [ ] Aguardar conclusão
- [ ] Testar health endpoint
- [ ] ✅ Sucesso!

---

## ❓ Dúvidas Frequentes

**P: Qual versão devo usar, SQLite ou PostgreSQL?**
R: SQLite para começar. PostgreSQL se tiver múltiplos usuários/dados críticos.

**P: Quanto tempo leva o deploy?**
R: 3-5 minutos (build + inicialização de serviços)

**P: Como atualizar a aplicação?**
R: No Dokploy, clique Redeploy. Se houver webhook configurado, push automático dispara deploy.

**P: Dados persistem após reiniciar?**
R: Sim! Os volumes garantem persistência.

**P: Posso usar outro domínio?**
R: Sim! Configure em Network/Bindings do Dokploy.

---

## 🆘 Algo Deu Errado?

1. **Verificar Logs**: Dashboard → Service → Logs
2. **Reiniciar serviço**: Dashboard → Service → Restart
3. **Validar variáveis**: Certifique-se todas as obrigatórias estão preenchidas
4. **Aumentar timeout**: Se build está lento, pode estar compilando native modules

---

**Documentação Completa**: Ver `DOKPLOY_DEPLOYMENT.md`

**Pronto para fazer o deploy?** 🚀
