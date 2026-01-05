# Seat Select

座位选择系统 - Vue 3 + Supabase

## 技术栈

- Vue 3
- Vue Router
- Vue I18n
- Supabase (数据库 & 实时订阅)
- Tailwind CSS

## 本地开发

### 安装依赖

```bash
npm install
```

### 配置环境变量

复制 `.env.example` 为 `.env` 并填写配置：

```bash
cp .env.example .env
```

需要配置的变量：
- `VUE_APP_SUPABASE_URL` - Supabase 项目 URL
- `VUE_APP_SUPABASE_ANON_KEY` - Supabase 匿名密钥
- `VUE_APP_ETRANSFER_EMAIL` - E-transfer 收款邮箱

### 启动开发服务器

```bash
npm run serve
```

### 构建生产版本

```bash
npm run build
```

## 部署到 Cloudflare Pages

### 首次部署

1. 安装 Wrangler CLI：

```bash
npm install -g wrangler
```

2. 登录 Cloudflare：

```bash
wrangler login
```

3. 构建并部署：

```bash
npm run build
wrangler pages deploy dist --project-name=saskatoonsfc
```

### 更新部署（每次代码修改后）

只需运行以下命令：

```bash
npm run build && wrangler pages deploy dist --project-name=saskatoonsfc
```

或者分步执行：

```bash
# 1. 构建
npm run build

# 2. 部署
wrangler pages deploy dist --project-name=saskatoonsfc
```

### 自定义域名配置

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 进入 **Compute & AI** → **Workers & Pages**
3. 点击 `seat-select` 项目
4. 选择 **Custom domains** 选项卡
5. 点击 **Set up a custom domain**
6. 输入域名并确认

### 环境变量说明

Vue CLI 的 `VUE_APP_*` 环境变量在**构建时**注入，不是运行时读取。

- 本地部署：修改 `.env` 后重新 `npm run build`
- Git 自动部署：在 Cloudflare Dashboard → Pages → seat-select → Settings → Environment variables 中配置

## 项目结构

```
src/
├── pages/          # 页面组件
├── components/     # 公共组件
├── router/         # 路由配置
├── i18n/           # 国际化配置
├── supabase.js     # Supabase 客户端
└── App.vue         # 根组件
```

## License

MIT
