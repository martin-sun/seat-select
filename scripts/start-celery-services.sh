#!/bin/bash

# Seat-Select Celery 服务启动脚本
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/seat-select-backend/.env"

echo -e "${BLUE}🚀 启动 Seat-Select Celery 服务 (Docker)...${NC}"

cd "$PROJECT_ROOT"

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  警告: 未找到 $ENV_FILE, 将使用默认端口和配置${NC}"
fi

# 启动服务
docker compose up -d --build

echo -e "${GREEN}✅ 服务已在后台启动！${NC}"
echo -e "${BLUE}📋 查看日志：${NC}"
echo -e "   docker compose logs -f worker celery-beat"

echo -e "\n${YELLOW}🛑 提示: 第一次运行 Gmail 授权时，可能需要进入容器或在本地运行一次以生成 token.pickle${NC}"
