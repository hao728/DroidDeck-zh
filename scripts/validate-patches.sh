#!/usr/bin/env bash
# validate-patches.sh — 校验补丁有效性
# 功能: 下载指定版本APK → 反编译 → 检查每个补丁文件是否存在 → 检查smali补丁原文匹配

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

VERSION="${1:-$(get_upstream_version)}"
[ -n "$VERSION" ] || die "未指定版本且 state/upstream-version 为空"

banner "校验补丁有效性: ${VERSION}"

step "1/4 下载并反编译"
VALIDATE_DIR="$(make_workdir validate)"
APK_NAME="$(get_apk_name "$VERSION")"
URL="$(get_apk_url "$VERSION")"
APK_FILE="${WORK_DIR}/${APK_NAME}"
download "$URL" "$APK_FILE"
APKTOOL_JAR="$(ensure_apktool)"
run_apktool "$APKTOOL_JAR" d -s -f "$APK_FILE" -o "${VALIDATE_DIR}/decoded"
ok "反编译完成"

step "2/4 检查补丁文件存在性"
MISSING=0
NEW_FILE=0
TOTAL=0
while IFS= read -r -d '' patch_file; do
  TOTAL=$((TOTAL + 1))
  rel="${patch_file#${PATCH_DIR}/}"
  target="${VALIDATE_DIR}/decoded/${rel}"
  if [ ! -f "$target" ]; then
    case "$rel" in
      res/values-*/*)
        echo -e "  ${C_CYAN}+${C_RESET} 新增资源: $rel"
        NEW_FILE=$((NEW_FILE + 1))
        ;;
      assets/*)
        echo -e "  ${C_CYAN}+${C_RESET} 新增覆盖层: $rel"
        NEW_FILE=$((NEW_FILE + 1))
        ;;
      *)
        echo -e "  ${C_RED}✗${C_RESET} 文件不存在: $rel"
        MISSING=$((MISSING + 1))
        ;;
    esac
  else
    debug "✓ 文件存在: $rel"
  fi
done < <(find "$PATCH_DIR" -type f -print0)

if [ "$MISSING" -gt 0 ]; then
  error "${MISSING}/${TOTAL} 个补丁文件在反编译结果中不存在"
  error "上游可能重构了代码结构，需要更新补丁"
  exit 1
fi
ok "全部 ${TOTAL} 个补丁有效（${NEW_FILE} 个新增资源，$((TOTAL - NEW_FILE)) 个修改文件）"

step "3/4 检查 smali 补丁原文匹配"
SMALI_CHECK=0
SMALI_FAIL=0
while IFS= read -r -d '' patch_file; do
  rel="${patch_file#${PATCH_DIR}/}"
  case "$rel" in
    smali*/*.smali)
      SMALI_CHECK=$((SMALI_CHECK + 1))
      target="${VALIDATE_DIR}/decoded/${rel}"
      while IFS= read -r s; do
        [ -n "$s" ] || continue
        if ! grep -qF "$s" "$target" 2>/dev/null; then
          echo -e "  ${C_YELLOW}⚠${C_RESET} 原文不匹配: $rel → \"$s\""
          SMALI_FAIL=$((SMALI_FAIL + 1))
        fi
      done < <(grep -oE 'const-string[^"]*"[^"]*"' "$patch_file" 2>/dev/null | grep -oE '"[^"]*"' | sed 's/^"//;s/"$//')
      ;;
  esac
done < <(find "$PATCH_DIR" -type f -print0)

if [ "$SMALI_FAIL" -gt 0 ]; then
  warn "${SMALI_FAIL} 处 smali 字符串不匹配（上游可能修改了原文）"
else
  ok "smali 补丁原文全部匹配（检查了 ${SMALI_CHECK} 个文件）"
fi

step "4/5 验证 diff patch 能否干净应用"
DIFF_CHECK=0
DIFF_FAIL=0
DIFFS_DIR="${PATCH_DIR}/diffs"
if [ -d "$DIFFS_DIR" ]; then
  for p in "$DIFFS_DIR"/*.patch; do
    [ -f "$p" ] || continue
    DIFF_CHECK=$((DIFF_CHECK + 1))
    pname=$(basename "$p")
    if patch -p1 --dry-run -d "${VALIDATE_DIR}/decoded" < "$p" >/dev/null 2>&1; then
      debug "✓ diff patch 可干净应用: $pname"
    else
      echo -e "  ${C_RED}✗${C_RESET} diff patch 无法应用（上游已变更，需重新生成）: $pname"
      patch -p1 --dry-run -d "${VALIDATE_DIR}/decoded" < "$p" 2>&1 | grep -E 'Hunk|FAIL|error' | head -3
      DIFF_FAIL=$((DIFF_FAIL + 1))
    fi
  done
fi
if [ "$DIFF_FAIL" -gt 0 ]; then
  error "${DIFF_FAIL}/${DIFF_CHECK} 个diff patch无法应用，上游代码结构已变更"
else
  ok "全部 ${DIFF_CHECK} 个diff patch可干净应用到上游${VERSION}"
fi

step "5/5 总结"
if [ "$MISSING" -eq 0 ] && [ "$SMALI_FAIL" -eq 0 ] && [ "$DIFF_FAIL" -eq 0 ]; then
  echo ""
  echo -e "  ${C_GREEN}✓ 所有补丁有效，可以安全构建${C_RESET}"
  echo ""
  exit 0
else
  echo ""
  echo -e "  ${C_YELLOW}⚠ 存在 ${MISSING} 个缺失文件 + ${SMALI_FAIL} 处不匹配字符串 + ${DIFF_FAIL} 个失败patch${C_RESET}"
  echo -e "  建议先修复补丁再构建"
  echo ""
  exit 2
fi
