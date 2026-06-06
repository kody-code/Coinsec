# CoinSec

个人财务管理系统，包含三个独立子项目。

## 项目结构

| 子项目 | 目录 | 技术栈 |
|--------|------|--------|
| **后端** | `CoinSec-Backend/` | Spring Boot 4.0.6 + Java 25 + PostgreSQL |
| **Android App** | `CoinSec-App/` | Kotlin + Jetpack Compose + Material 3 |
| **Web 前端** | `CoinSec-Web/` | Vue 3 + TypeScript + Element Plus |

## 快速开始

### 后端

```bash
cd CoinSec-Backend
./gradlew bootRun
```

启动前确保本地 PostgreSQL 已运行，并创建 `coinsec_db` 数据库（配置见 `application-dev.yaml`）。

### Web 前端

```bash
cd CoinSec-Web
pnpm install
pnpm dev
```

默认在 `http://localhost:3000` 启动，开发服务器代理 `/api` 到后端 `:8080`。

### Android App

```bash
cd CoinSec-App
./gradlew assembleDebug
```

需 Android SDK 36，签名密钥通过环境变量配置。

## 文档

各子项目详细文档见对应目录下的 `README.md`：

- [后端文档](CoinSec-Backend/README.md)
- [App 文档](CoinSec-App/README.md)
- [Web 文档](CoinSec-Web/README.md)

开发方案见 [docs/](docs/) 目录。

## 开发规范

详见 [AGENTS.md](AGENTS.md)。
