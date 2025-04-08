FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
ENV TZ=UTC

WORKDIR /app

# Instalar dependências necessárias, incluindo as para Playwright
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    build-essential \
    curl \
    npm \
    git \
    wget \
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

# Instalar dependências principais usando uv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install -e . --extra postgresql

# Instalar dependências adicionais específicas
RUN pip install playwright autogen-ai autogen autogenstudio typing-extensions==4.9.0
RUN playwright install --with-deps chromium

# Build do frontend
RUN cd src/frontend && npm install && npm run build

# Configurar o ambiente para inicialização
ENV LANGFLOW_HOST="0.0.0.0"
ENV LANGFLOW_PORT="7860"
ENV LANGFLOW_FRONTEND_PATH="/app/src/frontend/build"

EXPOSE 7860

# Comando para iniciar o servidor
CMD ["python", "-m", "src.backend.langflow", "run"]