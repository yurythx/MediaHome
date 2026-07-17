#!/bin/bash
# Envia em massa vídeos para o PeerTube, sem precisar subir um por um pela
# interface web.
#
# PRÉ-REQUISITO (rodar uma vez só, no servidor, fora deste script):
#   sudo npm install -g @peertube/peertube-cli
#   peertube-cli auth add -u https://SEU_PEERTUBE_HOSTNAME -U root --password 'sua_senha'
#
# Uso:
#   ./bulk-upload.sh <pasta> [privacy]
#   ./bulk-upload.sh --retry <arquivo_de_log_de_falhas> [privacy]
#
# privacy: 1=Público  2=Não listado (padrão)  3=Privado
#
# O PeerTube limita a API geral a 50 requisições a cada 10s por padrão
# (rates_limit.api no config). O upload usa o protocolo "resumable" (várias
# requisições HTTP por vídeo só), então uploads em sequência rápida demais
# tomam erro 429 "Too Many Requests" - e depois de um 429, TODOS os envios
# seguintes tendem a falhar em cascata também. Por isso o script espera
# SLEEP_SEGUNDOS entre cada envio, e pausa mais ainda se detectar um 429.

set -uo pipefail

SLEEP_SEGUNDOS=6

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

enviar_arquivo() {
  local file="$1"
  total=$((total + 1))
  local name
  name=$(basename "$file")
  name="${name%.*}"

  echo ""
  echo "== [$total] Enviando: $name =="
  local saida
  saida=$(peertube-cli upload -f "$file" -n "$name" -P "$PRIVACY" --no-wait-transcoding 2>&1)
  local status=$?
  echo "$saida"

  if [ $status -eq 0 ]; then
    ok=$((ok + 1))
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
echo "=== Concluído: $ok/$total enviados com sucesso ==="
if [ -f "$LOG_FALHAS" ]; then
  echo "Falhas registradas em: $LOG_FALHAS"
  echo "Para tentar de novo só os que falharam: $0 --retry $LOG_FALHAS"
fi
