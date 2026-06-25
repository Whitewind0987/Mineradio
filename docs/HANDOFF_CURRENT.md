# 当前任务交接

## 状态

- 分支：`feature/desktop-lyrics-toolbar`
- 当前工作：Stage 4.3 桌面歌词解锁工具栏已由 White 完成手动验收；本文件仅记录当前未提交状态。
- 提交状态：尚未提交，尚未推送。

## 已验证的 Stage 4.3 行为

- 紧凑桌面歌词工具栏。
- 默认隐藏，解锁状态下鼠标进入桌面歌词交互区域时显示。
- 鼠标离开后延迟隐藏。
- 锁定状态下完全隐藏。
- 上一首、播放/暂停、下一首控制。
- 单/双行切换。
- 左、中、右对齐。
- 紧凑桌面歌词字号滑杆。
- 中文 hover 与 accessibility 标签。
- 恢复默认按钮。
- 锁定和关闭控制。
- 工具栏控件不会启动桌面歌词窗口拖拽。
- 工具栏可见时纳入交互 hot bounds。
- 播放控制复用现有语义播放路径。
- 工具栏状态跟随主渲染器权威状态。
- 行模式、对齐和字号继续使用 `mineradio-lyric-layout-v1` 持久化。

## 恢复默认范围

只重置：

- `desktopLyricsLineMode = single`
- `desktopLyricsAlignment = center`
- `desktopLyricsSize = 1` / `100%`

不重置：

- 桌面歌词启用状态；
- 锁定/穿透状态；
- X/Y 位置；
- 显示器 ID；
- BrowserWindow bounds；
- 透明度；
- 颜色；
- 字体族、字重、行高、字距；
- glow 或 highlight 设置；
- 播放状态或当前歌曲；
- 壁纸状态。

## 保持不变

- Stage 4.1 静态双行行为仍为权威行为。
- 已接受的主窗口移动时轻微初始/拖动闪烁限制保持不变。
- 未恢复垂直双行 rolling、snapshot、clone、shell、FLIP 或纵向 viewport animation。
- 无新增依赖。
- 无品牌、安装器或更新器变更。

## 明确未验证

- Stage 4.6 多显示器测试暂时跳过，因为 White 当前只有一个显示器；不得标记为已通过。

## 下一步

- Stage 4.2 逐字高亮是下一开发阶段。
- Stage 4.2 之后，单独进行后台与桌面歌词功耗优化工作。
