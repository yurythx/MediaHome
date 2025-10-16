# 🎬 Stack MediaHome - Servidor de Mídia Doméstico

Esta stack oferece uma solução completa de servidor de mídia doméstico, centralizando filmes, séries, música, quadrinhos e e-books com acesso via web e compartilhamento de arquivos.

## 📋 Visão Geral

### Componentes da Stack
- **🎬 Jellyfin**: Servidor de streaming de vídeos (filmes e séries)
- **📚 Komga**: Biblioteca digital de quadrinhos e mangás
- **🎵 Navidrome**: Servidor de streaming de música
- **📁 Samba**: Compartilhamento de arquivos via SMB/CIFS
- **🌐 Portainer**: Interface de gerenciamento Docker
- **💾 Backup**: Sistema automatizado de backup das configurações

### Arquitetura
- **Rede**: Todos os serviços compartilham a rede local `mediahome_default`
- **Volumes**: Dados persistidos em volumes locais Docker
- **Armazenamento**: Bind mounts para `/mnt/dados` e `/mnt/dados2`
- **Configurações**: Centralizadas em `/mnt/config`
- **Backups**: Automatizados diariamente em `/mnt/backup`

## 🚀 Início Rápido

### Pré-requisitos
- ✅ Docker Desktop (Windows) ou Docker Engine (Linux)
- ✅ Docker Compose v2+
- ✅ Portas disponíveis: 8096, 8082, 4533, 9020, 445
- ✅ Estrutura de diretórios configurada (veja seção abaixo)

### Estrutura de Diretórios Obrigatória
```powershell
# Windows (PowerShell como Administrador)
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\jellyfin"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\komga"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\navidrome"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\portainer"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\dados"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\dados2"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\backup"
```

```bash
# Linux/Ubuntu
sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,portainer}
sudo mkdir -p /mnt/dados /mnt/dados2 /mnt/backup
sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
```

### Instalação e Execução
1. **Clone ou baixe o projeto**
2. **Configure a estrutura de diretórios** (veja acima)
3. **Execute a stack**:
```powershell
docker compose up -d
```

### Verificação do Status
```powershell
# Verificar containers em execução
docker compose ps

# Verificar logs de um serviço específico
docker compose logs jellyfin --tail 50
```

## 🌐 Acesso aos Serviços

| Serviço | URL Local | Porta | Descrição |
|---------|-----------|-------|-----------|
| **Jellyfin** | http://localhost:8096 | 8096 | Streaming de filmes e séries |
| **Komga** | http://localhost:8082 | 8082 | Biblioteca de quadrinhos |
| **Navidrome** | http://localhost:4533 | 4533 | Streaming de música |
| **Portainer** | http://localhost:9020 | 9020 | Gerenciamento Docker |
| **Samba** | `\\localhost\Dados` | 445 | Compartilhamento de arquivos |

### Primeiro Acesso

#### 🎬 Jellyfin
1. Acesse http://localhost:8096
2. Configure conta de administrador
3. Adicione bibliotecas de mídia:
   - **Filmes**: `/media/dados/Filmes`
   - **Séries**: `/media/dados/Series`
   - **Música**: `/media/dados/Musica`
4. Configure metadados e scrapers

#### 📚 Komga
1. Acesse http://localhost:8082
2. Crie conta de administrador
3. Adicione bibliotecas:
   - **Quadrinhos**: `/data/Quadrinhos`
   - **Mangás**: `/data2/Mangas`
4. Configure leitura e metadados

#### 🎵 Navidrome
1. Acesse http://localhost:4533
2. Configure conta inicial
3. As pastas de música são detectadas automaticamente:
   - `/music` (dados)
   - `/music2` (dados2)
4. Execute rescan da biblioteca

#### 📁 Samba
- **Windows**: Acesse `\\localhost\Dados` e `\\localhost\Dados2`
- **Credenciais padrão**: `suporte` / `suporte123`
- **Compartilhamentos**:
  - `Dados` → `/mnt/dados`
  - `Dados2` → `/mnt/dados2`
  - `Config` → `/mnt/config`

> ⚠️ **IMPORTANTE**: Altere as credenciais padrão do Samba em produção!

## 🔧 Gerenciamento da Stack

### Comandos Básicos
```powershell
# Iniciar todos os serviços
docker compose up -d

# Parar todos os serviços
docker compose down

# Ver status dos containers
docker compose ps

# Ver logs de um serviço específico
docker compose logs [serviço] --tail 100

# Atualizar imagens e reiniciar
docker compose pull && docker compose up -d
```

