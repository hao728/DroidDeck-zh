# 汉化翻译指南

## 一、发现漏翻译词条

### 智能提取（推荐，自动过滤内部字符串）

上游更新后，运行智能提取脚本，自动过滤 checkNotNullParameter 参数名、Compose key、日志 tag、文件路径等内部字符串，只输出有翻译价值的 UI 文本：

```bash
python3 scripts/extract-ui-strings.py <反编译目录> patches/smali-strings.txt
```

输出：
- 按模块分类的翻译覆盖率报告（ui/session/runtime/core/frontend/files/gpu/input）
- 每个模块的未翻译 TOP 列表（带来源文件）
- 完整未翻译列表写入 `untranslated-report.txt`

**上游同步时自动运行**：`sync-upstream.sh` 已集成此脚本，检测到新版本后自动生成报告。

### 全量提取（旧版，含内部字符串）

```bash
bash scripts/extract-strings.sh DroidDeck-0.1.7 reports/
```

### 手动扫描

```bash
bash scripts/init.sh DroidDeck-0.1.7   # 完整反编译到 sources/
bash scripts/scan-strings.sh sources/  # 扫描未汉化字符串
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
- 原文必须与 smali 中 `const-string` 后的字符串**完全一致**（含 `\n`、`\u00xx`、尾随空格、`\"` 转义引号等）
- 中文翻译中**禁止使用未转义的 ASCII 双引号 `"`**（会破坏 smali 语法），用中文角括号「」代替；如需保留引号用 `\"`
- 保留原文中的格式符 `%s`、`%d`、`%.1f` 和转义符 `\n`、`\t`
- 前缀字符串（如 `Delete \"`）翻译后必须保留 `\"`，因为代码会在后面拼接文件名

### 资源字符串

编辑 `patches/res/values-zh-rCN/strings.xml` 和 `arrays.xml`。构建时自动**合并**到上游已有翻译中（不会覆盖上游已有的 83 条）。

## 三、翻译质量规范

### 精翻术语表（Linux/Wine/Steam 游戏圈风格）

| 英文 | 统一译法 | 说明 |
|---|---|---|
| Session | 会话 | 不译"会议/场次" |
| Runtime | 运行时 | 不译"运行环境" |
| Compositor | 合成器 | 显示合成器 |
| Compatibility tools | 兼容工具 | Proton 等 |
| Frame generation | 帧生成 | 不译"帧率生成" |
| Driver | 驱动 | Turnip/Mesa 驱动 |
| Storage | 存储 | 不译"储存" |
| Resolution | 分辨率 | 不译"解析度" |
| Performance HUD | 性能浮层 | 游戏内性能显示 |
| QAM (Quick Access Menu) | 快捷菜单 | Steam Deck 术语 |
| TSO (Total Store Ordering) | TSO | CPU 内存模型，保留缩写 |
| glthread | glthread | Mesa 线程化 GL，保留 |
| ICD (Installable Client Driver) | ICD | Vulkan 驱动，保留 |
| ROM | ROM | 游戏镜像，保留 |
| Steam/Wine/Proton/FEX | 保留原文 | 品牌/项目名不翻译 |
| Vulkan/OpenGL/DirectX | 保留原文 | 图形 API 名 |
| Adreno/Turnip/Mesa/Zink | 保留原文 | 驱动/项目名 |
| DXVK/vkd3d | 保留原文 | 兼容层项目名 |
| LSFG/Lossless Scaling | 保留原文 | 帧生成工具 |
| KGSL | KGSL | Android GPU 内核驱动 |
| RetroArch | RetroArch | 模拟器前端 |
| GameCube/Wii | 保留原文 | 游戏机名 |
| SD card | SD 卡 | 不译"安全数字卡" |
| Teardown | 清理/收尾 | 会话结束清理 |
| Scrubbed | 已脱敏 | 日志隐私处理 |

### 机翻味避免

- ❌ "进行下载" → ✅ "下载中"
- ❌ "无法被删除" → ✅ "无法删除"
- ❌ "关于此应用的信息" → ✅ "应用信息"
- ❌ "对于游戏来说" → 直接删介词
- 错误信息用「无法…」「…失败」开头，不用被动语态
- 设置项用简洁名词短语，不用完整句子

### 格式与长度

- **格式符必须保留**：`%1$s`、`%2$d` 等位置参数不能打乱顺序
- **转义符必须保留**：`\n`（换行）、`\u00b7`（·）、`\u2026`（…）、`\"`（转义引号）
- **尾随空格**：原文末尾有空格的（如 `Activated fake input ring for slot `），翻译后也要保留，因为代码会在后面拼接变量
- **长度控制**：中文通常比英文短，设置项标签不宜过长；错误信息可适当扩展

### 语境判断

- **设置项标签**：简洁名词短语，如「显示驱动」「客户端核心」
- **描述文本**：完整句子，如「下次会话生效」
- **错误信息**：以「无法…」「…失败」开头
- **按钮文字**：动词开头，如「立即安装」「选择文件夹」
- **技术日志**：底层输入模拟、网络配置等日志保留英文更利于排查

## 四、校验翻译

提交前运行校验脚本：

```bash
# 仅校验映射文件
bash scripts/lint-translations.sh

# 校验映射 + 构建好的 APK
bash scripts/lint-translations.sh dist/DroidDeck-0.1.7-zh.apk
```

校验项：
- ✅ 无未转义 ASCII 双引号（smali 语法杀手）
- ✅ 格式符一致性（%s %d 等）
- ✅ 转义符一致性（\n \t \"）
- ✅ 无重复映射
- ✅ 无空翻译
- ✅ 尾随空格一致性
- ✅ **专有名词一致性**（Steam/Wine/Proton/FEX/Vulkan 等不被误译）
- ✅ **机翻味检测**（被动语态滥用、冗余动词等）
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
6. **转义引号丢失**：`Delete \"` 中的 `\"` 是 smali 转义的双引号，翻译时必须保留为 `删除 \"`，否则 smali 语法错误
7. **通用词缺乏语境**：Client/Channel/Build/Level 等词在不同语境下含义不同，优先翻译完整短语而非单个单词

## 六、上游更新流程

1. `bash scripts/sync-upstream.sh` — 检测新版本，自动运行智能提取生成未翻译报告
2. 查看 `untranslated-report.txt`，按模块补充翻译到 `smali-strings.txt`
3. 参考本指南术语表精翻，避免机翻味
4. `bash scripts/lint-translations.sh` — 校验（含术语一致性和机翻味检测）
5. 本地构建验证：`bash scripts/build.sh`
6. 提交 push，CI 自动构建为预发布版
7. 安装验证稳定后，手动触发构建并取消「预发布」勾选，发布正式版
