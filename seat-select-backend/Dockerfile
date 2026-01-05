# 使用基础 Python 镜像
FROM python:3.12-slim-bookworm

# 设置工作目录
WORKDIR /app

# 安装 uv 和必要的系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

# 将 uv 添加到路径
ENV PATH="/root/.local/bin:${PATH}"

# 复制依赖定义文件
COPY pyproject.toml uv.lock ./

# [关键修复] 直接将依赖安装到系统 Python 环境中，避免 .venv 路径问题
RUN uv pip install --system --no-cache -r pyproject.toml

# 复制项目代码
COPY . .

# 设置 Python 环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 默认命令（可在 docker-compose 中覆盖）
CMD ["celery", "-A", "celery_app.celery", "worker", "--loglevel=info"]
