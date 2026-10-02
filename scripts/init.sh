#!/usr/bin/env bash
# init.sh — 一键生成可编辑源码
# 用法: bash scripts/init.sh [版本号]
# 功能: 下载上游APK → 完整反编译 → 生成sources/ → 初始化patches/ → 扫描未汉化字符串

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

VERSION="${1:-}"

banner "DroidDeck 汉化仓库初始化"

# ===== 1. 检测版本 =====
step "1/6 检测上游版本"
if [ -z "$VERSION" ]; then
  info "查询上游 releases"
  VERSION="$(detect_latest_version)"
  [ -n "$VERSION" ] || die "无法检测上游最新版本，请手动指定: bash scripts/init.sh DroidDeck-0.1.7"
else
  info "使用指定版本: $VERSION"
fi
ok "版本: $VERSION"

# ===== 2. 下载 APK =====
step "2/6 下载上游 APK"
APK_NAME="$(get_apk_name "$VERSION")"
URL="$(get_apk_url "$VERSION")"
APK_FILE="${WORK_DIR}/${APK_NAME}"
info "文件名: $APK_NAME"
download "$URL" "$APK_FILE"
ok "APK: $(stat -c %s "$APK_FILE") bytes"

# ===== 3. 反编译（完整反编译，因为 init 要生成可编辑的 sources/）=====
step "3/6 反编译 APK"
ensure_java
APKTOOL_JAR="$(ensure_apktool)"
SOURCES_DIR="${REPO_ROOT}/sources"
if [ -d "$SOURCES_DIR" ]; then
  warn "sources/ 已存在，将删除后重新生成"
  rm -rf "$SOURCES_DIR"
fi
info "运行 apktool d (完整反编译)"
run_apktool "$APKTOOL_JAR" d -f "$APK_FILE" -o "$SOURCES_DIR"
[ -d "$SOURCES_DIR" ] || die "反编译失败: sources/ 目录不存在"
[ -f "$SOURCES_DIR/AndroidManifest.xml" ] || die "反编译失败: AndroidManifest.xml 不存在"
ok "反编译完成: $(find "$SOURCES_DIR" -type f | wc -l) 个文件"

# ===== 4. 初始化 patches/ =====
step "4/6 初始化汉化补丁目录"
if [ -d "$SOURCES_DIR/res/values-zh-rCN" ]; then
  mkdir -p "$PATCH_DIR/res/values-zh-rCN"
  for f in "$SOURCES_DIR"/res/values-zh-rCN/*.xml; do
    fname="$(basename "$f")"
    if [ ! -f "$PATCH_DIR/res/values-zh-rCN/$fname" ]; then
      cp "$f" "$PATCH_DIR/res/values-zh-rCN/$fname"
      info "初始化: patches/res/values-zh-rCN/$fname"
    fi
  done
fi
ok "patches/ 就绪"

# ===== 5. 扫描未汉化字符串 =====
step "5/6 扫描未汉化字符串"
bash "${SCRIPTS_DIR}/scan-strings.sh" "$SOURCES_DIR" || true
ok "扫描完成"

# ===== 6. 更新状态 =====
step "6/6 更新状态文件"
set_upstream_version "$VERSION"

python3 - "$PATCH_DIR" "${STATE_DIR}/patch-manifest.json" <<'PY'
import os, json, hashlib, sys
patch_dir, manifest_path = sys.argv[1], sys.argv[2]
patches = []
for root, dirs, files in os.walk(patch_dir):
    for f in files:
        full = os.path.join(root, f)
        rel = os.path.relpath(full, patch_dir)
        with open(full, 'rb') as fh:
            h = hashlib.sha256(fh.read()).hexdigest()
        patches.append({"path": rel, "sha256": h})
with open(manifest_path, 'w') as fh:
    json.dump({"version": 1, "count": len(patches), "patches": patches}, fh, indent=2, ensure_ascii=False)
print(f"  记录 {len(patches)} 个补丁文件")
PY

echo ""
banner "初始化完成"
echo -e "  版本:     ${C_GREEN}${VERSION}${C_RESET}"
echo -e "  源码:     ${C_GREEN}sources/${C_RESET} (可直接编辑)"
echo -e "  补丁:     ${C_GREEN}patches/${C_RESET} (提交到git)"
echo -e "  报告:     ${C_GREEN}UNTRANSLATED_REPORT.md${C_RESET}"
echo ""
echo -e "  下一步:"
echo -e "    1. 编辑 sources/ 中的文件进行汉化"
echo -e "    2. 运行 ${C_CYAN}bash scripts/extract-patches.sh${C_RESET} 将修改提取到 patches/"
echo -e "    3. 运行 ${C_CYAN}bash scripts/build.sh${C_RESET} 构建汉化APK"
echo -e "    4. 提交 patches/ 到 git"
echo ""
