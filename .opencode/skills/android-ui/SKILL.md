---
name: android-ui
description: Use when building Android Jetpack Compose UI screens and components in CoinSec-App/. Produces polished, modern, visually appealing Compose layouts with proper Material 3 theming.
---

# Android Compose UI 设计指南

## 设计原则

- 遵循 Material Design 3 规范，使用 Material3 组件库
- 保持简洁、干净、有呼吸感的布局
- 颜色从 Theme 取色，不硬编码色值
- 适当的圆角、阴影、间距让界面有质感

## 主题与颜色

使用 Material3 的 `MaterialTheme`，通过 `ColorScheme` 定义一套完整的配色。

```kotlin
private val LightColorScheme = lightColorScheme(
    primary = Color(0xFF1A73E8),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFD2E3FC),
    secondary = Color(0xFF5F6368),
    surface = Color(0xFFFFFBFE),
    background = Color(0xFFF8F9FA),
    surfaceVariant = Color(0xFFE8EAED),
    outline = Color(0xFFDADCE0),
)
```

- 背景色用浅灰白 (`#F8F9FA`) 而非纯白，更有质感
- 卡片容器用白底加 subtle 阴影
- 主色调选一个有活力的蓝色或其他品牌色

## 布局规范

### 间距
```kotlin
// 不要用硬编码 dp
// 正确：使用系统维度或语义常量
val spacing = 16.dp
val cardPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp)
```

- 页面边距：`contentPadding = PaddingValues(16.dp)`
- 卡片之间的间距：12.dp - 16.dp
- 内容内部间距：12.dp - 16.dp

### 卡片设计
```kotlin
Card(
    modifier = Modifier.fillMaxWidth(),
    shape = RoundedCornerShape(16.dp), // 温和圆角
    colors = CardDefaults.cardColors(
        containerColor = MaterialTheme.colorScheme.surface
    ),
    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
)
```

- 圆角：大卡片用 `16.dp`，小卡片用 `12.dp`
- 阴影：`1.dp` ~ `2.dp`，不要过重
- 大圆角 + 浅阴影 = 现代感

### 文本排版
- 标题：`MaterialTheme.typography.titleLarge` (22sp)，中等字重
- 次级标题：`titleMedium` (16sp)
- 正文：`bodyLarge` (16sp) / `bodyMedium` (14sp)
- 金额数字：可用 `monospace` 或 `FontWeight.Medium` + `fontSize = 24.sp`
- 颜色层级：正文 `onSurface`/`onBackground`，辅助文字 `onSurfaceVariant`

## 列表与条目

使用 `LazyColumn`，每一项外层用 Card。

```
┌──────────────────────────────────┐
│                                  │
│  图标  餐饮                  25.00│
│       2026-06-04 12:30           │
│                                  │
└──────────────────────────────────┘
```

```kotlin
Card(
    modifier = Modifier
        .fillMaxWidth()
        .padding(horizontal = 16.dp, vertical = 4.dp),
    shape = RoundedCornerShape(12.dp),
    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
) {
    Row(
        modifier = Modifier.padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 左侧图标
        Icon(...)
        Spacer(Modifier.width(12.dp))
        // 中间文字
        Column(modifier = Modifier.weight(1f)) { ... }
        // 右侧金额
        Text(amount, fontWeight = FontWeight.Medium)
    }
}
```

## 输入框与按钮

### TextField
```kotlin
OutlinedTextField(
    value = ...,
    onValueChange = ...,
    modifier = Modifier.fillMaxWidth(),
    shape = RoundedCornerShape(12.dp),
    label = { Text("账户名称") },
    colors = OutlinedTextFieldDefaults.colors(
        focusedBorderColor = MaterialTheme.colorScheme.primary,
        unfocusedBorderColor = MaterialTheme.colorScheme.outline
    )
)
```

### Button
```kotlin
Button(
    onClick = ...,
    modifier = Modifier
        .fillMaxWidth()
        .height(50.dp),
    shape = RoundedCornerShape(14.dp)
) {
    Text("保存", fontSize = 16.sp)
}
```

- 按钮大圆角 `14.dp`，全宽
- 次要操作用 `OutlinedButton`

## 点击动画

### 基础涟漪效果（Material3 默认）

```kotlin
Modifier.clickable(
    indication = rememberRipple(),
    interactionSource = remember { MutableInteractionSource() }
) { onClick() }
```

`Modifier.clickable` 默认自带 Material ripple，无需额外配置。所有可点击卡片、列表项必须使用 `clickable` 而非 `onClick` 参数，以确保涟漪反馈。

### 按压缩放动画（提升手感）

```kotlin
@Composable
fun PressScaleCard(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    var pressed by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (pressed) 0.96f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "scale"
    )

    Card(
        modifier = modifier
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = {
                        pressed = true
                        tryAwaitRelease()
                        pressed = false
                    },
                    onTap = { onClick() }
                )
            }
    ) {
        content()
    }
}
```

### 列表项点击反馈组合

```kotlin
LazyColumn {
    items(items) { item ->
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 4.dp)
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = rememberRipple(bounded = true)
                ) { onItemClick(item) },
            shape = RoundedCornerShape(12.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
        ) {
            ...
        }
    }
}
```

### 按压变暗效果（适合图片/图标按钮）

```kotlin
var pressed by remember { mutableStateOf(false) }

IconButton(
    onClick = { ... },
    modifier = Modifier
        .graphicsLayer { alpha = if (pressed) 0.6f else 1f }
        .pointerInput(Unit) {
            detectTapGestures(
                onPress = {
                    pressed = true
                    tryAwaitRelease()
                    pressed = false
                },
                onTap = { /* do action */ }
            )
        }
) {
    Icon(...)
}
```

### 最佳实践

- **不要手动实现 ripple**：Material3 的 `clickable` 已经自带，不要用 `Modifier.background` 模拟点击背景色
- **按压缩放适用于卡片、按钮**，小图标用变暗（alpha 变化）更自然
- **`spring()` 动画**比 `tween()` 更有弹性感，建议配合 `dampingRatio = MediumBouncy`
- 动画时长控制在 `200ms` 以内（弹簧动画自然满足），过长的动画会让界面感觉拖沓

## 空状态 / 加载 / 错误

始终覆盖三种状态，用统一样式：

```kotlin
@Composable
fun EmptyState(icon: ImageVector, message: String) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(72.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
        )
        Spacer(Modifier.height(16.dp))
        Text(message, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
```

## 整体 UI 风格参考

以 iOS 系统原生应用为质感目标：
- 大量留白，不拥挤
- 温和圆角，不锐利
- 文字层级清晰，字体只用系统默认
- 颜色简洁克制，不要超过 3 种主色
- 交互反馈柔和（点击涟漪效果）

## 典型页面结构

```
Scaffold(
    topBar = { TopAppBar(title = { Text("页面标题") }) }
) { padding ->
    LazyColumn(contentPadding = PaddingValues(vertical = paddingValues, horizontal = 16.dp)) {
        // 统计摘要卡片
        item { SummaryCard(...) }
        // 筛选栏
        item { FilterRow(...) }
        // 列表条目
        items(records) { RecordCard(it) }
    }
}
```
