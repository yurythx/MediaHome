# Deploy Stack MediaHome - Ubuntu 24.04 + aaPanel

Este guia cobre o que é **específico de rodar em produção num servidor Ubuntu com aaPanel**: preparo do host, montagem de discos, firewall, proxy reverso/domínios e SSL.

Para tudo que é comum a qualquer ambiente (o que cada serviço faz, portas, `.env`, primeiro acesso a cada app, backup manual, troubleshooting geral, comandos do dia a dia), veja o [README.md](README.md) — este documento não repete esse conteúdo.

## Pré-requisitos
- Ubuntu 24.04 LTS
- aaPanel instalado (ou você vai instalar no passo 5)
- Espaço em disco adequado para mídia (recomendado: 1TB+)
- IP do servidor (ex: `192.168.0.121`) e, se for expor externamente, um domínio próprio

## 1. Instalar Docker
```bash
sudo apt update && sudo apt upgrade -y

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER && newgrp docker

# Verificar instalação
docker --version
docker compose version
```

## 2. Preparar Discos e Diretórios

### Estrutura de diretórios
```bash
sudo mkdir -p /mnt/dados/{filmes,series,musicas,quadrinhos}
sudo mkdir -p /mnt/dados2/{filmes,series,musicas,quadrinhos}
sudo mkdir -p /mnt/externo /mnt/backup
sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,portainer,qbittorrent}
sudo mkdir -p /mnt/config/peertube/{data,config,postgres,redis}
sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/dados2 /mnt/externo /mnt/backup
sudo chmod -R 755 /mnt/config /mnt/dados /mnt/dados2 /mnt/externo /mnt/backup
```

### Discos locais (ext4) — montagem automática via fstab
```bash
# Identificar discos e obter UUIDs
lsblk -f
sudo blkid

# Editar fstab
sudo nano /etc/fstab

# Adicionar linhas (substitua pelos UUIDs reais)
UUID=seu-uuid-dados  /mnt/dados   ext4  defaults,noatime  0  2
UUID=seu-uuid-dados2 /mnt/dados2  ext4  defaults,noatime  0  2

# Aplicar
sudo systemctl daemon-reload
sudo mount -a
```

### Alternativa: compartilhamento SMB remoto (outro servidor)
```bash
sudo apt install -y cifs-utils

sudo bash -c 'cat >/etc/samba-cred <<EOF
username=seu_usuario
password=sua_senha
EOF'
sudo chmod 600 /etc/samba-cred

sudo nano /etc/fstab
# Adicionar:
//IP_SERVIDOR/Dados  /mnt/dados  cifs  credentials=/etc/samba-cred,uid=1000,gid=1000,vers=3.0,iocharset=utf8,file_mode=0644,dir_mode=0755  0  0
//IP_SERVIDOR/Dados2 /mnt/dados2 cifs  credentials=/etc/samba-cred,uid=1000,gid=1000,vers=3.0,iocharset=utf8,file_mode=0644,dir_mode=0755  0  0

sudo systemctl daemon-reload
sudo mount -a
```

## 3. Configurar Firewall (UFW)
```bash
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 8096/tcp    # Jellyfin
sudo ufw allow 8082/tcp    # Komga
sudo ufw allow 4533/tcp    # Navidrome
sudo ufw allow 445/tcp     # Samba
sudo ufw allow 9020/tcp    # Portainer
sudo ufw allow 8080/tcp    # qBittorrent Web UI
sudo ufw allow 6881/tcp    # Torrent TCP
sudo ufw allow 6881/udp    # Torrent UDP
sudo ufw allow 9000/tcp    # PeerTube
sudo ufw --force enable
```

> Se for expor a stack via Cloudflare Tunnel (veja passo 6), as portas de cada serviço não precisam ficar abertas para a internet — mantenha-as restritas à rede local e libere no UFW apenas SSH/HTTP/HTTPS.

## 4. Clonar e Subir a Stack
```bash
git clone <URL_DO_REPOSITORIO>
cd MediaHome

# Configurar variáveis de ambiente (obrigatório)
cp .env.example .env
nano .env   # defina SAMBA_PASSWORD, PEERTUBE_HOSTNAME, PEERTUBE_ADMIN_EMAIL,
            # PEERTUBE_SECRET e PEERTUBE_DB_PASSWORD, e ajuste HOST_IP/caminhos

docker compose up -d
docker compose ps
```

> ⚠️ **PeerTube**: `PEERTUBE_HOSTNAME` fica definitivo assim que você roda o `up` acima. Decida agora o domínio final (ex: `clips.seudominio.com`, o mesmo que vai configurar no passo 5) antes de subir a stack pela primeira vez — trocar depois exige apagar `/mnt/config/peertube/postgres` e recomeçar do zero.

