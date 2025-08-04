# Start from slim Python
FROM python:3.11-slim

# 1. Install bash (needed by the Ollama installer), curl, and certificates
RUN apt-get update \
 && apt-get install -y bash curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 2. Install Ollama CLI via its installer script
#    We force it to use bash so it drops the binary into /usr/local/bin
RUN curl -sSfL https://install.ollama.com | bash

# 3. Verify ollama is present
RUN which ollama

# 4. Set working directory
WORKDIR /app

# 5. Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6. Pull the Ollama model at build time
RUN ollama pull llama3.2

# 7. Copy in your app code
COPY . .

# 8. Environment variables (Serper key injected at runtime)
ENV STREAMLIT_SERVER_HEADLESS=true
ENV STREAMLIT_SERVER_ENABLECORS=false
ENV OLLAMA_BASE_URL=http://localhost:11434
ENV SERPER_API_KEY=""

# 9. Expose the ports for Streamlit and Ollama
EXPOSE 8501 11434

# 10. Start Ollama daemon in background, then launch Streamlit
CMD ["bash", "-lc", "\
    ollama serve --listen 0.0.0.0:11434 & \
    streamlit run travel_agent.py --server.port=8501 --server.address=0.0.0.0 \
"]