### Gerenciamento Individual de Serviços
```powershell
# Iniciar serviço específico
docker compose -f jellyfin/jellyfin.yml up -d
docker compose -f komga/komga.yml up -d
docker compose -f navidrome/navidrome.yml up -d
docker compose -f fileserver/samba.yml up -d
docker compose -f portainer/portainer.yml up -d

# Parar serviço específico
docker compose -f jellyfin/jellyfin.yml down
```

### Estrutura de Volumes
Os dados são persistidos em volumes locais Docker:
- `mediahome_jellyfin_config` - Configurações do Jellyfin
- `mediahome_komga_config` - Configurações do Komga
- `mediahome_navidrome_config` - Configurações do Navidrome
- `mediahome_portainer_data` - Dados do Portainer
- `mediahome_backup_data` - Dados do sistema de backup

### Bind Mounts (Dados de Mídia)
- `/mnt/dados` → Disco principal de mídia
- `/mnt/dados2` → Disco secundário de mídia
- `/mnt/config` → Configurações dos serviços
- `/mnt/backup` → Backups automatizados

## 💾 Sistema de Backup Automatizado

### Características do Backup
- **Frequência**: A cada 24 horas (configurável)
- **Retenção**: 30 dias (configurável)
- **Formato**: Arquivos `.tar.gz` compactados
- **Localização**: `/mnt/backup/mediahome_config_YYYYMMDD_HHMMSS.tar.gz`
- **Conteúdo**: Todas as configurações dos serviços
- **Logs**: Auditoria completa em `/mnt/backup/backup.log`
- **Health Check**: Monitoramento automático

### Comandos de Backup
```powershell
# Verificar status do backup
docker compose logs backup-configs --tail 50

# Ver backups criados
ls /mnt/backup/*.tar.gz

# Ver log de auditoria
cat /mnt/backup/backup.log

# Forçar backup manual
docker exec backup-configs /backup.sh
```

### Configurar Frequência do Backup
Edite o arquivo `docker-compose.yml` na seção do serviço `backup-configs`:
```yaml
environment:
  - BACKUP_INTERVAL=86400    # 24 horas (em segundos)
  - RETENTION_DAYS=30        # Retenção em dias
```

**Exemplos de intervalos**:
- 6 horas: `21600`
- 12 horas: `43200`
- 24 horas: `86400` (padrão)
- 48 horas: `172800`

### Restaurar Backup
```powershell
# Parar todos os serviços
docker compose down

# Listar backups disponíveis
ls -lt /mnt/backup/mediahome_config_*.tar.gz

# Restaurar backup mais recente (Linux)
cd /mnt/backup
LATEST_BACKUP=$(ls -t mediahome_config_*.tar.gz | head -1)
tar -xzf $LATEST_BACKUP -C /mnt/config/

# Restaurar backup específico (Windows)
tar -xzf mediahome_config_20241016_140000.tar.gz -C /mnt/config/

# Ajustar permissões (Linux)
sudo chown -R 1000:1000 /mnt/config

# Reiniciar serviços
docker compose up -d
```

## 📁 Organização de Mídia Recomendada

### Estrutura de Pastas
```
/mnt/dados/
├── Filmes/
│   ├── Ação/
│   ├── Comédia/
│   └── Drama/
├── Series/
│   ├── Breaking Bad/
│   │   ├── Season 01/
│   │   └── Season 02/
│   └── Game of Thrones/
├── Musica/
│   ├── Rock/
│   ├── Pop/
│   └── Clássica/
└── Documentarios/

/mnt/dados2/
├── Quadrinhos/
│   ├── Marvel/
│   ├── DC/
│   └── Nacionais/
├── Mangas/
│   ├── Naruto/
│   ├── One Piece/
│   └── Attack on Titan/
└── Ebooks/
    ├── Ficção/
    ├── Técnicos/
    └── Biografias/
```

### Configurar Bibliotecas nos Apps

#### Jellyfin
1. Acesse **Dashboard → Libraries → Add Media Library**
2. Configure os caminhos:
   - **Filmes**: `/media/dados/Filmes`
   - **Séries**: `/media/dados/Series`
   - **Música**: `/media/dados/Musica`
   - **Documentários**: `/media/dados/Documentarios`

#### Komga
1. Acesse **Admin → Libraries → New Library**
2. Configure os caminhos:
   - **Quadrinhos**: `/data/Quadrinhos`
   - **Mangás**: `/data2/Mangas`

#### Navidrome
- Configuração automática para:
  - `/music` (mapeado para `/mnt/dados/Musica`)
  - `/music2` (mapeado para `/mnt/dados2/Musica`)

