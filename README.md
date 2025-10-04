# MediaHome - Servidor de Mídia Doméstico

Sistema completo de servidor de mídia doméstico usando Docker Compose com arquitetura modular.

## 🎯 Propósito da Stack

Centralizar, organizar e disponibilizar toda a sua mídia doméstica (vídeos, músicas, quadrinhos e e-books) em um único servidor, com gestão simples via web, backups diários e compatibilidade com múltiplos dispositivos. A stack foi pensada para:
- Subir rapidamente em qualquer host com Docker (Windows/Linux/Ubuntu + aaPanel)
- Evitar conflitos de portas e coexistir com outras stacks via rede compartilhada `app_network`
- Oferecer administração via Portainer e rotinas de backup automáticas

## ✅ Por que usar o MediaHome
- Simplicidade: um único `docker compose up -d` inicia tudo
- Modularidade: serviços podem ser iniciados individualmente
- Portabilidade: roda em ambientes diferentes sem ajustes complexos
- Segurança básica: isolamento por rede, portas explícitas e orientações de firewall
- Manutenção facilitada: Portainer para gerenciar containers e logs

## 📋 Serviços Incluídos

- **Jellyfin** (8096) - Servidor de mídia (filmes, séries, música)
- **Komga** (8082) - Servidor de quadrinhos/mangás
- **Navidrome** (4533) - Servidor de música
- **Samba** (1445) - Compartilhamento de arquivos
- **Portainer** (9020) - Monitoramento Docker
- **Backup** - Sistema automatizado de backup

## 🧩 Vantagens de cada serviço

- **Jellyfin**
  - Vantagens: open source, suporte a múltiplos codecs, clientes para TV/desktop/mobile
  - Quando usar: streaming de filmes e séries na rede local
- **Komga**
  - Vantagens: biblioteca rica para quadrinhos/mangás, leitura web responsiva
  - Quando usar: organizar e ler sua coleção de HQs e mangás
- **Navidrome**
  - Vantagens: servidor leve de música, compatível com clientes Subsonic
  - Quando usar: streaming de música para desktop e mobile
- **Samba**
  - Vantagens: compartilhamento de arquivos em rede, compatível com Windows/Linux/Mac
  - Quando usar: montar pastas de mídia em outros dispositivos
- **Portainer**
  - Vantagens: painel web para gerenciar Docker, logs e updates
  - Quando usar: administração simples dos containers e imagens
- **Backup**
  - Vantagens: rotina diária com retenção de 30 dias, tar.gz versionado
  - Quando usar: proteger configurações e facilitar restauração

## 🔌 Tabela de Portas

| Serviço     | Porta Host |
|-------------|------------|
| Jellyfin    | 8096       |
| Komga       | 8082       |
| Navidrome   | 4533       |
| Portainer   | 9020       |
| Samba (SMB) | 1445       |


## 🏗️ Estrutura Modular

```
MediaHome/
├── docker-compose.yml          # Compose principal (inclui todos os serviços)
├── README.md
├── jellyfin/
│   └── jellyfin.yml           # Serviço Jellyfin independente
├── komga/
│   └── komga.yml              # Serviço Komga independente
├── navidrome/
│   └── navidrome.yml          # Serviço Navidrome independente
├── portainer/
│   └── portainer.yml          # Serviço Portainer independente
└── fileserver/
    └── samba.yml              # Serviço Samba independente
```

## 🚀 Como Usar

### Iniciar Todos os Serviços
```bash
# Compose v2 (recomendado)
docker compose up -d

# Se estiver usando Compose v1
docker-compose up -d
```

### Iniciar Serviço Específico
```bash
# Compose v2
docker compose -f jellyfin/jellyfin.yml up -d
docker compose -f komga/komga.yml up -d
docker compose -f navidrome/navidrome.yml up -d
docker compose -f fileserver/samba.yml up -d
docker compose -f portainer/portainer.yml up -d
```

## ⚙️ Pré-requisitos

