# CoinSec — Agent Guide

## Repository structure

Two independent Gradle projects in one repo, **not** a unified monorepo build:

| Directory          | Type                | Entrypoint                                | Key stack                                               |
| ------------------ | ------------------- | ----------------------------------------- | ------------------------------------------------------- |
| `CoinSec-App/`     | Android app         | `MainActivity.kt` → `Greeting` composable | Kotlin, Jetpack Compose, AGP 9.2.1, minSdk/targetSdk 36 |
| `CoinSec-Backend/` | Spring Boot backend | `CoinSecBackendApplication.java`          | Spring Boot 4.0.6, Java 25, PostgreSQL, Lombok          |

Both are freshly-scaffolded starter projects with **no business logic** yet.

## Commands

### Backend (`CoinSec-Backend/`)

```bash
./gradlew bootRun          # starts on :8080 with dev profile (activates PG datasource)
./gradlew test             # JUnit 5 — single contextLoads smoke test
```

### App (`CoinSec-App/`)

```bash
./gradlew assembleDebug    # build debug APK
./gradlew test             # JUnit 4 unit tests
```

## Gotchas

- **Backend `main` is not `public`** (`static void main` without `public`). Works with Spring Boot 4.x, but agents looking for `public static void main` won't find it.
- **Backend uses Java 25** — verify JDK before running Gradle.
- **App Gradle uses Aliyun mirrors** (`maven.aliyun.com`) in `settings.gradle.kts`. If building outside China, consider adding `mavenCentral()` / `google()` as primary repos.
- **Dev profile is active by default** (`spring.profiles.active: dev`). Backend requires a local PostgreSQL at `localhost:5432/coinsec_db` with credentials `coinsec` / `097016@CoinSec`.
- **No CI, no lint config, no formatter config** in this repo.
- **KSP declared but unused** — `com.google.devtools.ksp` in root `build.gradle.kts` of `CoinSec-App` has no consuming module.

## 开发要求

1. **后端代码**保持 Java / Spring Boot 规范
2. **前端代码**保持 APP 项目规范
3. 不随意重构、不随意格式化代码
4. 只做需求内的修改，不添加无关功能
5. **注释必须有效**，不写无意义的注释（如"为了修复xx问题"或者修复类注释），仅在代码逻辑需要解释时才写注释
   - 修复原因、改动说明等应在**对话中**通过代码块展示，**不写入代码注释**
6. **新增功能必须编写测试代码**，测试通过后方可提交
7. **添加新依赖**必须先通知我，说明该依赖的用途，经审核同意后方可添加
8. **后端接口必须使用 RESTful 风格**
9. **提交前必须运行测试**，确保所有测试通过

## 后端 Spring Boot 强制开发规范

适用于 `CoinSec-Backend/` 目录下所有 Java 代码。

### 1. 包结构规范（必须严格遵守）

固定包路径：`com.kody.coinsec.backend`

子包结构：

- `controller` — 接口层（对外提供 API）
- `service` — 业务逻辑层
- `service/impl` — 业务实现类
- `entity/model` — 数据库实体 / 数据模型
- `mapper/dao` — 数据访问（MyBatis/JPA）
- `dto` — 数据传输对象（请求/响应）
- `config` — 配置类
- `exception` — 全局异常、自定义异常
- `util` — 工具类

### 2. 分层调用规范

- 外部请求 → Controller → Service → Repository/DAO
- Controller 只处理请求、参数校验、返回统一格式
- Service 只写业务逻辑，不处理 HTTP 相关
- 禁止跨层调用（如 Controller 直接操作数据库）

### 3. 命名规范

- 类名：大驼峰，望文知意（`UserController`、`UserService`、`UserEntity`）
- 接口名：以 `I` 开头或直接用名词，实现类加 `Impl`（`UserService` → `UserServiceImpl`）
- 方法名：小驼峰，动词+名词（`getUserById`、`createOrder`、`updateUserStatus`）
- 常量名：全大写+下划线（`PAGE_SIZE`、`DEFAULT_STATUS`）

### 4. 代码风格

