#!/bin/bash
# ==============================================================================
# Seat-Select - 部署 Backend 到内网服务器
# ==============================================================================
# 功能：
#   - SSH 到内网服务器
#   - 拉取最新 Docker 镜像
#   - 重启 Backend 服务 (API + Worker + Beat + Cloudflared) (force-recreate)
#   - 验证服务健康状态
#
# 使用方法：
#   ./deploy-backend.sh              # 部署 (需确认)
#   ./deploy-backend.sh -y           # 跳过确认直接部署
#
# 配置文件：
#   脚本会自动加载同目录下的 .env.deploy.backend 文件
#
# 前置条件：
#   1. 已配置 .env.deploy.backend 文件
#   2. 已配置 SSH 访问到内网服务器 (密钥或密码)
#   3. 服务器上已安装 Docker 和 Docker Compose
#   4. 服务器上已配置 .env.production 文件
# ==============================================================================

set -euo pipefail  # 严格模式：错误退出、未定义变量报错、管道失败检测

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==============================================================================
# 加载配置文件
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env.deploy.backend"

if [ -f "${ENV_FILE}" ]; then
    echo -e "${BLUE}加载配置文件: ${ENV_FILE}${NC}"
    # shellcheck source=/dev/null
    source "${ENV_FILE}"
else
    echo -e "${YELLOW}警告: 配置文件不存在: ${ENV_FILE}${NC}"
    echo -e "${YELLOW}将使用环境变量或默认值${NC}"
    echo -e "${YELLOW}建议: 复制 .env.deploy.backend.example 为 .env.deploy.backend 并填写配置${NC}"
    echo ""
fi

# ==============================================================================
# 配置变量 (优先使用配置文件，其次使用环境变量，最后使用默认值)
# ==============================================================================
# 内网服务器 SSH 配置
BACKEND_USER="${BACKEND_USER:-msun}"
BACKEND_HOST="${BACKEND_HOST:-192.168.192.57}"
BACKEND_PORT="${BACKEND_PORT:-22}"
SSH_KEY="${BACKEND_SSH_KEY:-}"
USE_PASSWORD="${USE_PASSWORD:-false}"

# 服务器上的部署目录和 compose 文件
BACKEND_DEPLOY_PATH="${BACKEND_DEPLOY_PATH:-/home/msun/Projects/saskatoonsfc}"
BACKEND_COMPOSE_FILE="${BACKEND_COMPOSE_FILE:-docker-compose.backend.yml}"

# 镜像仓库配置
# 重要：请确保你的镜像已经推送到相应的仓库。
# 默认使用跟 BeanFlow-LLM 类似的仓库，或者根据 seat-select 项目需要修改。
REGISTRY_URL="${REGISTRY_URL:-registry.woohelps.com}"
IMAGE_NAME="${IMAGE_NAME:-seat-select-backend}"

# ==============================================================================
# SSH 连接函数
# ==============================================================================
ssh_cmd() {
    if [ -n "${SSH_KEY:-}" ] && [ -f "${SSH_KEY}" ]; then
        ssh -i "${SSH_KEY}" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -p "${BACKEND_PORT}" "${BACKEND_USER}@${BACKEND_HOST}" "$@"
    elif [ "${USE_PASSWORD:-false}" = "true" ] && command -v sshpass &> /dev/null; then
        sshpass -p "${BACKEND_PASSWORD}" ssh -o StrictHostKeyChecking=accept-new -p "${BACKEND_PORT}" "${BACKEND_USER}@${BACKEND_HOST}" "$@"
    else
        ssh -o StrictHostKeyChecking=accept-new -p "${BACKEND_PORT}" "${BACKEND_USER}@${BACKEND_HOST}" "$@"
    fi
}