1. **Docker** e **Docker Compose** instalados
2. **Estrutura de diretórios** criada:
   ```bash
   # Configurações (SSD recomendado)
   sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,portainer}
   
   # Mídia (HDs)
   sudo mkdir -p /mnt/dados/media/{video,musica}
   sudo mkdir -p /mnt/dados2/media/comics
   
   # Backup
   sudo mkdir -p /mnt/backup
   
   # Ajustar permissões
   sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/dados2 /mnt/backup
   ```

## 🔧 Configuração

### Ajustar Caminhos
Edite os arquivos `.yml` conforme sua estrutura de diretórios:
- **Configurações**: `/mnt/config/[serviço]`
- **Mídia**: `/mnt/dados/media/` e `/mnt/dados2/media/`
- **Backup**: `/mnt/backup`

### Configurar Credenciais Samba
**⚠️ IMPORTANTE**: Altere as credenciais padrão no arquivo `fileserver/samba.yml`:
```yaml
command:
  - "-u"
  - "suporte;suporte123"  # ← ALTERE ESTAS CREDENCIAIS
```

### Ajustar PUID/PGID
Se necessário, altere os valores nos arquivos de serviço:
```yaml
environment:
  - PUID=1000  # ← Seu User ID
  - PGID=1000  # ← Seu Group ID
```

### Configurar Portainer (Primeira Execução)
1. Acesse http://localhost:9000 após iniciar o serviço
2. Crie uma conta de administrador na primeira execução
3. Conecte ao Docker local (endpoint já configurado automaticamente)

## 🌐 URLs de Acesso (LAN)

- **Jellyfin**: http://192.168.0.121:8096
- **Komga**: http://192.168.0.121:8082
- **Navidrome**: http://192.168.0.121:4533
- **Portainer**: http://192.168.0.121:9020
- **Samba**: `smb://192.168.0.121:1445` (Linux/Mac) — no Windows, use compartilhamento padrão sem porta

> Dica: em produção, utilize aaPanel/Nginx como proxy reverso com SSL e nomes de host (ex.: `jellyfin.seu-dominio`).

## 💾 Sistema de Backup

- **Frequência**: Diário (24h)
- **Retenção**: 30 dias
- **Localização**: `/mnt/backup/mediahome_config_YYYYMMDD_HHMMSS.tar.gz`
- **Conteúdo**: Todas as configurações dos serviços

## 📝 Comandos Úteis

```bash
# Ver logs de todos os serviços
docker-compose logs -f

# Ver logs de serviço específico
docker-compose logs -f jellyfin

# Parar todos os serviços
docker-compose down

# Parar serviço específico
docker-compose -f jellyfin/jellyfin.yml down

# Atualizar imagens
docker-compose pull
docker-compose up -d

# Ver status dos containers
docker-compose ps

# Reiniciar serviço específico
docker-compose restart jellyfin

# Acessar logs do Portainer
docker-compose -f portainer/portainer.yml logs -f
```

## 🔒 Segurança

1. **Altere as credenciais padrão do Samba**
2. Configure firewall para limitar acesso às portas
3. Use VPN para acesso remoto
4. Mantenha backups atualizados
5. Atualize regularmente as imagens Docker

## 🛠️ Solução de Problemas

### Problemas de Permissão
```bash
sudo chown -R 1000:1000 /mnt/config
sudo chmod -R 755 /mnt/config
```

### Verificar Logs
```bash
docker-compose logs [nome_do_serviço]
```

### Recriar Containers
```bash
docker-compose down
docker-compose up -d --force-recreate
```

### Rede não encontrada
Se houver erro de rede ao iniciar serviços individuais:
```bash
# Criar rede externa compartilhada (idempotente)
docker network create app_network

# Ou iniciar o compose principal primeiro
docker compose up -d
```

---

## 🚀 Implantação em Ubuntu + aaPanel (IP 192.168.0.121)