## 🔗 Integração e Configurações Avançadas

### Configurar Samba (Compartilhamento de Arquivos)

#### Alterar Credenciais Padrão
Edite o arquivo `fileserver/samba.yml`:
```yaml
command:
  - "-u"
  - "seu_usuario;sua_senha_segura"  # Altere estas credenciais
```

#### Acessar Compartilhamentos
**Windows**:
```cmd
# Via Explorer
\\SEU_IP\Dados
\\SEU_IP\Dados2

# Via linha de comando
net use Z: \\SEU_IP\Dados /user:seu_usuario sua_senha_segura
```

**Linux**:
```bash
# Instalar cliente SMB
sudo apt install -y smbclient cifs-utils

# Acessar via smbclient
smbclient //SEU_IP/Dados -U seu_usuario

# Montar permanentemente
sudo mount -t cifs //SEU_IP/Dados /mnt/dados_remoto \
  -o username=seu_usuario,password=sua_senha_segura,uid=1000,gid=1000,vers=3.0
```

**macOS**:
```bash
# Via Finder
# Go → Connect to Server: smb://SEU_IP/Dados
```

### Configurar Portainer
1. Acesse http://localhost:9020
2. Crie conta de administrador no primeiro acesso
3. Conecte ao Docker local (endpoint automático)
4. Gerencie containers, volumes e redes via interface web

### Monitoramento e Logs
```powershell
# Status geral da stack
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Uso de recursos
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Logs agregados
docker compose logs --tail=50 --follow

# Verificar saúde dos serviços
docker inspect --format='{{.Name}}: {{.State.Health.Status}}' $(docker ps -q)
```

## 🛠️ Solução de Problemas

### Problemas Comuns

#### Jellyfin não carrega
```powershell
# Verificar logs
docker compose logs jellyfin --tail 100

# Verificar permissões
ls -la /mnt/config/jellyfin
ls -la /mnt/dados

# Recriar container
docker compose restart jellyfin
```

#### Komga não encontra bibliotecas
```powershell
# Verificar logs
docker compose logs komga --tail 100

# Verificar caminhos internos
docker exec komga ls -la /data /data2

# Verificar permissões no host
sudo chown -R 1000:1000 /mnt/dados /mnt/dados2
```

#### Navidrome não detecta música
```powershell
# Verificar configuração
docker compose logs navidrome --tail 100

# Forçar rescan
# Acesse http://localhost:4533 → Settings → Library → Rescan

# Verificar caminhos
docker exec navidrome ls -la /music /music2
```

#### Samba inacessível
```powershell
# Verificar se o serviço está rodando
docker compose ps | findstr samba

# Verificar logs
docker compose logs samba --tail 100

# Testar conectividade (Windows)
Test-NetConnection -ComputerName localhost -Port 445

# Verificar conflito de portas
netstat -an | findstr ":445"
```

#### Backup não funciona
```powershell
# Verificar logs do backup
docker compose logs backup-configs --tail 100

# Verificar permissões
ls -la /mnt/backup
sudo chown -R 1000:1000 /mnt/backup

# Verificar espaço em disco
df -h /mnt/backup

# Executar backup manual
docker exec backup-configs /backup.sh
```

### Problemas de Permissão
```bash
# Linux - Ajustar permissões
sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
sudo chmod -R 755 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
```

```powershell
# Windows - Verificar compartilhamento
# Certifique-se de que as pastas estão compartilhadas no Docker Desktop
# Settings → Resources → File Sharing
```

### Recriar Containers
```powershell
# Recriar todos os containers
docker compose down
docker compose up -d --force-recreate

# Recriar container específico
docker compose up -d --force-recreate jellyfin
```

## 🔒 Segurança

### Recomendações de Segurança
- ✅ Altere **todas** as credenciais padrão (especialmente Samba)
- ✅ Use senhas fortes (mínimo 16 caracteres)
- ✅ Configure firewall para limitar acesso às portas
- ✅ Use VPN para acesso remoto
- ✅ Mantenha backups regulares e criptografados
- ✅ Mantenha as imagens Docker atualizadas
- ✅ Configure HTTPS para acesso externo

### Configuração de Firewall
```powershell
# Windows Firewall
New-NetFirewallRule -DisplayName "Jellyfin" -Direction Inbound -Protocol TCP -LocalPort 8096 -Action Allow
New-NetFirewallRule -DisplayName "Komga" -Direction Inbound -Protocol TCP -LocalPort 8082 -Action Allow
New-NetFirewallRule -DisplayName "Navidrome" -Direction Inbound -Protocol TCP -LocalPort 4533 -Action Allow
New-NetFirewallRule -DisplayName "Portainer" -Direction Inbound -Protocol TCP -LocalPort 9020 -Action Allow
New-NetFirewallRule -DisplayName "Samba" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow
```

