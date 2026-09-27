# DroidDeck 汉化构建仓库

自动跟踪上游 [The412Banner/winlator-contents](https://github.com/The412Banner/winlator-contents) 的 DroidDeck APK，自动下载、解包、应用汉化补丁、回编译、自签名并发布。

- 上游包名：`com.droiddeck.launcher`
- 当前基线：`DroidDeck-0.1.7`（ludashi 变体）
- 汉化范围：资源字符串（合并上游已有翻译）+ **smali 硬编码 UI 字符串**（318 条映射，335 处替换）
- 签名：社区持久化密钥（`secrets/release.keystore`），非上游原签名

## 关于签名（重要）

**修改 APK 内容必然使原签名失效**——Android v1/v2/v3 签名覆盖全部文件字节，任何改动都会破坏校验。因此本项目使用自己的持久化密钥重新签名，这是汉化改装的唯一可行方式。用户首次安装需卸载原版（签名不同），后续同签名版本可覆盖安装。

## 关于语言切换

DroidDeck 本身**没有应用内语言切换开关**，语言由系统 locale 决定：

- **资源字符串**（`res/values-zh-rCN/`）：系统设为简体中文时自动生效
- **smali 硬编码字符串**：已直接替换为中文，无论系统语言均显示中文
- 如需在非中文系统上使用本汉化版：smali 部分始终中文，资源部分跟随系统语言

Android 13+ 可在 **设置 → 系统 → 语言 → 应用语言** 中单独设置本应用语言（需应用支持 localeConfig，当前版本未启用）。

## 预发布机制

- **push 自动构建**：一律发布为**预发布版（prerelease）**，不设为 latest
- **手动构建**：Actions → Run workflow，`prerelease` 勾选为预发布；**取消勾选**则发布为正式版（latest）
- 未经充分验证的版本保持预发布状态，确认稳定可用后再手动触发正式版

## 快速开始

1. Actions → **Build Localized APK** → Run workflow
2. 等待 4-6 分钟（全量反编译含 smali）
3. Releases 下载 `DroidDeck-*-zh.apk`

## 工作流

| 工作流 | 触发 | 功能 |
|---|---|---|
| Build Localized APK | 手动 / push patches·scripts·config | 下载APK→全量解包→合并资源补丁→替换smali字符串→回编译→签名→发布 |
| Sync Upstream | 每日定时 / 手动 | 检查上游新版本，有更新则下载扫描并开 Issue 提醒 |
| Validate Patches | PR / 手动 | 校验补丁完整性和兼容性 |

## 本地构建

```bash
# 依赖：Java 11+、Android SDK build-tools（zipalign + apksigner）
bash scripts/build.sh DroidDeck-0.1.7
# 产物在 dist/
```

## 维护汉化

### 资源字符串
编辑 `patches/res/values-zh-rCN/` 下的 `strings.xml` / `arrays.xml`。构建时**合并**到上游已有翻译中（上游已有的 83 条不会被覆盖，仅追加缺失条目和覆盖指定条目）。

### smali 硬编码字符串
编辑 `patches/smali-strings.txt`，每行格式：
```
英文原文|||中文翻译
```
- 仅替换 `const-string` / `const-string/jumbo` 中的字符串
- 中文翻译中**禁止使用 ASCII 双引号 `"`**（会破坏 smali 语法），用中文角括号「」代替
- 保留原文中的 `\n`、`\u00xx` 等转义符
- 构建时自动全量反编译（含 dex/smali），每文件只读一次批量替换

上游大版本更新时：
```bash
bash scripts/sync-upstream.sh     # 检测并下载新版，生成 UNTRANSLATED_REPORT.md
bash scripts/init.sh DroidDeck-x.x.x  # 完整反编译到 sources/ 供编辑
bash scripts/scan-strings.sh sources/  # 扫描未汉化字符串
```

## 目录结构

```
config/          上游与构建配置（变体、apktool、签名）
patches/
  res/values-zh-rCN/  资源字符串补丁（合并模式）
  smali-strings.txt   smali 硬编码字符串映射
scripts/
  build.sh            主构建脚本（8步）
  apply-smali-strings.sh  smali 字符串替换
  merge-resources.py      资源 XML 合并
  sync-upstream.sh    上游版本同步
  validate-patches.sh 补丁校验
  init.sh             完整反编译生成可编辑 sources/
  scan-strings.sh     扫描未汉化字符串
  lib/common.sh       公共函数库
secrets/         持久化签名密钥（已提交，.gitignore 已放行）
state/           上游版本记录、补丁清单
.github/workflows/  CI 自动化
```

## 开源协议

本项目基于 [Winlator](https://github.com/brunodev85/winlator)（LGPL）派生，汉化补丁与构建脚本以 **LGPL-3.0** 开源。分发修改版 APK 时须保留上游版权声明并提供对应修改源码（本仓库即满足）。详见 [LICENSE](LICENSE) 与 [ATTRIBUTION.md](ATTRIBUTION.md)。