### 1) Preparar servidor
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose-plugin git curl
sudo usermod -aG docker $USER && newgrp docker
```

### 2) Clonar projeto
```bash
git clone <URL_DO_REPO>
cd MediaHome
```

### 3) Rede Docker
Este projeto usa uma rede externa compartilhada `app_network` para coexistir com outras stacks.
```bash
docker network create app_network || true
```

### 4) Estrutura de diretórios
```bash
sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,portainer}
sudo mkdir -p /mnt/dados/media/{video,musica,quadrinhos}
sudo mkdir -p /mnt/backup
sudo chown -R 1000:1000 /mnt/config /mnt/dados /mnt/backup
```

### 5) Subir serviços
```bash
docker compose up -d
docker ps
```

### 6) Abrir portas no firewall (UFW)
```bash
sudo ufw allow 8096/tcp 8082/tcp 4533/tcp 9020/tcp 1445/tcp
sudo ufw reload
```

### 7) Configurar aaPanel (reverse proxy)
- Acesse `http://192.168.0.121:8888`
- Instale Nginx via App Store
- Crie sites/domínios e configure proxy reverso para cada serviço:
  - `jellyfin.seu-dominio` → `http://192.168.0.121:8096`
  - `komga.seu-dominio` → `http://192.168.0.121:8082`
  - `musica.seu-dominio` → `http://192.168.0.121:4533`
  - `portainer.seu-dominio` → `http://192.168.0.121:9020`

Trecho Nginx padrão (em cada site):
```
location / {
  proxy_pass http://192.168.0.121:PORTA_ALVO;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

### 8) SSL (Let's Encrypt)
No aaPanel, em cada site: “SSL” → “Let’s Encrypt” → emitir certificados. Habilite redirecionamento HTTPS.

### 9) Testes rápidos
```bash
curl -I http://192.168.0.121:8096
curl -I http://192.168.0.121:8082
curl -I http://192.168.0.121:4533
curl -I http://192.168.0.121:9020
```

### 10) Observações
- Samba no Windows usa porta 445 por padrão e não permite especificar porta; o container está exposto em `1445` para evitar conflito, recomendado acesso por outros dispositivos ou ajustar topologia conforme necessidade.
- Caso já exista MinIO usando 9000/9001, Portainer desta stack está em 9020 para coexistir com outra stack.

## 🤝 Contribuição

PRs e issues são bem-vindos. Sugestões comuns:
- Adicionar healthchecks por serviço (`healthcheck:`)
- Centralizar portas em `.env` e referenciar nos YAML
- Integrar Traefik/Nginx com TLS e autenticação
- Automatizar backups com Restic/Rclone e verificação de integridade

## 📄 Licença

Projeto para uso pessoal/doméstico. Verifique licenças individuais dos serviços utilizados.

## 🧠 Samba — Credenciais e Montagem

- Credenciais atuais:
  - Usuário: `suporte`
  - Senha: `suporte123`
- Compartilhamentos (shares):
  - `Dados` → `/mnt/dados`
  - `Dados2` → `/mnt/dados2`
  - `Config` → `/mnt/config`

Como acessar na LAN (`192.168.0.121`):
- Windows:
  - Explorador: `\\192.168.0.121\Dados` e `\\192.168.0.121\Dados2`
  - Mapear unidade (ex.): `net use Z: \\192.168.0.121\Dados /user:suporte suporte123`
- Linux:
  - `sudo apt install smbclient cifs-utils`
  - `smbclient //192.168.0.121/Dados -U suporte`
  - Montar via CIFS (ex.):
    - `sudo mount -t cifs //192.168.0.121/Dados /mnt/dados_client -o username=suporte,password=suporte123,uid=1000,gid=1000,vers=3.0`
- macOS:
  - Finder → Go → Connect to Server: `smb://192.168.0.121/Dados`

Portas e produção:
- Desenvolvimento no Windows: container expõe `1445:445` para evitar conflito com o SMB do Windows.
- Produção no Ubuntu: preferir `445:445` e abrir `445/tcp` no UFW.

Segurança e boas práticas:
- Troque as credenciais acima em produção por senhas fortes.
- Se quiser somente leitura, ajuste o share para `readonly`.
- Restrinja acesso por rede/sub-rede conforme necessidade (ex.: `192.168.0.0/24`).

### Produção (Ubuntu) — usar arquivo dedicado

