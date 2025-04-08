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

# Agora copiamos o restante dos arquivos
COPY . /app

# Instalar dependências com versões específicas para evitar conflitos
RUN pip install --no-deps langchain==0.3.10 langchain-community==0.3.10

# Instalar dependências do Langflow manualmente
RUN pip install --no-deps langflow-base==0.3.2 beautifulsoup4==4.12.3 google-search-results>=2.4.1,<3.0.0 \
    google-api-python-client==2.154.0 huggingface-hub>=0.23.2,<1.0.0 networkx==3.4.2 fake-useragent==1.5.1 \
    pyarrow==19.0.0 wikipedia==1.4.0 qdrant-client==1.9.2 weaviate-client==4.10.2 \
    faiss-cpu==1.9.0.post1 types-cachetools==5.5.0.20240820 pymongo==4.10.1 \
    supabase==2.6.0 certifi>=2023.11.17,<2025.0.0 certifi==2024.8.30 fastavro==1.9.7 \
    redis==5.2.1 metaphor-python==0.1.23 langfuse==2.53.9 metal_sdk==2.5.1 MarkupSafe==3.0.2 \
    boto3==1.34.162 numexpr==2.10.2 qianfan==0.3.5 pgvector==0.3.6 elasticsearch==8.16.0 \
    pytube==15.0.0 dspy-ai==2.5.41 assemblyai==0.35.1 litellm==1.60.2 chromadb==0.5.23 \
    zep-python==2.0.2 youtube-transcript-api==0.6.3 Markdown==3.7 upstash-vector==0.6.0 \
    GitPython==3.1.43 kubernetes==31.0.0 json_repair==0.30.3 langwatch==0.1.16 \
    langsmith==0.1.147 yfinance==0.2.50 wolframalpha==5.1.3

# Instalar dependências PostgreSQL para evitar conflitos
RUN pip install psycopg2-binary sqlalchemy

# Instalar dependências adicionais específicas para workflows
# - Instalação do AutoGen 0.8.5 e suas dependências
# - Instalação do playwright com versão específica para garantir compatibilidade
RUN pip install pyautogen==0.8.5 autogenstudio typing-extensions==4.9.0
RUN pip install playwright==1.42.0

# Instalar o navegador Chromium para Playwright
RUN playwright install --with-deps chromium

# Instalar dependências do frontend
WORKDIR /app/src/frontend
RUN npm install

# Build do frontend
RUN npm run build

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