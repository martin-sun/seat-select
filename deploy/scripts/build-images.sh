#!/bin/bash
# ==============================================================================
# Seat-Select Backend - Docker Image Build Script
# ==============================================================================
# 构建 Docker 镜像并标记版本
# 支持跨平台构建 (Mac M系列 → Linux x86_64)
# ==============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$DEPLOY_DIR")"
BACKEND_DIR="${PROJECT_ROOT}/seat-select-backend"

# 加载配置 (优先从 deploy 目录加载，兼容 scripts 目录)
if [ -f "$DEPLOY_DIR/.env.deploy.backend" ]; then
    source "$DEPLOY_DIR/.env.deploy.backend"
elif [ -f "$SCRIPT_DIR/.env.deploy.backend" ]; then
    source "$SCRIPT_DIR/.env.deploy.backend"
else
    echo -e "${RED}错误: 找不到 .env.deploy.backend 配置文件${NC}"
    echo -e "${YELLOW}请复制 deploy/.env.deploy.backend.example 为 deploy/.env.deploy.backend 并填写配置${NC}"
    exit 1
fi

# 版本号处理
VERSION="${1:-$(git rev-parse --short HEAD 2>/dev/null || echo 'latest')}"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Seat-Select Backend - 构建 Docker 镜像${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "版本: ${GREEN}${VERSION}${NC}"
echo -e "镜像仓库: ${GREEN}${REGISTRY_URL}${NC}"
echo -e "后端目录: ${GREEN}${BACKEND_DIR}${NC}"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    exit 1
fi

# 检查 Docker Buildx
echo -e "${YELLOW}检查 Docker Buildx...${NC}"
if ! docker buildx version &> /dev/null; then
    echo -e "${RED}错误: Docker Buildx 未安装${NC}"
    exit 1
fi

# 检测是否需要跨平台构建
# 始终构建 linux/amd64 镜像以兼容生产服务器
PLATFORM_FLAG="--platform linux/amd64"
LOAD_FLAG=""  # 跨平台构建不能使用 --load
PUSH_FLAG="--push"  # 直接推送到仓库

echo -e "${YELLOW}目标平台: linux/amd64${NC}"

# 确保 buildx builder 存在
BUILDER_NAME="seat-select-builder"
if ! docker buildx inspect $BUILDER_NAME &> /dev/null; then
    # 尝试使用现有的 builder
    if ! docker buildx inspect multiarch-builder &> /dev/null; then
        echo -e "${YELLOW}创建 multiarch builder...${NC}"
        docker buildx create --name multiarch-builder --use
        docker buildx inspect --bootstrap
    else
        docker buildx use multiarch-builder
    fi
else
    docker buildx use $BUILDER_NAME
fi

# 构建镜像
IMAGE_NAME="${REGISTRY_URL}/seat-select/backend"

echo ""
echo -e "${YELLOW}开始构建后端镜像...${NC}"
echo -e "Dockerfile: ${BACKEND_DIR}/Dockerfile"
echo -e "Context: ${BACKEND_DIR}"
echo ""

cd "${BACKEND_DIR}"

# 使用 docker buildx build
docker buildx build \
    $PLATFORM_FLAG \
    $LOAD_FLAG \
    $PUSH_FLAG \
    -f Dockerfile \
    -t "${IMAGE_NAME}:${VERSION}" \
    -t "${IMAGE_NAME}:latest" \
    .

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  构建完成!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "镜像:"
echo -e "  ${GREEN}${IMAGE_NAME}:${VERSION}${NC}"
echo -e "  ${GREEN}${IMAGE_NAME}:latest${NC}"

# 根据是否跨平台构建显示不同的下一步提示
if [[ -n "$PUSH_FLAG" ]]; then
    echo ""
    echo -e "${GREEN}镜像已自动推送到仓库!${NC}"
    echo -e "下一步: 运行 ${YELLOW}./deploy-backend.sh${NC} 部署到内网服务器"
else
    echo ""
    echo -e "下一步: 运行 ${YELLOW}./push-images.sh${NC} 推送镜像到仓库"
fi
