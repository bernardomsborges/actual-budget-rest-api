# ✅ Checklist Pré-Deploy Dokploy

Use este checklist para garantir que tudo está configurado corretamente antes de fazer o deploy.

## 📋 Pré-Requisitos

- [ ] Arquivo clonado: `actual-budget-rest-api`
- [ ] Conta Dokploy ativa e acessível
- [ ] Repositório GitHub conectado ao Dokploy
- [ ] Domínio apontando para o servidor Dokploy (DNS configured)
- [ ] Acesso ao servidor Actual Budget (URL, senha, sync ID)

## 🔐 Segurança & Secrets

### Gerar Chaves Seguras

Antes de configurar, gere as chaves necessárias:

```bash
# Execute os comandos abaixo e copie os resultados

echo "=== JWT_SECRET ==="
openssl rand -base64 32

echo "=== JWT_REFRESH_SECRET ==="
openssl rand -base64 32

echo "=== SESSION_SECRET ==="
openssl rand -base64 32

echo "=== REDIS_PASSWORD ==="
openssl rand -base64 24

echo "=== POSTGRES_PASSWORD (se usar PostgreSQL) ==="
openssl rand -base64 24
```

### Checklist de Segurança

- [ ] JWT_SECRET gerado (32+ caracteres)
- [ ] JWT_REFRESH_SECRET gerado e ≠ JWT_SECRET
- [ ] SESSION_SECRET gerado e diferente dos outros
- [ ] ADMIN_PASSWORD criada (forte, 12+ caracteres)
- [ ] REDIS_PASSWORD gerada (se aplicável)
- [ ] POSTGRES_PASSWORD gerada (se usar PostgreSQL)
- [ ] Nenhuma chave foi copiada para email/chat não seguro
- [ ] Arquivo .env nunca será commitado (verificar .gitignore)

## 🗄️ Escolher Tipo de Banco de Dados

### SQLite (Recomendado para Começar)

- [ ] Usar arquivo: `docker-compose.prod.sqlite.yml`
- [ ] Variável: `DB_TYPE=sqlite`
- [ ] Sem variáveis PostgreSQL necessárias
- [ ] Menos recursos (mais rápido para começar)

### PostgreSQL (Recomendado para Produção)

- [ ] Usar arquivo: `docker-compose.prod.postgres.yml`
- [ ] Variável: `DB_TYPE=postgres`
- [ ] POSTGRES_PASSWORD definida
- [ ] POSTGRES_DB: `actual_rest_api`
- [ ] POSTGRES_USER: `postgres`
- [ ] POSTGRES_HOST: `postgres` (será o container)
- [ ] POSTGRES_PORT: `5432`

## 📝 Variáveis de Ambiente Obrigatórias

Verifique se todas estas estão preparadas (copie para o Dokploy):

**Servidor:**
- [ ] `NODE_ENV=production`
- [ ] `PORT=3010`
- [ ] `TRUST_PROXY=true`

**Autenticação:**
- [ ] `ADMIN_USER=admin` (ou seu usuário preferido)
- [ ] `ADMIN_PASSWORD=<sua_senha_forte>`
- [ ] `JWT_SECRET=<gerada_acima>`
- [ ] `JWT_REFRESH_SECRET=<gerada_acima>`
- [ ] `SESSION_SECRET=<gerada_acima>`

**Actual Budget:**
- [ ] `ACTUAL_SERVER_URL=https://seu-servidor.com` (validar HTTPS)
- [ ] `ACTUAL_PASSWORD=<sua_senha>`
- [ ] `ACTUAL_SYNC_ID=<seu_sync_id>`

**Networking:**
- [ ] `ALLOWED_ORIGINS=https://seu-dominio.com` (pode ser múltiplas, separadas por vírgula)

**Redis:**
- [ ] `REDIS_HOST=redis`
- [ ] `REDIS_PORT=6379`
- [ ] `REDIS_PASSWORD=<gerada_acima>`

**Banco de Dados (se PostgreSQL):**
- [ ] `DB_TYPE=postgres`
- [ ] `POSTGRES_HOST=postgres`
- [ ] `POSTGRES_PORT=5432`
- [ ] `POSTGRES_DB=actual_rest_api`
- [ ] `POSTGRES_USER=postgres`
- [ ] `POSTGRES_PASSWORD=<gerada_acima>`

