#!/bin/bash

# Get the directory where the script is located, which should also contain docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/test.log"
REDIS_SERVICE_NAME="redis" # This MUST match the service name in your docker-compose.yml
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

# --- Automatic logging to test.log and console ---
exec > >(tee "${LOG_FILE}") 2>&1

# Check if docker-compose.yml exists
if [ ! -f "${COMPOSE_FILE}" ]; then
    echo "Error: docker-compose.yml not found at ${COMPOSE_FILE}"
    exit 1
fi

# Check if the Redis service container is running
# Get container ID. If empty, service is not running or not found by compose.
CONTAINER_ID=$(docker-compose -f "${COMPOSE_FILE}" ps -q ${REDIS_SERVICE_NAME})

if [ -z "${CONTAINER_ID}" ]; then
    echo "Error: The Redis service ('${REDIS_SERVICE_NAME}') container is not found."
    exit 1
fi

# Check if the container is actually in a running state
# This filters by ID and checks the status string.
CONTAINER_STATUS=$(docker ps --filter "id=${CONTAINER_ID}" --format "{{.Status}}")
if [[ ! "${CONTAINER_STATUS}" =~ ^Up ]]; then # Check if status starts with "Up"
    echo "Error: The Redis service ('${REDIS_SERVICE_NAME}') container (ID: ${CONTAINER_ID}) is found but not in a running state (Status: ${CONTAINER_STATUS})."
    exit 1
fi

# Use docker-compose exec to run redis-cli inside the 'redis' service container.
# The -T option disables pseudo-tty allocation, which is crucial for heredocs.
# redis-cli -p 6379 connects to Redis *inside* the container.
docker-compose -f "${COMPOSE_FILE}" exec -T ${REDIS_SERVICE_NAME} redis-cli -p 6379 <<EOF 2>&1 | awk '{print strftime("%Y-%m-%d %H:%M:%S"), $0; fflush()}' | tee "${LOG_FILE}"
EVAL "return redis.call('SET', KEYS[1], string.rep('x', 1024*1024*20), 'NX')" 1 key:oom_test_
EVAL "return redis.call('SET', KEYS[1], string.rep('y', 1024*1024*20), 'NX')" 1 key:oom_test_2
EOF
