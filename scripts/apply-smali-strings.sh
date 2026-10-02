#!/usr/bin/env bash
# apply-smali-strings.sh — 将 smali 中的硬编码英文字符串替换为中文
# 用法: bash scripts/apply-smali-strings.sh <decoded-dir> <mapping-file>
# 映射文件格式: 每行 "英文|||中文"，# 开头为注释
# 仅替换 const-string / const-string/jumbo 中的字符串，不改变 smali 结构

set -euo pipefail

DECODED_DIR="${1:?用法: apply-smali-strings.sh <decoded-dir> <mapping-file>}"
MAPPING_FILE="${2:?用法: apply-smali-strings.sh <decoded-dir> <mapping-file>}"

[ -d "$DECODED_DIR" ] || { echo "错误: 解码目录不存在: $DECODED_DIR"; exit 1; }
[ -f "$MAPPING_FILE" ] || { echo "错误: 映射文件不存在: $MAPPING_FILE"; exit 1; }

# 统计有效映射行数
TOTAL=$(grep -vE '^\s*(#|$)' "$MAPPING_FILE" | wc -l)
echo "smali 字符串替换: ${TOTAL} 条映射，扫描 ${DECODED_DIR}"

python3 - "$DECODED_DIR" "$MAPPING_FILE" <<'PYEOF'
import os, re, sys

decoded_dir = sys.argv[1]
mapping_file = sys.argv[2]

# 读取映射并预编译正则
mappings = []
with open(mapping_file, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.rstrip('\n')
        if not line.strip() or line.strip().startswith('#'):
            continue
        if '|||' not in line:
            print(f"  警告: 跳过格式错误的行: {line[:60]}")
            continue
        eng, chn = line.split('|||', 1)
        if eng and chn:
            pattern = re.compile(
                r'(const-string(?:/jumbo)?\s+\w+,\s+")' + re.escape(eng) + r'(")'
            )
            mappings.append((eng, chn, pattern))

print(f"  加载 {len(mappings)} 条映射")

# 收集所有 smali 文件
smali_files = []
for root, dirs, files in os.walk(decoded_dir):
    for fn in files:
        if fn.endswith('.smali'):
            smali_files.append(os.path.join(root, fn))

print(f"  扫描 {len(smali_files)} 个 smali 文件（每文件只读一次）")

total_replaced = 0
files_modified = 0
match_counts = {}  # eng -> count

for sf in smali_files:
    try:
        with open(sf, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
    except Exception:
        continue

    changed = False
    for eng, chn, pattern in mappings:
        # 用 lambda 替换，避免 re.sub 将 chn 中的 \n \t 等解释为转义符
        content, n = pattern.subn(lambda m, _chn=chn: m.group(1) + _chn + m.group(2), content)
        if n > 0:
            match_counts[eng] = match_counts.get(eng, 0) + n
            total_replaced += n
            changed = True

    if changed:
        with open(sf, 'w', encoding='utf-8') as f:
            f.write(content)
        files_modified += 1

# 输出每条映射的匹配情况
for eng, chn, _ in mappings:
    cnt = match_counts.get(eng, 0)
    if cnt > 0:
        print(f"  ✓ {eng[:50]} → {chn[:30]} ({cnt}处)")
    else:
        print(f"  - {eng[:50]} (未找到)")

print(f"\n替换完成: 共 {total_replaced} 处，修改 {files_modified} 个文件")
PYEOF

echo "smali 字符串替换完成"
