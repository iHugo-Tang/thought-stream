# Agent Guide

本仓库为 ThoughtStream（iOS）语音与音频分段应用的最简开发指引。

## 环境
- Xcode（稳定版），Swift 6.2+。
- 依赖管理：Swift Package Manager
- 数据持久化: SwiftData

## 打开与运行
- 打开 `ThoughtStream.xcworkspace`
- 选择 `ThoughtStream` scheme，目标为 iOS 模拟器或真机，直接运行。
- 清理 Tuist (可选): `tuist clean && tuist install`.
- 使用 Tuist 重新生成工程 (可选)：`tuist generate`。

## 目录速览
- 源码：`ThoughtStream/Sources`
- 资源：`ThoughtStream/Resources`
- 迁移脚本：`ThoughtStream/Resources/Migrations`
- 测试：`ThoughtStream/Tests`

## 开发约定
- 4 空格缩进；类型 PascalCase；属性/方法/文件名 camelCase。
- 倾向现代 Swift：`async/await`、协议优先、结果构建器等。
- 代码样式参考 @DesignStyles.md, 如果里面没有定义则在其内增加定义。
- 只需要考虑iOS 26，不需要考虑兼容。

## 安全与隐私
- 不要硬编码密钥或令牌；如需存储，使用系统钥匙串。
- 对持久化与日志保持最小化收集。

## 协作
- 提交信息简洁清晰（如：`Adjust Database Schema`），正文说明动机与影响。
- PR 简要列出变更要点与测试方式。
