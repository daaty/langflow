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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiar todos os arquivos do projeto
COPY . /app

# Instalar Langflow e suas dependências usando uv
# Especificando uma versão máxima para algumas dependências problemáticas
RUN pip install --upgrade pip && \
    pip install "langchain<0.4.0" "langchain-community<0.4.0" && \
    pip install .

# Instalar extras para PostgreSQL
RUN pip install "psycopg2-binary" "sqlalchemy[postgresql]" "pgvector==0.3.6"

# Instalar dependências adicionais específicas para workflows
RUN pip install "pyautogen==0.8.5" "autogenstudio" "typing-extensions==4.9.0"
RUN pip install "playwright==1.42.0"

# Instalar o navegador Chromium para Playwright
RUN playwright install --with-deps chromium

# Build do frontend
WORKDIR /app/src/frontend
RUN npm install && npm run build

# Voltar ao diretório principal
WORKDIR /app

# Configurar o ambiente para inicialização
ENV LANGFLOW_HOST="0.0.0.0"
ENV LANGFLOW_PORT="7860"
ENV LANGFLOW_FRONTEND_PATH="/app/src/frontend/build"

# Expor a porta para acesso ao Langflow
EXPOSE 7860

# Comando para iniciar o servidor
CMD ["python", "-m", "src.backend.langflow", "run"]