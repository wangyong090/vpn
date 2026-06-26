# BPB Worker Panel 完整部署与配置指南

> 版本：v4.1.3 | 更新日期：2026-06-26

---

## 目录

1. [项目概述](#1-项目概述)
2. [前置准备](#2-前置准备)
3. [部署 Worker](#3-部署-worker)
4. [配置 KV 存储](#4-配置-kv-存储)
5. [配置环境变量](#5-配置环境变量)
6. [验证部署](#6-验证部署)
7. [首次使用](#7-首次使用)
8. [高级配置](#8-高级配置)
9. [常见问题](#9-常见问题)
10. [配置信息汇总](#10-配置信息汇总)

---

## 1. 项目概述

**BPB Worker Panel** 是一款基于 Cloudflare Workers 的代理面板，支持：
- VLESS / Trojan 协议
- 订阅链接生成
- Fragment 配置
- WARP / WARP PRO
- 自定义节点
- 路由规则

**特点**：
- 🆓 完全免费（Cloudflare Free Plan）
- ⚡ 全球 CDN 加速
- 🔒 无需服务器
- 🔄 自动更新支持

---

## 2. 前置准备

### 2.1 必需条件

- ✅ Cloudflare 账户（免费即可）
- ✅ 现代浏览器
- ⏱️ 约 10 分钟配置时间

### 2.2 创建 Cloudflare 账户

1. 访问 [Cloudflare 注册页面](https://dash.cloudflare.com/sign-up)
2. 使用邮箱注册（推荐 Gmail）
3. 完成邮箱验证

> ⚠️ **注意**：不要使用 `bpb` 等关键词作为 Worker 名称，可能触发 Cloudflare 检测导致 1101 错误。

---

## 3. 部署 Worker

### 3.1 方法一：手动部署（推荐新手）

#### 步骤 1：下载 Worker 代码

从 GitHub Release 下载最新版：
```
https://github.com/bia-pain-bache/BPB-Worker-Panel/releases/latest/download/worker.js
```

#### 步骤 2：创建 Worker

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 左侧菜单 → **Workers & Pages**
3. 点击 **Create application**
4. 选择 **Workers** 标签 → **Hello World** → **Get started**
5. 输入 Worker 名称（比如 `my-panel`），点击 **Deploy**

#### 步骤 3：上传代码

1. 点击 **Edit code**
2. 删除左侧的 `worker.js` 文件
3. 上传下载的 `worker.js`（重命名为 `worker.js`）
4. 右上角点击 **Deploy**

### 3.2 方法二：使用 Wrangler CLI 部署

#### 安装 Wrangler

```bash
npm install -g wrangler
```

#### 登录 Cloudflare

```bash
wrangler login
```

#### 创建配置文件

创建 `wrangler.toml`：

```toml
name = "your-worker-name"
main = "_worker.js"
compatibility_date = "2024-01-01"
```

#### 部署

```bash
wrangler deploy
```

---

## 4. 配置 KV 存储

> ⚠️ **重要**：KV 命名空间的 **binding 名称必须是 `kv`**（全小写），否则面板无法读取配置！

### 4.1 创建 KV 命名空间

1. 打开 Cloudflare Dashboard
2. 左侧菜单 → **Workers & Pages**
3. 点击 **KV**
4. 点击 **Create a namespace**
5. 输入名称（比如 `bpb-panel`），点击 **Add**

### 4.2 绑定 KV 到 Worker

1. 进入您的 Worker 页面
2. 点击 **Settings** 标签
3. 左侧菜单 → **Bindings**
4. 点击 **Add binding**
5. 选择 **KV Namespace**
6. 填写配置：
   - **Variable name（变量名）**：`kv` （⚠️ 必须是小写 kv！）
   - **KV namespace**：选择刚才创建的命名空间
7. 点击 **Add**

---

## 5. 配置环境变量

### 5.1 核心配置（必需）

在 Worker 的 **Settings** → **Variables and Secrets** 中添加以下 3 个变量：

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `UUID` | VLESS UUID | `d7674958-1d1e-4836-8b3d-3db896bea8e0` |
| `TROJAN_PASSWORD` | Trojan 密码 | `JqsHdshiuUMOJAWJ` |
| `SUB_PATH` | 订阅路径 | `6gdtiysu` |

### 5.2 生成您自己的配置

#### 生成 UUID

**Linux / macOS：**
```bash
uuidgen
```

**Windows（PowerShell）：**
```powershell
[guid]::NewGuid().ToString()
```

**在线生成：**
- 访问 Worker 地址 + `/secrets`（如 `https://your-worker.workers.dev/secrets`）
- 或使用 [UUID Generator](https://www.uuidgenerator.net/)

#### 生成随机密码

**Linux / macOS：**
```bash
tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16
```

#### 生成订阅路径

订阅路径可以是任意字符串，用于隐藏您的订阅链接，建议使用随机字符串。

**Linux / macOS：**
```bash
tr -dc 'a-z0-9' < /dev/urandom | head -c 8
```

### 5.3 添加变量步骤

1. 进入 Worker → **Settings** → **Variables and Secrets**
2. 点击 **Add variable**
3. 输入变量名（如 `UUID`）
4. 输入变量值
5. 点击 **Add**
6. 重复添加所有 3 个变量
7. 最后点击 **Deploy** 保存

---

## 6. 验证部署

### 6.1 检查配置是否生效

访问您的 Worker 地址：
```
https://your-worker.your-subdomain.workers.dev
```

如果配置正确，根路径会重定向到 speedtest 页面（伪装页面）。

### 6.2 访问面板

在地址后面加上 `/panel`：
```
https://your-worker.your-subdomain.workers.dev/panel
```

✅ **成功**：显示设置管理员密码页面  
❌ **失败**：显示 "Something went wrong" 错误

---

## 7. 首次使用

### 7.1 设置管理员密码

1. 首次访问 `/panel` 会要求设置密码
2. 密码要求：
   - 至少 8 位
   - 包含大写字母
   - 包含数字
3. 输入密码后点击确认

### 7.2 登录面板

使用刚才设置的密码登录。

### 7.3 获取订阅链接

登录后，您的订阅链接为：
```
https://your-worker.your-subdomain.workers.dev/您的SUB_PATH
```

例如：
```
https://my-panel.abc123.workers.dev/6gdtiysu
```

将此链接导入 V2rayN / NekoBox / Clash 等客户端即可使用。

---

## 8. 高级配置

### 8.1 回退域名（伪装页面）

默认访问根路径会跳转到 speedtest。您可以自定义：

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `FALLBACK` | 回退域名（不带 http://） | `www.speedtest.net` |

### 8.2 代理 IP（优选 IP）

指定用于连接 Cloudflare 的代理 IP：

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `PROXY_IP` | 代理 IP 或域名，多个用逗号分隔 | `151.213.181.145, 5.163.51.41` |

### 8.3 NAT64 前缀

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `NAT64_PREFIX` | NAT64 前缀，多个用逗号分隔 | `[2602:fc59:b0:64::], [2602:fc59:11:64::]` |

### 8.4 完整 wrangler.toml 示例

```toml
name = "my-bpb-panel"
main = "_worker.js"
compatibility_date = "2024-01-01"

# KV 存储（必需，binding 必须为 "kv"）
[[kv_namespaces]]
binding = "kv"
id = "您的KV命名空间ID"

# 核心配置
[vars]
UUID = "您的UUID"
TROJAN_PASSWORD = "您的密码"
SUB_PATH = "您的订阅路径"

# 可选配置
# FALLBACK = "www.speedtest.net"
# PROXY_IP = ""
# NAT64_PREFIX = ""
```

---

## 9. 常见问题

### Q1：显示 "Something went wrong" 怎么办？

**可能原因及解决方法：**

1. **KV binding 名称错误**
   - ✅ 检查：Settings → Bindings → 变量名是否为 `kv`（小写）
   - ❌ 常见错误：`WORKERS`、`KV`、`bpb` 等都不行，必须是 `kv`

2. **缺少环境变量**
   - 检查是否设置了 `UUID`、`TROJAN_PASSWORD`、`SUB_PATH`
   - 变量名大小写要完全一致

3. **变量名拼写错误**
   - 确认变量名完全正确（大写）
   - `UUID` ✅，不是 `uuid` ❌
   - `TROJAN_PASSWORD` ✅，不是 `TROJAN_PASS` ❌
   - `SUB_PATH` ✅，不是 `SUBPATH` ❌

### Q2：1101 错误怎么办？

1101 错误是 Cloudflare 的脚本运行错误，可能原因：
- Worker 名称包含敏感关键词（如 `bpb`、`vless`）
- 代码被 Cloudflare 标记

**解决方法：**
- 重新创建一个 Worker，换个不相关的名字
- 使用混淆过的代码
- 不要在 Worker 名称中使用 `bpb`、`proxy`、`vless` 等词

### Q3：订阅链接无法使用怎么办？

1. 确认 UUID 和密码正确
2. 检查订阅路径是否正确
3. 尝试更新订阅
4. 检查 Cloudflare 状态是否正常

### Q4：如何更新面板？

**方法一：手动更新**
1. 下载最新的 worker.js
2. 进入 Worker → Edit code
3. 删除旧文件，上传新文件
4. Deploy

**方法二：GitHub Actions 自动更新**
- 参考项目中的自动同步工作流

### Q5：认领临时 Worker 后配置丢失？

**正常现象！** Claim（认领）操作只会迁移 Worker 代码，不会迁移：
- KV 命名空间
- 环境变量
- KV Binding

**解决方法**：在您的账户中重新配置 KV 和环境变量（参考本指南第 4、5 章）。

### Q6：如何重置面板密码？

删除 KV 中的相关数据，或在 KV 中找到密码配置进行修改。

---

## 10. 配置信息汇总

> 💡 请将您的配置信息填写到下面，方便以后查阅

### 基本信息

| 项目 | 您的配置 |
|------|----------|
| Worker 名称 | `___________________` |
| Worker 地址 | `___________________` |
| 面板路径 | `/panel` |
| 订阅路径 | `___________________` |

### 核心配置

| 配置项 | 值 |
|--------|-----|
| **VLESS UUID** | `___________________` |
| **Trojan 密码** | `___________________` |
| **订阅路径 (SUB_PATH)** | `___________________` |

### KV 存储

| 项目 | 值 |
|------|-----|
| KV 命名空间名称 | `___________________` |
| KV 命名空间 ID | `___________________` |
| KV Binding 名称 | `kv`（必须） |

### 可选配置

| 配置项 | 值 |
|--------|-----|
| FALLBACK（回退域名） | `___________________` |
| PROXY_IP（代理 IP） | `___________________` |
| NAT64_PREFIX | `___________________` |

---

## 参考链接

- 🔗 [BPB Worker Panel 官方文档](https://bia-pain-bache.github.io/BPB-Worker-Panel/)
- 🔗 [GitHub 仓库](https://github.com/bia-pain-bache/BPB-Worker-Panel)
- 🔗 [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- 🔗 [Wrangler CLI 文档](https://developers.cloudflare.com/workers/wrangler/)

---

*文档生成时间：2026-06-26 | BPB Panel v4.1.3*
