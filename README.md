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
- **KoodoReader** (3010) - Leitor de e-books
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
- **KoodoReader**
  - Vantagens: leitura de e-books na web, interface limpa, suporte a múltiplos formatos
  - Quando usar: gerenciar e ler ePUB/PDF diretamente no navegador
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
| KoodoReader | 3010       |
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
├── koodoreader/
│   └── koodoreader.yml        # Serviço KoodoReader independente
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
docker compose -f koodoreader/koodoreader.yml up -d
docker compose -f fileserver/samba.yml up -d
docker compose -f portainer/portainer.yml up -d
```

## ⚙️ Pré-requisitos

1. **Docker** e **Docker Compose** instalados
2. **Estrutura de diretórios** criada:
   ```bash
   # Configurações (SSD recomendado)
   sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,koodoreader,portainer}
   
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
- **KoodoReader**: http://192.168.0.121:3010
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
sudo mkdir -p /mnt/config/{jellyfin,komga,navidrome,koodoreader,portainer}
sudo mkdir -p /mnt/dados/media/{video,musica,ebooks,quadrinhos}
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
sudo ufw allow 8096/tcp 8082/tcp 3010/tcp 4533/tcp 9020/tcp 1445/tcp
sudo ufw reload
```

### 7) Configurar aaPanel (reverse proxy)
- Acesse `http://192.168.0.121:8888`
- Instale Nginx via App Store
- Crie sites/domínios e configure proxy reverso para cada serviço:
  - `jellyfin.seu-dominio` → `http://192.168.0.121:8096`
  - `komga.seu-dominio` → `http://192.168.0.121:8082`
  - `ebooks.seu-dominio` → `http://192.168.0.121:3010`
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
curl -I http://192.168.0.121:3010
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


## 📞 Suporte

Para problemas específicos:
1. Verifique os logs do serviço
2. Confirme as permissões dos diretórios
3. Verifique se as portas não estão em uso
4. Consulte a documentação oficial de cada serviço