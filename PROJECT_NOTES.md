# Uptime Kuma 项目改动记录

## 📋 项目简介

**Uptime Kuma** 是一个开源的服务监控和状态页面系统，用于监控网站/服务的可用性、响应时间等指标。

- **原项目地址**: https://github.com/louislam/uptime-kuma
- **本地仓库路径**: `/home/ubikry/codes/uptime-kuma/uptime-kuma`
- **技术栈**:
  - 后端: Node.js + Express + SQLite3 + Socket.IO
  - 前端: Vue 3 + Vite + Bootstrap 5
  - 运行时: Node.js 22.x

## 🔧 我的改动记录

### 1. 状态页面增强 (2026-01-15)

**功能**: 在公开状态页面中为每个监控项添加详细统计信息

**修改文件**:
- `server/routers/status-page-router.js` - 扩展 API 返回 24h 平均响应、当前响应、多时段在线率
- `src/components/MonitorStats.vue` - 新建统计组件，展示响应时间和在线率
- `src/components/PublicGroupList.vue` - 集成统计组件，直接显示在每个监控项下
- `src/pages/StatusPage.vue` - 处理新增的 `avgPingList` 和 `currentPingList`

**展示内容**:
- 平均响应时间 (24小时)
- 在线率 (24小时 / 30天 / 1年)
- 证书有效期（HTTPS 监控）

### 2. 企业微信通知调试 (2026-01-15)

**功能**: 为 WeCom 通知添加调试日志

**修改文件**:
- `server/notification-providers/wecom.js` - 添加详细日志追踪
- `server/server.js` - 在 `testNotification` 事件中添加日志
- `src/components/NotificationDialog.vue` - 前端测试按钮添加日志

### 3. Docker 镜像构建修复 (2026-01-15)

**问题**: 原 Dockerfile 缺少前端构建步骤，导致 `dist/index.html` 缺失

**修改文件**:
- `docker/dockerfile` - 添加 `npm run build` 构建前端
- `config/vite.config.js` - 增加 PWA 文件缓存大小限制到 5MB

**构建流程**:
```dockerfile
RUN npm ci                    # 安装所有依赖
COPY . .                      # 复制源码
RUN npm run build             # 构建前端 -> 生成 dist/
RUN mkdir ./data              # 创建数据目录
```

### 4. 构建和推送脚本 (2026-01-15)

**文件**: `build-and-push.sh`

**功能**: 自动化 Docker 镜像构建和推送流程
- 自动从 `package.json` 读取版本号
- 构建镜像并打标签 (latest + 版本号)
- 推送到阿里云容器镜像服务

### 5. 国际化支持 (2026-01-15)

**修改文件**:
- `src/components/MonitorStats.vue` - 将硬编码的"平均响应时间"改为 `$t("Avg. Response")`

## 🚀 开发和运行

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器（前端 + 后端同时启动）
npm run dev

# 前端: http://localhost:3000
# 后端: http://localhost:3001
```

### 生产环境构建

```bash
# 仅构建前端（生成 dist/ 目录）
npm run build

# 启动生产服务器
npm run start
```

## 🐳 Docker 镜像构建和推送

### 使用自动化脚本（推荐）

```bash
# 一键构建并推送到阿里云
./build-and-push.sh
```

脚本会自动：
1. 从 `package.json` 读取当前版本 (如 `2.1.0-beta.2`)
2. 构建 Docker 镜像
3. 打标签: `latest` 和 `2.1.0-beta.2`
4. 推送到阿里云容器镜像服务

### 手动构建（了解流程）

```bash
# 1. 构建镜像
docker build \
  -f docker/dockerfile \
  --target release \
  -t uptime-kuma:latest \
  -t uptime-kuma:2.1.0-beta.2 \
  .

# 2. 打阿里云标签
docker tag uptime-kuma:latest \
  registry.cn-hangzhou.aliyuncs.com/ubikry/uptime-kuma:latest
docker tag uptime-kuma:2.1.0-beta.2 \
  registry.cn-hangzhou.aliyuncs.com/ubikry/uptime-kuma:2.1.0-beta.2

# 3. 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/ubikry/uptime-kuma:latest
docker push registry.cn-hangzhou.aliyuncs.com/ubikry/uptime-kuma:2.1.0-beta.2
```

## 📦 镜像仓库

### 阿里云容器镜像服务

- **仓库地址**: `registry.cn-hangzhou.aliyuncs.com/ubikry/uptime-kuma`
- **可用标签**:
  - `latest` - 最新版本
  - `2.1.0-beta.2` - 特定版本

### 部署命令

```bash
docker run -d \
  --name uptime-kuma \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  registry.cn-hangzhou.aliyuncs.com/ubikry/uptime-kuma:latest
```

访问地址: http://localhost:3001

## 📝 版本更新流程

当需要发布新版本时：

```bash
# 1. 更新版本号
npm version patch   # 2.1.0 -> 2.1.1 (补丁版本)
npm version minor   # 2.1.1 -> 2.2.0 (次版本)
npm version major   # 2.2.0 -> 3.0.0 (主版本)

# 2. 构建并推送镜像
./build-and-push.sh

# 3. 提交代码
git push origin master --tags
```

## 🔍 关键文件说明

| 文件 | 说明 |
|------|------|
| `package.json` | 项目配置、依赖、版本号、构建脚本 |
| `server/server.js` | 后端服务器入口 |
| `src/main.js` | 前端应用入口 |
| `config/vite.config.js` | 前端构建配置 |
| `docker/dockerfile` | Docker 镜像构建文件 |
| `build-and-push.sh` | 自动化构建推送脚本 |
| `data/` | 数据库和配置文件目录（运行时生成） |

## 🗂️ 项目结构

```
uptime-kuma/
├── server/                      # 后端代码
│   ├── server.js               # Express 服务器
│   ├── notification-providers/ # 通知提供者
│   ├── routers/                # API 路由
│   └── model/                  # 数据模型
├── src/                         # 前端代码
│   ├── components/             # Vue 组件
│   │   ├── MonitorStats.vue   # 统计信息组件（新增）
│   │   └── PublicGroupList.vue # 公开分组列表
│   ├── pages/                  # 页面
│   └── lang/                   # 国际化文件
├── config/
│   └── vite.config.js          # Vite 构建配置
├── docker/
│   └── dockerfile              # Docker 构建文件
├── dist/                        # 前端构建输出（npm run build 生成）
├── data/                        # 数据目录（运行时）
├── package.json                 # 项目配置
├── build-and-push.sh           # 构建推送脚本（新增）
└── PROJECT_NOTES.md            # 本文档
```

## 🔐 环境要求

- **Node.js**: >= 20.4.0（推荐 22.x）
- **Docker**: 用于容器化部署
- **阿里云账号**: 用于推送镜像到私有仓库

## 📚 相关链接

- **原项目 GitHub**: https://github.com/louislam/uptime-kuma
- **官方文档**: https://github.com/louislam/uptime-kuma/wiki
- **Docker Hub**: https://hub.docker.com/r/louislam/uptime-kuma

## 💡 提示

- 修改前端代码后需要 `npm run build` 重新构建
- 修改后端代码后重启服务即可（开发模式自动重启）
- 数据库文件在 `data/kuma.db`，注意备份
- 生产环境务必配置 HTTPS 和反向代理（Nginx/Caddy）

---

**最后更新**: 2026-01-15
