# 🎬 Stack MediaHome - Servidor de Mídia Doméstico

Esta stack oferece uma solução completa de servidor de mídia doméstico, centralizando filmes, séries, música, quadrinhos e e-books com acesso via web e compartilhamento de arquivos.

## 📋 Visão Geral

### Componentes da Stack
- **🎬 Jellyfin**: Servidor de streaming de vídeos (filmes e séries)
- **📚 Komga**: Biblioteca digital de quadrinhos e mangás
- **🎵 Navidrome**: Servidor de streaming de música
- **📁 Samba**: Compartilhamento de arquivos via SMB/CIFS
- **🌐 Portainer**: Interface de gerenciamento Docker
- **📥 qBittorrent**: Cliente de torrent integrado para downloads diretos nos HDs
- **📹 PeerTube**: Plataforma de vídeos estilo YouTube, para hospedar seus próprios clipes

### Arquitetura
- **Rede**: Todos os serviços compartilham a rede Docker `mediahome` (bridge), declarada em cada `.yml` para permitir subir cada serviço isoladamente
- **Volumes**: Dados persistidos via bind mount para o host (sem volumes nomeados órfãos)
- **Armazenamento**: Bind mounts para `/mnt/dados` e `/mnt/dados2`
- **Configurações**: Centralizadas em `/mnt/config`
- **Backups**: Realizados de forma manual/agendada para economizar espaço
- **Configuração**: Todas as portas, caminhos e credenciais vêm do arquivo `.env` (veja `.env.example`) — nada de credencial fixa no código

## 🚀 Início Rápido

### Pré-requisitos
- ✅ Docker Desktop (Windows) ou Docker Engine (Linux)
- ✅ Docker Compose v2+
- ✅ Portas disponíveis: 8096, 8082, 4533, 9020, 445, 8080, 6881, 9000
- ✅ Estrutura de diretórios configurada (veja seção abaixo)

### Estrutura de Diretórios Obrigatória
```powershell
# Windows (PowerShell como Administrador)
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\jellyfin"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\komga"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\navidrome"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\portainer"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\qbittorrent"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\peertube\config"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\peertube\postgres"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\config\peertube\redis"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\dados"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\dados\peertube"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\dados2"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\externo"
New-Item -ItemType Directory -Force -Path "C:\MediaHome\backup"
```

```bash
# Linux/Ubuntu
sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,portainer,qbittorrent}
sudo mkdir -p /mnt/config/peertube/{config,postgres,redis}
sudo mkdir -p /mnt/dados /mnt/dados2 /mnt/backup /mnt/externo
sudo mkdir -p /mnt/dados/peertube
sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup /mnt/externo
# O Postgres do PeerTube roda com um usuário interno próprio (UID/GID 70,
# não 1000) - sem isso, ele não consegue abrir os próprios arquivos de banco
sudo chown -R 70:70 /mnt/config/peertube/postgres
# O app do PeerTube roda com UID/GID 999 (também usuário interno próprio) -
# os vídeos ficam em /mnt/dados/peertube (disco de mídia, não o de config)
sudo chown -R 999:999 /mnt/dados/peertube /mnt/config/peertube/config
```

### Instalação e Execução
1. **Clone ou baixe o projeto**
2. **Configure a estrutura de diretórios** (veja acima)
3. **Configure as variáveis de ambiente**:
```bash
cp .env.example .env
# edite o .env: defina SAMBA_PASSWORD, PEERTUBE_HOSTNAME, PEERTUBE_ADMIN_EMAIL,
# PEERTUBE_SECRET e PEERTUBE_DB_PASSWORD (todos obrigatórios) e ajuste HOST_IP/paths
# conforme seu servidor. PEERTUBE_HOSTNAME é definitivo após o primeiro "up" - veja
# a seção do PeerTube mais abaixo antes de decidir o valor.
```
4. **Execute a stack**:
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
| **qBittorrent** | http://localhost:8080 | 8080 | Interface Web do Cliente Torrent |
| **PeerTube** | http://localhost:9000 | 9000 | Plataforma de vídeos (seus clipes) |

### Primeiro Acesso

#### 🎬 Jellyfin
1. Acesse http://localhost:8096
2. Configure conta de administrador
3. Adicione bibliotecas de mídia:
   - **Filmes**: `/media/dados/Filmes`
   - **Séries**: `/media/dados/Series`
   - **Música**: `/media/dados/Musica`
   - **Disco externo**: `/media/externo` (o que estiver salvo em `/mnt/externo`)