```bash
# Linux UFW
sudo ufw allow 8096/tcp  # Jellyfin
sudo ufw allow 8082/tcp  # Komga
sudo ufw allow 4533/tcp  # Navidrome
sudo ufw allow 9020/tcp  # Portainer
sudo ufw allow 445/tcp   # Samba
sudo ufw reload
```

### Exposição Segura (Reverse Proxy)
Para expor os serviços na internet, use um reverse proxy com SSL:
```nginx
# Exemplo de configuração Nginx
server {
    listen 443 ssl;
    server_name jellyfin.seudominio.com;
    
    location / {
        proxy_pass http://127.0.0.1:8096;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support para Jellyfin
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## 📊 Monitoramento e Métricas

### Portainer - Interface de Gerenciamento
- **URL**: http://localhost:9020
- **Funcionalidades**:
  - Visualização de containers, volumes e redes
  - Logs centralizados de todos os serviços
  - Monitoramento de recursos (CPU, RAM, rede)
  - Gerenciamento visual de stacks
  - Atualizações de imagens via interface
  - Estatísticas de uso e performance

### Comandos de Monitoramento
```powershell
# Status detalhado da stack
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"

# Uso de recursos em tempo real
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Verificar volumes
docker volume ls | findstr mediahome

# Verificar espaço em disco
docker system df

# Logs agregados com timestamp
docker compose logs --timestamps --tail=100
```

### Health Checks
```powershell
# Verificar saúde de todos os containers
docker ps --format "table {{.Names}}\t{{.Status}}"

# Verificar container específico
docker inspect jellyfin --format='{{.State.Health.Status}}'

# Testar conectividade dos serviços
Test-NetConnection -ComputerName localhost -Port 8096  # Jellyfin
Test-NetConnection -ComputerName localhost -Port 8082  # Komga
Test-NetConnection -ComputerName localhost -Port 4533  # Navidrome
Test-NetConnection -ComputerName localhost -Port 9020  # Portainer
```

## 🚀 Implantação em Produção (Ubuntu + aaPanel)

### 1. Preparar Servidor Ubuntu
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
sudo apt install -y docker.io docker-compose-plugin git curl
sudo usermod -aG docker $USER && newgrp docker

# Verificar instalação
docker --version
docker compose version
```

### 2. Configurar Estrutura de Diretórios
```bash
# Criar diretórios
sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,portainer}
sudo mkdir -p /mnt/dados /mnt/dados2 /mnt/backup

# Ajustar permissões
sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
sudo chmod -R 755 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
```

### 3. Configurar Montagem de Discos
#### Para Discos Locais (ext4)
```bash
# Identificar discos
lsblk -f

# Obter UUIDs
sudo blkid

# Configurar montagem automática
sudo nano /etc/fstab

# Adicionar linhas (substitua pelos UUIDs reais)
UUID=seu-uuid-dados  /mnt/dados   ext4  defaults,noatime  0  2
UUID=seu-uuid-dados2 /mnt/dados2  ext4  defaults,noatime  0  2

# Aplicar configuração
sudo systemctl daemon-reload
sudo mount -a
```

#### Para Compartilhamentos SMB Remotos
```bash
# Instalar cliente CIFS
sudo apt install -y cifs-utils

# Criar arquivo de credenciais
sudo bash -c 'cat >/etc/samba-cred <<EOF
username=seu_usuario
password=sua_senha
EOF'
sudo chmod 600 /etc/samba-cred

# Configurar montagem automática
sudo nano /etc/fstab

# Adicionar linhas
//IP_SERVIDOR/Dados  /mnt/dados  cifs  credentials=/etc/samba-cred,uid=1000,gid=1000,vers=3.0,iocharset=utf8,file_mode=0644,dir_mode=0755  0  0
//IP_SERVIDOR/Dados2 /mnt/dados2 cifs  credentials=/etc/samba-cred,uid=1000,gid=1000,vers=3.0,iocharset=utf8,file_mode=0644,dir_mode=0755  0  0

# Aplicar configuração
sudo systemctl daemon-reload
sudo mount -a
```

### 4. Clonar e Configurar Projeto
```bash
# Clonar projeto
git clone <URL_DO_REPOSITORIO>
cd MediaHome

# Ajustar configurações se necessário
# Editar docker-compose.yml para caminhos específicos
```

