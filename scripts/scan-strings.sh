#!/usr/bin/env bash
# scan-strings.sh — 扫描未汉化的硬编码字符串
# 用法: bash scripts/scan-strings.sh [反编译目录]
# 功能: 扫描 smali 中的 const-string，过滤技术字符串，生成未汉化报告

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

DECODED_DIR="${1:-${REPO_ROOT}/sources}"
[ -d "$DECODED_DIR" ] || die "目录不存在: $DECODED_DIR"

REPORT="${REPO_ROOT}/UNTRANSLATED_REPORT.md"
IGNORE_FILE="${CONFIG_DIR}/ignore-patterns.txt"

banner "扫描未汉化字符串"

step "1/3 提取所有 smali const-string"
SMALI_DIRS=$(find "$DECODED_DIR" -maxdepth 1 -name 'smali*' -type d)
[ -n "$SMALI_DIRS" ] || { warn "未找到 smali 目录（可能使用了 --no-src 反编译）"; exit 0; }

TMP_ALL="${WORK_DIR}/all_strings.txt"
TMP_FILTERED="${WORK_DIR}/filtered_strings.txt"
> "$TMP_ALL"

for dir in $SMALI_DIRS; do
  # 扫描应用自身包 com/droiddeck（修正：原脚本错误地扫描 com/steamdeck）
  find "$dir" -path '*/com/droiddeck/*' -name '*.smali' -type f 2>/dev/null | \
    while IFS= read -r smali_file; do
      rel="${smali_file#${DECODED_DIR}/}"
      grep -n 'const-string' "$smali_file" 2>/dev/null | \
        grep -oE '"[^"]*"' 2>/dev/null | sed 's/^"//;s/"$//' | \
        while IFS= read -r s; do
          [ -n "$s" ] || continue
          echo -e "${rel}\t${s}" >> "$TMP_ALL"
        done || true
    done || true
done

TOTAL=$(wc -l < "$TMP_ALL")
info "提取到 ${TOTAL} 条字符串引用"

step "2/3 过滤技术字符串"
cut -f2 "$TMP_ALL" | sort -u > "${WORK_DIR}/unique_strings.txt"

CLEAN_IGNORE="${WORK_DIR}/ignore-clean.txt"
grep -vE '^\s*$|^\s*#' "$IGNORE_FILE" > "$CLEAN_IGNORE" || true

grep -vE -f "$CLEAN_IGNORE" "${WORK_DIR}/unique_strings.txt" > "$TMP_FILTERED" || true

grep -E '[A-Za-z]' "$TMP_FILTERED" | \
  grep -vE '^[0-9]+$' | \
  grep -vE '^[[:punct:][:space:]]+$' | \
  awk 'length($0) > 2' > "${WORK_DIR}/ui_strings.txt" || true

UI_COUNT=$(wc -l < "${WORK_DIR}/ui_strings.txt")
ok "过滤后剩余 ${UI_COUNT} 条疑似 UI 文本（原始 ${TOTAL} 条引用，去重后 $(wc -l < "${WORK_DIR}/unique_strings.txt") 条）"

step "3/3 生成报告"
{
  echo "# 未汉化字符串报告"
  echo ""
  echo "> 自动生成于 $(date '+%Y-%m-%d %H:%M:%S')"
  echo "> 反编译目录: ${DECODED_DIR}"
  echo "> 疑似 UI 文本: ${UI_COUNT} 条"
  echo ""
  echo "## 使用方法"
  echo ""
  echo "1. 在下表中找到要汉化的字符串"
  echo "2. 查看「所在文件」列，在 sources/ 中打开对应 smali 文件"
  echo "3. 搜索原文，将 \`const-string vX, \"英文\"\` 改为 \`const-string vX, \"中文\"\`"
  echo "4. 运行 \`bash scripts/extract-patches.sh\` 提取修改到 patches/"
  echo ""
  echo "## 字符串清单"
  echo ""
  echo "| # | 原文 | 所在文件 |"
  echo "|---|------|----------|"

  idx=0
  MAX_REPORT=300
  while IFS= read -r s; do
    idx=$((idx + 1))
    if [ "$idx" -gt "$MAX_REPORT" ]; then
      echo "| ... | (共 ${UI_COUNT} 条，仅显示前 ${MAX_REPORT} 条) | |"
      break
    fi
    loc=$(grep -m1 -F "$s" "$TMP_ALL" 2>/dev/null | cut -f1 || echo "unknown")
    s_escaped=$(echo "$s" | sed 's/|/\\|/g')
    echo "| ${idx} | \`${s_escaped}\` | \`${loc}\` |"
  done < "${WORK_DIR}/ui_strings.txt"

  echo ""
  echo "---"
  echo "*报告由 scripts/scan-strings.sh 自动生成*"
} > "$REPORT"

ok "报告已生成: $REPORT"
echo ""
echo -e "  共 ${C_GREEN}${UI_COUNT}${C_RESET} 条疑似 UI 文本待汉化"
echo -e "  详见: ${C_CYAN}${REPORT}${C_RESET}"
echo ""
