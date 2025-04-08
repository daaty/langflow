FROM langflowai/langflow:latest

USER root

# Instalar dependências necessárias para o Playwright
RUN apt-get update \
    && apt-get install -y \
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

# Instalar dependências extras: autogen e playwright
RUN pip install autogen pgvector==0.3.6 playwright==1.42.0

# Instalar o navegador Chromium para Playwright
RUN playwright install --with-deps chromium

# Configurar o ambiente para inicialização
ENV LANGFLOW_HOST=0.0.0.0
ENV LANGFLOW_PORT=7860

# Voltar para o usuário não-root 
USER user

# Comando para iniciar o Langflow
CMD ["langflow", "run"]