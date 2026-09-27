#!/usr/bin/env bash
# common.sh — 公共函数库
# 所有脚本 source 此文件获得日志、校验、错误处理能力

set -euo pipefail

# ===== 颜色与日志 =====
if [ -t 1 ]; then
  C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'
  C_BLUE='\033[0;34m'; C_CYAN='\033[0;36m'; C_RESET='\033[0m'
else
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_CYAN=''; C_RESET=''
fi

_log() {
  local level="$1"; shift
  local color="$1"; shift
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "${color}[${ts}] [${level}]${C_RESET} $*" >&2
}
info()  { _log "INFO"  "$C_GREEN"  "$@"; }
warn()  { _log "WARN"  "$C_YELLOW" "$@"; }
error() { _log "ERROR" "$C_RED"    "$@"; }
debug() { [ "${DEBUG:-0}" = "1" ] && _log "DEBUG" "$C_CYAN" "$@" || true; }
die()   { error "$@"; exit 1; }

# ===== 路径解析 =====
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PATCH_DIR="${REPO_ROOT}/patches"
CONFIG_DIR="${REPO_ROOT}/config"
STATE_DIR="${REPO_ROOT}/state"
SCRIPTS_DIR="${REPO_ROOT}/scripts"
TOOLS_DIR="${REPO_ROOT}/.tools"
WORK_DIR="${REPO_ROOT}/.work"
OUTPUT_DIR="${REPO_ROOT}/dist"

mkdir -p "$WORK_DIR" "$TOOLS_DIR" "$OUTPUT_DIR" "$STATE_DIR"

# ===== 配置读取 =====
read_config() {
  local file="$1" key="$2"
  [ -f "$file" ] || die "配置文件不存在: $file"
  python3 -c "
import json, sys
with open('$file') as f:
    data = json.load(f)
keys = '$key'.split('.')
v = data
for k in keys:
    v = v[k]
print(v)
" 2>/dev/null || die "读取配置失败: $file -> $key"
}

# ===== 上游 APK 名称与 URL（统一从 config 读取，支持变体）=====
get_apk_name() {
  # get_apk_name <version> → 输出实际 APK 文件名（含变体后缀）
  local version="$1"
  local variant name_tpl apk_name
  variant="$(read_config "${CONFIG_DIR}/upstream.json" apk_variant)"
  name_tpl="$(read_config "${CONFIG_DIR}/upstream.json" apk_name_template)"
  apk_name="${name_tpl//\{tag\}/$version}"
  apk_name="${apk_name//\{variant\}/$variant}"
  echo "$apk_name"
}

get_apk_url() {
  # get_apk_url <version> → 输出完整下载 URL
  local version="$1"
  local repo url_tpl apk_name url
  repo="$(read_config "${CONFIG_DIR}/upstream.json" repo)"
  url_tpl="$(read_config "${CONFIG_DIR}/upstream.json" download_url_template)"
  apk_name="$(get_apk_name "$version")"
  url="${url_tpl//\{repo\}/$repo}"
  url="${url//\{tag\}/$version}"
  url="${url//\{apk_name\}/$apk_name}"
  echo "$url"
}

detect_latest_version() {
  # 调用 GitHub API 检测最新正式版 tag
  local repo prefix
  repo="$(read_config "${CONFIG_DIR}/upstream.json" repo)"
  prefix="$(read_config "${CONFIG_DIR}/upstream.json" release_tag_prefix)"
  curl -fsSL "https://api.github.com/repos/${repo}/releases?per_page=30" | \
  python3 -c "
import json, sys
releases = json.load(sys.stdin)
prefix = '${prefix}'
for r in releases:
    tag = r.get('tag_name', '')
    if tag.startswith(prefix) and not r.get('prerelease', False):
        for a in r.get('assets', []):
            if a.get('name', '').endswith('.apk'):
                print(tag)
                sys.exit(0)
print('')
"
}

# ===== 校验函数 =====
require_cmd() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "缺少必需命令: $cmd"
  done
}

require_file() { [ -f "$1" ] || die "文件不存在: $1"; }
require_dir()  { [ -d "$1" ] || die "目录不存在: $1"; }

sha256_file() { sha256sum "$1" | awk '{print $1}'; }

verify_sha256() {
  local file="$1" expected="$2" actual
  actual="$(sha256_file "$file")"
  if [ "$actual" != "$expected" ]; then
    die "校验和不匹配: $file\n  expected: $expected\n  actual:   $actual"
  fi
  debug "校验通过: $file ($actual)"
}

# ===== 下载（带重试和校验）=====
download() {
  local url="$1" output="$2" expected="${3:-}"
  local max_retries=5 retry_delay=10
  for i in $(seq 1 $max_retries); do
    info "下载 ($i/$max_retries): $url"
    if curl -fsSL --retry 3 --retry-delay 5 --connect-timeout 30 \
         -o "$output" "$url"; then
      if [ -n "$expected" ]; then verify_sha256 "$output" "$expected"; fi
      info "下载完成: $output ($(stat -c %s "$output") bytes)"
      return 0
    fi
    warn "下载失败，${retry_delay}秒后重试..."
    sleep "$retry_delay"
  done
  die "下载失败（已重试$max_retries次）: $url"
}

# ===== apktool 执行（正确捕获退出码，避免管道吞掉错误）=====
run_apktool() {
  # run_apktool <jar> <args...>
  local jar="$1"; shift
  local tmp_log
  tmp_log="$(mktemp)"
  if ! java -jar "$jar" "$@" >"$tmp_log" 2>&1; then
    echo "----- apktool 输出 -----" >&2
    cat "$tmp_log" >&2
    echo "------------------------" >&2
    rm -f "$tmp_log"
    die "apktool 执行失败"
  fi
  if [ "${DEBUG:-0}" = "1" ]; then cat "$tmp_log"; fi
  rm -f "$tmp_log"
}

