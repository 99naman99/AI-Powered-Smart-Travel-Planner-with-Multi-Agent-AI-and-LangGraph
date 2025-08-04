FROM python:3.11-slim

# 1. Install Bash (needed by Ollama installer), curl & certs
RUN apt-get update \
 && apt-get install -y bash curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 2. Install Ollama CLI
RUN curl -sSfL https://install.ollama.com | bash

WORKDIR /app

# 3. Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Pull the Ollama model at build time
RUN ollama pull llama3.2

# 5. Copy application code
COPY . .

# 6. Environment variables
ENV STREAMLIT_SERVER_HEADLESS=true
ENV STREAMLIT_SERVER_ENABLECORS=false
ENV OLLAMA_BASE_URL=http://localhost:11434
ENV SERPER_API_KEY=""

# 7. Expose ports
EXPOSE 8501 11434

# 8. Start Ollama daemon then Streamlit
CMD ["bash", "-lc", "\
     ollama serve --listen 0.0.0.0:11434 & \
     streamlit run travel_agent.py --server.port=8501 --server.address=0.0.0.0 \
"]
