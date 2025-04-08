# Implantação do Langflow customizado no EasyPanel

Este guia fornece instruções sobre como implantar o Langflow customizado com dependências adicionais (autogen, playwright, etc.) usando o EasyPanel por meio de um repositório Git.

## Pré-requisitos

- Uma instância do EasyPanel em execução
- Acesso ao GitHub ou outro repositório Git

## Passos para implantação

### 1. Preparar seu repositório Git

1. Faça um fork deste repositório para sua conta GitHub ou outro provedor Git
2. Clone seu fork: `git clone https://github.com/seu-usuario/langflow.git`
3. Faça commit e push das alterações personalizadas feitas aos Dockerfiles e docker-compose

### 2. Configurar o serviço no EasyPanel

1. Acesse o painel do EasyPanel
2. Clique em "Add a new service"
3. Selecione "Custom" como tipo de serviço
4. Configure os seguintes parâmetros:
   - **Name**: Langflow-Custom (ou outro nome de sua escolha)
   - **Repository URL**: URL do seu repositório Git (ex: `https://github.com/seu-usuario/langflow.git`)
   - **Branch**: main (ou a branch que contém suas customizações)
   - **Docker Compose File Path**: `docker/easypanel-compose.yml`
   - **Build Method**: Build from Dockerfile
   - **Port**: 7860

5. Clique em "Deploy" para iniciar a implantação

### 3. Configuração de ambiente (opcional)

Se necessário, você pode adicionar variáveis de ambiente na seção "Environment Variables" do EasyPanel:

- `LANGFLOW_SUPERUSER`: Nome de usuário do superusuário (opcional)
- `LANGFLOW_SUPERUSER_PASSWORD`: Senha do superusuário (opcional)
- `LANGFLOW_AUTO_LOGIN`: false (para habilitar o login com o superusuário)

## Dependências incluídas

Esta versão personalizada do Langflow inclui:

- AutoGen AI (autogen-ai)
- AutoGen Studio (autogenstudio)
- Playwright (com suporte ao navegador Chromium)
- Todas as dependências originais do Langflow

## Solução de problemas

Se você encontrar problemas com o Playwright, você pode ajustar o Dockerfile para incluir pacotes adicionais ou configurações específicas para seu ambiente.

Para verificar se o serviço está funcionando corretamente, verifique os logs do contêiner no EasyPanel.