# ==============================================================================
# 脚本开始
# ==============================================================================

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Seat-Select Backend 内网部署${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查配置
if [ "${BACKEND_HOST}" = "your-internal-server-ip" ]; then
    echo -e "${RED}错误: 请先配置内网服务器地址${NC}"
    echo -e "${YELLOW}编辑 .env.deploy.backend 文件设置 BACKEND_HOST${NC}"
    exit 1
fi

echo -e "${BLUE}目标服务器: ${BACKEND_USER}@${BACKEND_HOST}:${BACKEND_PORT}${NC}"
echo -e "${BLUE}部署路径: ${BACKEND_DEPLOY_PATH}${NC}"
echo -e "${BLUE}Compose 文件: ${BACKEND_COMPOSE_FILE}${NC}"
echo ""

# 确认部署 (除非使用 -y 参数)
if [ "${1:-}" != "-y" ]; then
    read -p "$(echo -e ${YELLOW}是否继续部署 Backend 到内网服务器? \(y/N\) ${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}取消部署${NC}"
        exit 1
    fi
fi

echo ""

# ==============================================================================
# SSH 到服务器并执行部署
# ==============================================================================
echo -e "${BLUE}连接到内网服务器并执行部署...${NC}"
echo ""

if ssh_cmd << DEPLOY_EOF
set -e

# 颜色输出（在远程服务器上）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "\${BLUE}========================================\${NC}"
echo -e "\${BLUE}内网服务器 Backend 部署流程\${NC}"
echo -e "\${BLUE}========================================\${NC}"
echo ""

# 检查部署目录
if [ ! -d "${BACKEND_DEPLOY_PATH}" ]; then
    echo -e "\${YELLOW}部署目录不存在，正在创建: ${BACKEND_DEPLOY_PATH}\${NC}"
    mkdir -p "${BACKEND_DEPLOY_PATH}"
fi

cd "${BACKEND_DEPLOY_PATH}"

# 检查 compose 文件
if [ ! -f "${BACKEND_COMPOSE_FILE}" ]; then
    echo -e "\${RED}错误: ${BACKEND_COMPOSE_FILE} 文件不存在\${NC}"
    echo -e "\${YELLOW}请先同步 docker-compose.backend.yml 到服务器\${NC}"
    exit 1
fi

# 检查 .env.production 文件
if [ ! -f ".env.production" ]; then
    echo -e "\${RED}错误: .env.production 文件不存在\${NC}"
    echo -e "\${YELLOW}请先配置环境变量文件\${NC}"
    exit 1
fi

echo -e "\${GREEN}✓ 目录和配置文件检查通过\${NC}"
echo ""

# 登录 Docker Registry
echo -e "\${BLUE}[1/5] 登录 Docker Registry...\${NC}"
if [ -n "\${REGISTRY_PASSWORD}" ]; then
    echo "\${REGISTRY_PASSWORD}" | docker login ${REGISTRY_URL} -u "\${REGISTRY_USER}" --password-stdin
fi
echo ""

# 拉取最新镜像
echo -e "\${BLUE}[2/5] 拉取 Docker 镜像...\${NC}"
docker compose -f ${BACKEND_COMPOSE_FILE} --env-file .env.production pull

if [ \$? -eq 0 ]; then
    echo -e "\${GREEN}✓ 镜像拉取成功\${NC}"
else
    echo -e "\${RED}✗ 镜像拉取失败\${NC}"
    exit 1
fi
echo ""

# 停止旧服务
echo -e "\${BLUE}[3/5] 停止旧服务...\${NC}"
docker compose -f ${BACKEND_COMPOSE_FILE} --env-file .env.production down || true
echo ""

# 启动/重建服务
echo -e "\${BLUE}[4/5] 启动 Backend 服务...\${NC}"
docker compose -f ${BACKEND_COMPOSE_FILE} --env-file .env.production up -d --force-recreate

if [ \$? -eq 0 ]; then
    echo -e "\${GREEN}✓ Backend 服务已启动\${NC}"
else
    echo -e "\${RED}✗ 启动服务失败\${NC}"
    exit 1
fi
echo ""

# 等待服务启动
echo -e "\${BLUE}等待服务启动...\${NC}"
sleep 5

# 检查服务状态
echo -e "\${BLUE}[5/5] 检查服务状态...\${NC}"
docker compose -f ${BACKEND_COMPOSE_FILE} --env-file .env.production ps

echo ""
echo -e "\${BLUE}检查服务健康状态...\${NC}"
docker ps --filter "name=seat-select" --filter "name=saskatoonsfc" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""

# 显示最近日志
echo -e "\${BLUE}API 最近日志:\${NC}"
docker logs --tail 20 seat-select-api 2>&1 || true

echo ""
echo -e "\${BLUE}Worker 最近日志:\${NC}"
docker logs --tail 20 seat-select-worker 2>&1 || true

echo ""
echo -e "\${BLUE}Beat 最近日志:\${NC}"
docker logs --tail 20 seat-select-beat 2>&1 || true

echo ""
echo -e "\${BLUE}Cloudflare Tunnel 最近日志:\${NC}"
docker logs --tail 20 saskatoonsfc-tunnel 2>&1 || true

echo ""

# 清理旧镜像（节省空间）
echo -e "\${BLUE}清理旧镜像...\${NC}"
docker image prune -f || true
echo -e "\${GREEN}✓ 清理完成\${NC}"

echo ""
echo -e "\${GREEN}========================================\${NC}"
echo -e "\${GREEN}Backend 部署完成！\${NC}"
echo -e "\${GREEN}========================================\${NC}"
echo ""
echo -e "\${BLUE}查看日志:\${NC}"
echo -e "  全部服务: docker compose -f ${BACKEND_COMPOSE_FILE} --env-file .env.production logs -f"
echo ""
DEPLOY_EOF
then
    # SSH 命令执行成功
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Backend 部署成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}内网 Backend 服务:${NC}"
    echo -e "  • API 容器: seat-select-api"
    echo -e "  • Worker 容器: seat-select-worker"
    echo -e "  • Beat 容器: seat-select-beat"
    echo -e "  • Cloudflare Tunnel: saskatoonsfc-tunnel"
    echo ""
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Backend 部署失败！${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
