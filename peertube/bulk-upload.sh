#!/bin/bash
# Envia em massa todos os vídeos de uma pasta para o PeerTube, sem precisar
# subir um por um pela interface web.
#
# PRÉ-REQUISITO (rodar uma vez só, no servidor, fora deste script):
#   sudo npm install -g @peertube/peertube-cli
#   peertube-cli auth add -u https://SEU_PEERTUBE_HOSTNAME -U root --password 'sua_senha'
#
# Uso:
#   ./bulk-upload.sh /mnt/dados/Series/Ninja\ Kamui
#
# Cada vídeo é enviado como "Não listado" (privacy 2) por padrão - veja o
# aviso de federação/privacidade no README.md antes de mudar para Público (1).

set -uo pipefail

SRC_DIR="${1:-}"
PRIVACY="${2:-2}"  # 1=Público 2=Não listado 3=Privado
LOG_FALHAS="falhas_upload_$(date +%Y%m%d_%H%M%S).log"

if [ -z "$SRC_DIR" ] || [ ! -d "$SRC_DIR" ]; then
  echo "Uso: $0 <pasta> [privacy: 1=Público 2=Não-listado(padrão) 3=Privado]"
  exit 1
fi

if ! command -v peertube-cli >/dev/null 2>&1; then
  echo "peertube-cli não encontrado. Instale com: sudo npm install -g @peertube/peertube-cli"
  exit 1
fi

total=0
ok=0

while IFS= read -r -d '' file; do
  total=$((total + 1))
  name=$(basename "$file")
  name="${name%.*}"

  echo ""
  echo "== [$total] Enviando: $name =="
  if peertube-cli upload -f "$file" -n "$name" -P "$PRIVACY" --no-wait-transcoding; then
    ok=$((ok + 1))
  else
    echo "$file" >> "$LOG_FALHAS"
    echo "FALHOU (registrado em $LOG_FALHAS): $file"
  fi
done < <(find "$SRC_DIR" -type f \( \
    -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \
    -o -iname "*.avi" -o -iname "*.mov" \
  \) -print0)

echo ""
echo "=== Concluído: $ok/$total enviados com sucesso ==="
if [ -f "$LOG_FALHAS" ]; then
  echo "Falhas registradas em: $LOG_FALHAS"
fi
