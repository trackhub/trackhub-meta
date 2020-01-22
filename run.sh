#!/usr/bin/env bash

NAME="graphql"
SERVICES="web sql"

[[ $UID == 0 ]] && export WEB_UID=1000 || export WEB_UID=$UID

# Parse commands
[[ -z $1 ]] && command="serve" || command=$1

case ${command} in
    "serve")
        docker-compose up --build
        ;;
    "clean")
        # Remove containers
        for service in ${SERVICES}; do

            docker ps | grep -q "${NAME}_${service}_1" && \
                echo -n "Stopping: " && \
                docker stop "${NAME}_${service}_1"

            docker ps -a | grep -q "${NAME}_${service}_1" && \
                echo -n "Removing: " && \
                docker rm "${NAME}_${service}_1"
        done

        # Remove volumes
        docker volume ls | grep -q "${NAME}_database_data" && \
            echo -n "Removing volumes: " && \
            docker volume rm "graphql_database_data"
        ;;
    *)
        echo "Unknown command: ${command}" >2
        exit 1
        ;;
esac
