#!/usr/bin/env bash
# extract-patches.sh — 从 sources/ 提取修改到 patches/
# 用法: bash scripts/extract-patches.sh
# 功能: 对比 sources/ 和干净反编译结果，把修改过的文件复制到 patches/
# 修改原因: 用户在 sources/ 里编辑后，需要一键提取到 patches/ 提交到git
# 影响范围: 更新 patches/ 目录
# 回滚方法: git checkout patches/ 即可恢复

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

SOURCES_DIR="${REPO_ROOT}/sources"
[ -d "$SOURCES_DIR" ] || die "sources/ 不存在，请先运行 init.sh"

VERSION="$(get_upstream_version)"
[ -n "$VERSION" ] || die "state/upstream-version 为空，请先运行 init.sh"

banner "提取汉化补丁"

step "1/4 生成干净反编译基准"
CLEAN_DIR="$(make_workdir clean)"
APK_NAME="$(get_apk_name "$VERSION")"
APK_FILE="${WORK_DIR}/${APK_NAME}"
if [ ! -f "$APK_FILE" ]; then
  URL="$(get_apk_url "$VERSION")"
  download "$URL" "$APK_FILE"
fi
APKTOOL_JAR="$(ensure_apktool)"
run_apktool "$APKTOOL_JAR" d -f "$APK_FILE" -o "$CLEAN_DIR"
ok "干净基准生成完成"

step "2/4 对比文件差异"
CHANGED=0
while IFS= read -r -d '' file; do
  rel="${file#${SOURCES_DIR}/}"
  clean_file="${CLEAN_DIR}/${rel}"
  # 跳过不存在于干净版本的文件（新增文件）
  if [ ! -f "$clean_file" ]; then
    debug "新增文件: $rel"
  elif ! diff -q "$clean_file" "$file" >/dev/null 2>&1; then
    debug "修改文件: $rel"
  else
    continue
  fi

  # 复制到 patches/
  target="${PATCH_DIR}/${rel}"
  mkdir -p "$(dirname "$target")"
  cp "$file" "$target"
  CHANGED=$((CHANGED + 1))
  echo -e "  ${C_GREEN}+${C_RESET} $rel"
done < <(find "$SOURCES_DIR" -type f -print0)

step "3/4 更新 patch-manifest.json"
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
PY

step "4/4 完成"
ok "提取了 ${CHANGED} 个修改/新增文件到 patches/"
echo ""
echo -e "  下一步: ${C_CYAN}git add patches/ state/ && git commit${C_RESET}"
echo ""