# ===== 临时目录管理 =====
make_workdir() {
  local tag="${1:-build}"
  local dir="${WORK_DIR}/${tag}-$$"
  mkdir -p "$dir"
  echo "$dir"
}

cleanup() {
  local exit_code=$?
  if [ "${KEEP_WORK:-0}" = "1" ]; then
    warn "KEEP_WORK=1，保留工作目录: ${WORK_DIR}"
  else
    rm -rf "${WORK_DIR}" 2>/dev/null || true
  fi
  exit $exit_code
}
trap cleanup EXIT INT TERM

# ===== 工具版本管理 =====
ensure_apktool() {
  local version
  version="$(read_config "${CONFIG_DIR}/build.json" apktool.version)"
  mkdir -p "$TOOLS_DIR"
  local jar="${TOOLS_DIR}/apktool-${version}.jar"
  if [ ! -f "$jar" ]; then
    local url hash
    url="$(read_config "${CONFIG_DIR}/build.json" apktool.url_template | sed "s/{VERSION}/$version/g")"
    hash="$(read_config "${CONFIG_DIR}/build.json" "apktool.sha256")"
    download "$url" "$jar" "$hash"
  fi
  echo "$jar"
}

ensure_java() {
  require_cmd java
  local ver
  ver="$(java -version 2>&1 | head -1 | grep -oE '[0-9]+' | head -1)"
  [ "$ver" -ge 11 ] || die "需要 Java 11+，当前: $ver"
  debug "Java 版本: $(java -version 2>&1 | head -1)"
}

ensure_apksigner() {
  if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
    local apksigner
    apksigner="$(find "$ANDROID_HOME/build-tools" -name apksigner -type f 2>/dev/null | head -1)"
    [ -n "$apksigner" ] && { echo "$apksigner"; return 0; }
  fi
  for p in /usr/local/lib/android/sdk /opt/android-sdk /usr/lib/android-sdk "${ANDROID_SDK_ROOT:-}"; do
    [ -n "$p" ] && [ -d "$p" ] || continue
    local apksigner
    apksigner="$(find "$p/build-tools" -name apksigner -type f 2>/dev/null | head -1)"
    [ -n "$apksigner" ] && { echo "$apksigner"; return 0; }
  done
  die "找不到 apksigner，请设置 ANDROID_HOME 或安装 Android SDK build-tools"
}

ensure_zipalign() {
  if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
    local za
    za="$(find "$ANDROID_HOME/build-tools" -name zipalign -type f 2>/dev/null | head -1)"
    [ -n "$za" ] && { echo "$za"; return 0; }
  fi
  for p in /usr/local/lib/android/sdk /opt/android-sdk /usr/lib/android-sdk "${ANDROID_SDK_ROOT:-}"; do
    [ -n "$p" ] && [ -d "$p" ] || continue
    local za
    za="$(find "$p/build-tools" -name zipalign -type f 2>/dev/null | head -1)"
    [ -n "$za" ] && { echo "$za"; return 0; }
  done
  die "找不到 zipalign"
}

# ===== 持久化签名密钥（从 config 读取，不存在则生成）=====
ensure_keystore() {
  # 输出 keystore 绝对路径；若不存在则按 config 生成
  local rel_path alias storepass keypass dname validity keystore
  rel_path="$(read_config "${CONFIG_DIR}/build.json" signing.keystore_path)"
  alias="$(read_config "${CONFIG_DIR}/build.json" signing.alias)"
  storepass="$(read_config "${CONFIG_DIR}/build.json" signing.storepass)"
  keypass="$(read_config "${CONFIG_DIR}/build.json" signing.keypass)"
  dname="$(read_config "${CONFIG_DIR}/build.json" signing.dname)"
  validity="$(read_config "${CONFIG_DIR}/build.json" signing.validity_days)"
  keystore="${REPO_ROOT}/${rel_path}"
  mkdir -p "$(dirname "$keystore")"
  if [ ! -f "$keystore" ]; then
    info "生成签名密钥: $keystore (alias=$alias)"
    keytool -genkeypair -keystore "$keystore" -alias "$alias" \
      -keyalg RSA -keysize 2048 -validity "$validity" \
      -storepass "$storepass" -keypass "$keypass" \
      -dname "$dname" 2>/dev/null || die "生成 keystore 失败"
  fi
  echo "$keystore"
}

# ===== 状态管理 =====
get_upstream_version() { cat "${STATE_DIR}/upstream-version" 2>/dev/null || echo ""; }
set_upstream_version() {
  echo "$1" > "${STATE_DIR}/upstream-version"
  info "更新上游版本记录: $1"
}

# ===== 补丁清单管理 =====
get_patch_manifest() { cat "${STATE_DIR}/patch-manifest.json" 2>/dev/null || echo '{"patches":[]}'; }

# ===== 辅助 =====
banner() {
  echo ""
  echo -e "${C_BLUE}============================================================${C_RESET}"
  echo -e "${C_BLUE}  $*${C_RESET}"
  echo -e "${C_BLUE}============================================================${C_RESET}"
  echo ""
}
step() { echo ""; echo -e "${C_CYAN}▶ $*${C_RESET}"; }
ok()   { echo -e "${C_GREEN}  ✓ $*${C_RESET}"; }
