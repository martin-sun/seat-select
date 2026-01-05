#!/bin/bash

# Seat-Select Celery 服务启动脚本 (根目录版)
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_ROOT/seat-select-backend/.env"

echo -e "${BLUE}🚀 启动 Seat-Select Celery 服务 (Docker)...${NC}"

# 确保在根目录执行
cd "$PROJECT_ROOT"

# 检查 .env
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  警告: 未找到 $ENV_FILE, 将使用默认配置${NC}"
fi

# 启动服务
docker compose up -d --build

echo -e "${GREEN}✅ 服务已在后台启动！${NC}"
echo -e "${BLUE}� 正在显示实时日志 (按 Ctrl+C 退出日志查看，容器会继续运行)：${NC}\n"

# 跟踪日志
docker compose logs -f worker celery-beat
