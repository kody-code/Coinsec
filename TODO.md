# CoinSec TODO 列表

## 一、后端开发（按模块顺序，依赖先前模块完成）

### 0. 基础骨架
- [ ] common 模块：统一返回结果 `Result<T>`、全局异常处理 `GlobalExceptionHandler`、业务异常 `BusinessException`
- [ ] config 模块：跨域配置 `CorsConfig`、Sa-Token 配置 `SaTokenConfig`
- [ ] util 工具类：时间工具、密码加密（BCrypt）

### 1. Auth 模块（依赖：基础骨架）
- [ ] 实体/数据库对照确认
- [ ] 登录接口 `POST /api/auth/login`
- [ ] 首次初始化接口 `POST /api/auth/setup`
- [ ] 登出接口 `POST /api/auth/logout`
- [ ] 编写测试

### 2. 用户模块（依赖：Auth 模块）
- [ ] 获取用户信息 `GET /api/user/info`
- [ ] 修改昵称 `PUT /api/user/nickname`
- [ ] 修改密码 `PUT /api/user/password`
- [ ] 上传头像 `POST /api/user/avatar`
- [ ] 编写测试

### 3. 分类模块（依赖：Auth 模块）
- [ ] 分类列表 `GET /api/categories`
- [ ] 新增分类 `POST /api/categories`
- [ ] 修改分类 `PUT /api/categories/{id}`
- [ ] 删除分类 `DELETE /api/categories/{id}`
- [ ] 编写测试

### 4. 账户模块（依赖：Auth 模块）
- [ ] 账户列表 `GET /api/accounts`
- [ ] 新增账户 `POST /api/accounts`
- [ ] 修改账户 `PUT /api/accounts/{id}`
- [ ] 删除账户 `DELETE /api/accounts/{id}`
- [ ] 编写测试

### 5. 记账记录模块（依赖：分类 + 账户模块）
- [ ] 新增记录 `POST /api/records`
- [ ] 记录列表 `GET /api/records`（分页 + 筛选）
- [ ] 收支统计 `GET /api/records/statistics`
- [ ] 编写测试

### 6. 转账模块（依赖：账户模块）
- [ ] 转账 `POST /api/transfers`
- [ ] 转账记录 `GET /api/transfers`（分页 + 筛选）
- [ ] 编写测试

## 二、APP 开发（依赖：后端 API 完成）

- [ ] 项目包结构调整（com.kody.coinsec.app）
- [ ] 网络请求封装（Retrofit）
- [ ] 登录页面
- [ ] 首页仪表盘
- [ ] 记账页面
- [ ] 账单列表页面
- [ ] 统计数据页面
- [ ] 账户管理页面
- [ ] 分类管理页面
- [ ] 个人中心页面

## 三、Web 前端开发（依赖：后端 API 完成）

- [ ] 网络请求封装（Axios）
- [ ] 登录页面
- [ ] 首页仪表盘
- [ ] 记账页面
- [ ] 账单列表页面
- [ ] 统计数据页面
- [ ] 账户管理页面
- [ ] 分类管理页面
- [ ] 个人中心页面

## 四、文档完善

- [ ] APP UI 设计文档
- [ ] Web UI 设计文档
- [ ] 部署文档