4. Configure metadados e scrapers

#### 📚 Komga
1. Acesse http://localhost:8082
2. Crie conta de administrador
3. Adicione bibliotecas:
   - **Quadrinhos**: `/data/Quadrinhos`
   - **Mangás**: `/data2/Mangas`
   - **Disco externo**: `/data3` (o que estiver salvo em `/mnt/externo`)
4. Configure leitura e metadados

#### 🎵 Navidrome
1. Acesse http://localhost:4533
2. Configure conta inicial
3. As pastas de música são detectadas automaticamente:
   - `/music` (dados)
   - `/music2` (dados2)
   - `/music3` (disco externo)
4. Execute rescan da biblioteca

#### 📁 Samba
- **Windows**: Acesse `\\localhost\Dados`, `\\localhost\Dados2` e `\\localhost\Externo`
- **Credenciais**: definidas em `SAMBA_USER`/`SAMBA_PASSWORD` no seu `.env` (não há mais senha padrão fixa no código — o container recusa subir se `SAMBA_PASSWORD` não estiver definida)
- **Compartilhamentos**:
  - `Dados` → `/mnt/dados`
  - `Dados2` → `/mnt/dados2`
  - `Externo` → `/mnt/externo`
  - `Config` → configs individuais de cada serviço (**exceto** o banco de dados do PeerTube, que não é compartilhado de propósito - veja aviso abaixo)

> ⚠️ **IMPORTANTE**: Use uma senha forte em `SAMBA_PASSWORD` e nunca commite o arquivo `.env`.

#### 📹 PeerTube
1. Acesse `http://SEU_IP:9000` (localmente) ou `https://SEU_DOMÍNIO` (via aaPanel, veja [DEPLOY_UBUNTU_AAPANEL.md](DEPLOY_UBUNTU_AAPANEL.md))
2. O usuário admin é `root` — a senha inicial é gerada automaticamente e aparece no log do container:
   ```bash
   docker compose logs peertube | grep -A1 "Username: root"
   ```
   Ou redefina com:
   ```bash
   docker compose exec -u peertube peertube npm run reset-password -- -u root
   ```
3. Troque a senha em **Minha conta → Configurações**.
4. Faça upload dos clipes em **Publicar → Enviar um vídeo**.

> ⚠️ **IMPORTANTE**: `PEERTUBE_HOSTNAME` (no `.env`) é definitivo após o primeiro `docker compose up` — o PeerTube não suporta trocar de domínio depois sem apagar o banco (`/mnt/config/peertube/postgres`) e recomeçar do zero. Decida o domínio final antes de subir este serviço pela primeira vez.

##### Enviar vários clipes de uma vez (sem arrastar um por um na web)
O PeerTube **não** escaneia pastas automaticamente como o Jellyfin — cada vídeo precisa ser enviado explicitamente, um a um, através da API. Pra não fazer isso manualmente na interface web, use `peertube-cli` (roda **no próprio servidor Ubuntu**, que já tem acesso nativo a `/mnt/dados`, `/mnt/dados2` e `/mnt/externo`, sem precisar de nada dentro do container):

```bash
# 0. Conferir se o Node.js >= 22 já está instalado (requisito do peertube-cli)
node --version
# Se não tiver Node.js ou a versão for menor que 22, instale com:
#   curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
#   sudo apt install -y nodejs

# 1. Instalar o peertube-cli (uma vez só)
sudo npm install -g @peertube/peertube-cli

# 2. Salvar as credenciais - DUAS entradas, uma pro domínio público (uso geral)
#    e outra pro endereço local (usada pelo bulk-upload.sh, veja aviso abaixo)
peertube-cli auth add -u https://SEU_PEERTUBE_HOSTNAME -U root --password 'sua_senha'
peertube-cli auth add -u http://localhost:9000 -U root --password 'sua_senha'

# 3a. Enviar um vídeo específico (pelo domínio público, arquivo pequeno)
peertube-cli upload -f /mnt/dados/Filmes/clipe.mp4 -n "Nome do vídeo" -P 2

# 3b. Ou enviar TODOS os vídeos de uma pasta de uma vez, com o script incluído no repositório:
cd /home/suporte/MediaHome
./peertube/bulk-upload.sh "/mnt/dados/Series/Ninja Kamui"
```
`-P 2` = privacidade "Não listado" (recomendado para uso pessoal — veja o aviso sobre federação/ActivityPub mais abaixo). Use `-P 1` para Público ou `-P 3` para Privado. O script `bulk-upload.sh` varre a pasta inteira (`.mp4`, `.mkv`, `.webm`, `.avi`, `.mov`), envia cada arquivo com `--no-wait-transcoding` (não trava esperando cada vídeo terminar de transcodificar antes de mandar o próximo) e grava um log dos que falharem.

