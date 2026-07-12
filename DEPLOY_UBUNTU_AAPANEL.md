# Deploy Stack MediaHome - Ubuntu 24.04 + aaPanel

## Visão Geral
Esta documentação detalha o processo de implantação da Stack MediaHome (Jellyfin, Komga, Navidrome, Samba) em Ubuntu 24.04 com aaPanel.

## Serviços Incluídos
- **Jellyfin**: Servidor de mídia (filmes, séries, música)
- **Komga**: Servidor de quadrinhos e mangás
- **Navidrome**: Servidor de música com interface web
- **Samba**: Servidor de arquivos para compartilhamento de rede
- **Portainer**: Gerenciamento de containers
- **qBittorrent**: Cliente de torrent integrado para downloads diretos

## Pré-requisitos

### Sistema Operacional
- Ubuntu 24.04 LTS
- IP do servidor: 192.168.0.121 (ajustar conforme necessário)
- aaPanel instalado e configurado
- Espaço em disco adequado para mídia (recomendado: 1TB+)

### Dependências
```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt update
sudo apt install docker-compose-plugin
```

### Configurações do Ubuntu
```bash
# Configurar firewall
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
sudo ufw --force enable

# Criar estrutura de diretórios para mídia
sudo mkdir -p /mnt/dados/{filmes,series,musicas,quadrinhos}
sudo mkdir -p /mnt/dados2/{filmes,series,musicas,quadrinhos}
sudo mkdir -p /mnt/externo
sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,portainer,qbittorrent}
sudo chown -R 1000:1000 /mnt/config
sudo chown -R 1000:1000 /mnt/dados
sudo chown -R 1000:1000 /mnt/dados2
sudo chown -R 1000:1000 /mnt/externo
```

## Configuração do aaPanel

### 1. Configurar Domínios
No painel do aaPanel, adicione os seguintes domínios:
- `jellyfin.seudominio.com` → Proxy reverso para `192.168.0.121:8096`
- `komga.seudominio.com` → Proxy reverso para `192.168.0.121:8082`
- `navidrome.seudominio.com` → Proxy reverso para `192.168.0.121:4533`
- `portainer.seudominio.com` → Proxy reverso para `192.168.0.121:9020`
- `torrent.seudominio.com` → Proxy reverso para `192.168.0.121:8080`

