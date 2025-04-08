FROM python:3.12-slim-bookworm
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

# Instalar Langflow diretamente do PyPI em vez da fonte
RUN pip install --upgrade pip && \
    pip install langflow==1.3.2

# Copiar o código-fonte para construir o frontend
COPY . /app

# Construir o frontend
WORKDIR /app/src/frontend
RUN npm install && npm run build

# Voltar ao diretório principal
WORKDIR /app

# Instalar dependências extras para PostgreSQL
RUN pip install "psycopg2-binary" "sqlalchemy[postgresql]" "pgvector==0.3.6"

# Instalar dependências adicionais específicas para workflows
RUN pip install "pyautogen==0.8.5" "autogenstudio" "typing-extensions==4.9.0"
RUN pip install "playwright==1.42.0"

# Instalar o navegador Chromium para Playwright
RUN playwright install --with-deps chromium

# Configurar o ambiente para inicialização
ENV LANGFLOW_HOST="0.0.0.0"
ENV LANGFLOW_PORT="7860"
ENV LANGFLOW_FRONTEND_PATH="/app/src/frontend/build"

# Expor a porta para acesso ao Langflow
EXPOSE 7860

# Comando para iniciar o servidor
CMD ["langflow", "run"]