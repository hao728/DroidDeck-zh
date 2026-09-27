#!/usr/bin/env bash
# sync-upstream.sh — 同步上游新版本
# 功能: 检测上游最新版本 → 对比 → 有新版则下载反编译 → 扫描未汉化字符串 → 更新版本记录

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

banner "同步上游版本"

step "1/4 检测上游最新版本"
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

step "2/4 下载并反编译新版本"
APK_NAME="$(get_apk_name "$LATEST")"
URL="$(get_apk_url "$LATEST")"
APK_FILE="${WORK_DIR}/${APK_NAME}"
info "下载: $APK_NAME"
download "$URL" "$APK_FILE"

APKTOOL_JAR="$(ensure_apktool)"
DECODED_DIR="${WORK_DIR}/decoded"
run_apktool "$APKTOOL_JAR" d -s -f "$APK_FILE" -o "$DECODED_DIR"
ok "新版本反编译完成"

step "3/4 扫描未汉化字符串"
bash "${SCRIPTS_DIR}/scan-strings.sh" "$DECODED_DIR" || true
ok "扫描完成"

step "4/4 更新版本记录"
set_upstream_version "$LATEST"
echo "UP_TO_DATE=false" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true
echo "NEW_VERSION=$LATEST" >> "${GITHUB_OUTPUT:-/dev/null}" 2>/dev/null || true

echo ""
banner "同步完成"
echo -e "  ${C_YELLOW}${CURRENT:-（无）}${C_RESET} → ${C_GREEN}${LATEST}${C_RESET}"
echo -e "  请检查 UNTRANSLATED_REPORT.md，补全新增字符串后提交"
echo ""