- 缩进 4 空格
- 大括号不换行（K&R 风格）
- 一行只写一条语句
- 方法行数尽量不超过 80 行
- 禁止魔法值（所有硬编码数字/字符串抽成常量或枚举）

### 5. 注解规范

- 接口使用 `@RestController`
- 业务类使用 `@Service`
- 配置类使用 `@Configuration`
- 依赖注入统一使用构造器注入（禁止字段注入 `@Autowired`）
- 使用 Lombok 简化代码（`@Data`、`@NoArgsConstructor`、`@AllArgsConstructor`、`@Builder`）

### 6. API 接口规范

- 请求路径使用小写 + 中横线：`/user/login-log`
- 统一返回结果格式：`code`、`msg`、`data`
- GET 用于查询，POST 用于新增，PUT 用于修改，DELETE 用于删除
- 接口必须加 `@Operation` / 接口说明（方便文档生成）

### 7. 异常规范

- 统一全局异常处理
- 业务异常抛自定义 `RuntimeException`
- 禁止在业务代码里 catch 异常不处理
- 异常信息清晰，不暴露内部敏感信息

### 8. 禁止行为

- 禁止在 Controller 写业务逻辑
- 禁止直接在 Controller 操作数据库
- 禁止使用 `System.out.println`，必须用日志
- 禁止硬编码配置信息
- 禁止随意修改 `application.yml` 配置

## APP Android 强制开发规范（Kotlin + Jetpack Compose）

适用于 `CoinSec-App/` 目录下所有 Kotlin 代码。

### 一、项目包结构

基础根包：`com.kody.coinsec.app`

分层子包划分：

```
ui          页面、Compose 组件
viewmodel   视图业务逻辑
repository  数据仓库层
data        实体、DTO、本地/远程数据源
domain      业务模型、枚举、用例
common      通用工具、常量、扩展函数
navigation  页面路由
di          依赖注入
```

### 二、分层职责

1. **UI 层**：仅负责页面渲染、用户交互回调，不处理业务逻辑
2. **ViewModel**：管理页面状态、处理事件、调度数据，持有生命周期感知
3. **Repository**：统一聚合本地缓存与网络请求，隔离数据源
4. **Data 层**：定义数据实体、接口请求、数据库映射

### 三、命名规范

- 类 / Compose 页面：大驼峰 `HomeScreen`、`UserViewModel`
- 函数 / 变量：小驼峰 `clickLogin`、`userInfo`
- 常量：全大写下划线 `MAX_INPUT_LENGTH`
- 状态变量：后缀标识 `uiState`、`loadingState`
- 资源文件：小写下划线 `ic_logo`、`bg_main`

### 四、Compose 编码规范

1. 可组合函数统一以 `Screen` / `Component` 结尾区分页面与小组件
2. 页面状态统一用 `UiState` 数据类托管，避免零散变量
3. 组件拆分：单一职责，单组件代码不宜过长，复用组件抽离
4. 状态只读优先，状态修改统一交由 ViewModel 处理
5. 布局优先使用 Column/Row/Box 基础布局，嵌套层级精简
6. 主题、颜色、尺寸统一抽取到 Theme 文件，禁止硬编码色值、字号

### 五、编码与语法规范

1. 全程使用 Kotlin 语法，遵循 Kotlin 官方编码风格
2. 空安全严格管控，合理使用 `?`，`!!` 谨慎使用
3. 避免全局静态变量，共享数据走仓库 / 状态流转
4. 日志统一封装工具类，禁用原生打印
5. 废弃代码直接删除，不注释遗留无用代码

### 六、状态与生命周期

1. 页面状态使用 `remember`、`rememberSaveable` 留存数据
2. 协程统一在 ViewModel 作用域启动，自动跟随生命周期取消
3. 页面销毁及时终止网络、订阅任务，杜绝内存泄漏

### 七、网络与数据请求

1. 网络请求统一封装，异常统一拦截处理
2. 接口入参、响应实体与后端字段命名对齐
3. 请求加载、失败、空数据状态页面统一兜底展示

### 八、路由与页面跳转

