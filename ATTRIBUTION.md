# 归属与开源声明

本项目是对以下开源项目的派生与汉化，遵守各自的开源协议：

## 上游项目

| 项目 | 作者 | 协议 | 用途 |
|---|---|---|---|
| [Winlator](https://github.com/brunodev85/winlator) | brunodev85 | LGPL（v2.1 / 任意更新版本） | Android 上运行 Windows 应用的运行时，DroidDeck 的基础 |
| [DroidDeck / winlator-contents](https://github.com/The412Banner/winlator-contents) | The412Banner | 基于 Winlator 派生 | 被汉化的目标 APK（ludashi 变体） |
| [Apktool](https://github.com/iBotPeaches/Apktool) | iBotPeaches | Apache 2.0 | APK 反编译与回编译 |

## 本项目的修改

- 新增 `patches/res/values-zh-rCN/` 简体中文翻译
- 新增自动化构建、同步、校验脚本
- 对 APK 重新签名（社区持久化密钥，非上游原签名）

## 协议义务

根据 LGPL，分发本修改版 APK 时：

1. **保留**上游版权与许可声明
2. **提供**本项目的修改源码（本仓库即满足）
3. 本项目的汉化补丁与脚本以 **LGPL-3.0** 开源
4. 不得将修改版声明为闭源/专有软件

## 免责

本项目为社区汉化学习用途，与 Valve、Steam、Winlator 作者及 DroidDeck 作者无官方关联。Steam 为 Valve Corporation 的商标。
