ollamaRun()
{
  docker run -d --name ollama \
    -p 11434:11434 \
    -v ollama:/root/.ollama \
    ollama/ollama
}

ollamaOpenWebsite()
{
  xdg-open https://ollama.com
}

ollamaGetModel()
{
  docker exec -it ollama ollama run "$1"
}

ollamaOpenWebUi()
{
  docker run -d -p 3000:8080 \
    --add-host=host.docker.internal:host-gateway \
    -v open-webui:/app/backend/data \
    --name open-webui \
    --restart always \
    ghcr.io/open-webui/open-webui:main
}
