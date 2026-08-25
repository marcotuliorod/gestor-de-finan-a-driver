#!/bin/sh
# Roda dentro do serviço `backup` (docker-compose.prod.yml, profile "backup").
# Não sobe sozinho -- disparado sob demanda (tipicamente via cron no VPS):
#   docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile backup run --rm backup
set -eu

STAMP=$(date -u +%Y%m%dT%H%M%SZ)
FILE="/backups/driver_finance_${STAMP}.sql.gz"

pg_dump | gzip > "$FILE"
echo "Backup salvo em $FILE"

# Rotação: mantém só os 14 dumps mais recentes (~2 semanas se rodar 1x/dia).
cd /backups
ls -1t driver_finance_*.sql.gz 2>/dev/null | tail -n +15 | xargs -r rm --