Veja o [README.md](README.md#primeiro-acesso) para o primeiro acesso/configuração inicial de cada serviço (Jellyfin, Komga, Navidrome, Samba, qBittorrent, Portainer) — os passos são os mesmos, só que aqui você acessa pelo domínio configurado no passo 5 em vez de `localhost`.

## 5. Configurar aaPanel (Proxy Reverso + SSL)

### Instalar aaPanel
```bash
wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
sudo bash install.sh
```

### Criar sites com proxy reverso
No painel aaPanel, instale o Nginx via App Store e crie um site por serviço, apontando para a porta local:
- `jellyfin.seudominio.com` → `http://127.0.0.1:8096`
- `komga.seudominio.com` → `http://127.0.0.1:8082`
- `navidrome.seudominio.com` → `http://127.0.0.1:4533`
- `portainer.seudominio.com` → `http://127.0.0.1:9020`
- `torrent.seudominio.com` → `http://127.0.0.1:8080`
- `PEERTUBE_HOSTNAME` (ex: `clips.seudominio.com`, o valor definido no `.env`) → `http://127.0.0.1:9000`

Exemplo de configuração Nginx para o Jellyfin (streaming precisa de `proxy_buffering off` e WebSocket habilitado):
```nginx
location / {
    proxy_pass http://127.0.0.1:8096;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_buffering off;
    proxy_request_buffering off;
    client_max_body_size 0;

    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

> O PeerTube usa o mesmo modelo de proxy do Jellyfin acima (`proxy_buffering off`, `client_max_body_size 0`, WebSocket habilitado) — uploads de vídeo grandes travam com o `client_max_body_size` padrão do Nginx se você não zerar esse limite.

### Configurar SSL
Para cada site criado, configure certificado SSL via Let's Encrypt (aba SSL do site no aaPanel) e habilite redirecionamento HTTPS.

## 6. Alternativa: Cloudflare Tunnel (Zero Trust)

Se preferir não abrir portas no roteador nem configurar domínios/proxy no aaPanel:
1. Abra o painel do Cloudflare Zero Trust → **Access** → **Tunnels**.
2. Edite o túnel do seu servidor e, na aba **Public Hostname**, adicione um hostname por serviço, por exemplo:
   - **Public Hostname**: `torrent.seudominio.com`
   - **Service Type**: `HTTP`
   - **URL**: `192.168.0.121:8080` (IP local do servidor + porta do serviço)
3. Repita para os demais serviços que quiser expor.
4. O tráfego do túnel é criptografado e repassado via agente local — não é necessário abrir portas no roteador, e as portas de gerenciamento (Portainer, etc.) podem ficar restritas ao IP local no UFW.

## 7. Verificação
```bash
# Local
curl -I http://localhost:8096  # Jellyfin
curl -I http://localhost:8082  # Komga
curl -I http://localhost:4533  # Navidrome
curl -I http://localhost:9020  # Portainer
curl -I http://localhost:8080  # qBittorrent
curl -I http://localhost:9000  # PeerTube
smbclient -L localhost -U seu_usuario

# Via domínio (após configurar aaPanel/SSL)
curl -I https://jellyfin.seudominio.com
```

## Hardware Recomendado
- **CPU**: mínimo 4 cores (transcodificação de vídeo no Jellyfin **e** no PeerTube consome bastante — cada upload no PeerTube dispara transcodificação em múltiplas resoluções)
- **RAM**: mínimo 8GB (o PeerTube sozinho já soma 3 containers: app + Postgres + Redis)
- **Armazenamento**: SSD para `/mnt/config`, HDD para mídia
- **Rede**: Gigabit Ethernet recomendado

## Problemas Específicos deste Ambiente
| Sintoma | Verificar |
|---|---|
| Proxy reverso não funciona | Configuração do site no aaPanel, certificado SSL válido |
| Samba não conecta de fora da rede local | Firewall UFW, se a porta 445 está exposta (normalmente não deveria estar, prefira VPN) |
| Discos não montam após reiniciar | `sudo mount -a` e conferir UUIDs em `/etc/fstab` com `sudo blkid` |
| PeerTube não abre / erro de domínio | `PEERTUBE_HOSTNAME` no `.env` precisa ser idêntico ao domínio configurado no site do aaPanel; se você errou o valor no primeiro `up`, é preciso apagar `/mnt/config/peertube/postgres` e recomeçar |

Para os demais problemas (containers, permissões, backup, cada serviço individualmente), veja a seção "🛠️ Solução de Problemas" do [README.md](README.md#solução-de-problemas).

---

**Nota**: Substitua `seudominio.com`, `192.168.0.121` e os caminhos de disco pelos valores reais do seu servidor.
