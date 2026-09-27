# DroidDeck 汉化构建仓库

自动跟踪上游 [The412Banner/winlator-contents](https://github.com/The412Banner/winlator-contents) 的 DroidDeck APK，自动下载、解包、应用汉化补丁、回编译、自签名并发布。

- 上游包名：`com.droiddeck.launcher`
- 当前基线：`DroidDeck-0.1.7`（ludashi 变体）
- 汉化范围：`res/values-zh-rCN/strings.xml` + `arrays.xml`
- 签名：社区持久化密钥（`secrets/release.keystore`），非上游原签名

## 关于签名（重要）

**修改 APK 内容必然使原签名失效**——Android v1/v2/v3 签名覆盖全部文件字节，任何改动都会破坏校验。因此本项目使用自己的持久化密钥重新签名，这是汉化改装的唯一可行方式。用户首次安装需卸载原版（签名不同），后续同签名版本可覆盖安装。

## 快速开始

1. Actions → **Build Localized APK** → Run workflow
2. 等待 3-5 分钟
3. Releases 下载 `DroidDeck-*-zh.apk`

## 工作流

| 工作流 | 触发 | 功能 |
|---|---|---|
| Build Localized APK | 手动 / push patches·scripts·config | 下载APK→解包→打补丁→回编译→签名→发布 |
| Sync Upstream | 每日定时 / 手动 | 检查上游新版本，有更新则下载扫描并开 Issue 提醒 |
| Validate Patches | PR / 手动 | 校验补丁完整性和兼容性 |

## 本地构建

```bash
# 依赖：Java 11+、Android SDK build-tools（zipalign + apksigner）
bash scripts/build.sh DroidDeck-0.1.7
# 产物在 dist/
```

## 维护汉化

编辑 `patches/res/values-zh-rCN/` 下的文件，提交后下次构建自动生效。

上游大版本更新时：
```bash
bash scripts/sync-upstream.sh     # 检测并下载新版，生成 UNTRANSLATED_REPORT.md
bash scripts/init.sh DroidDeck-x.x.x  # 完整反编译到 sources/ 供编辑
bash scripts/scan-strings.sh sources/  # 扫描未汉化字符串
```

## 目录结构

```
config/          上游与构建配置（变体、apktool、签名）
patches/         汉化补丁（覆盖到反编译结果）
scripts/         构建、同步、校验、扫描脚本
secrets/         持久化签名密钥（已提交，.gitignore 已放行）
state/           上游版本记录、补丁清单
.github/workflows/  CI 自动化
```

## 开源协议

本项目基于 [Winlator](https://github.com/brunodev85/winlator)（LGPL）派生，汉化补丁与构建脚本以 **LGPL-3.0** 开源。分发修改版 APK 时须保留上游版权声明并提供对应修改源码（本仓库即满足）。详见 [LICENSE](LICENSE) 与 [ATTRIBUTION.md](ATTRIBUTION.md)。
