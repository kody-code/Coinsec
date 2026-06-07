#!/bin/bash

# 加载 .env 文件（与 jar 同级目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
fi

export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-prod}

java -jar "$SCRIPT_DIR/backend-1.0.0.jar"
