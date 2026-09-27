# 汉化规范

## 资源字符串汉化（patches/res/values-zh-rCN/）

### 基本原则

1. **保留占位符**：所有 `%1$s`、`%1$d%%`、`\n` 等必须原样保留，不能删除或修改
2. **保留转义**：`\"`、`\'`、`\n` 等转义字符必须保留
3. **标点用中文**：中文文本使用中文标点（，。！？：；""''）
4. **术语统一**：参考下方术语表

### 术语表

| 英文 | 中文 | 说明 |
|---|---|---|
| Linux runtime | Linux 运行时 | 不翻译为"运行库" |
| Frame generation | 帧生成 | 技术术语 |
| Performance HUD | 性能监控 | HUD 不翻译 |
| On-screen controls | 虚拟按键 / 屏幕按键 | OSC |
| Big Picture | Big Picture | Steam 模式名，保留英文 |
| Steam Deck | Steam Deck | 产品名，保留英文 |
| Proton | Proton | 兼容层名称，保留英文 |
| gamescope | gamescope | 合成器名称，保留英文 |
| Adreno | Adreno | GPU 品牌，保留英文 |
| ROMs | ROM | 游戏 ROM，保留英文 |
| AppImage | AppImage | 包格式，保留英文 |

### 长文本翻译

- `credits_body`：保留作者署名和许可证声明的英文，只翻译说明性文字
- `frame_gen_help`：技术说明，注意专业术语准确
- `remove_runtime_message`：警告文本，语气正式

## smali 硬编码字符串汉化

### 定位方法

1. 运行 `bash scripts/scan-strings.sh` 生成 `UNTRANSLATED_REPORT.md`
2. 在报告中找到要汉化的字符串，查看「所在文件」列
3. 在 `sources/` 中打开对应 smali 文件
4. 搜索原文，找到 `const-string vX, "英文"` 行

### 修改方法

```smali
# 修改前
const-string v0, "Install Linux runtime"

# 修改后
const-string v0, "安装 Linux 运行时"
```

### 注意事项

1. **只改字符串值，不改寄存器**：`const-string v0,` 中的 `v0` 不能改
2. **字符串长度限制**：smali 的 const-string 支持任意长度 UTF-8，不用担心中文变长
3. **不要改 const-string/jumbo**：如果是 `const-string/jumbo`，保持指令类型不变
4. **特殊字符**：中文直接写，不需要转义；双引号需要转义为 `\"`

### 提取修改

```bash
# 编辑完 sources/ 后
bash scripts/extract-patches.sh
git add patches/ state/
git commit -m "feat: 汉化 xxx 界面"
```

## 提交规范

```
feat: 汉化主界面按钮
fix: 修正帧生成说明翻译
chore: 同步上游 0.1.6
```

- `feat`：新增汉化内容
- `fix`：修正已有翻译
- `chore`：同步上游、工具更新等
