# 常见问题排查

## 构建失败

### 1. apktool 回编译报错

**症状**：`brut.androlib.AndrolibException` 或 `Error brut.androlib`

**原因**：
- apktool 版本不兼容上游 APK 使用的 aapt2 版本
- 反编译时资源解析有警告，回编译时出错

**解决**：
1. 检查 `config/build.json` 中的 apktool 版本，尝试升级到最新版
2. 本地手动回编译看详细错误：`java -jar apktool.jar b sources/ -o test.apk`
3. 如果是资源 ID 冲突，删除 `sources/` 重新 `init.sh`

### 2. 补丁文件不存在

**症状**：`补丁目标不存在（上游可能已变更）: xxx`

**原因**：上游重构了代码，文件路径或类名变了

**解决**：
1. 运行 `bash scripts/validate-patches.sh` 查看哪些补丁失效
2. 重新 `init.sh` 生成新的 sources/
3. 在新 sources/ 中重新汉化，然后 `extract-patches.sh`
4. 删除 patches/ 中失效的文件

### 3. smali 原文不匹配

**症状**：`原文不匹配: xxx.smali → "yyy"`

**原因**：上游修改了该字符串的原文，补丁里的旧原文找不到了

**解决**：
1. 在新 sources/ 中搜索该字符串，看是否被修改或删除
2. 如果只是文字微调，更新 patches/ 里的 smali 文件
3. 如果字符串被删除了，从 patches/ 中移除对应修改

### 4. 签名失败

**症状**：`apksigner` 报错或 `apksigner verify` 失败

**原因**：
- keystore 生成失败
- zipalign 未正确执行

**解决**：
1. 手动生成 keystore：`keytool -genkeypair -keystore debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"`
2. 手动 zipalign：`zipalign -f 4 input.apk output.apk`
3. 手动签名：`apksigner sign --ks debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android --key-pass pass:android --out signed.apk aligned.apk`

## 同步问题

### 5. 检测不到上游新版本

**症状**：`无法检测上游最新版本`

**原因**：
- GitHub API 限流（未认证请求每小时 60 次）
- 上游 release 命名规则变了

**解决**：
1. 手动指定版本：`bash scripts/init.sh SteamDeck-0.1.6`
2. 检查 `config/upstream.json` 中的 `release_tag_prefix` 是否正确
3. 在 GitHub Actions 中使用 `${{ secrets.GITHUB_TOKEN }}` 可提高 API 限额

### 6. 同步后补丁大量失效

**症状**：上游大版本更新后，validate-patches.sh 报告大量补丁失效

**原因**：上游进行了大重构（如 0.1.4 → 0.1.5 的 UI 重写）

**解决**：
1. 这是正常现象，大版本更新需要重新汉化
2. 保留旧版本的 patches/ 作为参考
3. 重新 `init.sh`，对照旧翻译在新 sources/ 中重新汉化
4. 优先汉化核心界面（主按钮、设置项），次要界面可后续补充

## 安装问题

### 7. 安装失败：签名不一致

**症状**：`INSTALL_FAILED_UPDATE_INCOMPATIBLE`

**原因**：已安装原版或其他签名的版本

**解决**：
```bash
adb uninstall com.steamdeck.launcher
adb install SteamDeck-x.x.x-zh.apk
```
注意：卸载会清除应用数据，但 Linux 运行时和游戏通常在外部存储，不会丢失。

### 8. 安装后仍是英文

**症状**：安装汉化版后界面还是英文

**原因**：
- 系统语言不是简体中文
- 汉化的字符串没有覆盖到该界面

**解决**：
1. 确认系统语言设为「简体中文」
2. 如果某些界面仍是英文，说明是 smali 硬编码字符串未汉化
3. 运行 `scan-strings.sh` 查找未汉化字符串，补充汉化

## 运行时问题

### 9. 应用崩溃

**症状**：打开应用后闪退

**原因**：
- smali 修改时改错了寄存器或指令
- 资源文件格式错误

**解决**：
1. 检查 logcat：`adb logcat | grep -i steamdeck`
2. 重点看 `AndroidRuntime` 相关的崩溃堆栈
3. 如果是 `Resources$NotFoundException`，说明资源 ID 有问题，重新 init + build
4. 如果是 smali 相关错误，检查最近修改的 smali 文件

### 10. 部分文字显示乱码或方框

**症状**：中文字符显示为方框或乱码

**原因**：字体不支持中文字符

**解决**：
- SteamDeck 应用使用系统字体，Android 系统通常自带中文字体
- 如果是自定义字体导致的，检查是否修改了字体相关资源
- 极少数情况是 smali 中中文编码问题，确保文件保存为 UTF-8

## 性能问题

### 11. GitHub Actions 构建超时

**症状**：工作流运行超过 10 分钟被取消

**原因**：下载 APK 或反编译耗时过长

**解决**：
1. 检查网络，GitHub Actions 通常有足够带宽
2. apktool 反编译 21MB APK 通常 1-2 分钟
3. 如果持续超时，增加工作流的 `timeout-minutes`
