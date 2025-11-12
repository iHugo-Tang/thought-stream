# ThoughtStream 文档导航

- **PRD**: 请参阅 `Docs/PRD.md`（音频库模块 - 产品与设计规范）
- **设计规范**: 请参阅 `Docs/DesignStyles.md`（颜色、排版、组件与无障碍）
- **TDD**: 请参阅 `Docs/TDD.md`（测试策略与用例占位）

## 模块概述（Audio Library）

- 首页（音频库）：导入音频、查看列表、按集合筛选
- 详情页：音频信息、集合选择、片段列表或“开始切句”引导
- 切句编辑器：波形、切点标记、播放/循环/缩放
- 片段详情：播放控制、录音按钮、收藏与词汇

## 开发入口

- Tab 入口：`ThoughtStream/Sources/App/MainTabView.swift`
- 列表页：`ThoughtStream/Sources/Features/Import/ImportView.swift`（将演进为音频库首页）
- 切句编辑器：`ThoughtStream/Sources/Features/Segmentation/SegmentationView.swift`
- 波形组件：`ThoughtStream/Sources/Features/Waveform/WaveformView.swift`

## 数据层

- 仓库：`ThoughtStream/Sources/Data/Repositories`（Audio、Segment 等）
- 数据库：`ThoughtStream/Sources/Data/Database` + `ThoughtStream/Resources/Migrations`

## 术语

- Audio（音频文件）
- Segment（片段）
- Collection（集合/分组）
