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
