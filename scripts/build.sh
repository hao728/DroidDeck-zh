#!/usr/bin/env bash
# build.sh — 构建汉化APK
# 用法: bash scripts/build.sh [版本号]
# 功能: 下载上游APK → 反编译(仅资源) → 应用汉化补丁 → 回编译 → 对齐 → 自签名 → 输出 dist/

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

VERSION="${1:-$(get_upstream_version)}"
[ -n "$VERSION" ] || die "未指定版本且 state/upstream-version 为空，请先运行 init.sh"

banner "构建汉化 APK: ${VERSION}"

# ===== 1. 准备工作目录 =====
step "1/7 准备工作目录"
BUILD_DIR="$(make_workdir build)"
DECODED_DIR="${BUILD_DIR}/decoded"
mkdir -p "$OUTPUT_DIR"
ok "工作目录: $BUILD_DIR"

# ===== 2. 下载上游 APK（使用 config 中的变体模板，不再硬编码）=====
step "2/7 下载上游 APK"
APK_NAME="$(get_apk_name "$VERSION")"
URL="$(get_apk_url "$VERSION")"
APK_FILE="${BUILD_DIR}/${APK_NAME}"
info "文件名: $APK_NAME"
download "$URL" "$APK_FILE"
ok "APK 下载完成 ($(stat -c %s "$APK_FILE") bytes)"

# ===== 3. 反编译（仅资源，不解码 dex/smali，更快更稳）=====
step "3/7 反编译 APK（--no-src）"
ensure_java
APKTOOL_JAR="$(ensure_apktool)"
run_apktool "$APKTOOL_JAR" d -s -f "$APK_FILE" -o "$DECODED_DIR"
[ -f "$DECODED_DIR/AndroidManifest.xml" ] || die "反编译失败: 缺少 AndroidManifest.xml"
ok "反编译完成: $(find "$DECODED_DIR" -type f | wc -l) 个文件"

# ===== 4. 应用补丁 =====
step "4/7 应用汉化补丁"
PATCH_COUNT=0
PATCH_FAIL=0
while IFS= read -r -d '' patch_file; do
  rel_path="${patch_file#${PATCH_DIR}/}"
  target="${DECODED_DIR}/${rel_path}"
  if [ ! -f "$target" ]; then
    # values-zh-rCN 等本地化目录在上游不存在时属于新增，视为正常
    case "$rel_path" in
      res/values-*/*)
        info "新增本地化资源: $rel_path"
        mkdir -p "$(dirname "$target")"
        cp "$patch_file" "$target"
        PATCH_COUNT=$((PATCH_COUNT + 1))
        ;;
      *)
        warn "补丁目标不存在（上游可能已变更）: $rel_path"
        PATCH_FAIL=$((PATCH_FAIL + 1))
        ;;
    esac
    continue
  fi
  cp "$patch_file" "$target"
  PATCH_COUNT=$((PATCH_COUNT + 1))
  debug "应用补丁: $rel_path"
done < <(find "$PATCH_DIR" -type f -print0)

if [ "$PATCH_FAIL" -gt 0 ]; then
  die "${PATCH_FAIL} 个补丁文件无法应用，请运行 validate-patches.sh 检查"
fi
ok "已应用 ${PATCH_COUNT} 个补丁文件"

# ===== 5. 回编译 =====
step "5/7 回编译 APK"
UNSIGNED_APK="${BUILD_DIR}/dist-unsigned.apk"
run_apktool "$APKTOOL_JAR" b "$DECODED_DIR" -o "$UNSIGNED_APK"
[ -f "$UNSIGNED_APK" ] || die "回编译失败: 未生成 APK"
ok "回编译完成: $(stat -c %s "$UNSIGNED_APK") bytes"

# ===== 6. 对齐 + 签名（使用持久化密钥，签名跨构建一致）=====
step "6/7 对齐并签名"
ZIPALIGN="$(ensure_zipalign)"
ALIGNED_APK="${BUILD_DIR}/dist-aligned.apk"
"$ZIPALIGN" -f 4 "$UNSIGNED_APK" "$ALIGNED_APK"
ok "zipalign 完成"

KEYSTORE="$(ensure_keystore)"
KS_ALIAS="$(read_config "${CONFIG_DIR}/build.json" signing.alias)"
KS_STOREPASS="$(read_config "${CONFIG_DIR}/build.json" signing.storepass)"
KS_KEYPASS="$(read_config "${CONFIG_DIR}/build.json" signing.keypass)"

APKSIGNER="$(ensure_apksigner)"
OUTPUT_NAME="$(read_config "${CONFIG_DIR}/build.json" output.name_template | sed "s/{version}/$VERSION/")"
OUTPUT_APK="${OUTPUT_DIR}/${OUTPUT_NAME}"

"$APKSIGNER" sign \
  --ks "$KEYSTORE" \
  --ks-key-alias "$KS_ALIAS" \
  --ks-pass "pass:$KS_STOREPASS" \
  --key-pass "pass:$KS_KEYPASS" \
  --out "$OUTPUT_APK" \
  "$ALIGNED_APK"
ok "签名完成（密钥: $KEYSTORE）"

# ===== 7. 验证 =====
step "7/7 验证输出"
"$APKSIGNER" verify --print-certs "$OUTPUT_APK" >/dev/null 2>&1 || die "签名验证失败"
ok "签名验证通过"
ok "输出: $OUTPUT_APK ($(stat -c %s "$OUTPUT_APK") bytes)"

echo ""
banner "构建成功"
echo -e "  版本:   ${C_GREEN}${VERSION}${C_RESET}"
echo -e "  输出:   ${C_GREEN}${OUTPUT_APK}${C_RESET}"
echo -e "  补丁:   ${C_GREEN}${PATCH_COUNT} 个文件${C_RESET}"
echo -e "  签名:   ${C_GREEN}持久化密钥（可覆盖安装）${C_RESET}"
echo ""