- Utilize o arquivo: `fileserver/samba.ubuntu.yml`
- Este arquivo publica apenas a porta `445:445` e usa `container_name: samba-ubuntu` para evitar conflito com containers existentes e com o serviço Samba nativo do host.
- Comandos:
  - `sudo ufw allow 445/tcp`
  - `docker compose -f fileserver/samba.ubuntu.yml up -d`
- Acesso no Windows: `\\192.168.0.121\Dados` e `\\192.168.0.121\Dados2`
- Mantém a rede externa `app_network` para coexistir com outras stacks.
- Se houver erro de acesso, veja a seção "Samba (Ubuntu) — porta em uso ou conflito de container" abaixo.

### Samba no Windows (host)

- Limitação: o cliente SMB do Windows usa sempre a porta `445` e não permite especificar outra. No host Windows, o serviço SMB nativo ocupa `445`, por isso o container exposto em `1445:445` não pode ser acessado via Explorer (`\\localhost\Dados`).
- Opções de acesso:
  - WSL/Ubuntu: monte com CIFS usando `port=1445` e acesse via `\\wsl$`:
    - `sudo apt install cifs-utils`
    - `sudo mkdir -p /mnt/dados_client /mnt/dados2_client`
    - `sudo mount -t cifs //localhost/Dados /mnt/dados_client -o username=suporte,password=suporte123,port=1445,vers=3.0`
    - `sudo mount -t cifs //localhost/Dados2 /mnt/dados2_client -o username=suporte,password=suporte123,port=1445,vers=3.0`
    - Acesse pelo Explorer: `\\wsl$\Ubuntu\mnt\dados_client`
  - Outro dispositivo Linux/macOS: montar SMB especificando `port=1445` (Linux) ou usar cliente compatível.
  - Produção (Ubuntu): exponha `445:445` e abra `445/tcp` no UFW; Windows acessa direto `\\192.168.0.121\Dados`.
  - Alternativa não recomendada: desativar o SMB do Windows e mapear `445:445` no container.
- Nota: o Samba é para clientes externos. Entre containers, o acesso aos discos já é feito via bind mounts (`/mnt/dados` e `/mnt/dados2`) nos YAML dos serviços.

### Samba (Ubuntu) — porta em uso ou conflito de container
Se ao iniciar o Samba em produção você ver erros como:
- `failed to bind port 0.0.0.0:139/tcp ... address already in use`
- `You have to remove (or rename) that container to be able to reuse that name`

Siga estas etapas:
```bash
# 1) Remover/derrubar qualquer container antigo chamado "samba"
docker rm -f samba || true
docker compose -f fileserver/samba.yml down || true

# 2) Parar e desabilitar os serviços Samba nativos do host (liberam 139/445)
sudo systemctl stop smbd nmbd
sudo systemctl disable smbd nmbd

# 3) Verificar se as portas estão livres
sudo ss -tulpn | grep -E ':(139|445)' || true

# 4) Subir o Samba do projeto (Ubuntu)
docker compose -f fileserver/samba.ubuntu.yml up -d

# 5) Abrir firewall (se necessário)
sudo ufw allow 445/tcp
sudo ufw reload
```

Notas importantes:
- Não rode dois containers Samba ao mesmo tempo; mesmo com nomes diferentes eles competem pela porta `445`.
- O arquivo `fileserver/samba.ubuntu.yml` publica apenas `445:445` (SMB moderno). A porta `139` (NetBIOS) não é necessária e costuma estar em uso pelo serviço nativo.
- Após subir, acesse do Windows via `\\SEU_IP\Dados` e `\\SEU_IP\Dados2`.

### Containers não reconhecem caminhos de rede (SMB)
Containers não acessam diretamente caminhos de rede como `\\host\Dados`. Eles precisam de caminhos locais do host (bind mounts). Se os dados estão em outro servidor/host, monte os compartilhamentos SMB no host onde os containers rodam e, só então, referencie esses caminhos locais no YAML.