> ⚠️ **Vídeos grandes falhando com "user quota is exceeded or video file is too big"**: essa é a mensagem genérica que o `peertube-cli` mostra pra **qualquer** erro `413 Payload Too Large` - não é necessariamente sobre cota. O `peertube-cli upload` sempre manda o arquivo inteiro numa única requisição HTTP (não existe modo "resumable"/em pedaços nessa ferramenta, só na interface web). Se a stack for exposta via **Cloudflare Tunnel**, que tem limite fixo de ~100MB por requisição, vídeos grandes estouram esse limite. Por isso o `bulk-upload.sh` já aponta pro endereço **local** (`http://localhost:9000`, configurável via `PEERTUBE_LOCAL_URL`) em vez do domínio público — rodando no próprio servidor, isso contorna o Cloudflare completamente. Certifique-se de ter rodado o `auth add -u http://localhost:9000` do passo 2 antes de usar o script.

> 💡 **Roda de novo sem medo de duplicar**: todo arquivo enviado com sucesso é registrado em `enviados_peertube.log` (fica salvo na pasta onde você roda o script). Se você rodar `bulk-upload.sh` de novo na mesma pasta - por exemplo, depois de adicionar vídeos novos - ele pula automaticamente quem já foi enviado antes, sem duplicar.

> ⚠️ **Rate limit da API**: o PeerTube limita a API geral a 50 requisições/10s por padrão — em teoria isso não deveria valer pra o usuário `root`/admin autenticado, mas na prática um upload em massa consegue esbarrar nisso mesmo assim. Já aumentamos o limite via `PEERTUBE_RATES_LIMIT_API_MAX` no `.env` (padrão 1000, bem acima do 50 original) porque este é um servidor pessoal de um usuário só, não uma instância pública multiusuário. O script também espera alguns segundos entre cada envio como camada extra de segurança (ajustável na variável `SLEEP_SEGUNDOS` no topo do arquivo) e detecta um 429 pra pausar mais ainda se acontecer. Se mesmo assim algum falhar, reenvie **só os que falharam** (sem duplicar os que já deram certo):
> ```bash
> ./peertube/bulk-upload.sh --retry falhas_upload_20260716_194854.log
> ```
> Se estiver rodando uma instância já configurada antes desta mudança, edite o `.env` e rode `docker compose up -d --force-recreate peertube` para aplicar o novo limite.

> ⚠️ **Vídeos grandes falham com "user quota is exceeded or video file is too big"**: essa é a mensagem genérica que o `peertube-cli` mostra pra **qualquer** erro `413 Payload Too Large` — não é necessariamente sobre cota. Se você expõe o PeerTube via **Cloudflare Tunnel**, o Cloudflare tem um limite fixo de ~100MB por requisição, e o upload "resumable" manda o vídeo em pedaços (chunks) cujo tamanho o PeerTube calcula automaticamente - podendo passar de 100MB pra arquivos grandes. `PEERTUBE_UPLOAD_CHUNK_SIZE` no `.env` fixa esse tamanho bem abaixo do limite (padrão `50MB`). Depois de mudar, recrie o container: `docker compose up -d --force-recreate peertube`.

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
# (as versões estão fixadas em cada .yml — edite a tag antes de dar pull
#  se quiser subir de versão; "pull" sozinho não traz release nova)
docker compose pull && docker compose up -d
```

### Gerenciamento Individual de Serviços
Rode a partir da raiz do projeto e sempre com `--env-file .env` — sem essa flag, o Compose procura o `.env` dentro da pasta do serviço (ex: `jellyfin/.env`) em vez da raiz, e o Samba recusa subir por não achar `SAMBA_PASSWORD`.
```powershell
# Iniciar serviço específico
docker compose --env-file .env -f jellyfin/jellyfin.yml up -d
docker compose --env-file .env -f komga/komga.yml up -d
docker compose --env-file .env -f navidrome/navidrome.yml up -d
docker compose --env-file .env -f fileserver/samba.yml up -d
docker compose --env-file .env -f portainer/portainer.yml up -d
docker compose --env-file .env -f qbittorrent/qbittorrent.yml up -d
docker compose --env-file .env -f peertube/peertube.yml up -d

