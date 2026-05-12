# 📚 Guia de Documentação - Deploy & Configuração

Escolha o documento certo para sua necessidade:

## 🚀 Começando Agora? Comece Aqui 👇

### ⚡ Opção 1: Deploy Rápido no Dokploy (5 minutos)
📄 **File**: [DOKPLOY_QUICKSTART.md](DOKPLOY_QUICKSTART.md)
- ✅ Setup mais rápido possível
- ✅ Para testes/staging
- ✅ Passo a passo visual
- 👉 **Comece por aqui se quer deploy rápido**

### ✅ Opção 2: Validar Configuração Antes de Deploy
📄 **File**: [PREDEPLOY_CHECKLIST.md](PREDEPLOY_CHECKLIST.md)
- ✅ Checklist completo
- ✅ Gerador de secrets
- ✅ Validação de variáveis
- 👉 **Use antes de fazer qualquer deploy**

### 📖 Opção 3: Guia Completo Dokploy
📄 **File**: [DOKPLOY_DEPLOYMENT.md](DOKPLOY_DEPLOYMENT.md)
- ✅ Documentação profunda
- ✅ Troubleshooting
- ✅ Monitoramento
- ✅ CI/CD com webhooks
- 👉 **Use se quer entender tudo em detalhe**

---

## 📋 Diferentes Cenários

### Cenário 1: "Quero fazer deploy no Dokploy agora"

1. Leia: [PREDEPLOY_CHECKLIST.md](PREDEPLOY_CHECKLIST.md) (10 min)
   - Gere as chaves de segurança
   - Valide todos os dados

2. Siga: [DOKPLOY_QUICKSTART.md](DOKPLOY_QUICKSTART.md) (5 min)
   - Copie variáveis
   - Configure Dokploy
   - Deploy!

3. Teste:
   ```bash
   curl https://seu-dominio.com/v2/health
   ```

---

### Cenário 2: "Preciso fazer deploy local/comandos"

📄 **File**: [DEPLOY_GUIDE_3010.md](DEPLOY_GUIDE_3010.md)

Commands:
```bash
# SQLite
docker-compose -f docker-compose.prod.sqlite.yml --env-file .env up -d

# PostgreSQL
docker-compose -f docker-compose.prod.postgres.yml --env-file .env up -d

# Logs
docker-compose -f docker-compose.prod.sqlite.yml logs -f

# Health check
curl http://localhost:3010/v2/health
```

---

### Cenário 3: "Quero usar o script de deploy automatizado"

📄 **File**: [deploy.sh](deploy.sh)

Commands:
```bash
# Inicializar
./deploy.sh init

# Iniciar (SQLite)
./deploy.sh up

# Iniciar (PostgreSQL)
./deploy.sh up --db postgres

# Ver logs
./deploy.sh logs -f

# Parar
./deploy.sh down

# Health check
./deploy.sh health
```

---

### Cenário 4: "Preciso de ajuda com troubleshooting"