Passo a passo (Ubuntu):
```bash
# 1) Criar pontos de montagem locais
sudo mkdir -p /mnt/dados /mnt/dados2

# 2) Montar os compartilhamentos SMB no host
sudo apt install -y cifs-utils
sudo mount -t cifs //SEU_IP/Dados /mnt/dados \
  -o username=SEU_USUARIO,password=SEU_SEGREDO,vers=3.0,uid=1000,gid=1000,iocharset=utf8,file_mode=0644,dir_mode=0755

sudo mount -t cifs //SEU_IP/Dados2 /mnt/dados2 \
  -o username=SEU_USUARIO,password=SEU_SEGREDO,vers=3.0,uid=1000,gid=1000,iocharset=utf8,file_mode=0644,dir_mode=0755

# 3) Verificar conteúdo
ls -la /mnt/dados
ls -la /mnt/dados2

# 4) Subir/reativar os serviços para que enxerguem os caminhos
docker compose up -d
```

Persistência no boot (`/etc/fstab`):
```bash
sudo bash -c 'cat >/etc/samba-cred <<EOF\nusername=SEU_USUARIO\npassword=SEU_SEGREDO\nEOF'
sudo chmod 600 /etc/samba-cred

sudo bash -c 'cat >>/etc/fstab <<EOF\n//SEU_IP/Dados  /mnt/dados  cifs  credentials=/etc/samba-cred,uid=1000,gid=1000,vers=3.0,iocharset=utf8,file_mode=0644,dir_mode=0755  0  0\n//SEU_IP/Dados2 /mnt/dados2 cifs  credentials=/etc/samba-cred,uid=1000,gid=1000,vers=3.0,iocharset=utf8,file_mode=0644,dir_mode=0755  0  0\nEOF'

sudo mount -a
```

Importante:
- Os YAML desta stack referenciam subpastas como `/mnt/dados/media/video`, `/mnt/dados/media/musica`, etc. Garanta que essa estrutura exista dentro do compartilhamento (crie `media/video`, `media/musica`, `media/ebooks`, `media/quadrinhos`).
- Alternativamente, ajuste os YAML para apontar diretamente para os caminhos que você realmente usa no host (ex.: montar `/mnt/dados` como `/media` no Jellyfin e configurar as bibliotecas lá dentro).
- Evite montar SMB dentro do container; monte no host e use bind mounts. Isto simplifica permissões e melhora desempenho.


## 📚 Configurar Bibliotecas nos Apps

Para que os apps reconheçam os discos montados via bind mounts, informe explicitamente os caminhos internos do container ao criar as bibliotecas.

- Jellyfin
  - Vá em `Dashboard → Libraries → Add Media Library`.
  - Em `Folders`, digite manualmente os caminhos:
    - Vídeos: `/media/video` e `/media/video2`
    - Música: `/media/musica` e `/media/musica2`
  - Dica: se o navegador de pastas não listar `/media`, digite o caminho direto e salve.
  - Verificação opcional:
    - `docker exec -it jellyfin ls -la /media`
    - `docker exec -it jellyfin ls -la /media/video /media/video2 /media/musica /media/musica2`

- Komga
  - Vá em `Admin → Libraries → New Library`.
  - Informe o caminho da biblioteca como `/data` (disco 1) e/ou `/data2` (disco 2).
  - Verificação:
    - `docker exec -it komga ls -la /data /data2`

- Navidrome
  - Já configurado para múltiplas pastas com `ND_MUSICFOLDERS=/music,/music2`.
  - Vá em `Settings → Library` e clique em `Rescan`.
  - Verificação:
    - `docker exec -it navidrome ls -la /music /music2`

 Se algum caminho não existir dentro do container, verifique no host:
```bash
ls -la /mnt/dados/media/{video,musica,quadrinhos}
ls -la /mnt/dados2/media/{video,musica,quadrinhos}
sudo chown -R 1000:1000 /mnt/dados /mnt/dados2
```

## 📞 Suporte

Para problemas específicos:
1. Verifique os logs do serviço
2. Confirme as permissões dos diretórios
3. Verifique se as portas não estão em uso
4. Consulte a documentação oficial de cada serviço