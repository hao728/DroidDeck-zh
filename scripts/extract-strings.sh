#!/usr/bin/env bash
# extract-strings.sh — 自动解包上游APK，提取所有可汉化字符，生成翻译报告
# 用法: bash scripts/extract-strings.sh <版本号或APK路径> [输出目录]
# 功能: 全量反编译 → 提取 smali const-string + 资源 strings → 对比已有映射 → 生成未翻译报告

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

INPUT="${1:?用法: extract-strings.sh <版本号或APK路径> [输出目录]}"
OUTPUT_DIR="${2:-reports}"
mkdir -p "$OUTPUT_DIR"

# 解析输入：是版本号还是本地APK路径
if [ -f "$INPUT" ]; then
  APK_FILE="$INPUT"
  VERSION="$(basename "$APK_FILE" .apk)"
else
  VERSION="$INPUT"
  APK_NAME="$(get_apk_name "$VERSION")"
  URL="$(get_apk_url "$VERSION")"
  APK_FILE="${OUTPUT_DIR}/${APK_NAME}"
  info "下载上游 APK: $APK_NAME"
  download "$URL" "$APK_FILE"
fi

WORK_DIR="$(make_workdir "extract-${VERSION}")"
DECODED_DIR="${WORK_DIR}/decoded"

banner "提取可汉化字符: ${VERSION}"

# 1. 全量反编译
step "1/4 全量反编译"
ensure_java
APKTOOL_JAR="$(ensure_apktool)"
run_apktool "$APKTOOL_JAR" d -f "$APK_FILE" -o "$DECODED_DIR"
ok "反编译完成: $(find "$DECODED_DIR" -type f | wc -l) 个文件"

# 2. 提取 smali const-string
step "2/4 提取 smali 硬编码字符串"
SMALI_REPORT="${OUTPUT_DIR}/${VERSION}-smali-strings.txt"
python3 - "$DECODED_DIR" "$SMALI_REPORT" <<'PYEOF'
import os, re, sys

decoded_dir = sys.argv[1]
output_file = sys.argv[2]

# 收集 com/droiddeck 下的所有 const-string
strings = {}  # string -> count
for root, dirs, files in os.walk(decoded_dir):
    if '/com/droiddeck/' not in root:
        continue
    for fn in files:
        if not fn.endswith('.smali'):
            continue
        fpath = os.path.join(root, fn)
        try:
            with open(fpath, 'r', encoding='utf-8', errors='replace') as f:
                for line in f:
                    m = re.search(r'const-string(?:/jumbo)?\s+\w+,\s+"([^"]*)"', line)
                    if m:
                        s = m.group(1)
                        strings[s] = strings.get(s, 0) + 1
        except:
            pass

# 筛选可能是 UI 文本的
def is_ui_text(s):
    if not re.search(r'[A-Za-z]', s):
        return False
    if s.startswith(('http', 'file:', 'content:', '/', '--')):
        return False
    if re.match(r'^[a-z_]+$', s):
        return False
    if re.search(r'\.(so|dll|json|xml|png|jpg|svg|ttf|wav|mp3|cfg|ini|conf|log|dat|bin|acf|zip|tar|gz|xz)$', s):
        return False
    if re.match(r'^[0-9 .,%/:+-]+$', s):
        return False
    if len(s) < 3 or len(s) > 300:
        return False
    if ' ' in s or (s[0].isupper() and len(s) > 3):
        return True
    return False

ui_strings = [(s, c) for s, c in strings.items() if is_ui_text(s)]
ui_strings.sort(key=lambda x: (-x[1], x[0]))

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(f"# {VERSION} smali 可汉化字符串提取报告\n")
    f.write(f"# 总数: {len(ui_strings)} 条（按出现次数排序）\n")
    f.write(f"# 格式: 出现次数\t字符串\n")
    f.write(f"# 生成时间: $(date)\n\n")
    for s, c in ui_strings:
        f.write(f"{c}\t{s}\n")

print(f"  提取 {len(ui_strings)} 条疑似 UI 字符串 → {output_file}")
PYEOF
ok "smali 字符串报告: $SMALI_REPORT"

# 3. 提取资源 strings
step "3/4 提取资源字符串"
RES_REPORT="${OUTPUT_DIR}/${VERSION}-res-strings.txt"
if [ -f "$DECODED_DIR/res/values/strings.xml" ]; then
  python3 - "$DECODED_DIR/res/values/strings.xml" "$DECODED_DIR/res/values-zh-rCN/strings.xml" "$RES_REPORT" <<'PYEOF'
import xml.etree.ElementTree as ET, sys

default_file = sys.argv[1]
zh_file = sys.argv[2]
output_file = sys.argv[3]

default = ET.parse(default_file).getroot()
zh_names = set()
try:
    zh = ET.parse(zh_file).getroot()
    zh_names = {s.get('name') for s in zh.findall('string')}
except:
    pass

missing = []
for s in default.findall('string'):
    name = s.get('name')
    if name not in zh_names:
        missing.append((name, (s.text or '').strip()))

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(f"# 资源 strings.xml 缺失中文翻译: {len(missing)} 条\n\n")
    for name, text in missing:
        f.write(f"{name} = {text}\n")
print(f"  资源缺失翻译: {len(missing)} 条 → {output_file}")
PYEOF
fi

# 4. 对比已有映射，生成未翻译报告
step "4/4 对比已有映射，生成未翻译清单"
MAPPING_FILE="${PATCH_DIR}/smali-strings.txt"
UNTRANSLATED="${OUTPUT_DIR}/${VERSION}-untranslated.txt"
if [ -f "$MAPPING_FILE" ]; then
  python3 - "$SMALI_REPORT" "$MAPPING_FILE" "$UNTRANSLATED" <<'PYEOF'
import sys

smali_report = sys.argv[1]
mapping_file = sys.argv[2]
output_file = sys.argv[3]

# 加载已有映射
mapped = set()
with open(mapping_file, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith('#') and '|||' in line:
            mapped.add(line.split('|||')[0])

# 读取提取的字符串
untranslated = []
with open(smali_report, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split('\t', 1)
        if len(parts) == 2:
            count, s = int(parts[0]), parts[1]
            if s not in mapped:
                untranslated.append((count, s))

untranslated.sort(key=lambda x: (-x[0], x[1]))
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(f"# 未翻译字符串清单: {len(untranslated)} 条\n")
    f.write(f"# 格式: 出现次数\t英文原文（可直接复制到 smali-strings.txt，加 ||| 中文翻译）\n\n")
    for count, s in untranslated:
        f.write(f"{count}\t{s}\n")
print(f"  未翻译: {len(untranslated)} 条 → {output_file}")
PYEOF
else
  warn "未找到映射文件 $MAPPING_FILE，跳过对比"
fi

echo ""
banner "提取完成"
echo -e "  版本:   ${C_GREEN}${VERSION}${C_RESET}"
echo -e "  报告:   ${C_GREEN}${OUTPUT_DIR}/${VERSION}-*.txt${C_RESET}"
echo ""