**Problema**: Aplicação não inicia
- [ ] Verificar logs: [DOKPLOY_DEPLOYMENT.md](DOKPLOY_DEPLOYMENT.md#-troubleshooting)
- [ ] Validar variáveis: [PREDEPLOY_CHECKLIST.md](PREDEPLOY_CHECKLIST.md#-variáveis-de-ambiente-obrigatórias)

**Problema**: Conectividade Redis/PostgreSQL
- [ ] Ver logs: `docker logs container_name`
- [ ] Ler: [DOKPLOY_DEPLOYMENT.md](DOKPLOY_DEPLOYMENT.md#redis-falha-ao-conectar)

**Problema**: Health check falhando
- [ ] Aguardar 40+ segundos (startup inicial)
- [ ] Verificar logs: `docker logs actual-rest-api`
- [ ] Validar URL do Actual Budget

---

### Cenário 5: "Estou em produção e quero monitoramento"

📄 **File**: [monitoring/README.md](monitoring/README.md)

Features:
- Prometheus metrics
- Grafana dashboards
- Health checks automáticos
- Alertas (configurável)

---

## 🗂️ Arquivos de Configuração

| Arquivo | Propósito | Quando Usar |
|---------|----------|-------------|
| `docker-compose.prod.sqlite.yml` | SQLite setup | Desenvolvimento/Teste |
| `docker-compose.prod.postgres.yml` | PostgreSQL setup | Produção com múltiplos usuários |
| `docker-compose.dev.yml` | Desenvolvimento | Local com Actual Server + n8n + Prometheus + Grafana |
| `.env.example` | Template variáveis | Copiar e customizar |
| `Dockerfile` | Imagem produção | Build da aplicação |
| `.dockerignore` | Otimização build | Nem altere |

---

## 🔒 Segurança

### Gerar Secrets

```bash
# JWT_SECRET
openssl rand -base64 32

# JWT_REFRESH_SECRET (diferente!)
openssl rand -base64 32

# SESSION_SECRET (diferente!)
openssl rand -base64 32

# REDIS_PASSWORD
openssl rand -base64 24

# POSTGRES_PASSWORD
openssl rand -base64 24
```

### Checklist Segurança

- ✅ Nunca commit `.env` no git
- ✅ Usar secrets manager em produção
- ✅ Secrets com 32+ caracteres mínimo
- ✅ Cada secret deve ser único
- ✅ Usar HTTPS em produção
- ✅ Rate limiting habilitado
- ✅ ALLOWED_ORIGINS configurado

---

## 📊 Monitoramento & Logs

### Logs Estruturados

```bash
# Arquivo docker-compose
docker-compose -f docker-compose.prod.sqlite.yml logs -f

# Apenas erros
docker logs actual-rest-api 2>&1 | grep -i error

# Últimas 50 linhas
docker-compose -f docker-compose.prod.sqlite.yml logs --tail=50
```

### Health Check

```bash
# Endpoint
curl https://seu-dominio.com/v2/health

# Resposta esperada
{
  "status": "ok",
  "timestamp": "2024-05-12T10:30:00Z"
}
```

### Métricas Prometheus

```bash
curl https://seu-dominio.com/v2/metrics/prometheus
```

---

## 🔄 Atualizar/Redeploy

### Opção 1: Via Dokploy UI
- Dashboard → Service → Redeploy
- Selecionar versão se usar git tags
- Deploy automático se webhook configurado

### Opção 2: Via Comando
```bash
# Parar, atualizar, iniciar
docker-compose -f docker-compose.prod.sqlite.yml down
docker-compose -f docker-compose.prod.sqlite.yml pull
docker-compose -f docker-compose.prod.sqlite.yml up -d
```

### Opção 3: Via Script
```bash
./deploy.sh restart
```

---

## 🆘 Precisa de Help?

### Recursos

| Recurso | Link | Para |
|---------|------|------|
| Dokumentasi Dokploy | https://dokploy.com/docs | Deploy &  CI/CD |
| Actual Budget | https://actualbudget.org/ | API REST wrapper para |
| Docker Compose | https://docs.docker.com/compose/ | Docker setup |
| Prometheus | https://prometheus.io/ | Monitoramento |
| Traefik | https://doc.traefik.io/ | Reverse proxy |

### FAQ

**P: Qual versão de banco de dados devo usar?**

R: Para começar use **SQLite** (mais simples). Para produção com múltiplos usuários, use **PostgreSQL**.

**P: Quanto tempo leva para fazer deploy?**

R: Normalmente 3-5 minutos (build + inicialização).

**P: Posso integrar com GitHub Actions?**

R: Sim! Use webhooks no Dokploy (automático) ou variables do GitHub Secrets.

**P: Os dados persistem após reiniciar?**

R: Sim! Os volumes garantem persistência. Sempre faça backup em produção.

**P: Como fazer rollback para versão anterior?**

R: No Dokploy: Deployments → Histórico → Rollback. Via comando: reutilize versão anterior da imagem.

**P: Posso usar um domínio customizado?**

R: Sim! Configure em Network/Bindings do Dokploy e aponte DNS.

---

## ✨ Quick Summary

```
┌─ Dokploy Deploy
│
├─ 1️⃣  Ler: PREDEPLOY_CHECKLIST.md (generar secrets)
├─ 2️⃣  Ler: DOKPLOY_QUICKSTART.md (setup simples)
├─ 3️⃣  Deploy no Dokploy (3-5 min)
├─ 4️⃣  Testar: curl https://seu-dominio.com/v2/health
│
└─ ✅ Sucesso!

Dúvidas?
├─ Deploy local → DEPLOY_GUIDE_3010.md
├─ Detalhes Dokploy → DOKPLOY_DEPLOYMENT.md
├─ Script automático → ./deploy.sh init && ./deploy.sh up
└─ Monitoramento → monitoring/README.md
```

---

**Pronto para começar?** 👉 Comece com [DOKPLOY_QUICKSTART.md](DOKPLOY_QUICKSTART.md)

💡 **Dica**: Leia [PREDEPLOY_CHECKLIST.md](PREDEPLOY_CHECKLIST.md) primeiro para validar tudo!

🚀 **Boa sorte com o deploy!**
