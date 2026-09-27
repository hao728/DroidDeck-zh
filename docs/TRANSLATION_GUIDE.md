# 汉化翻译指南

## 一、发现漏翻译词条

### 自动提取（推荐）

上游更新后，运行自动提取脚本生成完整报告：

```bash
bash scripts/extract-strings.sh DroidDeck-0.1.7 reports/
```

输出三个报告：
- `*-smali-strings.txt` — 所有 smali 中疑似 UI 字符串（按出现次数排序）
- `*-res-strings.txt` — 资源 strings.xml 中缺失中文翻译的条目
- `*-untranslated.txt` — 对比已有映射后，真正未翻译的词条清单

### 手动扫描

```bash
# 完整反编译到 sources/
bash scripts/init.sh DroidDeck-0.1.7
# 扫描未汉化字符串
bash scripts/scan-strings.sh sources/
```

## 二、补充翻译

### smali 硬编码字符串

编辑 `patches/smali-strings.txt`，每行一条：

```
英文原文|||中文翻译
```

**格式规则：**
- 分隔符必须是 `|||`（三个竖线）
- `#` 开头为注释
- 原文必须与 smali 中 `const-string` 后的字符串**完全一致**（含 `\n`、`\u00xx`、尾随空格等）
- 中文翻译中**禁止使用 ASCII 双引号 `"`**（会破坏 smali 语法），用中文角括号「」代替
- 保留原文中的格式符 `%s`、`%d`、`%.1f` 和转义符 `\n`、`\t`

### 资源字符串

编辑 `patches/res/values-zh-rCN/strings.xml` 和 `arrays.xml`。构建时自动**合并**到上游已有翻译中（不会覆盖上游已有的 83 条）。

## 三、翻译质量规范

### 术语一致性

建立统一术语表，避免同一概念多种译法：

| 英文 | 统一译法 | 避免 |
|---|---|---|
| Session | 会话 | 会议、场次 |
| Runtime | 运行时 | 运行环境 |
| Compositor | 合成器 | 合成器、混音器 |
| Compatibility tools | 兼容工具 | 兼容性工具 |
| Frame generation | 帧生成 | 帧率生成 |
| Driver | 驱动 | 驱动程序 |
| Storage | 存储 | 储存 |
| Resolution | 分辨率 | 解析度 |

### 格式与长度

- **格式符必须保留**：`%1$s`、`%2$d` 等位置参数不能打乱顺序
- **转义符必须保留**：`\n`（换行）、`\u00b7`（·）、`\u2026`（…）
- **尾随空格**：原文末尾有空格的（如 `Activated fake input ring for slot `），翻译后也要保留，因为代码会在后面拼接变量
- **长度控制**：中文通常比英文短，设置项标签不宜过长；错误信息可适当扩展

### 语境判断

- **设置项标签**：简洁名词短语，如「显示驱动」「客户端核心」
- **描述文本**：完整句子，如「下次会话生效」
- **错误信息**：以「无法…」「…失败」开头
- **按钮文字**：动词开头，如「立即安装」「选择文件夹」

## 四、校验翻译

提交前运行校验脚本：

```bash
# 仅校验映射文件
bash scripts/lint-translations.sh

# 校验映射 + 构建好的 APK
bash scripts/lint-translations.sh dist/DroidDeck-0.1.7-zh.apk
```

校验项：
- ✅ 无 ASCII 双引号（smali 语法杀手）
- ✅ 格式符一致性（%s %d 等）
- ✅ 转义符一致性（\n \t）
- ✅ 无重复映射
- ✅ 无空翻译
- ✅ 尾随空格一致性
- ✅ XML 格式有效
- ✅ APK 有效且签名正确
- ✅ 中文字符串已编译进 dex

CI 构建时会自动运行校验，失败则不发布。

## 五、常见坑

1. **中文引号被存成 ASCII `"`**：编辑器自动转换，提交前用 lint 检查
2. **`re.sub` 解释 `\n`**：替换脚本已用 lambda 修复，不要改回字符串替换
3. **上游已有翻译被覆盖**：已改用合并模式，补丁只追加/覆盖指定条目
4. **字符串拼接**：有些 UI 文本是多段拼接的（如 `"). Check the connection..."`），需单独翻译每段
5. **技术字符串误翻**：日志、调试、文件路径等不要翻，只翻面向用户的文本

## 六、上游更新流程

1. `bash scripts/sync-upstream.sh` — 检测新版本
2. `bash scripts/extract-strings.sh <新版本> reports/` — 提取新词条
3. 对比 `*-untranslated.txt`，补充到 `smali-strings.txt`
4. `bash scripts/lint-translations.sh` — 校验
5. 提交 push，CI 自动构建为预发布版
6. 安装验证稳定后，手动触发构建并取消「预发布」勾选，发布正式版
