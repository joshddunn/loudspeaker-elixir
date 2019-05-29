docker ps -f "name=loudspeaker-elixir_app" | tail -n +2 | awk '{print $1}' | xargs docker kill
docker-compose up -d
