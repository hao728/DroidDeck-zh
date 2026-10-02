#!/usr/bin/env bash
# regenerate-diffs.sh — 重新生成 diff patch
# 用途: 上游更新后，手动将汉化修改移植到新版上游文件并保存到 patches/，
#       然后运行此脚本对比上游原版与汉化版，生成新的 diff patch。
#
# 使用方法:
#   1. 下载并反编译新版上游APK到某个目录
#   2. 将汉化修改应用到新版文件，保存到 patches/ 对应路径
#   3. 运行: bash scripts/regenerate-diffs.sh <上游反编译目录>
#
# 示例: bash scripts/regenerate-diffs.sh /path/to/upstream/decoded

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

UPSTREAM_DECODED="${1:-}"
if [ -z "$UPSTREAM_DECODED" ] || [ ! -d "$UPSTREAM_DECODED" ]; then
  die "用法: $0 <上游反编译目录>"
fi

DIFFS_DIR="${PATCH_DIR}/diffs"
mkdir -p "$DIFFS_DIR"

banner "重新生成 diff patch"

# 需要生成diff的文件列表（全文件替换型补丁）
DIFF_TARGETS=(
  "assets/linuxfs/usr/local/bin/bannerlator-session"
  "smali_classes2/com/droiddeck/launcher/session/SessionFiles.smali"
)

GENERATED=0
for rel in "${DIFF_TARGETS[@]}"; do
  upstream_file="${UPSTREAM_DECODED}/${rel}"
  patched_file="${PATCH_DIR}/${rel}"
  patch_name=$(echo "$rel" | tr '/' '_')
  patch_file="${DIFFS_DIR}/${patch_name}.patch"

  if [ ! -f "$upstream_file" ]; then
    warn "跳过（上游文件不存在）: $rel"
    continue
  fi
  if [ ! -f "$patched_file" ]; then
    warn "跳过（汉化版文件不存在）: $rel"
    continue
  fi

  # 生成临时目录用于相对路径diff
  tmpdir=$(mktemp -d)
  mkdir -p "$tmpdir/a/$(dirname "$rel")" "$tmpdir/b/$(dirname "$rel")"
  cp "$upstream_file" "$tmpdir/a/$rel"
  cp "$patched_file" "$tmpdir/b/$rel"

  cd "$tmpdir"
  if diff -ruN a b > "$patch_file" 2>/dev/null; then
    warn "无变化: $rel（上游与汉化版相同）"
    rm -f "$patch_file"
  else
    # 标准化路径
    sed -i 's|^--- a/|--- a/|; s|^+++ b/|+++ b/|' "$patch_file"
    mv "$patch_file" "$patch_file" 2>/dev/null || true
    cp "$tmpdir/$(basename "$patch_file")" "$patch_file" 2>/dev/null || true
    # 直接从tmpdir复制
    find "$tmpdir" -name "*.patch" -exec cp {} "$patch_file" \;
    ok "生成: $(basename "$patch_file") ($(grep -c '^[+-]' "$patch_file") 行变更)"
    GENERATED=$((GENERATED + 1))
  fi
  cd - >/dev/null
  rm -rf "$tmpdir"
done

echo ""
if [ "$GENERATED" -gt 0 ]; then
  ok "已生成 ${GENERATED} 个diff patch"
  echo "  请运行 validate-patches.sh 验证兼容性"
else
  warn "未生成任何diff patch"
fi
echo ""
