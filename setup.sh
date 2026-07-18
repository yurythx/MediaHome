#!/bin/bash
# Cria a estrutura de diretórios da stack inteira e ajusta as permissões
# (UID/GID) que cada serviço espera, automatizando os passos manuais
# descritos em .env.example / README.md / DEPLOY_UBUNTU_AAPANEL.md.
#
# Uso (a partir da raiz do projeto, no servidor):
#   sudo ./setup.sh
#
# Precisa rodar como root (sudo) porque faz chown. Lê os caminhos e o
# PUID/PGID do arquivo .env na raiz do projeto - rode "cp .env.example .env"
# e ajuste os valores antes de usar este script.
#
# Idempotente: pode rodar de novo a qualquer momento sem duplicar nada nem
# quebrar uma instalação já em uso.
#
# O que este script NÃO faz (de propósito):
#   - Não edita o .env (senhas/tokens são responsabilidade sua).
#   - Não sobe os containers (docker compose up -d) - rode isso manualmente
#     depois de conferir o .env.
#   - Não faz chown -R nos discos de mídia inteiros (MEDIA_PATH_1/2/EXT) -
#     eles já costumam ter terabytes de conteúdo existente com a permissão
#     correta; um chown -R ali seria lento e desnecessário toda vez que o
#     script rodasse. Só as subpastas novas específicas de cada serviço
#     (peertube, ytdl) recebem chown.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa rodar como root (faz chown). Use: sudo ./setup.sh"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Arquivo .env não encontrado em $ENV_FILE"
  echo "Rode primeiro: cp .env.example .env   (e ajuste os valores)"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
CONFIG_PATH="${CONFIG_PATH:-/mnt/config}"
MEDIA_PATH_1="${MEDIA_PATH_1:-/mnt/dados}"
MEDIA_PATH_2="${MEDIA_PATH_2:-/mnt/dados2}"
MEDIA_PATH_EXT="${MEDIA_PATH_EXT:-/mnt/externo}"
BACKUP_PATH="${BACKUP_PATH:-/mnt/backup}"

echo "== Criando estrutura de diretórios =="

# Discos de mídia (raiz) - só garante que existem, sem mexer em conteúdo já lá
mkdir -p "$MEDIA_PATH_1" "$MEDIA_PATH_2" "$MEDIA_PATH_EXT" "$BACKUP_PATH"

# Organização recomendada dentro de cada disco (opcional, não usada por
# nenhum bind mount diretamente - é só convenção de pastas)
mkdir -p "$MEDIA_PATH_1"/{filmes,series,musicas,quadrinhos}
mkdir -p "$MEDIA_PATH_2"/{filmes,series,musicas,quadrinhos}

# Config de cada serviço
mkdir -p "$CONFIG_PATH"/{jellyfin,komga,navidrome,portainer,qbittorrent}
mkdir -p "$CONFIG_PATH"/peertube/{config,postgres,redis}
mkdir -p "$CONFIG_PATH"/ytdl-material/{appdata,subscriptions,users,postgres}
mkdir -p "$CONFIG_PATH/vaultwarden"

# Dados de mídia gerados pelos próprios serviços (subpastas novas e vazias,
# diferente da raiz do disco - seguro fazer chown nelas)
mkdir -p "$MEDIA_PATH_1/peertube"
mkdir -p "$MEDIA_PATH_1"/ytdl/{audio,video}

echo "== Ajustando permissões (PUID=$PUID PGID=$PGID) =="

# Padrão: tudo em CONFIG_PATH e as subpastas novas de mídia usam PUID/PGID
# (cobre Jellyfin, Komga, Navidrome, Portainer, qBittorrent e Vaultwarden -
# Vaultwarden não tem PUID/PGID nativo, mas seu "user:" no vaultwarden.yml
# já está fixado em PUID:PGID, então cai nessa mesma regra)
chown -R "$PUID:$PGID" "$CONFIG_PATH" "$BACKUP_PATH"
chown -R "$PUID:$PGID" "$MEDIA_PATH_1/peertube" "$MEDIA_PATH_1/ytdl"
chmod -R 755 "$CONFIG_PATH" "$BACKUP_PATH"

# Postgres (PeerTube e ytdl-material, mesma imagem base) roda com usuário
# interno próprio UID/GID 70, não PUID/PGID - precisa ser reaplicado por cima
chown -R 70:70 "$CONFIG_PATH/peertube/postgres" "$CONFIG_PATH/ytdl-material/postgres"

# App do PeerTube roda com usuário interno próprio UID/GID 999
chown -R 999:999 "$MEDIA_PATH_1/peertube" "$CONFIG_PATH/peertube/config"

echo ""
echo "=== Estrutura de diretórios pronta ==="
echo "Próximo passo: confira o .env (senhas, PEERTUBE_HOSTNAME, etc.) e suba a stack:"
echo "  docker compose up -d"