### 5. Configurar Firewall
```bash
# Configurar UFW
sudo ufw allow 8096/tcp  # Jellyfin
sudo ufw allow 8082/tcp  # Komga
sudo ufw allow 4533/tcp  # Navidrome
sudo ufw allow 9020/tcp  # Portainer
sudo ufw allow 445/tcp   # Samba
sudo ufw reload
```

### 6. Iniciar Stack
```bash
# Iniciar todos os serviços
docker compose up -d

# Verificar status
docker compose ps

# Verificar logs
docker compose logs --tail=50
```

### 7. Configurar aaPanel (Reverse Proxy)
1. **Instalar aaPanel**:
```bash
wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
sudo bash install.sh
```

2. **Configurar Nginx via aaPanel**:
   - Acesse o painel aaPanel
   - Instale Nginx via App Store
   - Crie sites para cada serviço:
     - `jellyfin.seudominio.com` → `http://127.0.0.1:8096`
     - `komga.seudominio.com` → `http://127.0.0.1:8082`
     - `music.seudominio.com` → `http://127.0.0.1:4533`
     - `portainer.seudominio.com` → `http://127.0.0.1:9020`

3. **Configurar SSL**:
   - Para cada site, configure SSL via Let's Encrypt
   - Habilite redirecionamento HTTPS

### 8. Teste e Validação
```bash
# Testar conectividade local
curl -I http://localhost:8096  # Jellyfin
curl -I http://localhost:8082  # Komga
curl -I http://localhost:4533  # Navidrome
curl -I http://localhost:9020  # Portainer

# Verificar Samba
smbclient -L localhost -U seu_usuario

# Verificar backups
ls -la /mnt/backup/
```

## 📚 Recursos Adicionais

### Documentação Oficial
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Komga Documentation](https://komga.org/guides/)
- [Navidrome Documentation](https://www.navidrome.org/docs/)
- [Samba Documentation](https://www.samba.org/samba/docs/)
- [Portainer Documentation](https://docs.portainer.io/)

### Estrutura do Projeto
```
MediaHome/
├── docker-compose.yml          # Orquestração principal
├── README.md                   # Esta documentação
├── jellyfin/
│   └── jellyfin.yml           # Serviço Jellyfin independente
├── komga/
│   └── komga.yml              # Serviço Komga independente
├── navidrome/
│   └── navidrome.yml          # Serviço Navidrome independente
├── fileserver/
│   └── samba.yml              # Serviço Samba independente
├── portainer/
│   └── portainer.yml          # Interface de gerenciamento
└── backup/
    └── backup.yml             # Sistema de backup
```

## 🎯 Casos de Uso

### Streaming Doméstico
1. **Organização**: Centralize toda mídia em `/mnt/dados` e `/mnt/dados2`
2. **Acesso**: Streaming via Jellyfin para TVs, tablets e smartphones
3. **Música**: Navidrome para streaming de música em qualquer dispositivo
4. **Leitura**: Komga para biblioteca digital de quadrinhos e mangás

### Compartilhamento de Arquivos
1. **Upload**: Adicione novos arquivos via Samba
2. **Organização**: Mantenha estrutura de pastas consistente
3. **Acesso**: Compartilhe com família via rede local
4. **Backup**: Sistema automatizado protege configurações

### Gerenciamento Centralizado
1. **Monitoramento**: Portainer para visão geral da infraestrutura
2. **Logs**: Centralizados para troubleshooting
3. **Atualizações**: Gerenciamento de imagens via interface web
4. **Recursos**: Monitoramento de CPU, RAM e armazenamento

## 🚀 Próximos Passos

### Melhorias Recomendadas
- [ ] Implementar Traefik para roteamento automático
- [ ] Configurar autenticação SSO (Authelia/Keycloak)
- [ ] Implementar monitoramento com Prometheus/Grafana
- [ ] Configurar backup remoto (Rclone/Restic)
- [ ] Implementar transcodificação de vídeo otimizada
- [ ] Configurar CDN para acesso externo

### Integrações Futuras
- [ ] Sonarr/Radarr para automação de downloads
- [ ] Plex/Emby como alternativa ao Jellyfin
- [ ] Nextcloud para sincronização de arquivos
- [ ] Home Assistant para automação doméstica
- [ ] VPN (WireGuard) para acesso remoto seguro

---

> 💡 **Dica**: Esta stack foi configurada para usar volumes e redes locais, garantindo isolamento e facilidade de deploy. Todos os dados de mídia são acessados via bind mounts para máxima performance.

> ⚠️ **Importante**: Sempre altere as credenciais padrão do Samba e mantenha backups regulares. Para acesso externo, use sempre HTTPS e autenticação adequada.