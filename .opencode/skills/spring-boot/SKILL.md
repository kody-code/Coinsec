---
name: spring-boot
description: Use when building Spring Boot backend code in CoinSec-Backend/. Covers layered architecture, RESTful API design, JPA/MyBatis data access, exception handling, and testing conventions aligned with Spring Boot 4.x + Java 25.
---

# Spring Boot 后端开发指南

## 项目结构

固定包路径：`com.kody.coinsec.backend`

```
controller   — API 层，@RestController
service/     — 业务接口
service/impl — 业务实现 @Service
entity/model — 数据库实体 / 数据模型
mapper/dao   — 数据访问（MyBatis/JPA）
dto          — 请求/响应 DTO
config       — @Configuration 配置类
exception    — 全局异常处理、自定义异常
util         — 工具类
```

## 分层职责

- **Controller**: 接收请求、参数校验、调用 Service、返回统一格式
- **Service**: 业务逻辑，不处理 HTTP 相关
- **Repository/DAO**: 数据访问，不写业务逻辑
- 禁止跨层调用（Controller 直接操作数据库）

## 命名规范

| 元素 | 格式 | 示例 |
|------|------|------|
| 类 | 大驼峰 | `UserController` |
| 接口 | `I` 开头或名词 | `UserService` |
| 实现类 | 接口名 + `Impl` | `UserServiceImpl` |
| 方法 | 小驼峰 | `getUserById` |
| 常量 | 全大写 + 下划线 | `PAGE_SIZE` |
| 请求路径 | 小写 + 中横线 | `/user/login-log` |

## 注解与依赖注入

- Controller: `@RestController` + `@RequestMapping`
- Service: `@Service`
- 配置: `@Configuration`
- 依赖注入: **构造器注入**，禁止 `@Autowired` 字段注入
- 使用 Lombok（`@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`）

## RESTful API 规范

| 操作 | HTTP | 路径示例 |
|------|------|----------|
| 查询 | GET | `/api/v1/users` |
| 新增 | POST | `/api/v1/users` |
| 修改 | PUT | `/api/v1/users/{id}` |
| 删除 | DELETE | `/api/v1/users/{id}` |

统一返回格式：

```java
{
  "code": 200,
  "msg": "success",
  "data": { ... }
}
```

接口必须加 `@Operation` 注解（SpringDoc/OpenAPI）。

## 异常处理

- 全局 `@RestControllerAdvice` 统一处理
- 业务异常继承 `RuntimeException`，自定义错误码
- 禁止在业务代码里 catch 异常不处理
- 不暴露内部敏感信息

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusiness(BusinessException e) {
        return Result.error(e.getCode(), e.getMessage());
    }
}
```

## 数据访问

- 实体类字段与数据库表结构完全一致
- 禁止 `SELECT *`，必须指定字段
- UPDATE/DELETE 必须带 WHERE
- 优先逻辑删除（`is_deleted`）
- 事务使用 `@Transactional(rollbackFor = Exception.class)`

## 认证与授权（Sa-Token）

本项目使用 **Sa-Token** 进行身份认证。

### 配置（application.yaml）

```yaml
sa-token:
  token-name: satoken
  timeout: 2592000
  active-timeout: -1
  is-concurrent: true
  is-share: false
  token-style: uuid
  is-log: true
```

### 核心 API

| 操作 | 代码 |
|------|------|
| 登录 | `StpUtil.login(userId)` |
| 校验登录 | `StpUtil.checkLogin()` |
| 获取当前用户 ID | `StpUtil.getLoginIdAsLong()` |
| 登出 | `StpUtil.logout()` |

### 路由保护（SaTokenConfig）

```java
@Configuration
public class SaTokenConfig implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SaInterceptor(handle -> StpUtil.checkLogin()))
                .addPathPatterns("/api/**")
                .excludePathPatterns("/api/auth/login", "/api/auth/setup");
    }
}
```

### 前端请求方式

所有需要认证的请求在 Header 中携带：
```
satoken: {token}
```

### Token 异常处理

在 `GlobalExceptionHandler` 中捕获 `NotLoginException` 返回 401。

### 统一响应

所有接口返回统一格式：
```json
{ "code": 200, "msg": "success", "data": { ... } }
```

## API 路径版本规范

统一前缀 `/api/v{n}`，当前为 `/api/v1`。

## 测试规范

- 使用 JUnit 5 + Mockito
- Service 层单元测试 mock DAO
- Controller 层使用 `@WebMvcTest` + `MockMvc`
- 测试类名 `XxxTest`，方法名 `测试场景_预期结果`
- 使用 `@DisplayName` 标注测试目的

```java
@SpringBootTest
class UserServiceTest {

    @Autowired
    private UserService userService;

    @Test
    @DisplayName("查询用户-存在时返回用户信息")
    void getUserById_Exists_ReturnUser() {
        // given

        // when
        var result = userService.getUserById(1L);

        // then
        assertNotNull(result);
    }
}
```

## 日志规范

- 使用 SLF4J + Logback
- 禁止 `System.out.println`
- 统一 `lombok.extern.slf4j.Slf4j` 注解

## 配置规范

- 敏感信息（数据库密码、密钥）放在 `application-secret.yml`，不提交 Git
- 环境配置通过 `spring.profiles.active` 切换
- 禁止硬编码配置值
