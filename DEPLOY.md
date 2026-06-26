# Cloudflare Workers 部署指南

## 准备工作

### 1. 安装 Wrangler CLI

```bash
npm install -g wrangler
```

或使用 Yarn:
```bash
yarn global add wrangler
```

### 2. 登录 Cloudflare

```bash
wrangler login
```

这会打开浏览器进行授权。

### 3. 检查登录状态

```bash
wrangler whoami
```

应该显示您的 Cloudflare 账号信息。

---

## 部署方法

### 方法一：使用交互式脚本（推荐）

```bash
chmod +x deploy.sh
./deploy.sh
```

脚本会引导您完成：
- 检查文件
- 验证登录状态
- 部署或预览选项

### 方法二：使用 Makefile

#### 部署到生产环境：
```bash
make deploy
```

#### 本地开发预览：
```bash
make dev
```

### 方法三：直接使用 Wrangler 命令

#### 仅验证配置（不实际部署）：
```bash
wrangler deploy --dry-run
```

#### 部署到生产环境：
```bash
wrangler deploy
```

#### 本地开发预览：
```bash
wrangler dev
```

---

## 配置文件说明

### wrangler.toml

```toml
name = "bpb-worker-panel"      # Worker 名称
main = "_worker.js"            # 入口文件
compatibility_date = "2024-01-01"  # 兼容性日期

logpush = true                  # 启用 Workers 日志推送
```

### 自定义配置（可选）

#### 添加环境变量：
```toml
[vars]
API_KEY = "your-api-key"
DOMAIN = "example.com"
```

#### 添加 KV 存储：
```toml
[[kv_namespaces]]
binding = "WORKERS"
id = "your-kv-namespace-id"
```

---

## 获取资源 ID

### KV 命名空间 ID

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 进入 Workers & Pages
3. 点击 "KV"
4. 创建新的命名空间或查看现有 ID

### Account ID

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 点击右侧边栏的任意域名
3. 在"概述"页面底部找到 "Account ID"

---

## 部署后验证

### 1. 检查部署状态

```bash
wrangler deployments list
```

### 2. 查看日志

```bash
wrangler tail
```

### 3. 测试 Worker

部署后，Worker 应该可以通过以下 URL 访问：
```
https://bpb-worker-panel.<your-subdomain>.workers.dev
```

---

## 常见问题

### Q: 部署失败，显示权限错误？
A: 运行 `wrangler login` 重新授权

### Q: 如何回滚到旧版本？
A:
```bash
wrangler deployments list
# 选择旧版本的 ID
wrangler rollback <deployment-id>
```

### Q: 如何查看详细日志？
A:
```bash
wrangler dev --log-level debug
```

### Q: 部署后无法访问？
A: 检查 Workers 配额和订阅状态，确保账户有足够的配额。

---

## 自动化部署（可选）

如果您希望每次 GitHub Actions 更新时自动部署，可以：

1. 在 Cloudflare Dashboard 创建 API Token
2. 在 GitHub Secrets 中添加 `CLOUDFLARE_API_TOKEN`
3. 在工作流中添加部署步骤

---

## 更多信息

- [Wrangler 文档](https://developers.cloudflare.com/workers/wrangler/)
- [Workers 定价](https://developers.cloudflare.com/workers/platform/pricing/)
- [Workers 示例](https://developers.cloudflare.com/workers/examples/)
