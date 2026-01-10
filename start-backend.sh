#!/bin/bash

# Seat-Select Backend 服务启动脚本 (FastAPI + Celery)
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

API_ONLY=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --api-only|-a)
            API_ONLY=true
            shift
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --api-only, -a    只启动 FastAPI 服务"
            echo "  -h, --help        显示帮助信息"
            echo ""
            echo "无参数时启动所有服务 (FastAPI + Redis + Celery Worker + Celery Beat)"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}未知参数: $1${NC}"
            echo "使用 -h 查看帮助"
            exit 1
            ;;
    esac
done

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_ROOT/seat-select-backend/.env"

# 确保在根目录执行
cd "$PROJECT_ROOT"

# 检查 .env
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  警告: 未找到 $ENV_FILE, 将使用默认配置${NC}"
fi

if [ "$API_ONLY" = true ]; then
    echo -e "${BLUE}🚀 启动 FastAPI 服务...${NC}"
    docker compose up -d --build api redis

    echo -e "${GREEN}✅ FastAPI 服务已启动！${NC}"
    echo ""
    echo -e "${BLUE}📋 服务:${NC}"
    echo "  - API:        http://localhost:8010"
    echo "  - API Docs:   http://localhost:8010/docs"
    echo "  - Redis:      localhost:6380"
    echo ""
    echo -e "${YELLOW}📝 查看日志:${NC}\n"

    docker compose logs -f api redis
else
    echo -e "${BLUE}🚀 启动 Seat-Select Backend 服务 (Docker)...${NC}"

    # 启动服务
    docker compose up -d --build

    echo -e "${GREEN}✅ 服务已在后台启动！${NC}"
    echo ""
    echo -e "${BLUE}📋 服务列表:${NC}"
    echo "  - API:        http://localhost:8010"
    echo "  - API Docs:   http://localhost:8010/docs"
    echo "  - Redis:      localhost:6380"
    echo "  - Worker:     seat-select-worker"
    echo "  - Celery Beat: seat-select-beat"
    echo ""
    echo -e "${YELLOW}📝 查看日志 (按 Ctrl+C 退出日志查看，容器会继续运行)：${NC}\n"

    # 跟踪所有服务日志
    docker compose logs -f api worker celery-beat redis
fi
