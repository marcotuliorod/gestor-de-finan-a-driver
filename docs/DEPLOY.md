# Deploy do backend em produção (VPS + Docker)

Runbook para colocar `backend/` no ar num VPS, com HTTPS automático via Caddy. Assume um VPS Ubuntu 22.04+ com acesso root/sudo via SSH.

## 1. Provisionar o VPS

```bash
# No VPS, como root ou com sudo:
apt update && apt upgrade -y
curl -fsSL https://get.docker.com | sh
# Instala Docker Engine + o plugin `docker compose` (v2) automaticamente.

# Firewall: só 22 (SSH), 80 e 443 ficam abertos. Nunca abra 5432 ou 8000
# publicamente — o Postgres e a API não devem ser alcançáveis diretamente
# da internet, só através da Caddy.
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

## 2. Apontar o domínio

No provedor de DNS do seu domínio, crie um registro `A` apontando para o IP público do VPS:

```
api.seudominio.com.   A   <IP-DO-VPS>
```

Espere a propagação (minutos a poucas horas) antes de subir a Caddy — ela só emite certificado Let's Encrypt se o domínio já resolver para o servidor.

## 3. Clonar o repositório e configurar

```bash
git clone https://github.com/marcotuliorod/gestor-de-finan-a-driver.git
cd gestor-de-finan-a-driver
cp .env.example .env
```

Edite `.env` e preencha **todos** os valores (nunca deixe os placeholders `change-me`):

```bash
# Gera senhas fortes:
openssl rand -base64 32   # POSTGRES_PASSWORD
openssl rand -base64 32   # APP_DB_PASSWORD (diferente da anterior)
openssl rand -base64 48   # JWT_SECRET
```

- `DOMAIN`: o domínio real do passo 2 (ex: `api.seudominio.com`)
- `GOOGLE_CLIENT_ID`: client ID OAuth do Google Cloud Console
- `APPLE_BUNDLE_ID`: confirme o bundle id real gerado em `ios/Runner.xcodeproj` (não commitado — gerado via `flutter create` no CI; o macOS deste projeto usa `com.marcotuliorod.driverFinance`, diferente do Android que usa `com.marcotuliorod.driver_finance` — confira qual bate com o app iOS antes de configurar o OAuth)

## 4. Subir os containers

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

Isso builda a imagem da API, roda as migrations automaticamente (`tool/migrate.py`, disparado pelo `CMD` do `backend/Dockerfile`), e sobe Postgres + API + Caddy. Repare que **não** passamos `-f docker-compose.override.yml` nem deixamos o Compose auto-carregar — por isso `postgres`/`api` não ficam com porta pública, só a Caddy (80/443).

## 5. Verificar

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs caddy --tail=50
curl https://api.seudominio.com/health
# Deve retornar: {"status":"ok"}
```

Se a Caddy não conseguir emitir o certificado, confira: (a) o DNS já propagou (`dig api.seudominio.com`), (b) as portas 80/443 estão realmente abertas no firewall do provedor de VPS também (alguns provedores têm firewall próprio além do `ufw` do sistema).

## 6. Backup automático (cron)

No host do VPS (fora do container), edite o crontab:

```bash
crontab -e
```

Adicione (roda todo dia às 3h, salva log num arquivo):

```
0 3 * * * cd /caminho/para/gestor-de-finan-a-driver && docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile backup run --rm backup >> /var/log/driver-finance-backup.log 2>&1
```

Os dumps ficam no volume `backup_data` (últimos 14 são mantidos, ver `deploy/backup.sh`). Para copiar um dump pro seu computador:

```bash
docker run --rm -v gestor-de-finan-a-driver_backup_data:/backups -v "$(pwd)":/out alpine \
  cp /backups/driver_finance_<timestamp>.sql.gz /out/
```

**Limitação conhecida:** o backup fica só no próprio VPS. Se o VPS inteiro for perdido (disco corrompido, conta suspensa, etc.), o backup vai junto. Copiar os dumps periodicamente para fora do VPS (seu computador, outro storage) é responsabilidade manual por enquanto — não há upload automático configurado.

## 7. Deploy de atualizações futuras

```bash
cd /caminho/para/gestor-de-finan-a-driver
git pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

O `up -d --build` recria só os containers cuja imagem mudou; migrations novas em `backend/migrations/` rodam automaticamente no start da API (idempotente — já aplicadas são puladas).

## 8. Acesso administrativo ao Postgres

Como a porta 5432 não é pública, acesse via `exec` no próprio VPS:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec postgres psql -U driver_finance -d driver_finance
```