# Parar serviço específico
docker compose --env-file .env -f jellyfin/jellyfin.yml down
```

### Estrutura de Volumes
Os dados são persistidos em volumes locais Docker:
- `mediahome_jellyfin_config` - Configurações do Jellyfin
- `mediahome_komga_config` - Configurações do Komga
- `mediahome_navidrome_config` - Configurações do Navidrome
- `mediahome_portainer_data` - Dados do Portainer

### Bind Mounts (Dados de Mídia)
- `/mnt/dados` → Disco principal de mídia (inclui `/mnt/dados/peertube`, onde ficam os vídeos enviados ao PeerTube - de propósito no disco de mídia, não no de config)
- `/mnt/dados2` → Disco secundário de mídia
- `/mnt/config` → Configurações dos serviços (incluindo qBittorrent em `/mnt/config/qbittorrent` e PeerTube em `/mnt/config/peertube/{config,postgres,redis}`)
- `/mnt/backup` → Local para salvar os backups manuais

## 💾 Sistema de Backup Manual

Como os backups automáticos constantes ocupavam muito espaço em disco, o contêiner de backup automático foi removido. Os backups agora podem ser executados manualmente no host quando você preferir.

> ⚠️ **O backup abaixo cobre só `/mnt/config`** (configurações). Os vídeos do PeerTube ficam em `/mnt/dados/peertube` — inclua esse caminho no seu backup do disco de mídia, não no comando de `/mnt/config` a seguir.

> ⚠️ **PeerTube usa banco de dados (Postgres)**: copiar `/mnt/config/peertube/postgres` com o container rodando pode gerar um backup corrompido/inconsistente (cópia "a quente" dos arquivos do banco). Pare o Postgres do PeerTube antes de rodar o `tar` abaixo:
> ```bash
> docker compose stop peertube peertube-postgres
> # ... rode o backup ...
> docker compose start peertube-postgres peertube
> ```
> Os demais serviços (Jellyfin, Komga, Navidrome, Samba, qBittorrent, Portainer) não usam banco de dados e podem ser copiados com tudo rodando sem esse risco.

### Criar Backup Manual (Linux/Ubuntu)
```bash
# Criar backup compactado das configurações
sudo tar -czf /mnt/backup/mediahome_config_$(date +%Y%m%d_%H%M%S).tar.gz -C /mnt/config .

