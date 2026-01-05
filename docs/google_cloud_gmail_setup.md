# Google Cloud Gmail API 配置指南

为了让后端系统能够自动检查 Interac 付款邮件，您需要在 Google Cloud Console 中配置 Gmail API 并生成 `credentials.json` 文件。

## 第一步：创建 Google Cloud 项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)。
2. 在页面顶部，点击项目选择器（通常显示为 "Select a project"）。
3. 点击 **"NEW PROJECT"** (新项目)。
4. 输入项目名称（例如：`Seat-Select-Backend`），然后点击 **"CREATE"**。

## 第二步：启用 Gmail API

1. 确保已选中刚才创建的项目。
2. 在左侧菜单中，选择 **"APIs & Services"** > **"Enabled APIs & services"**。
3. 点击顶部的 **"+ ENABLE APIS AND SERVICES"**。
4. 在搜索框中输入 `Gmail API`。
5. 点击搜索结果中的 **"Gmail API"**，然后点击 **"ENABLE"** (启用)。

## 第三步：配置 OAuth 同意屏幕 (OAuth Consent Screen)

在生成凭据之前，必须先配置同意屏幕：

1. 在左侧菜单中，选择 **"APIs & Services"** > **"OAuth consent screen"**。
2. 选择 **"User Type"** 为 **"External"** (外部)，然后点击 **"CREATE"**。
3. 填写基本信息：
   - **App name**: `Seat Select Checker`
   - **User support email**: 选择您的 Gmail 邮箱。
   - **Developer contact information**: 输入您的邮箱。
4. 点击 **"SAVE AND CONTINUE"**。
5. **Scopes (范围)**:
   - 点击 **"ADD OR REMOVE SCOPES"**。
   - 在底部输入框手动添加以下两个范围（或在列表中搜索）：
     - `https://www.googleapis.com/auth/gmail.readonly` (读取邮件)
     - `https://www.googleapis.com/auth/gmail.send` (发送邮件)
   - 点击 **"ADD TO TABLE"**，然后点击 **"UPDATE"**。
   - 点击 **"SAVE AND CONTINUE"**。
6. **Test users (测试用户)**:
   - 点击 **"ADD USERS"**。
   - **非常重要**: 输入接收 Interac 付款通知的那个 Gmail 邮箱地址。
   - 点击 **"ADD"**，然后点击 **"SAVE AND CONTINUE"**。

## 第四步：生成凭据 (Credentials)

1. 在左侧菜单中，选择 **"APIs & Services"** > **"Credentials"**。
2. 点击顶部的 **"+ CREATE CREDENTIALS"**，选择 **"OAuth client ID"**。
3. **Application type**: 选择 **"Desktop app"** (桌面应用)。
4. **Name**: `Backend Auth` (可以随意填写)。
5. 点击 **"CREATE"**。
6. 弹出一个窗口显示 "OAuth client created"，点击 **"DOWNLOAD JSON"**。

## 第五步：部署凭据

1. 将下载的 `.json` 文件重命名为 `credentials.json`。
2. 将该文件移动到项目中的以下位置：
   `seat-select-backend/src/utils/gmail/creds/credentials.json`

## 第六步：完成身份验证

1. 启动您的 Celery Worker (或者运行 `gmail_api.py` 的测试脚本)。
2. 系统会自动在您的默认浏览器中打开一个 Google 登录页面。
3. 选择您在 **"Test users"** 中添加的那个账号。
4. **注意**: 可能会看到 "Google hasn't verified this app" (Google 尚未验证此应用) 的警告。
   - 点击 **"Advanced"** (高级)。
   - 点击 **"Go to Seat Select Checker (unsafe)"**。
5. 点击 **"Continue"** (继续) 授予权限。
6. 验证成功后，系统会在 `creds/` 目录下自动生成 `token.pickle` 文件，此后将不再需要手动登录。

> [!IMPORTANT]
> 请妥善保管 `credentials.json` 和 `token.pickle`，不要将它们上传到公共 Git 仓库。