### 2. Configurar SSL
Para cada domínio, configure certificados SSL (Let's Encrypt recomendado).

### 3. Configurar Proxy Reverso
```nginx
# Exemplo para Jellyfin
location / {
    proxy_pass http://192.168.0.121:8096;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Configurações específicas para streaming
    proxy_buffering off;
    proxy_request_buffering off;
    client_max_body_size 0;
}
```

### Alternativa: Exposição via Cloudflare Tunnel (Zero Trust)
Se você utiliza o **Cloudflare Tunnel** em vez de configurar domínios e proxy reverso no aaPanel para acessar os serviços:
1. Abra o painel do Cloudflare Zero Trust.
2. Navegue até **Access** → **Tunnels** e edite o túnel correspondente ao seu servidor.
3. Na aba **Public Hostname**, adicione o hostname para o qBittorrent:
   - **Public Hostname**: `torrent.seudominio.com` (ou similar)
   - **Service Type**: `HTTP`
   - **URL**: `localhost:8080` (ou o IP local do servidor, ex: `192.168.0.121:8080`)
4. Como o tráfego do túnel é criptografado e repassado diretamente via agente local, não é necessário abrir portas adicionais no roteador e você pode manter as portas de gerenciamento restritas ao IP local no firewall.

## Preparação dos Arquivos

### 1. Estrutura de Diretórios
Certifique-se de que a estrutura de diretórios está correta:
```
/mnt/
├── config/
│   ├── jellyfin/
│   ├── komga/
│   └── navidrome/
├── dados/
│   ├── filmes/
│   ├── series/
│   ├── musicas/
│   └── quadrinhos/
└── dados2/
    ├── filmes/
    ├── series/
    ├── musicas/
    └── quadrinhos/
```

### 2. Configurar Permissões
```bash
# Definir usuário e grupo corretos
sudo chown -R 1000:1000 /mnt/config
sudo chown -R 1000:1000 /mnt/dados
sudo chown -R 1000:1000 /mnt/dados2
sudo chown -R 1000:1000 /mnt/externo

# Definir permissões adequadas
sudo chmod -R 755 /mnt/config
sudo chmod -R 755 /mnt/dados
sudo chmod -R 755 /mnt/dados2
sudo chmod -R 755 /mnt/externo
```

## Processo de Deploy

### 1. Preparação
```bash
# Navegar para o diretório do projeto
cd /caminho/para/MediaHome

# Configurar variáveis de ambiente (obrigatório)
cp .env.example .env
nano .env   # defina SAMBA_PASSWORD e ajuste HOST_IP/caminhos para o seu servidor
```

> A rede Docker `mediahome` é criada automaticamente pelo Compose (declarada em cada `.yml` de serviço) — não é preciso criá-la manualmente.

### 2. Iniciar Serviços de Mídia
```bash
# Iniciar Jellyfin
docker compose -f jellyfin/jellyfin.yml up -d

# Aguardar inicialização
sleep 30

# Iniciar Komga
docker compose -f komga/komga.yml up -d

# Iniciar Navidrome
docker compose -f navidrome/navidrome.yml up -d
```

### 3. Iniciar Serviços de Infraestrutura e Torrent
```bash
# Iniciar Samba
docker compose -f fileserver/samba.yml up -d

# Iniciar Portainer
docker compose -f portainer/portainer.yml up -d

# Iniciar qBittorrent
docker compose -f qbittorrent/qbittorrent.yml up -d
```

## Verificação

### 1. Status dos Containers
```bash
docker ps
docker compose logs -f
```

### 2. Testes de Conectividade
```bash
# Testar Jellyfin
curl -I http://192.168.0.121:8096

# Testar Komga
curl -I http://192.168.0.121:8082

# Testar Navidrome
curl -I http://192.168.0.121:4533

# Testar Samba (via SMB)
smbclient -L //192.168.0.121 -p 445 -U suporte

# Testar qBittorrent
curl -I http://192.168.0.121:8080
```

## Configuração Inicial dos Serviços

### Jellyfin
1. Acesse `https://jellyfin.seudominio.com`
2. Complete o wizard de configuração inicial
3. Crie conta de administrador
4. Configure bibliotecas de mídia:
   - Filmes: `/media/dados/filmes` e `/media/dados2/filmes`
   - Séries: `/media/dados/series` e `/media/dados2/series`
   - Música: `/media/dados/musicas` e `/media/dados2/musicas`

### Komga
1. Acesse `https://komga.seudominio.com`
2. Crie conta de administrador
3. Configure bibliotecas:
   - Quadrinhos: `/data/quadrinhos` e `/data2/quadrinhos`

### Navidrome
1. Acesse `https://navidrome.seudominio.com`
2. Crie conta de administrador
3. A biblioteca de música será escaneada automaticamente

### Samba
O Samba usa as credenciais definidas em `SAMBA_USER`/`SAMBA_PASSWORD` no `.env` (sem senha padrão — defina antes de subir a stack):
- **Compartilhamentos**:
  - `\\192.168.0.121\Dados` → `/mnt/dados`
  - `\\192.168.0.121\Dados2` → `/mnt/dados2`
  - `\\192.168.0.121\Config` → `/mnt/config`

### qBittorrent
1. Acesse `http://192.168.0.121:8080` (ou o domínio configurado).
2. Obtenha a senha temporária inicial nos logs do contêiner:
   ```bash
   docker logs qbittorrent | grep "password"
   ```
3. Acesse com o usuário `admin` e mude a senha nas opções de Web UI.

### Portainer
1. Acesse `https://portainer.seudominio.com`
2. Crie conta de administrador
3. Configure ambiente Docker local

## Organização de Mídia

### Estrutura Recomendada
```
/mnt/dados/
├── filmes/
│   ├── Filme 1 (2023)/
│   │   └── Filme 1 (2023).mkv
│   └── Filme 2 (2024)/
│       └── Filme 2 (2024).mp4
├── series/
│   ├── Serie 1/
│   │   ├── Season 01/
│   │   └── Season 02/
│   └── Serie 2/
├── musicas/
│   ├── Artista 1/
│   │   └── Album 1/
│   └── Artista 2/
└── quadrinhos/
    ├── Marvel/
    └── DC/
```

## Monitoramento e Manutenção

### Comandos Úteis
```bash
# Ver logs
docker compose logs -f [serviço]

# Reiniciar serviços
docker compose restart [serviço]

# Verificar uso de espaço
df -h /mnt/dados /mnt/dados2

# Atualizar imagens
docker compose pull
docker compose up -d
```

### Backup de Configurações (Manual)
```bash
# Backup manual das configurações em arquivo compactado
sudo tar -czf /mnt/backup/mediahome-config-$(date +%Y%m%d_%H%M%S).tar.gz -C /mnt/config .
```

## Segurança

### Medidas Implementadas
- Comunicação interna via rede Docker
- SSL/TLS via aaPanel
- Firewall configurado
- Volumes com permissões adequadas
- Samba com autenticação

### Recomendações Adicionais
- Definir uma `SAMBA_PASSWORD` forte no `.env` (obrigatório, sem valor padrão)
- Nunca commitar o `.env` no git (já coberto pelo `.gitignore`)
- Restringir o acesso ao Portainer (porta 9020) via VPN/allowlist de IP — ele tem acesso ao socket do Docker, equivalente a root no host
- Configurar backup externo das mídias
- Monitorar uso de disco
- Atualizar as imagens de forma deliberada: as versões estão fixadas nos `.yml` (não usam `:latest`); revise o changelog do serviço antes de subir a versão

## Solução de Problemas

### Problemas Comuns
1. **Mídia não aparece**: Verificar permissões e caminhos
2. **Streaming lento**: Verificar recursos do servidor
3. **Samba não conecta**: Verificar firewall e credenciais
4. **Proxy reverso não funciona**: Verificar configuração aaPanel

### Logs Importantes
```bash
# Logs do Jellyfin
docker logs jellyfin

# Logs do Komga
docker logs komga

# Logs do Navidrome
docker logs navidrome

# Logs do Samba
docker logs samba
```

## Performance e Otimização

### Recomendações de Hardware
- **CPU**: Mínimo 4 cores para transcodificação
- **RAM**: Mínimo 8GB
- **Armazenamento**: SSD para configurações, HDD para mídia
- **Rede**: Gigabit Ethernet recomendado

### Otimizações do Jellyfin
- Habilitar aceleração de hardware se disponível
- Configurar transcodificação adequadamente
- Usar bibliotecas separadas por tipo de mídia

## URLs de Acesso

Após a configuração completa:
- **Jellyfin**: https://jellyfin.seudominio.com
- **Komga**: https://komga.seudominio.com
- **Navidrome**: https://navidrome.seudominio.com
- **Portainer**: https://portainer.seudominio.com
- **Samba**: `\\192.168.0.121` (porta 445)
- **qBittorrent**: https://torrent.seudominio.com

## Atualizações

As versões das imagens estão fixadas em cada `.yml` (não usam `:latest`). Para atualizar um serviço:
1. Confira o changelog/release notes da imagem.
2. Edite a tag da imagem no respectivo `.yml` (ex: `jellyfin/jellyfin:10.11.5` → nova versão).
3. Aplique:
```bash
docker compose pull
docker compose up -d
```

---

**Nota**: Substitua `seudominio.com` pelo seu domínio real e ajuste os caminhos de mídia conforme sua configuração.