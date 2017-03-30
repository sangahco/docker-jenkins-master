#!/usr/bin/env bash

set -e

PROJECT_NAME="$PROJECT_NAME"
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="$(cat .env | awk 'BEGIN { FS="="; } /^PROJECT_NAME/ {sub(/\r/,"",$2); print $2;}')"
fi
REGISTRY_URL="$REGISTRY_URL"
if [ -z "$REGISTRY_URL" ]; then
    REGISTRY_URL="$(cat .env | awk 'BEGIN { FS="="; } /^REGISTRY_URL/ {sub(/\r/,"",$2); print $2;}')"
fi

CONF_ARG="-f docker-compose.yml"

SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$SCRIPT_BASE_PATH"

usage() {
echo "Usage:  $(basename "$0") [MODE] [OPTIONS] [COMMAND]"
echo 
echo "Mode:"
echo "  --prod          Production mode"
echo "  --dev           Development mode"
echo "  --backup        Backup Jenkins Workspace"
echo
echo "Options:"
echo "  --help          Show this help message"
echo
echo "Commands:"
echo "  up              Start the services"
echo "  down            Stop the services"
echo "  ps              Show the status of the services"
echo "  logs            Follow the logs on console"
echo "  remove-all      Remove all containers"
echo "  stop-all        Stop all containers running"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for i in "$@"
do
case $i in
    --prod)
        CONF_ARG="-f docker-compose.yml"
        shift
        ;;
    --dev)
        CONF_ARG="-f docker-compose-dev.yml"
        shift
        ;;
    --dev)
        CONF_ARG="-f docker-compose.yml -f docker-compose-backup.yml"
        shift
        ;;
    --help|-h)
        usage
        exit 1
        ;;
    *)
        ;;
esac
done

echo "Arguments: $CONF_ARG"
echo "Command: $@"

if [ "$1" == "up" ]; then
    docker-compose $CONF_ARG pull
    docker-compose $CONF_ARG build --pull
    docker-compose $CONF_ARG up -d --remove-orphans
    exit 0

elif [ "$1" == "stop-all" ]; then
    if [ -n "$(docker ps --format {{.ID}})" ]
    then docker stop $(docker ps --format {{.ID}}); fi
    exit 0

elif [ "$1" == "remove-all" ]; then
    if [ -n "$(docker ps -a --format {{.ID}})" ]
    then docker rm $(docker ps -a --format {{.ID}}); fi
    exit 0

elif [ "$1" == "logs" ]; then
    shift
    docker-compose $CONF_ARG logs -f --tail 200 "$@"
    exit 0
fi

docker-compose $CONF_ARG "$@"
