# 🎨 ThoughtStream 设计规范（基于 SwiftUI 与 Apple HIG）

---

## 总述

### 平台与原则

| 项目 | 说明 |
|------|------|
| **平台** | iOS / iPadOS（横竖屏），遵循 Safe Area、Size Classes、自适应布局 |
| **风格** | SwiftUI 原生优先（系统字体、系统色、系统组件），极简信息层级，黑白对比清晰 |
| **状态支持** | 完整支持深浅色模式、动态字体、Reduce Motion、VoiceOver、RTL |
| **触控目标** | 最小可点区域 44×44 pt（iPad 建议 48×48 pt） |
| **手势原则** | 显性操作优先（按钮/菜单），隐性手势为增强（长按/滑动） |

---

## 1. 品牌与语气（不喧宾夺主）

| 维度 | 内容 |
|------|------|
| **App 名称** | ThoughtStream |
| **语气** | 冷静、客观、鼓励（无评价性词汇） |
| **文案范式** | 动作 + 对象（"开始录音""已保存 1 个片段"） |
| **错误提示** | 描述问题 + 下一步（"格式不支持。请导入 .mp3/.m4a/.wav"） |

---

## 2. 排版（Typography）

### 字体系统

- **系统字体：** 使用 Font API（系统自动选择 SF Pro）
- **动态字体：** 自动响应用户"动态文字大小"设置（Environment: .dynamicTypeSize）

### 文本层级

| 类型 | SwiftUI 字体样式 | 用途 |
|------|------|------|
| **标题** | `Font.largeTitle` | 主列表/统计页 |
| **分区标题** | `Font.title2` | 页面分区标题 |
| **正文** | `Font.body` | 主要内容 |
| **次信息/计数** | `Font.callout` 或 `Font.footnote` | 辅助信息 |
| **强调数值** | `Font.title3.weight(.bold)` | 统计数据 |

### 排版细则

- **行距：** 默认随字体类型，正文可添加 `.lineSpacing(2...4)`
- **截断：** 标题与片段名使用 `.lineLimit(1) + .truncationMode(.tail)`；详情页允许多行显示

---

## 3. 颜色系统（Color System）

> **原则：** 使用 SwiftUI 原生 Color，自动适配浅色/深色模式及无障碍对比。

### 系统颜色（SwiftUI）

| 用途 | SwiftUI 对应颜色 |
|------|------|
| **主色（强调态）** | `Color.accentColor`（自动从系统主题继承） |
| **文本主色** | `Color.primary` |
| **次文本色** | `Color.secondary` |
| **分隔/描边** | `Color.separator` 或 `Color.gray.opacity(0.2)` |
| **背景** | `Color(.systemBackground)` 或 `Color(.secondarySystemBackground)` |
| **状态色** | `.green`（成功）、`.red`（错误）、`.orange`（进行中） |