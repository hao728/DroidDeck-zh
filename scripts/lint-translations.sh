#!/usr/bin/env bash
# lint-translations.sh — 校验汉化映射和构建产物，检测错译/多译导致的运行异常
# 用法: bash scripts/lint-translations.sh [构建好的APK路径]
# 功能: ①校验 smali-strings.txt 映射质量 ②校验资源XML ③（可选）校验APK有效性

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

APK_PATH="${1:-}"
ERRORS=0
WARNINGS=0

banner "汉化质量校验"

# ===== 1. smali-strings.txt 映射校验 =====
step "1/4 校验 smali 字符串映射"
MAPPING_FILE="${PATCH_DIR}/smali-strings.txt"

if [ ! -f "$MAPPING_FILE" ]; then
  warn "未找到 $MAPPING_FILE"
else
  python3 - "$MAPPING_FILE" <<'PYEOF'
import sys, re

mapping_file = sys.argv[1]
errors = 0
warnings = 0
seen_eng = {}

with open(mapping_file, 'r', encoding='utf-8') as f:
    for lineno, line in enumerate(f, 1):
        raw = line.rstrip('\n')
        if not raw.strip() or raw.strip().startswith('#'):
            continue
        if '|||' not in raw:
            print(f"  ✗ 行{lineno}: 缺少 ||| 分隔符")
            errors += 1
            continue
        eng, chn = raw.split('|||', 1)

        # 检查空翻译
        if not chn.strip():
            print(f"  ✗ 行{lineno}: 中文翻译为空: '{eng[:40]}'")
            errors += 1

        # 检查 ASCII 双引号（会破坏 smali 语法）
        if '"' in chn:
            print(f"  ✗ 行{lineno}: 中文翻译含 ASCII 双引号（会导致 smali 语法错误）: '{chn[:40]}'")
            errors += 1

        # 检查格式符一致性
        eng_fmt = set(re.findall(r'%(?:\d+\$)?[sdifgxXeEfg%]', eng))
        chn_fmt = set(re.findall(r'%(?:\d+\$)?[sdifgxXeEfg%]', chn))
        if eng_fmt != chn_fmt:
            print(f"  ⚠ 行{lineno}: 格式符不一致 英文{eng_fmt} → 中文{chn_fmt}: '{eng[:30]}'")
            warnings += 1

        # 检查转义符一致性（\n \t \uXXXX）
        eng_esc = set(re.findall(r'\\[ntr]', eng))
        chn_esc = set(re.findall(r'\\[ntr]', chn))
        if eng_esc != chn_esc:
            print(f"  ⚠ 行{lineno}: 转义符不一致 英文{eng_esc} → 中文{chn_esc}: '{eng[:30]}'")
            warnings += 1

        # 重复映射
        if eng in seen_eng:
            print(f"  ⚠ 行{lineno}: 重复映射（首次出现于行{seen_eng[eng]}）: '{eng[:40]}'")
            warnings += 1
        else:
            seen_eng[eng] = lineno

        # 尾随空格一致性
        if eng.endswith(' ') != chn.endswith(' '):
            print(f"  ⚠ 行{lineno}: 尾随空格不一致: '{eng[-10:]}' vs '{chn[-10:]}'")
            warnings += 1

print(f"  映射校验: {errors} 错误, {warnings} 警告")
sys.exit(1 if errors > 0 else 0)
PYEOF
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS + 1))
  fi
fi

# ===== 2. 资源 XML 校验 =====
step "2/4 校验资源 XML"
for xml_file in "$PATCH_DIR"/res/values-zh-rCN/*.xml; do
  [ -f "$xml_file" ] || continue
  if python3 -c "import xml.etree.ElementTree as ET; ET.parse('$xml_file')" 2>/dev/null; then
    ok "$(basename "$xml_file"): XML 格式有效"
  else
    echo "  ✗ $(basename "$xml_file"): XML 格式错误"
    ERRORS=$((ERRORS + 1))
  fi
done

# ===== 3. 构建后 APK 校验（如果提供了APK路径）=====
if [ -n "$APK_PATH" ] && [ -f "$APK_PATH" ]; then
  step "3/4 校验 APK 有效性"

  # 检查是否是有效 ZIP/APK
  if python3 -c "
import zipfile, sys
z = zipfile.ZipFile('$APK_PATH')
required = ['AndroidManifest.xml', 'resources.arsc', 'classes.dex']
missing = [f for f in required if f not in z.namelist()]
if missing:
    print(f'  ✗ 缺少必需文件: {missing}')
    sys.exit(1)
print(f'  ✓ 有效 APK（{len(z.namelist())} 个条目）')
"; then
    :
  else
    ERRORS=$((ERRORS + 1))
  fi

  # 签名验证
  APKSIGNER="$(ensure_apksigner 2>/dev/null || true)"
  if [ -n "$APKSIGNER" ]; then
    if "$APKSIGNER" verify --print-certs "$APK_PATH" >/dev/null 2>&1; then
      ok "APK 签名验证通过"
    else
      echo "  ✗ APK 签名验证失败"
      ERRORS=$((ERRORS + 1))
    fi
  fi

  # 检查中文字符串是否在 dex 中
  step "4/4 校验中文汉化是否编译进 dex"
  python3 - "$APK_PATH" <<'PYEOF'
import zipfile, sys

apk = sys.argv[1]
z = zipfile.ZipFile(apk)
keywords = ['会话', '帧生成', '停止会话', '自定义分辨率', '显示驱动', '运行时', '恢复']
found = 0
total = len(keywords)
for dex_name in ['classes.dex', 'classes2.dex']:
    if dex_name in z.namelist():
        data = z.read(dex_name)
        for kw in keywords:
            if kw.encode('utf-8') in data:
                found += 1
                keywords.remove(kw)
print(f"  dex 中文字符串: {found}/{total} 关键词命中")
if found < total // 2:
    print("  ✗ 中文字符串覆盖率过低，可能 smali 替换未生效")
    sys.exit(1)
print("  ✓ 中文汉化已编译进 dex")
PYEOF
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS + 1))
  fi
else
  step "3/4 校验 APK（跳过：未提供APK路径）"
  step "4/4 dex 中文校验（跳过）"
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${C_RED}校验失败: ${ERRORS} 个错误${C_RESET}"
  exit 1
else
  echo -e "${C_GREEN}校验通过${C_RESET}（警告: ${WARNINGS}）"
fi
