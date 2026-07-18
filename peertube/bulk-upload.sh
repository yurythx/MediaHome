#!/bin/bash
# Envia em massa vídeos para o PeerTube, sem precisar subir um por um pela
# interface web.
#
# PRÉ-REQUISITO (rodar uma vez só, no servidor, fora deste script):
#   sudo npm install -g @peertube/peertube-cli
#   # Autenticação separada apontando pro endereço LOCAL (veja LOCAL_URL abaixo):
#   peertube-cli auth add -u http://localhost:9000 -U root --password 'sua_senha'
#
# Uso:
#   ./bulk-upload.sh <pasta> [privacy]
#   ./bulk-upload.sh --retry <arquivo_de_log_de_falhas> [privacy]
#
# privacy: 1=Público  2=Não listado (padrão)  3=Privado
#
# IMPORTANTE: o "peertube-cli upload" sempre manda o vídeo inteiro numa única
# requisição HTTP (modo "legacy") - não existe flag pra usar o protocolo
# resumable/em pedaços nessa ferramenta. Se a stack for exposta via Cloudflare
# Tunnel (limite fixo de ~100MB por requisição), vídeos grandes falham com
# "413 Payload Too Large" (o peertube-cli mostra isso como "user quota is
# exceeded or video file is too big", mensagem genérica dele pra qualquer 413).
# Por isso este script aponta pra LOCAL_URL (o endereço local do próprio
# servidor, sem passar pelo Cloudflare) em vez do domínio público - ajuste se
# não usar Cloudflare Tunnel ou se a porta for outra.
#
# O PeerTube limita a API geral a 50 requisições a cada 10s por padrão
# (rates_limit.api no config, já aumentado em peertube.yml). Mesmo assim,
# o script espera SLEEP_SEGUNDOS entre cada envio como camada extra de
# segurança, e pausa mais ainda se detectar um 429.
#
# Todo arquivo enviado com sucesso é registrado em ENVIADOS_LOG (persiste
# entre execuções, não é apagado). Rodar o script de novo na mesma pasta
# pula automaticamente quem já foi enviado - não reenvia/duplica nada.

set -uo pipefail

SLEEP_SEGUNDOS=6
LOCAL_URL="${PEERTUBE_LOCAL_URL:-http://localhost:9000}"
ENVIADOS_LOG="enviados_peertube.log"
touch "$ENVIADOS_LOG"

if [ "${1:-}" = "--retry" ]; then
  LOG_ENTRADA="${2:-}"
  PRIVACY="${3:-2}"
  if [ -z "$LOG_ENTRADA" ] || [ ! -f "$LOG_ENTRADA" ]; then
    echo "Uso: $0 --retry <arquivo_de_log> [privacy]"
    exit 1
  fi
  MODO="retry"
else
  SRC_DIR="${1:-}"
  PRIVACY="${2:-2}"
  if [ -z "$SRC_DIR" ] || [ ! -d "$SRC_DIR" ]; then
    echo "Uso: $0 <pasta> [privacy: 1=Público 2=Não-listado(padrão) 3=Privado]"
    echo "  ou: $0 --retry <arquivo_de_log_de_falhas> [privacy]"
    exit 1
  fi
  MODO="pasta"
fi

if ! command -v peertube-cli >/dev/null 2>&1; then
  echo "peertube-cli não encontrado. Instale com: sudo npm install -g @peertube/peertube-cli"
  exit 1
fi

LOG_FALHAS="falhas_upload_$(date +%Y%m%d_%H%M%S).log"
total=0
ok=0
pulados=0

enviar_arquivo() {
  local file="$1"

  if grep -Fxq "$file" "$ENVIADOS_LOG"; then
    pulados=$((pulados + 1))
    echo "-- Já enviado antes, pulando: $(basename "$file")"
    return
  fi

  total=$((total + 1))
  local name
  name=$(basename "$file")
  name="${name%.*}"

  echo ""
  echo "== [$total] Enviando: $name =="
  local saida
  saida=$(peertube-cli upload -u "$LOCAL_URL" -f "$file" -n "$name" -P "$PRIVACY" --no-wait-transcoding 2>&1)
  local status=$?
  echo "$saida"

  if [ $status -eq 0 ]; then
    ok=$((ok + 1))
    echo "$file" >> "$ENVIADOS_LOG"
  else
    echo "$file" >> "$LOG_FALHAS"
    echo "FALHOU (registrado em $LOG_FALHAS): $file"
    if echo "$saida" | grep -qi "429\|too many requests"; then
      echo ">> Rate limit da API detectado - aguardando 60s extras antes de continuar..."
      sleep 60
    fi
  fi

  sleep "$SLEEP_SEGUNDOS"
}

if [ "$MODO" = "retry" ]; then
  while IFS= read -r file; do
    [ -n "$file" ] && [ -f "$file" ] && enviar_arquivo "$file"
  done < "$LOG_ENTRADA"
else
  while IFS= read -r -d '' file; do
    enviar_arquivo "$file"
  done < <(find "$SRC_DIR" -type f \( \
      -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \
      -o -iname "*.avi" -o -iname "*.mov" \
    \) -print0)
fi

echo ""
echo "=== Concluído: $ok/$total enviados com sucesso ($pulados já enviados antes, pulados) ==="
if [ -f "$LOG_FALHAS" ]; then
  echo "Falhas registradas em: $LOG_FALHAS"
  echo "Para tentar de novo só os que falharam: $0 --retry $LOG_FALHAS"
fi
