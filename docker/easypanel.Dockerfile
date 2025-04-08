FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
ENV TZ=UTC

WORKDIR /app

# Instalar dependências necessárias incluindo as dependências do Playwright
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

# Instalar dependências usando uv
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=README.md,target=README.md \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=src/backend/base/README.md,target=src/backend/base/README.md \
    --mount=type=bind,source=src/backend/base/uv.lock,target=src/backend/base/uv.lock \
    --mount=type=bind,source=src/backend/base/pyproject.toml,target=src/backend/base/pyproject.toml \
    uv sync --frozen --no-install-project --no-dev --extra postgresql

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