# Listar backups criados
ls -lh /mnt/backup/*.tar.gz
```

### Criar Backup Manual (Windows)
```powershell
# Criar backup compactado das configurações no PowerShell
tar -czf C:\MediaHome\backup\mediahome_config_$(Get-Date -Format "yyyyMMdd_HHmmss").tar.gz -C C:\MediaHome\config .
```

### Restaurar Backup
```bash
# 1. Parar todos os serviços
docker compose down

# 2. Restaurar backup (Linux/Ubuntu)
sudo tar -xzf /mnt/backup/nome_do_arquivo.tar.gz -C /mnt/config/
# Ou Windows (PowerShell)
tar -xzf C:\MediaHome\backup\nome_do_arquivo.tar.gz -C C:\MediaHome\config\

# 3. Ajustar permissões (apenas Linux)
sudo chown -R 1000:1000 /mnt/config
sudo chown -R 70:70 /mnt/config/peertube/postgres  # Postgres usa UID/GID 70, não 1000
sudo chown -R 999:999 /mnt/dados/peertube /mnt/config/peertube/config  # PeerTube (app) usa UID/GID 999

# 4. Reiniciar serviços
docker compose up -d
```

## 📥 Download via Torrent (qBittorrent)

O serviço qBittorrent permite baixar arquivos torrent diretamente para os HDs mapeados.

### Características
- **Interface Web**: Acessível localmente em `http://localhost:8080` (ou IP do seu servidor).
- **Download Direto**: Mapeado para os mesmos discos que os outros serviços e para o HD externo:
  - `/downloads/dados` → `/mnt/dados` (Disco principal)
  - `/downloads/dados2` → `/mnt/dados2` (Disco secundário)
  - `/downloads/externo` → `/mnt/externo` (Disco externo)
- **Permissões de I/O**: Rodando com `PUID=1000` e `PGID=1000`, o que garante que todos os arquivos baixados tenham as permissões corretas para o Samba e o Jellyfin/Komga/Navidrome lerem ou moverem sem problemas.

### Configuração de Acesso Inicial
1. Acesse `http://localhost:8080` (Web UI).
2. O qBittorrent gera uma senha temporária única no log do contêiner por motivos de segurança. Para obter essa senha, execute:
   ```bash
   docker compose logs qbittorrent | grep "password"
   ```
3. Use o usuário padrão `admin` e a senha temporária encontrada no log.
4. Após o primeiro login, acesse **Tools -> Options -> Web UI** e configure uma senha definitiva segura.
5. Ao adicionar um torrent, altere o diretório de destino para `/downloads/dados/filmes`, `/downloads/dados/series`, etc., dependendo de onde deseja salvar.

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
   - **Disco externo**: `/media/externo`

#### Komga
1. Acesse **Admin → Libraries → New Library**
2. Configure os caminhos:
   - **Quadrinhos**: `/data/Quadrinhos`
   - **Mangás**: `/data2/Mangas`
   - **Disco externo**: `/data3`

#### Navidrome
- Configuração automática para:
  - `/music` (mapeado para `/mnt/dados/Musica`)
  - `/music2` (mapeado para `/mnt/dados2/Musica`)
  - `/music3` (mapeado para `/mnt/externo`)

## 🔗 Integração e Configurações Avançadas

### Configurar Samba (Compartilhamento de Arquivos)

#### Alterar Credenciais
Edite `SAMBA_USER` e `SAMBA_PASSWORD` no seu `.env` (não edite `fileserver/samba.yml` diretamente) e recrie o container:
```bash
docker compose up -d --force-recreate samba
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
docker exec komga ls -la /data /data2 /data3

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
docker exec navidrome ls -la /music /music2 /music3
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

#### PeerTube não sobe / fica reiniciando
```powershell
# Ver se o Postgres/Redis subiram antes do app (ordem esperada via depends_on)
docker compose ps peertube-postgres peertube-redis peertube

# Ver o motivo real - geralmente é PEERTUBE_HOSTNAME/PEERTUBE_SECRET não
# definidos no .env, ou o Postgres ainda inicializando
docker compose logs peertube --tail 100

# Verificar saúde do Postgres
docker compose logs peertube-postgres --tail 50
```
Se você errou o valor de `PEERTUBE_HOSTNAME` no primeiro `up`, não dá para só editar o `.env` e reiniciar — é preciso apagar `/mnt/config/peertube/postgres` (perde os dados do PeerTube) e subir de novo com o valor correto.

#### PeerTube sobe mas todo acesso dá erro 500 ("could not open file ... Permission denied")
Se `docker compose logs peertube` mostrar algo como `SequelizeConnectionError: could not open file "base/..." Permission denied` com `"routine": "mdopenfork"`, é permissão de arquivo do Postgres. Esse Postgres roda com usuário interno **UID/GID 70**, não 1000. Corrija sem perder dados:
```bash
docker compose stop peertube peertube-postgres
sudo chown -R 70:70 /mnt/config/peertube/postgres
docker compose start peertube-postgres peertube
```

#### Upload de vídeo no PeerTube falha com erro 500 ("EACCES: permission denied" em `/data/tmp/resumable-uploads`)
Mesma família de problema, mas no container `peertube` (não no Postgres): a imagem roda com usuário interno **UID/GID 999**, diferente do 1000 usado pelos outros serviços e do 70 do Postgres. Se `/mnt/dados/peertube` ou `/mnt/config/peertube/config` ficarem com outro dono (ex: depois de um `chown -R 1000:1000 /mnt/config` genérico), o upload falha assim que tenta gravar o arquivo temporário. Corrija:
```bash
docker compose stop peertube
sudo chown -R 999:999 /mnt/dados/peertube /mnt/config/peertube/config
docker compose start peertube
```

#### Permissões de `/mnt/config` "voltam sozinhas" para outro dono após reiniciar os containers
Causa raiz real encontrada em produção: a imagem `dperson/samba` (usada no serviço `samba`), sem as variáveis `USERID`/`GROUPID` explícitas, cria seu usuário interno com **UID/GID 100 por padrão** e re-chowna tudo que ela compartilha toda vez que o container sobe — e como ela montava a raiz de `/mnt/config` inteira, isso quebrava Jellyfin/Komga/Navidrome/qBittorrent (esperam UID 1000) *e* o Postgres do PeerTube (espera UID 70) a cada restart. Já corrigido no `fileserver/samba.yml` (`USERID`/`GROUPID` fixados em 1000, e o compartilhamento `Config` não inclui mais `peertube/postgres`/`peertube/redis`). Se ainda estiver em uma versão antiga do repositório, `git pull` e recrie o Samba:
```bash
git pull
docker compose up -d --force-recreate samba
sudo chown -R 1000:1000 /mnt/config
sudo chown -R 70:70 /mnt/config/peertube/postgres
sudo chown -R 999:999 /mnt/dados/peertube /mnt/config/peertube/config  # PeerTube (app) usa UID/GID 999
docker compose restart
```

#### Disco cheio / log do PeerTube gigante (dezenas de GB)
Já aconteceu em produção: o log do container `peertube` chegou a **72GB em ~1 dia** e quase encheu o disco. Todos os serviços já têm limite de log (`max-size`/`max-file`) configurado, então isso não deveria mais acontecer — mas se acontecer:
```bash
# Ver qual container está com log grande
docker ps -q | xargs -I{} sh -c 'echo {} $(docker inspect --format="{{.LogPath}}" {} | xargs du -h)'

# Esvaziar sem parar o container (libera espaço na hora)
sudo truncate -s 0 "$(docker inspect --format='{{.LogPath}}' peertube)"
```
A causa raiz identificada: `PEERTUBE_LOG_LEVEL=debug` faz o PeerTube despejar o conteúdo bruto (buffer, byte a byte) de comandos internos do Redis/Bull (fila de transcodificação) no log — um volume gigantesco em pouco tempo. `PEERTUBE_LOG_LEVEL` já vem fixado em `info` no `.env.example`; **não mude para `debug` em produção** a não ser que seja por um período curto e monitorado, para investigar algo específico.

#### Problema de permissão ao criar backup manual (Linux)
Se houver problemas ao criar ou acessar a pasta `/mnt/backup`:
```bash
# Ajustar proprietário e permissões da pasta de backup
sudo chown -R 1000:1000 /mnt/backup
sudo chmod -R 755 /mnt/backup
```

### Problemas de Permissão
```bash
# Linux - Ajustar permissões
sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
sudo chmod -R 755 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
# Postgres do PeerTube usa UID/GID 70, não 1000 - reaplique por cima:
sudo chown -R 70:70 /mnt/config/peertube/postgres
sudo chown -R 999:999 /mnt/dados/peertube /mnt/config/peertube/config  # PeerTube (app) usa UID/GID 999
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
- ✅ Defina `SAMBA_PASSWORD` no `.env` com uma senha forte (mínimo 16 caracteres) — o serviço não sobe sem ela
- ✅ Nunca commite o arquivo `.env` (já está no `.gitignore`)
- ✅ Configure firewall para limitar acesso às portas
- ✅ Use VPN para acesso remoto
- ✅ Mantenha backups regulares e criptografados
- ✅ As imagens Docker estão fixadas em versões específicas (não `:latest`) para evitar updates quebrando a stack sem aviso — atualize deliberadamente revisando o changelog de cada serviço antes de subir a versão nos arquivos `.yml`
- ✅ Configure HTTPS para acesso externo
- ✅ Portainer tem acesso ao socket do Docker (equivale a root no host): não exponha a porta 9020 diretamente na internet sem VPN, IP allowlist ou autenticação adicional (ex: Authelia)
- ⚠️ O qBittorrent tem acesso de **escrita** à raiz de `/mnt/dados` e `/mnt/dados2` (diferente dos demais serviços, que são somente leitura) — avalie restringir a uma subpasta dedicada de downloads
- ⚠️ O PeerTube federa via ActivityPub e, por padrão, vídeos marcados como "Público" ficam visíveis/indexáveis por outras instâncias PeerTube na internet, mesmo sem divulgar o link. Se os clipes são só para uso pessoal/família, marque-os como "Não listado" ou "Privado" ao publicar, e desative signup público em **Administração → Configurações → Cadastro**

### Configuração de Firewall
```powershell
# Windows Firewall
New-NetFirewallRule -DisplayName "Jellyfin" -Direction Inbound -Protocol TCP -LocalPort 8096 -Action Allow
New-NetFirewallRule -DisplayName "Komga" -Direction Inbound -Protocol TCP -LocalPort 8082 -Action Allow
New-NetFirewallRule -DisplayName "Navidrome" -Direction Inbound -Protocol TCP -LocalPort 4533 -Action Allow
New-NetFirewallRule -DisplayName "Portainer" -Direction Inbound -Protocol TCP -LocalPort 9020 -Action Allow
New-NetFirewallRule -DisplayName "Samba" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow
New-NetFirewallRule -DisplayName "qBittorrent" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
New-NetFirewallRule -DisplayName "PeerTube" -Direction Inbound -Protocol TCP -LocalPort 9000 -Action Allow
```

```bash
# Linux UFW
sudo ufw allow 8096/tcp  # Jellyfin
sudo ufw allow 8082/tcp  # Komga
sudo ufw allow 4533/tcp  # Navidrome
sudo ufw allow 9020/tcp  # Portainer
sudo ufw allow 445/tcp   # Samba
sudo ufw allow 8080/tcp  # qBittorrent Web UI
sudo ufw allow 6881/tcp  # Torrent TCP
sudo ufw allow 6881/udp  # Torrent UDP
sudo ufw allow 9000/tcp  # PeerTube
sudo ufw reload
```

### Exposição Segura (Reverse Proxy / Cloudflare Tunnel)
Para expor os serviços na internet, use sempre um reverse proxy com SSL ou um Cloudflare Tunnel — nunca exponha as portas diretamente no roteador. Exemplos completos de configuração Nginx e Cloudflare Tunnel estão em [DEPLOY_UBUNTU_AAPANEL.md](DEPLOY_UBUNTU_AAPANEL.md#5-configurar-aapanel-proxy-reverso--ssl).

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
Jellyfin e Samba já trazem `HEALTHCHECK` embutido nas próprias imagens oficiais. Komga, Navidrome, qBittorrent e PeerTube têm `healthcheck` configurado nos respectivos `.yml` (HTTP na porta interna do serviço). Portainer não tem healthcheck — a imagem é minimalista e não garante `curl`/`wget` disponíveis. Postgres e Redis do PeerTube também não têm healthcheck próprio aqui — se falharem, o container `peertube` vai indicar erro de conexão nos logs.

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
Test-NetConnection -ComputerName localhost -Port 8080  # qBittorrent
Test-NetConnection -ComputerName localhost -Port 9000  # PeerTube
```

## 🚀 Implantação em Produção (Ubuntu + aaPanel)

Para colocar a stack em produção num servidor Ubuntu com aaPanel — preparo do host, montagem de discos, firewall, domínios/proxy reverso, SSL e a alternativa via Cloudflare Tunnel — veja o guia dedicado: **[DEPLOY_UBUNTU_AAPANEL.md](DEPLOY_UBUNTU_AAPANEL.md)**.

## 📚 Recursos Adicionais

### Documentação Oficial
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Komga Documentation](https://komga.org/guides/)
- [Navidrome Documentation](https://www.navidrome.org/docs/)
- [Samba Documentation](https://www.samba.org/samba/docs/)
- [Portainer Documentation](https://docs.portainer.io/)
- [PeerTube Documentation](https://docs.joinpeertube.org/)

### Estrutura do Projeto
```
MediaHome/
├── docker-compose.yml          # Orquestração principal
├── .env.example                 # Template de variáveis (copie para .env)
├── .gitignore                   # Garante que .env não seja versionado
├── .github/workflows/
│   └── validate-compose.yml     # CI: valida a sintaxe dos .yml a cada push/PR
├── README.md                   # Esta documentação
├── DEPLOY_UBUNTU_AAPANEL.md    # Guia específico de produção (Ubuntu + aaPanel)
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
├── qbittorrent/
│   └── qbittorrent.yml        # Serviço qBittorrent independente
├── peertube/
│   ├── peertube.yml           # PeerTube + Postgres + Redis (plataforma de vídeos)
│   └── bulk-upload.sh         # Envia em massa uma pasta inteira via peertube-cli
└── backup/
    └── backup.yml             # Desativado (mantido apenas para referência)
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