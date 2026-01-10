#!/bin/bash

# Seat-Select Backend 服务停止脚本 (FastAPI + Celery)
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🛑 停止 Seat-Select Backend 服务...${NC}"

cd "$PROJECT_ROOT"

docker compose stop
docker compose rm -f

echo -e "${GREEN}✅ 服务已停止并清理容器${NC}"
