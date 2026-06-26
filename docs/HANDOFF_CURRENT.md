# 当前任务交接

## 状态

- 分支：`fix/installer-safety`
- 版本：`1.1.1-w1`
- 任务：Mineradio W 安装器/卸载器路径安全修复。
- 实现状态：已完成。
- 构建状态：`npm run build:win` 已成功生成完整 NSIS 安装包。
- 提交状态：尚未提交，尚未推送。

## 失败与修正记录

- 第一版 VM legacy 升级失败：已安装 Mineradio W `1.1.0-w1` 时，`1.1.1-w1` 安装器仍要求先移除旧版本。
- 第一版原因：electron-builder 生成的 `installSection.nsh` 会在安装文件前调用 `uninstallOldVersion` / `handleUninstallResult`；只删除 legacy 卸载器文件不足以阻止生成宏从 `UninstallString` 进入旧版本移除流程。
- 第二版 VM 复测失败：安装器不再要求手动卸载旧版，但把新版本装进旧目录下的嵌套 `Mineradio W\Mineradio W`。
- 第二版原因：`MineradioNormalizeInstallDir` / `un.MineradioNormalizeInstallDir` 用长度 `12` 判断 `\Mineradio W` 后缀；实际后缀长度为 `11`。
- 第三次 fresh-install VM 测试失败：White 选择 `C:\MRW-Test\Fresh`，期望 `C:\MRW-Test\Fresh\Mineradio W`，实际检查为 `False / False / True`，新文件落在 `C:\MRW-Test\Fresh\Mineradio W\Mineradio W`。
- 第三次原因：浏览按钮先规范化并写回 `...\Mineradio W`，目录页 leave 再规范化一次；固定长度后缀判断不可靠，导致基础 normalize 非幂等。
- 第四次 legacy-upgrade VM 测试失败：真实发布的 `1.1.0-w1` 默认目录是 `C:\Users\YMXD\AppData\Local\Programs\Mineradio-W`。White 在该根目录放置 `LEGACY-SENTINEL.txt` 后运行安装器，检查结果为 `False / False / False / True`：旧根下 `Mineradio-W.exe`、`LEGACY-SENTINEL.txt`、`.mineradio-w-install-root` 均不存在，而 `Mineradio-W\Mineradio W\Mineradio-W.exe` 存在。
- 第四次原因：legacy evidence、registered adoption 和 uninstall-registration neutralization 仍先套 fresh normalize，`Mineradio-W` 被当成父目录并追加 `Mineradio W`，因此真实旧根既未被收养，也未正确隐藏旧 `UninstallString`。
- `LEGACY-SENTINEL.txt` 的删除来源：electron-builder 生成的 `uninstallOldVersion` 读取仍可见的 legacy `UninstallString`，通过 `ExecWait` 执行旧 `Uninstall Mineradio-W.exe`。不是自定义 `Delete "$INSTDIR\*"`、`Delete "$INSTDIR\*.*"` 或 `RMDir /r "$INSTDIR"`，这些自定义 root/wildcard 删除仍不存在。
- 最终修正：
  - `customInit` 先从 Mineradio W 自己的注册表 key 收养安装目录并设置 `MineradioLegacyInstallDir` / `MineradioLegacyInstallAdopted`。
  - 后续目录页、校验和安装前处理通过 `MineradioNormalizeInstallDirPreservingAdopted` 保留真实 `Mineradio-W` 精确目录，不再追加 `Mineradio W`。
  - Fresh 基础规范化保持幂等：trim 尾部反斜杠（保留盘符根）→ drive root 特判 → `${GetFileName}` 获取最终目录组件 → 与 `Mineradio W` 比较 → 仅最终组件不是 `Mineradio W` 时追加。
  - 最终校验在通用“非空非专属目录”拒绝之前，先检查已验证的 legacy 收养状态：`$MineradioLegacyInstallAdopted == 1`、当前路径严格等于 `$MineradioLegacyInstallDir`、最终组件为 `Mineradio-W`、`Mineradio-W.exe` 与 Mineradio W 应用资源存在。只有完全匹配的 verified legacy 目标才提前放行。
  - 迁移 legacy 通过 `MineradioLegacyInstallDir` 绕过 fresh normalize；任意非空 `Mineradio-W` 文件夹仍然被阻止。
  - NSIS 临时寄存器污染曾导致 legacy 路径被覆盖为 `0` 或 `1`；重要路径值改用辅助函数外的 `$R3` 保存，避免被 `$0`–`$5` 覆盖。
  - 取消安全：UI 阶段只检测和记录；进入 instfiles 前才临时删除 legacy `UninstallString` / `QuietUninstallString`，并保存原值。`MUI_CUSTOMFUNCTION_ABORT` 和 `.onInstFailed` 会在取消或失败时恢复。安装提交后由新注册表覆盖。
  - 成功提交时只删除 legacy 空格名残留卸载器 `Uninstall Mineradio W.exe`；不会在 `customInstall` 删除 `Uninstall Mineradio-W.exe`。
  - 安全卸载只删除已知 Mineradio W 文件和明确应用拥有的目录，从不递归删除安装根；根目录内未知文件和子目录会保留。

