#!/usr/bin/env bash
# sync-upstream.sh — 同步上游新版本
# 功能: 检测上游最新版本 → 下载反编译 → 验证diff patch兼容性 → 扫描未汉化字符串 → 更新版本记录

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

banner "同步上游版本"

step "1/5 检测上游最新版本"
LATEST="$(detect_latest_version)"
[ -n "$LATEST" ] || die "无法检测上游最新版本"

CURRENT="$(get_upstream_version)"
info "当前版本: ${CURRENT:-（未记录）}"
info "上游最新: $LATEST"

if [ "$LATEST" = "$CURRENT" ]; then
  ok "已是最新版本，无需同步"
  echo "UP_TO_DATE=true" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true
  exit 0
fi

step "2/5 下载并反编译新版本"
APK_NAME="$(get_apk_name "$LATEST")"
URL="$(get_apk_url "$LATEST")"
APK_FILE="${WORK_DIR}/${APK_NAME}"
info "下载: $APK_NAME"
download "$URL" "$APK_FILE"

APKTOOL_JAR="$(ensure_apktool)"
DECODED_DIR="${WORK_DIR}/decoded"
run_apktool "$APKTOOL_JAR" d -s -f "$APK_FILE" -o "$DECODED_DIR"
ok "新版本反编译完成"

step "3/5 验证 diff patch 兼容性（关键：防止覆盖上游改进）"
DIFFS_DIR="${PATCH_DIR}/diffs"
DIFF_OK=0
DIFF_FAIL=0
DIFF_FILES=""
if [ -d "$DIFFS_DIR" ]; then
  for p in "$DIFFS_DIR"/*.patch; do
    [ -f "$p" ] || continue
    pname=$(basename "$p")
    tgt=$(grep -m1 '^+++ b/' "$p" | sed 's|^+++ b/||')
    if patch -p1 --dry-run -d "$DECODED_DIR" < "$p" >/dev/null 2>&1; then
      ok "  ✓ $pname → $tgt 可干净应用"
      DIFF_OK=$((DIFF_OK + 1))
    else
      warn "  ✗ $pname → $tgt 无法应用！上游已变更，需手动重新生成patch"
      DIFF_FAIL=$((DIFF_FAIL + 1))
      DIFF_FILES="$DIFF_FILES $tgt"
      # 显示冲突详情
      patch -p1 --dry-run -d "$DECODED_DIR" < "$p" 2>&1 | grep -E 'Hunk|FAIL' | head -3
    fi
  done
fi

if [ "$DIFF_FAIL" -gt 0 ]; then
  echo ""
  warn "========================================"
  warn "  ${DIFF_FAIL} 个diff patch无法应用到上游${LATEST}"
  warn "  受影响文件:${DIFF_FILES}"
  warn "  需要手动将汉化修改移植到新版上游文件"
  warn "  然后重新生成diff patch"
  warn "========================================"
  echo "DIFF_COMPATIBLE=false" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true
  echo "DIFF_FAILED_FILES=${DIFF_FILES}" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true
else
  ok "全部 ${DIFF_OK} 个diff patch兼容上游${LATEST}"
  echo "DIFF_COMPATIBLE=true" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true
fi

step "4/5 扫描未汉化字符串（智能过滤内部字符串）"
python3 "${SCRIPTS_DIR}/extract-ui-strings.py" "$DECODED_DIR" "${PATCH_DIR}/smali-strings.txt" || true
ok "扫描完成，未翻译列表见 untranslated-report.txt"

step "5/5 更新版本记录"
set_upstream_version "$LATEST"
echo "UP_TO_DATE=false" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true
echo "NEW_VERSION=$LATEST" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true

echo ""
banner "同步完成"
echo -e "  ${C_YELLOW}${CURRENT:-（无）}${C_RESET} → ${C_GREEN}${LATEST}${C_RESET}"
if [ "$DIFF_FAIL" -gt 0 ]; then
  echo -e "  ${C_RED}⚠ ${DIFF_FAIL}个patch需手动移植${C_RESET}"
fi
echo -e "  请检查 untranslated-report.txt，补全新增字符串后提交"
echo ""
