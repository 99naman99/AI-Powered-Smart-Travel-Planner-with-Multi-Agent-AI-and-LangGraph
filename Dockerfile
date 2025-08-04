FROM python:3.11-slim

# Install Ollama CLI
RUN apt-get update \
 && apt-get install -y curl ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && curl -sSfL https://install.ollama.com | sh

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pull the Ollama model at build time
RUN ollama pull llama3.2

# Copy application code
COPY . .

# Environment variables
ENV STREAMLIT_SERVER_HEADLESS=true
ENV STREAMLIT_SERVER_ENABLECORS=false
ENV OLLAMA_BASE_URL=http://localhost:11434
ENV SERPER_API_KEY=""

# Expose ports
EXPOSE 8501 11434

# Start Ollama daemon and then Streamlit
CMD ["bash", "-lc", "ollama serve --listen 0.0.0.0:11434 & streamlit run travel_agent.py --server.port=8501 --server.address=0.0.0.0"]
