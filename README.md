# DroidDeck 汉化版

对 [Droid-Deck/DroidDeck](https://github.com/Droid-Deck/DroidDeck) APK 进行简体中文汉化，自动下载上游 APK → 解包 → 打补丁 → 重编译 → 签名 → 发布。

- 包名：`com.droiddeck.launcher`（未修改）
- 当前基线：`0.2.0`（ludashi 变体）
- 翻译：smali 硬编码字符串 1132 条 + 资源字符串合并上游 values-zh-rCN
- 签名：社区持久化密钥 `secrets/release.keystore`，非上游原签名

## 签名说明

修改 APK 必然使原签名失效。本项目用自有密钥重签，首次安装需卸载原版，后续同签名版本可覆盖安装。

## 汉化范围

| 类型 | 方式 |
|------|------|
| 资源字符串 | `patches/res/values-zh-rCN/`，构建时合并到上游已有翻译 |
| smali 硬编码字符串 | `patches/smali-strings.txt`，`原文|||译文` 格式，构建时替换 `const-string` |
| 关键脚本修改 | `patches/diffs/*.patch`，diff 格式只改必要部分，不覆盖上游其他更新 |
| 新增文件 | `ZhDialog.smali`（启动弹窗）、`zh-overlay.tar.gz`（locale+中文字体） |

## Steam 客户端中文

DroidDeck 运行原生 ARM64 Linux Steam 客户端。已做以下处理：

- 启动参数加 `-lang schinese`、`-cef-lang=zh-CN`
- `config.vdf` 强制 `language=schinese`，首次中文启动清理 CEF 缓存
- `steamwebhelper` 包装脚本：替换 `-lang=en_US` 为 `-lang=zh_CN`，并设置中文环境变量
- 文泉驿微米黑字体注入 `~/.fonts` 和 `steamrtarm64/fonts`，fontconfig 配置 MotivaSans 回退

注意：Steam 首次启动后 webhelper 才下载，包装脚本第二次启动生效。若首次为英文，退出重进即可。

## 构建

```bash
# 依赖：Java 17、Android SDK build-tools（zipalign + apksigner）
bash scripts/build.sh 0.2.0
# 产物：dist/0.2.0-zh.apk
```

CI：push 到 `patches/`、`scripts/`、`config/` 自动构建并发布为 prerelease。手动触发时取消勾选 prerelease 可发布为正式版。

## 上游同步

```bash
bash scripts/sync-upstream.sh   # 检测新版本，生成未翻译报告，验证 diff patch 兼容性
```

上游大版本更新时，`patches/diffs/` 中的 patch 可能冲突。`sync-upstream.sh` 会检测并报告，需手动将汉化修改移植到新版上游文件后重新生成 patch：

```bash
bash scripts/regenerate-diffs.sh <上游反编译目录>
```

## 目录

```
config/          上游仓库、版本、签名配置
patches/
  diffs/         bannerlator-session、SessionFiles.smali 的 diff patch
  res/values-zh-rCN/  资源字符串
  smali-strings.txt   smali 硬编码字符串映射
  assets/linuxfs/     新增覆盖层文件（zh-overlay.tar.gz）
  smali_classes2/     新增 smali 类（ZhDialog）
scripts/         build.sh、sync-upstream.sh、validate-patches.sh 等
secrets/         签名密钥
.github/workflows/  CI
```

## 协议

基于 Winlator（LGPL）派生，汉化补丁与构建脚本以 LGPL-3.0 开源。
