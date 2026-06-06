# CoinSec App

Android 端个人财务管理应用，基于 Kotlin + Jetpack Compose + Material 3。

## 技术栈

- Kotlin + Jetpack Compose
- Material 3
- Android SDK 36（minSdk = targetSdk = 36）
- Gradle AGP 插件

## 项目结构

```
app/src/main/java/com/example/coinsec/app/
├── MainActivity.kt          # 入口 Activity
└── ui/
    └── theme/               # 主题配置
        ├── Color.kt
        ├── Theme.kt
        └── Type.kt
```

> 项目为初始模板结构，业务逻辑待开发。

## 构建

### Debug APK

```bash
./gradlew assembleDebug
```

### Release APK

需要设置环境变量：

```bash
export KEYSTORE_PASSWORD=your_password
export KEY_ALIAS=your_alias
export KEY_PASSWORD=your_password
./gradlew assembleRelease
```

## 测试

```bash
./gradlew test
```

JUnit 4（Compose UI Test 需连接模拟器）。
