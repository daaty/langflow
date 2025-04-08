FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
ENV TZ=UTC

WORKDIR /app

# Instalar dependências necessárias, incluindo as bibliotecas para o Playwright
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    build-essential \
    curl \
    npm \
    git \
    wget \
    # Bibliotecas necessárias para o Playwright
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libxshmfence1 \
    # Limpeza de pacotes para reduzir tamanho da imagem
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Primeiro copiamos apenas os arquivos de configuração necessários para instalação
COPY pyproject.toml uv.lock README.md /app/
COPY src/backend/base/README.md /app/src/backend/base/
COPY src/backend/base/pyproject.toml /app/src/backend/base/
COPY src/backend/base/uv.lock /app/src/backend/base/

# Instalar dependências principais do Langflow usando pip (evitando problemas com uv)
RUN pip install -e .[postgresql]

# Agora copiamos o restante dos arquivos
COPY . /app

# Instalar dependências adicionais específicas para workflows
# - Instalação do AutoGen 0.8.5 e suas dependências
# - Instalação do playwright com versão específica para garantir compatibilidade
RUN pip install pyautogen==0.8.5 autogenstudio typing-extensions==4.9.0
RUN pip install playwright==1.42.0

# Instalar o navegador Chromium para Playwright
RUN playwright install --with-deps chromium

# Build do frontend
RUN cd src/frontend && npm install && npm run build

# Configurar o ambiente para inicialização
ENV LANGFLOW_HOST="0.0.0.0"
ENV LANGFLOW_PORT="7860"
ENV LANGFLOW_FRONTEND_PATH="/app/src/frontend/build"

# Expor a porta para acesso ao Langflow
EXPOSE 7860

# Comando para iniciar o servidor
CMD ["python", "-m", "src.backend.langflow", "run"]