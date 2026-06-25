# Mineradio Fork — 已验证记忆

## 基线记录

### 2026-06-25：Stage 0.1 仓库基线验证

**分支**：`feature/fork-baseline`

**Upstream 基线**：`v1.1.0`（commit `e4453c3`）

**验证环境**：

| 项目 | 版本 |
|------|------|
| Node.js | v24.14.1 |
| npm | 11.11.0 |
| Git | 2.53.0.windows.2 |
| Windows | Windows 10 Pro 10.0.19045 |
| PowerShell | 5.1.19041.6456 |
| Electron（已安装） | 42.4.1 |

**依赖安装**：

- 命令：`npm ci --foreground-scripts`
- 结果：成功（添加 431 个包）
- `package.json` 和 `package-lock.json` 保持不变
- Electron 二进制通过镜像下载（`ELECTRON_MIRROR=https://cdn.npmmirror.com/binaries/electron/`）

**语法检查**：全部通过

| 文件 | 结果 |
|------|------|
| `server.js` | 通过 |
| `desktop/main.js` | 通过 |
| `desktop/preload.js` | 通过 |
| `desktop/overlay-preload.js` | 通过 |
| `dj-analyzer.js` | 通过 |

**开发启动**：

- `npm start` 在清除 `ELECTRON_RUN_AS_NODE` 后成功启动
- 本地服务器在 `http://localhost:3000` 启动
- 主窗口打开
- 基本搜索功能正常
- 未登录任何音乐平台
- 未修改任何应用源代码

**Unpacked 构建**：

