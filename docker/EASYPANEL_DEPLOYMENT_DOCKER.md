# Deploy do Langflow no EasyPanel usando Dockerfile

Este guia explica como fazer o deploy do Langflow customizado com dependências adicionais (autogen, playwright, etc.) diretamente no EasyPanel usando um Dockerfile personalizado.

## Pré-requisitos

- Uma instância do EasyPanel em execução
- Acesso ao seu repositório Git do Langflow (fork)

## Passos para implantação

### 1. Preparar seu repositório Git

1. Faça commit e push das alterações no Dockerfile personalizado (`docker/easypanel.Dockerfile`) para seu repositório Git.

### 2. Configurar o serviço no EasyPanel

1. Acesse o painel do EasyPanel
2. Clique em "Add a new service"
3. Selecione "Custom" como tipo de serviço
4. Configure os seguintes parâmetros:
   - **Name**: Langflow-Custom (ou outro nome de sua escolha)
   - **Repository URL**: URL do seu repositório Git (ex: `https://github.com/seu-usuario/langflow.git`)
   - **Branch**: main (ou a branch que contém suas customizações)
   - **Build Method**: Build from Dockerfile
   - **Dockerfile Path**: `docker/easypanel.Dockerfile` (caminho para o Dockerfile customizado)
   - **Port**: 7860

5. Clique em "Deploy" para iniciar a implantação

### 3. Configuração de ambiente (opcional)

Você pode adicionar variáveis de ambiente na seção "Environment Variables":

- `LANGFLOW_SUPERUSER`: Nome de usuário do superusuário
- `LANGFLOW_SUPERUSER_PASSWORD`: Senha do superusuário 
- `LANGFLOW_AUTO_LOGIN`: false (para habilitar o login com o superusuário)
- `LANGFLOW_DATABASE_URL`: URL para seu banco de dados PostgreSQL (ex: `postgresql://user:password@host:port/dbname`)

## Dependências incluídas

Esta versão personalizada do Langflow inclui:

- AutoGen AI (`autogen-ai`)
- AutoGen Studio (`autogenstudio`)
- Playwright (com suporte ao navegador Chromium)
- Todas as dependências originais do Langflow

## Solução de problemas

Se encontrar problemas durante a implantação:

1. **Logs do EasyPanel**: Verifique os logs de build e execução no painel do EasyPanel.
2. **Problemas com dependências**: Se necessário, ajuste o Dockerfile para incluir dependências adicionais.
3. **Problema com portas**: Certifique-se de que a porta 7860 está configurada corretamente no EasyPanel.

## Alternativa: Usando Nixpacks (como o Railway)

EasyPanel também suporta builds usando Nixpacks, semelhante ao Railway. Para isso:

1. Remova o Dockerfile personalizado e deixe que o Nixpacks detecte automaticamente o projeto Python
2. No EasyPanel, selecione "Build Method": Auto-detect
3. Adicione uma variável de build `NIXPACKS_PKGS` com valor `python playwright nodejs`
4. Adicione um arquivo `nixpacks.toml` na raiz do repositório com:

```toml
[phases.setup]
nixPkgs = ["python312", "nodejs", "playwright", "chromium"]

[phases.install]
cmds = [
  "pip install -e . --extra postgresql",
  "pip install playwright autogen-ai autogenstudio typing-extensions==4.9.0",
  "playwright install --with-deps chromium",
  "cd src/frontend && npm install"
]

[phases.build]
cmds = ["cd src/frontend && npm run build"]

[start]
cmd = "python -m src.backend.langflow run"
```

Este método permite que o EasyPanel construa o projeto automaticamente sem um Dockerfile explícito.