podman run -d --name ollama --replace --restart=always \
      --security-opt=label=disable \
      -p 11434:11434 \
      -v ollama:/root/.ollama \
      --stop-signal=SIGKILL \
      --memory="8g" \
      --cpus="2" \
      docker.io/ollama/ollama

podman exec -it ollama /bin/bash

# ollama pull qwen2.5-coder:0.5b
# ollama pull qwen2.5-coder:1.5b
# ollama pull llama3.2

# podman logs ollama