- 命令：`npm run build:win:dir`
- 结果：成功
- 输出目录：`dist\win-unpacked\`
- 可执行文件：`dist\win-unpacked\Mineradio.exe`
- Unpacked 可执行文件在清洁环境下成功启动

**重要：启动环境注意事项**

当前 IDE / Agent 终端环境注入了 `ELECTRON_RUN_AS_NODE=1`。该变量使 Electron 以 Node.js 模式运行，导致 `require('electron')` 返回可执行文件路径（字符串）而非 API 对象，进而引发 `app` 为 `undefined` 的崩溃。

启动应用前必须先清除该变量：

```powershell
Remove-Item Env:ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
npm start
```

明确事项：

- 此 workaround 仅当父 IDE / Agent 环境注入该变量时需要；
- 这不是应用程序源代码的要求；
- `desktop/main.js` **不得**为绕过此环境变量而修改；
- 这不是 Electron 42 兼容性问题，也不是 `desktop/main.js` 的缺陷。

**非阻塞性观察**（未在 Stage 0.1 中修复或调查）：

- 构建当前使用 `asar: false`（electron-builder 已警告）
- 依赖安装报告了多个废弃的传递依赖（`inflight`、`rimraf@2`、`glob@7`、`boolean`、`rcedit@5`）
- npm 报告 3 个依赖漏洞（1 个中等、2 个高危）
- `git diff --check` 对 `AGENTS.md` 有 CRLF 行尾警告

**验证范围**：仅包含基线启动、基本搜索、语法检查和 unpacked 构建。未进行完整功能测试。GUI 行为需要用户手动验证。

**不应回退的行为**：

- 应用在清洁环境下能正常启动
- `package.json` 和 `package-lock.json` 保持锁定版本
- 所有语法检查通过
- Unpacked 构建可以成功完成

---

## 技术隔离记录

### 2026-06-25：Stage 0.2 技术环境、用户数据与更新源隔离

**分支**：`feature/fork-technical-isolation`

**临时技术标识**：`MineradioForkDev`（非最终产品名，将在 Stage 9 替换）

**userData / sessionData 隔离**：

- 在 Chromium 开关和单实例锁之前配置
- 路径：`%APPDATA%\MineradioForkDev\`
- 通过 `app.setPath('userData', ...)` 和 `app.setPath('sessionData', ...)` 实现
- `.cookie`、`.qq-cookie`、`updates`、`beatmaps` 全部解析到 fork 用户数据目录内
- 不迁移上游 Cookie、设置、localStorage 或缓存
- 仓库根目录下的旧 Cookie 文件不会被自动迁移
- 迁移需要未来明确的、用户批准的任务
- 可见名称、Logo、图标、appId、AppUserModelId、可执行文件名、登录分区名保持不变

**更新显式禁用**：

- `package.json`：`mineradio.update.enabled: false`
- 环境变量覆盖：`MINERADIO_UPDATE_DISABLED=1`
- 禁用时 `configured: false`，无上游 GitHub 请求
- 更新 UI 仅当 `configured === true && updateAvailable === true` 时可见
- `preview` 单独永远不表示存在新版本
- 更新检查失败与"已禁用更新"在 UI 中区分显示

**桌面快捷方式**：私有开发期间自动创建已禁用（`FORK_PRIVATE_DEVELOPMENT = true`）

**节拍缓存**：重定向到 `%APPDATA%\MineradioForkDev\beatmaps`（不再使用 `D:\MineradioCache\beatmaps`）

**已修改文件**：`desktop/main.js`、`server.js`、`package.json`、`public/index.html`

**未修改**：`package-lock.json`

**已验证**：开发启动、unpacked 构建和启动、更新 API 端点、Cookie 隔离、快捷方式跳过

**不应回退的边界**：

- 不得将 `MineradioForkDev` 视为公开品牌
- 在 fork 拥有有效的自有发布源之前不得重新启用更新
- 不得自动迁移上游账户数据
- 不得将 `preview` 恢复为更新可用性条件

---

## 功能验证记录

### 2026-06-25：Stage 1 Windows 系统媒体控制

**分支**：`feature/windows-media-session`

**架构**：
- 仅渲染器实现；仅 `public/index.html` 包含集成代码
- 使用 Chromium `navigator.mediaSession`，无主进程变更
- 无 preload 或 IPC 变更；无依赖变更
- 保留 `contextIsolation: true` + `nodeIntegration: false`

**复用的播放行为**：
- 权威音频对象保持为 `audio`；权威队列 `playQueue`；权威索引 `currentIdx`；权威播放标志 `playing`
- play 复用 `playQueueAt()` / `attemptAudioPlay()`；pause 复用 `fadeOutAndPauseAudio()`
- previous 复用 `prevTrack()`；next 复用 `nextTrack()`

**已注册的操作处理程序**：`play`、`pause`、`previoustrack`、`nexttrack`
- 无 `stop`、`seekto`、`seekbackward`、`seekforward`；无 `setPositionState()`
- 无 Electron `MediaPlayPause`/`MediaNextTrack`/`MediaPreviousTrack` 全局快捷键

**竞态保护**：元数据更新直接与 `trackSwitchToken` 比较；过时异步曲目变更无法覆盖最新元数据；过时失败无法清除新曲目

**已由用户手动验证的行为**：
- Windows 10 媒体卡片在播放时出现；歌曲标题、歌手、相册和封面正确显示
- 系统播放/暂停/上一首/下一首工作正常，无重复操作
- 模拟的 Windows 媒体键（Play/Pause/Previous/Next）工作正常
- 快速连续下一首正确留下最终曲目和元数据
- 最小化和全屏状态下控件继续工作
- 现有应用内播放控件和进度条跳转保持正常
- 桌面歌词和设置正常打开和关闭
- 应用退出清除系统媒体状态；无残留进程

**已知限制**：
- 无 `setPositionState()`，无系统进度同步，无系统跳转操作，无 stop 操作
- 物理耳机按钮未经验证（需实际硬件测试）
- 锁屏界面未经单独验证

**不应回退的边界**：
- 在 Media Session 已处理媒体键的情况下，不得通过第二条 Electron globalShortcut 路径实现媒体键
- 不得用模拟按钮点击替代真实播放函数
- 不得创建另一个音频对象、队列或播放状态
- 位置状态支持需要单独的后续任务，并需严格校验时长
- Media Session 元数据失败绝不能阻断播放
- 最终失败清理必须保持令牌守卫

---

### 2026-06-25：Stage 2.1 Windows 系统托盘

**分支**：`feature/system-tray`

**架构**：
- 主进程 Electron `Tray` + `Menu`；临时复用现有 `build/icon.ico`
- 仅一个非权威显示快照（`title`、`artist`、`playing`、`hasTrack`）
- 窄预加载方法：`updateTrayPlaybackState`——渲染器→主进程通道 `mineradio-tray-update-playback`
- 播放命令复用 `mineradio-global-hotkey` + 现有操作名（`togglePlay`/`prevTrack`/`nextTrack`）
- 无新依赖；无原始 `ipcRenderer`；`contextIsolation: true` + `nodeIntegration: false`

**菜单**：当前歌曲信息（禁用）、分隔符、播放/暂停、上一首、下一首、分隔符、显示主窗口、退出。无曲目回退为 `当前没有播放歌曲`。Unicode 安全截断至 60 个字符。无曲目时播放命令禁用。左键单击恢复/聚焦主窗口；右键打开上下文菜单。全屏被保留。无可见性切换。托盘退出调用 `app.quit()`。

**状态边界**：渲染器保持权威（`audio`/`playing`/`playQueue`/`currentIdx`）。托盘缓存仅包含已清理的快照字段。仅在有意义的转换时更新：启动、当前曲目变更、成功播放、失败播放、中心暂停完成、最终失败、清空队列、移除当前曲目。暂停通知位于中心暂停路径（`fadeOutAndPauseAudio`）内部——也覆盖 Media Session 暂停。

**生命周期**：接受的单实例一个托盘。被拒绝的第二进程不创建托盘。`window-all-closed` 未修改——关闭按钮仍然完全退出。无关闭到托盘拦截。`before-quit` 销毁托盘并保留现有清理。

**用户已验证的行为**：
- 一个托盘图标出现；右键打开上下文菜单；无曲目状态正确；当前歌曲信息正确
- 播放/暂停/上一首/下一首各运行一次；播放/暂停标签正确反映状态
- 最小化恢复工作正常；最小化后托盘控件可用；全屏在托盘使用时正确保留
- 第二次启动不产生重复图标或窗口
- 应用内控件、Media Session、全局快捷键、桌面歌词、搜索、设置保持正常
- 主窗口关闭完全退出；托盘退出完全退出；托盘图标在退出时消失；无残留进程；无更新提示

**显式未验证**：
- 在暂停通知被移至中心路径的修复后，未重新运行"Windows 媒体卡片暂停后托盘标签更新"测试
- 物理耳机按钮和锁屏行为未经测试

**不应回退的边界**：
- 在 Stage 2.1 中不得将 `app.quit()` 从 `window-all-closed` 中移除
- 在独立的 Stage 2.2 设计之前不得拦截关闭
- 不得创建另一个播放命令分发器、主进程媒体键快捷键或权威托盘状态副本
- 不得在中心暂停路径外重复暂停通知
- 不得用可见性切换替代 `focusMainWindow()`

---

### 2026-06-25：Stage 2.2 可配置关闭行为

**分支**：`feature/close-behavior`

**模式**：`ask`（每次询问）、`tray`（最小化到托盘）、`exit`（直接退出）。默认 `exit`。存储键 `mineradio-close-behavior-v1`。渲染器 localStorage 持久化，主进程仅保留清理后的运行时缓存。更改即时生效。

**IPC**：渲染器→主进程通道 `mineradio-close-behavior-set`，预加载方法 `setCloseBehavior`。无新依赖，无原始 `ipcRenderer`，浏览器模式安全。

**生命周期**：
- `exit`：保留普通关闭——`window-all-closed` 未修改
- `tray`：`event.preventDefault()` → `mainWindow.hide()`。播放/服务器/托盘继续。恢复复用 `focusMainWindow()`、托盘左键单击和二次启动
- `ask`：显示 Electron 对话框——最小化到托盘（默认）、退出、取消。重入保护，延迟完成守卫，错误恢复
- 托盘退出绕过：调用 `app.quit()` → `before-quit` 设置 `isAppQuitting` → 关闭事件无拦截通过
- Windows `query-session-end`：标记退出中，不调用 `preventDefault()`
- 全屏在隐藏时保留，恢复时正确还原

**UI**：使用现有 `.fx-seg` 三段式视觉风格的三段选择器。原生单选框保留（视觉隐藏），共享 `name="closeBehavior"`，键盘导航正常，焦点可见。关闭行为包装器使用与 `.fx-slider` 控件相同的 `padding:9px 10px` 水平内缩及 12px 底部间距。过时的选择器 margin 变通方案已移除，其他分段控件未被修改。

**用户已验证**：三种关闭模式均正确工作；播放在隐藏时继续；托盘恢复和退出正确；询问对话框三个按钮均正确；重复关闭不产生多个对话框；偏好重启后保留；Alt+F4 行为正确；全屏隐藏和恢复正确；Stage 1 Media Session 和 Stage 2.1 托盘控件正常；全局快捷键正常；隐藏后桌面歌词保留；搜索、播放和设置正常；无更新提示；最终分段选择器间距和对齐正确。

**显式未验证**：Windows 关机/重启/注销行为未经手动测试；物理耳机和锁屏行为未测试。

**不应回退的边界**：
- 不得将 `app.quit()` 从 `window-all-closed` 中移除
- 不得拦截应用级退出
- 不得在隐藏前强制退出全屏
- 不得暴露通用 IPC
- 不得将主进程作为持久化偏好权威
- 不得更改 Stage 1 Media Session 或 Stage 2.1 托盘播放行为
- 不得为修复关闭行为选择器间距而更改无关的 `.fx-seg` 布局

---

### 2026-06-25：Stage 2.3 Windows 开机启动设置

**分支**：`feature/windows-startup`

**功能**：用户控制的 Windows 开机启动开关。默认关闭——不自动创建登录项。仅 Windows 打包版 (`app.isPackaged === true`) 支持。npm start 不可用且显示为禁用。

**状态归属**：Windows 是唯一权威来源。`app.getLoginItemSettings()` 直接读取注册表状态。无 localStorage 键，无主进程缓存。外部任务管理器更改会通过以下方式刷新：
- 设置面板打开时
- 当设置面板保持打开且应用窗口重新获得焦点时

刷新仅执行读取，不会在忙碌时运行，并使用单调递增令牌防止过期异步读取。

**登录项身份标识**：临时名称 `MineradioForkDev`（从 `FORK_USER_DATA_DIR_NAME` 派生）。当前 `AppUserModelId`（`com.mineradio.desktop`）未被用作隐式启动条目名称。Stage 9 必须在选择最终品牌后替换或清理此临时身份标识。

**查询**：通过精确匹配 `name === 'MineradioForkDev'`、当前 `process.execPath`、空 `args` 和 `launchItem.enabled` 来找到 fork 的启动条目。不依赖 `openAtLogin` 属性。过时的路径条目不会被误识为当前条目。

**设置器**：仅接受真实布尔值。启用时包含 `enabled: true`。禁用时从设置对象中省略 `enabled` 属性。每次写入后重新查询真实状态并验证匹配。

**IPC**：两个窄通道——`mineradio-startup-launch-get` 和 `mineradio-startup-launch-set`。预加载方法 `getStartupLaunchState()` 和 `setStartupLaunchEnabled(enabled)`。渲染器不能提供 `path`、`args`、`name` 或注册表值。无原始 `ipcRenderer`。

**UI**：`.fx-toggle` 分段开关，`role="switch"`，支持 Enter + Space（防止默认行为）。状态区分初始加载、已启用、已禁用、不支持、读取失败和写入忙碌。读取失败不显示为不支持，且保留上次成功的启用值。

**生命周期**：未更改 `window-all-closed`、`before-quit`、`app.quit()`、关闭行为、托盘、Media Session、全局快捷键、播放、桌面歌词或壁纸。无启动项在初始化、查询、面板打开、焦点刷新或退出时被写入。仅显式用户激活会写入启动状态。正常启动保持可见且非最小化。无自动播放。无命令行启动参数。

**White 已验证**：UI 位置和外观接受。npm start 不可用。解包构建支持。鼠标和键盘（Enter/Space）交互正确。无重复写入。通过应用启用/禁用正确反映在任务管理器中。任务管理器显示 `MineradioForkDev` 条目。关闭/重新打开面板查询实时状态。在任务管理器中外部禁用后返回 Mineradio 会刷新状态。关闭行为、托盘、Media Session、全局快捷键正常。无更新提示。

**显式未验证**：Windows 登出/登录后的实际自动启动。Windows 重启后的实际自动启动。已安装的 NSIS 构建行为。重新安装/升级后的登录项行为。卸载程序清理 `MineradioForkDev`。注册后移动/删除 win-unpacked 目录。不再存在的陈旧条目清理。最终品牌迁移。物理耳机按钮。Windows 锁屏行为。

**不应回退的边界**：
- 不得创建 localStorage 或主进程缓存
- 不得将 `openAtLogin` 用作已启用状态
- 不得在初始化时更改登录项状态；仅显式用户操作可写入
- 不得在关闭面板时跳过焦点刷新
- 不得移除过期异步读取保护
- Stage 9 必须替换或清理临时的 `MineradioForkDev` 启动身份标识

---

### 2026-06-25：Stage 3.1 恢复上次播放会话

**分支**：`feature/session-restore`

**功能**：应用重启后恢复播放队列、当前曲目、播放位置和播放模式，并保持暂停状态。无自动播放。

**存储归属**：
- localStorage 键：`mineradio-playback-session-v1`，schemaVersion `1`
- 仅渲染器拥有；无主进程持久化服务；无新 IPC
- `apex-player-volume` 保持音量权威——不在会话快照中重复

**持久化状态**：规范化的可恢复队列、当前队列索引、播放位置（秒）、`playMode`（`loop`/`shuffle`/`single`）、`savedAt`
**排除**：流媒体 URL、Blob URL、本地文件/文件系统路径、Cookie、Token、账户数据、视觉偏好、歌词状态、页面漫游

**来源行为**：支持网易云（稳定 `id`）、QQ 音乐（稳定 `mid`/`songmid`/`mediaMid`）。排除本地文件/Blob 曲目、电台/天气/未知来源。不持久化过期流媒体 URL。

**队列行为**：通过 `originalIdx` 匹配保留重复曲目的所选出现。不支持的条目被过滤。回退到当前索引之后（如果不存在，则为之前）的第一个可恢复条目。超过 1000 条限制时窗口包含所选出现。空/不可恢复队列移除会话键。

**位置行为**：待恢复位置绑定到 `{ trackKey, queueIndex, position }`。手动 Play 通过 `playQueueAt` 的 `resumeAt` 选项传递。URL 解析失败和 `audio.play()` 拒绝时会保留待恢复位置。在 `scheduleAudioResumePosition` 中成功定位应用后清除。用户上下文变更（下一首、上一首、手动定位、清空队列、删除当前曲目）会使其失效。预定位保存使用 pending 值而非零。

**保存行为**：结构性变更（队列、索引、播放模式）、暂停、定位完成和每约 5 秒的 `timeupdate` 检查点会触发保存。`pagehide` 和 `beforeunload` 执行同步最终保存。无固定 `setInterval`。强制终止依赖最新检查点。

**恢复行为**：同步恢复队列和元数据——不调用 `playQueueAt`、不解析音频 URL、不调用 `audio.play()`。封面从已保存的公共 URL 加载。Emily 专辑粒子视觉在暂停/静态状态下初始化。歌词按需加载。首页导航未恢复。

**White 已验证**：完整的 362 曲目网易云队列重启恢复。currentIdx、playMode、`playing === false`。无自动播放。标题和歌手立即可见。封面和背景立即可见。队列面板读取已恢复的 `playQueue`。时长规范化为秒。Emily 粒子视觉在重启后立即出现。手动 Play 从已保存位置解析新的流媒体 URL 并恢复。恢复成功后 `pendingRestorePosition` 清除。暂停保持粒子场景为静态。

**显式未验证**：通过 UI 的重复歌曲出现。安全 URL 解析失败及重试。超 1000 条队列。QQ / 播客完整行为。本地文件混合队列。强制终止精度。损坏及未来 schema 测试。已安装 NSIS。物理耳机。锁屏。

**不应回退的边界**：不得添加第二个队列权威。不得将音量重复添加到会话 schema。不得持久化流媒体 URL。不得持久化本地文件数据。不得持久化 Cookie/账户数据。恢复时不得自动播放。恢复时不得自动获取远程歌词。不得将页面导航恢复添加到 Stage 3.1。不得移除重复出现保护。不得在成功应用前清除待恢复位置。不得在恢复定位前将待恢复位置替换为零。

---

### 2026-06-25：Stage 3.2 UI 与视觉状态恢复

**分支**：`feature/ui-visual-state-restore`

**架构决策**：采用方案 A——保留现有独立存储键。未添加新的整体 Stage 3.2 快照。现有键保持权威；启动时仅修复缺失的同步。

**现有持久化状态**：
- `mineradio-lyric-layout-v1`：视觉预设、歌词布局/设置、桌面歌词偏好、歌单架及相关视觉设置
- `mineradio-diy-player-mode-v1`：简洁/DIY 模式（在首次绘制前于 DOM 解析时应用）
- `mineradio-playback-quality-v1`：播放/图形质量偏好
- `mineradio-free-camera-v1`：自由摄像机偏好
- `mineradio-fx-fab-auto-hide-v1`：视觉控制台 FAB 自动隐藏

**桌面歌词修复**：`fx.desktopLyrics` 通过 `mineradio-lyric-layout-v1` 在重启后存活。启动时恢复了布尔偏好但未调用窗口同步函数，导致偏好为 true 时 BrowserWindow 缺失。启动序列中的一次调用 `applyDesktopLyricsState(true)` 修复了此问题。复用现有的渲染器→预加载→IPC→主进程窗口路径。

**播放器控制台**：FAB 自动隐藏已持久化。面板打开/关闭、悬停、所选部分均为临时状态。`fxPanelPinned` 不是已实现的用户偏好。无需额外实现。

**White 已验证**：启用后桌面歌词在正常重启后恢复。禁用后桌面歌词在重启后保持禁用。主窗口启动正常。无自动播放。Stage 3.1 正常。

**显式未验证**：渲染器重新加载重复窗口行为。叠加层加载失败。Windows 登出/重启。已安装 NSIS。FAB 自动隐藏运行时测试。

**不应回退的边界**：不得创建新的 Stage 3.2 快照。不得重复现有键所有权。不得持久化面板打开/关闭。不得将 `fxPanelPinned` 变成新功能。不得创建第二个桌面歌词窗口系统。不得更改 Stage 3.1 播放恢复。

---

### 2026-06-25：Stage 4.1 桌面歌词布局与窗口稳定化

**分支**：`feature/desktop-lyrics-layout`

**功能**：单行/静态双行布局、下一行过滤、左/中/右对齐、桌面歌词位置持久化、拖拽最终位置同步、锁定穿透稳定化、主窗口移动期间桌面歌词组合抑制。

**偏好**：`desktopLyricsLineMode`（`single`/`double`）、`desktopLyricsAlignment`（`left`/`center`/`right`）、`desktopLyricsX`、`desktopLyricsY` 和 `desktopLyricsDisplayId` 存储在现有 `mineradio-lyric-layout-v1` 中。未新增独立桌面歌词存储。

**下一行过滤**：`findNextDesktopLyricLine`——跳过空白行和立即重复行。无第二解析器。过滤后的行用于进度跨度。

**位置行为**：桌面歌词窗口恢复保存的水平、垂直比例和显示器身份。窗口允许部分位于显示器外，但至少保留可恢复的可见区域。普通歌词/播放状态更新不再拥有或重置窗口几何；设置中的 Y 滑块是唯一的设置驱动重定位意图。

**拖拽行为**：解锁后复用现有 overlay preload bridge 拖动窗口。拖拽开始/结束通过 `setLyricsDrag(true/false)` 通知主进程；移动中节流写回，拖拽结束时 flush 最终位置并通知主窗口保存。

**主窗口移动缓解**：Windows 原生 `WM_ENTERSIZEMOVE` / `WM_EXITSIZEMOVE` hook 在主窗口手动移动/调整大小期间临时将桌面歌词 opacity 设为 0 并开启 background throttling，结束后恢复原值。未使用 hide/show 恢复，因为该方式破坏过桌面歌词交互。未修改 mouse-ignore 状态。

**双行滚动结论**：曾尝试垂直双行 rolling、snapshot、clone、shell、FLIP 和 viewport animation 等实验，视觉不稳定，已完全移除并延期。当前接受行为是静态当前歌词 + 下一句歌词，无纵向 rolling 动画。

**UI bug**：修复了分段控件双重选择问题——互斥的 `classList.toggle`。

**White 已验证**：桌面歌词完整重启后恢复保存位置；解锁后可拖动；锁定后鼠标穿透正确；再次解锁恢复拖动；单行和静态双行正常；左/中/右对齐正常；长歌词继续横向滚动；主窗口移动抑制可接受；失败的垂直 rolling 实验已完全移除，无 snapshot、clone、shell、FLIP 或纵向 viewport animation 残留。

**已知限制**：主窗口移动时偶尔可能仍有轻微初始/拖动闪烁；该限制已被 White 接受。不得声称该闪烁已完全消除。

**不应回退的边界**：不得添加第二解析器。不得全局去重歌词。不得让普通播放/歌词更新重置桌面歌词位置。不得移除拖拽结束最终位置 flush。不得恢复 hide/show 作为主窗口移动缓解。不得恢复垂直 rolling、snapshot、clone、shell、FLIP 或纵向 viewport animation。不得在此分支添加工具栏或性能优化。

---

### 2026-06-25：Stage 4.3 桌面歌词解锁工具栏

**分支**：`feature/desktop-lyrics-toolbar`

**功能**：解锁状态下显示的紧凑桌面歌词工具栏。默认隐藏；鼠标进入桌面歌词交互区域时显示；鼠标离开后延迟隐藏；锁定状态下完全隐藏。工具栏包含上一首、播放/暂停、下一首、单/双行切换、左/中/右对齐、桌面歌词字号滑杆、恢复默认、锁定和关闭。

**状态归属**：主渲染器仍是权威来源。`desktopLyricsLineMode`、`desktopLyricsAlignment`、`desktopLyricsSize` 继续存储在现有 `mineradio-lyric-layout-v1` 中。桌面歌词 overlay 不写 localStorage，不维护独立工具栏状态。工具栏状态由主渲染器推送的桌面歌词 payload 回填。

**IPC 与播放路径**：固定工具栏命令通过 `desktopOverlay.runLyricsToolbarCommand(command)` 进入 `mineradio-desktop-lyrics-toolbar-command`，主进程校验 sender 是当前桌面歌词窗口、命令是字符串且存在于 allowlist，再转发语义动作到主渲染器。播放控制复用现有语义播放路径，不模拟主界面按钮。字号滑杆使用独立窄 IPC `mineradio-desktop-lyrics-toolbar-font-size`，主进程校验 sender、有限数字、`0.72` 到 `1.55` 范围和 `0.01` 步进后再发送给主渲染器。

**字号滑杆**：替代字体缩小/放大按钮。使用现有 `desktopLyricsSize` 模型，范围 `0.72` 到 `1.55`，步进 `0.01`，显示为 `Math.round(size * 100) + '%'`。拖动时本地预览并重新计算歌词 fit 与长歌词横向滚动；最终值通过主渲染器现有保存和桌面歌词状态更新路径持久化。

**恢复默认**：只重置当前工具栏直接控制的三项：`desktopLyricsLineMode = single`、`desktopLyricsAlignment = center`、`desktopLyricsSize = 1`（显示 `100%`）。不会重置桌面歌词启用状态、锁定/穿透状态、X/Y 位置、显示器 ID、BrowserWindow bounds、透明度、颜色、字体族、字重、行高、字距、glow、highlight、播放状态、当前歌曲、壁纸状态或任何无关视觉设置。

**交互边界**：工具栏按钮、字号滑杆和恢复默认按钮均排除在桌面歌词窗口拖拽启动之外，并保持 `-webkit-app-region: no-drag`。工具栏可见时纳入桌面歌词交互 hot bounds。滑杆拖动期间不会触发延迟隐藏，也不会触发窗口移动。

**视觉与文案**：工具栏为紧凑图标按钮设计，沿用当前桌面歌词的半透明发光视觉语言。所有 toolbar hover 和 accessibility 标签均为中文。无 emoji，无宽文字按钮，无额外常驻面板。

**White 已验证**：紧凑工具栏、hover 显示与延迟隐藏、锁定时隐藏、播放控制、行模式、对齐、字号滑杆、恢复默认、锁定、关闭、拖拽排除、hot bounds、主渲染器状态同步和现有持久化路径均已通过手动验收。

**未改变/未验证**：Stage 4.1 静态双行行为仍是权威行为；未恢复垂直 two-line rolling、snapshot、clone、shell、FLIP 或纵向 viewport animation。Stage 4.1 已接受的主窗口移动时轻微初始/拖动闪烁限制未改变。Stage 4.6 多显示器测试因 White 当前只有一个显示器而跳过，不能标记为通过。Stage 4.2 逐字高亮是下一开发阶段；Stage 4.2 之后再进行独立的后台与桌面歌词功耗优化工作。

**不应回退的边界**：不得为工具栏创建第二套状态或存储；不得让 overlay 直接写持久化；不得用模拟按钮点击代替语义播放路径；不得让工具栏控件触发窗口拖拽；不得让恢复默认重置位置、锁定、启用、颜色、透明度、播放或 BrowserWindow bounds；不得恢复垂直 rolling；不得引入新依赖、品牌、安装器或更新器变更。