**Opcional:**
- [ ] `LOG_LEVEL=info` (ou debug se testes)
- [ ] `JWT_ACCESS_TTL=1h`
- [ ] `JWT_REFRESH_TTL=24h`

## 🌐 Configuração de Domínio

- [ ] Domínio escolhido (ex: `api-budget.fluxzone.com.br`)
- [ ] DNS apontado para IP do Dokploy
- [ ] Testar DNS: `nslookup seu-dominio.com`
- [ ] SSL/HTTPS disponível no Dokploy (Let's Encrypt ou manual)
- [ ] Certificado será auto-renovado

## 🐳 Docker Compose

- [ ] Arquivo selecionado no Dokploy confirmado
- [ ] Entre no repositório e confirme o arquivo existe:
  - Para SQLite: `docker-compose.prod.sqlite.yml`
  - Para PostgreSQL: `docker-compose.prod.postgres.yml`

## 💾 Volumes & Persistência

Mapeamentos necessários no Dokploy:

**Para ambos (SQLite e PostgreSQL):**
- [ ] Source: `data/prod/actual-api` → Mount: `/app/.actual-cache`
- [ ] Source: `data/prod/redis` → Mount: `/data`

**Apenas para PostgreSQL:**
- [ ] Source: `data/prod/postgres` → Mount: `/var/lib/postgresql/data`

## 🚀 No Painel do Dokploy

Antes de clicar Deploy, confirme:

### Informações do Projeto
- [ ] Project Name: `actual-budget-api` (ou seu nome)
- [ ] Repositório: Conectado e correto
- [ ] Branch: `main` (ou sua branch)

### Configuração do Serviço
- [ ] Service Name: `actual-rest-api`
- [ ] Compose File: `docker-compose.prod.sqlite.yml` ou `docker-compose.prod.postgres.yml`
- [ ] Todas as variáveis de ambiente configuradas
- [ ] Memory/CPU limits configurados (se aplicável)

### Networking
- [ ] Domain: `seu-dominio.com`
- [ ] Port: `3010`
- [ ] HTTPS: Habilitado
- [ ] Auto-redirect HTTP → HTTPS: Habilitado

### Volumes
- [ ] Todos os volumes mapeados
- [ ] Paths existem ou serão criados
- [ ] Permissões corretas (755 mínimo)

### Health Check
- [ ] Habilitado
- [ ] Path: `/v2/health`
- [ ] Port: `3010`
- [ ] Initial Delay: 40s (mínimo)
- [ ] Interval: 30s
- [ ] Timeout: 10s

## ✔️ Pré-Deploy Final

- [ ] Revisar todos os items acima
- [ ] Confirmar nenhuma chave sensível foi exposta
- [ ] Verificar backups (se necessário)
- [ ] Informar time sobre deployment (se aplicável)
- [ ] Ter plano de rollback (versão anterior)

## 🟢 Pronto para Deploy!

Se todos os items acima foram marcados ✅, você está pronto para:

1. Clique **"Deploy"** no painel do Dokploy
2. Aguarde build + inicialização (3-5 minutos)
3. Verifique logs para erros
4. Teste health endpoint

```bash
curl https://seu-dominio.com/v2/health
```

Resposta esperada:
```json
{
  "status": "ok",
  "timestamp": "2024-05-12T10:30:00Z"
}
```

## 🆘 Algo Deu Errado?

1. **Verificar logs no Dokploy**: Dashboard → Service → Logs
2. **Procurar por erros**: `error`, `failed`, `exception`
3. **Validar variáveis**: Todos os obrigatórios estão definidos?
4. **Health check falhando**: Aplicação pode estar inicializando, aguarde 40s
5. **Conectividade Redis/PostgreSQL**: Verificar container names e ports

### Troubleshooting Rápido

```bash
# Verificar se containers estão rodando
docker ps

# Ver logs
docker logs actual-rest-api

# Testar conexão
curl http://localhost:3010/v2/health

# Reiniciar
docker-compose -f docker-compose.prod.sqlite.yml restart
```

---

## 📞 Suporte

- **Documentação Dokploy**: https://dokploy.com/docs
- **Documentação Completa**: [DOKPLOY_DEPLOYMENT.md](DOKPLOY_DEPLOYMENT.md)
- **Quick Start**: [DOKPLOY_QUICKSTART.md](DOKPLOY_QUICKSTART.md)
- **Deploy Local**: [DEPLOY_GUIDE_3010.md](DEPLOY_GUIDE_3010.md)

**Sucesso no deploy! 🎉**