1. 页面跳转统一使用导航组件管理
2. 页面参数传递遵循导航规范，不使用全局传参

### 九、权限与适配

1. 动态权限按需申请，申请前增加弹窗提示
2. 适配不同屏幕尺寸，使用相对尺寸、权重布局
3. 兼容项目最低 SDK 36 特性，不调用高版本专属 API

### 十、禁止行为

1. 禁止在 Compose 组件内编写网络、数据库业务逻辑
2. 禁止直接跨页面篡改数据，状态变更统一单向流转
3. 禁止硬编码接口地址、密钥、账号配置
4. 禁止随意改动 Gradle 版本、依赖库版本、编译配置
5. 仅允许编辑 `CoinSec-App/app/**` 目录文件，改动其他文件需审批

## 文件修改权限

默认只修改以下两个目录：

1. **Java 后端**：`src/**`（SpringBoot 代码）
2. **APP 前端**：`app/**`

如需修改其他目录或文件，必须先通知我并说明原因，经我审核同意后方可修改。

TODO 列表文件（如 `TODO.md`）不受上述限制，可自由修改，内容必须使用中文。

## 数据库操作规范

### 1. 绝对禁止操作

- 禁止 DROP DATABASE（删除数据库）
- 禁止 DROP TABLE（删除表）
- 禁止 ALTER TABLE（修改表结构：加字段、删字段、改字段、改类型）
- 禁止 TRUNCATE TABLE（清空表数据）
- 禁止 CREATE TABLE（新建表）
- 禁止任何修改表结构的行为

### 2. 允许操作

- 允许 SELECT 查询数据
- 允许 INSERT 新增数据
- 允许 UPDATE 更新数据（必须带 WHERE）
- 允许 DELETE 删除数据记录（必须带 WHERE 条件）

### 3. 数据删除规则

- 优先使用逻辑删除：`is_deleted = true`
- 物理删除仅允许删除单条/指定记录，必须带 `WHERE id = ?`

### 4. SQL 编写规范

- 禁止使用 `SELECT *`
- 禁止无 WHERE 条件的 UPDATE / DELETE
- 禁止原生危险 SQL（DROP / ALTER / TRUNCATE）

### 5. 表结构说明

- 表结构已固定，永远不允许修改
- 实体类字段必须与现有表结构完全一致
- 不允许新增、删除、修改实体类字段

## 开发方案文档

`docs/` 目录下会有 `Backend/` 和 `App/` 两个文件夹，分别放置后端和 APP 的开发方案 **MD 文件**。开发时严格按照方案执行，不得自行修改方案。若需修改方案，必须通知我审核通过后方可调整。

## Git 规范

### 分支管理

1. **所有开发必须从 `dev` 分支拉出全新分支**
2. **分支命名规则：**
   - 后端功能：`feature/java-xxx`
   - 后端修复：`fix/java-xxx`
   - APP 功能：`feature/app-xxx`
   - APP 修复：`fix/app-xxx`
3. **开发完成后统一合并到 `dev` 分支**，由我测试通过后再合并到 `main`
4. **禁止直接修改 `main` / `master` 分支**
5. **禁止直接提交到 `dev` 分支**
6. **单用户开发时，功能分支仅在本地维护，不推送到远程 GitHub**。合并到 `dev` 后只推送 `dev` 分支到远程。

### Tag 命名规范

```
后端：backend-v主版本.次版本.补丁   （例：backend-v1.0.0）
App：  app-v主版本.次版本.补丁        （例：app-v1.0.0）
```

- 禁止使用 `v1.0.0` 这种无前缀格式（分不清所属项目）
- 必须前缀 `backend-` / `app-`
- 版本号遵循语义化：主版本（大改）.次版本（功能）.补丁（修复）

### 提交规范

1. **提交信息格式：**
   - 后端功能：`java: feat: 具体描述`
   - 后端修复：`java: fix: 具体描述`
   - APP 功能：`app: feat: 具体描述`
   - APP 修复：`app: fix: 具体描述`
2. **小步提交**，不允许一次性提交大量无关代码
3. 提交前检查 `git status` 和 `git diff`，只 stage 本次相关的文件