## 已实现

- Fresh install 目标规范化为专属 `Mineradio W` 子目录。
- 真实 legacy `1.1.0-w1` 目标 `Mineradio-W` 会精确原地收养，不改名、不追加 `Mineradio W`。
- 所有权 marker：`.mineradio-w-install-root`。
- marker appId：`com.whitewind0987.mineradio.w`。
- marker 在目录校验通过后写入。
- 卸载前同时校验专属路径最终组件（`Mineradio W` 或迁移后的 `Mineradio-W`）和 marker appId。
- 非空目录只接受有效 marker、注册表身份匹配的 legacy Mineradio W 安装，或空目录。
- 最终校验新增 verified markerless legacy 例外，在通用非空拒绝之前执行。
- legacy `1.1.0-w1` 旧卸载器不执行；legacy uninstall key 不在 UI 阶段被删除，只在安装即将开始时临时移除 `UninstallString` / `QuietUninstallString`，取消或失败会恢复。
- 支持从 uninstall key 的 `InstallLocation` 或 `UninstallString` 派生实际安装目录。
- 相关注册表 key：HKCU/HKLM `Software\80c6a246-0542-5156-a184-0d2440cdcc6d`；HKCU/HKLM `Software\Microsoft\Windows\CurrentVersion\Uninstall\80c6a246-0542-5156-a184-0d2440cdcc6d`。
- verified legacy 收养路径会以 `$MineradioLegacyInstallDir` 精确保留；fresh install 仍会把盘符根或普通父目录规范化到 `Mineradio W` 子目录。
- 只处理 Mineradio W 自己的注册表身份，不触碰官方 Mineradio 或其它应用。
- 卸载只删除已知 Mineradio W 文件和明确应用拥有的目录。
- `$INSTDIR` 只做非递归 `RMDir`。
- 版本保持为 `1.1.1-w1`。

## 构建产物

- `dist\Mineradio-W-1.1.1-w1-Setup.exe`
- `dist\Mineradio-W-1.1.1-w1-Setup.exe.blockmap`
- SHA256：`A99901BC27BBF5E3F80F4DC859560F071D4AC9498E3813D38FE92CC1D718D3E6`

## 已验证

- `git diff --check` 通过，仅提示 `build/installer.nsh` 的 LF/CRLF 工作区换行警告。
- `build/installer.nsh` 为有效 UTF-8。
- 搜索确认无 upstream appId、无 upstream marker、无裸 `\Mineradio` 强制安装路径、无 `RMDir /r "$INSTDIR"`。
- 搜索确认自定义脚本无 `Delete "$INSTDIR\*"`、无 `Delete "$INSTDIR\*.*"`、无 legacy root recursive delete。
- 搜索确认不再存在用于判断 `Mineradio W` 目录名的固定 `11` / `12` 后缀切片。
- 搜索确认 installer/uninstaller 均使用最终路径组件判断 `Mineradio W` / `Mineradio-W`。
- 生成模板确认 `uninstallOldVersion` 在文件释放前通过 `ExecWait` 调用旧卸载器；本修正会在 `MUI_PAGE_INSTFILES` 前事务式删除 verified legacy 的 `UninstallString` / `QuietUninstallString`。
- `npm run build:win` 成功。

## White 手动 VM 最终验证结果

已在 Windows VM 中完成以下验证：

1. Fresh 安装到所选父目录时，只创建一层 `Mineradio W` 子目录。
2. 未出现嵌套 `Mineradio W\Mineradio W` 目录。
3. 所有权 marker `.mineradio-w-install-root` 写入正确。
4. 无关非空目录仍被阻止。
5. marker 损坏或被篡改时卸载被阻止。
6. 真实 legacy `1.1.0-w1` 目录为 `C:\Users\YMXD\AppData\Local\Programs\Mineradio-W`。
7. 新安装器在目录页显示并保留该精确 legacy 目录。
8. Legacy 原地升级成功完成。
9. 升级后检查结果为 `True / True / True / False`：
   - 新可执行文件存在；
   - `LEGACY-SENTINEL.txt` 保留；
   - ownership marker 存在；
   - 不存在嵌套的 `Mineradio W\Mineradio-W.exe`。
10. 升级过程中未启动旧卸载器。
11. 升级后只保留一条卸载注册表项。
12. 卸载注册表项报告版本为 `1.1.1-w1`。
13. 在安装阶段前取消新安装器，旧 `1.1.0-w1` 的卸载注册表项与文件均保留。
14. 升级后执行安全卸载，已知 Mineradio W 文件被删除。
15. 卸载后未知根文件和未知子目录保留。
16. 存在未知文件时安装根目录保留。
17. 卸载注册表项最终被成功移除。

**注意**：以上 17 项为本次 White 手动验证的范围。未列出的测试（例如与官方 Mineradio 并存、物理耳机/锁屏等）不在本次 installer-safety 验证结论内。
