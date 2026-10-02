#!/usr/bin/env python3
"""
extract-ui-strings.py — 智能提取 smali 中的用户可见 UI 字符串
用法: python3 extract-ui-strings.py <decoded-dir> [mapping-file]
输出: 按模块分类的 UI 字符串列表，标记已翻译/未翻译
过滤: checkNotNullParameter参数名、Compose key、日志tag、文件路径、URL、技术标识符
"""
import sys
import os
import re
import glob
import json
from collections import defaultdict

# 内部字符串模式（无翻译价值）
INTERNAL_PATTERNS = [
    r'^\$this\$',           # Compose 参数名
    r'^\$destruct\$',       # 解构参数
    r'^com\.',              # 包名
    r'^android',            # Android 标识符
    r'^androidx',
    r'^kotlin',
    r'^java\.',
    r'^Lcom/',              # smali 类型
    r'^Landroid',
    r'^[A-Z][a-z]+Kt$',     # Kotlin 文件类名
    r'^[A-Z].*Kt\$',        # 内部类名
    r'^CC\(',               # Compose 编译器生成
    r'^C\d+@',              # Compose 编译器生成
    r'^\d+$',               # 纯数字
    r'^[a-z]+$',            # 全小写单词（通常是 key/tag，需人工判断）
    r'^[A-Z_]+$',           # 全大写下划线（常量名）
    r'^https?://',          # URL
    r'^/',                  # 文件路径
    r'^\.',                 # 隐藏文件/相对路径
    r'^[a-z]+_[a-z_]+$',    # snake_case（通常是 key）
    r'^[a-z]+\.[a-z]+',     # 点分隔标识符
    r'^%[0-9]*\$?[sdxf]',   # 纯格式符
    r'^\\u[0-9a-fA-F]{4}$', # 单个 unicode 转义
    r'^[vV]\d+$',           # 版本号
    r'^[0-9]+x[0-9]+$',     # 分辨率
    r'^[0-9]+ ?(MB|KB|GB|Hz|ms|s)$', # 单位
]

# 有翻译价值的短词白名单（虽然短但是 UI 文本）
UI_SHORT_WORDS = {
    'on', 'off', 'ok', 'yes', 'no', 'cancel', 'confirm', 'save', 'delete',
    'edit', 'add', 'remove', 'close', 'open', 'back', 'next', 'done',
    'skip', 'retry', 'refresh', 'settings', 'menu', 'search', 'more',
    'help', 'about', 'exit', 'quit', 'stop', 'start', 'pause', 'resume',
    'restart', 'install', 'update', 'download', 'upload', 'share',
    'copy', 'paste', 'cut', 'undo', 'redo', 'select', 'all', 'none',
    'auto', 'manual', 'default', 'custom', 'always', 'never',
    'low', 'medium', 'high', 'ultra', 'fast', 'slow',
    'left', 'right', 'up', 'down', 'center',
    'portrait', 'landscape', 'fullscreen',
    'enabled', 'disabled', 'active', 'inactive',
    'connected', 'disconnected', 'loading', 'ready', 'failed',
    'games', 'desktop', 'session', 'library', 'drivers', 'audio',
    'display', 'touch', 'keyboard', 'mouse', 'gamepad',
    'performance', 'storage', 'network', 'theme', 'language',
    'terminal', 'advanced', 'general', 'security', 'privacy',
    'play', 'record', 'mute', 'volume', 'brightness',
    'width', 'height', 'resolution', 'renderer',
    'client', 'server', 'host', 'guest', 'user', 'admin',
    'local', 'remote', 'cloud', 'online', 'offline',
    'new', 'old', 'stable', 'beta', 'preview',
    'setup', 'manage', 'choose', 'browse', 'apply',
    'reset', 'restore', 'backup', 'export', 'import',
    'clean', 'cache', 'data', 'files', 'folder',
    'steam', 'wine', 'proton', 'dxvk', 'vkd3d',
    'touchpad', 'trackpad', 'controller', 'microphone',
    'classic', 'direct', 'shape', 'channel',
    'level', 'score', 'event', 'daily', 'weekly',
    'reward', 'achievement', 'mission', 'quest',
    'submit', 'discard', 'rename', 'move', 'duplicate',
    'archive', 'star', 'pin', 'lock', 'unlock',
    'encrypt', 'decrypt', 'compress', 'extract',
    'mount', 'unmount', 'eject', 'format',
    'hibernate', 'sleep', 'wake', 'shutdown', 'logout',
    'screenshot', 'print', 'cast',
    'forward', 'home', 'reload', 'navigate',
    'find', 'replace', 'deselect',
    'protect', 'revoke', 'grant', 'deny', 'allow',
    'accept', 'reject', 'approve', 'block',
    'schedule', 'pending', 'processing', 'completed',
    'expired', 'valid', 'invalid', 'cancelled',
    'draft', 'deleted', 'away', 'busy', 'idle',
    'available', 'unavailable', 'mobile', 'web',
    'dark', 'light', 'system', 'wallpaper',
    'background', 'foreground', 'widget', 'component',
    'slider', 'switch', 'toggle', 'checkbox', 'radio',
    'dropdown', 'picker', 'input', 'field',
    'toolbar', 'drawer', 'sidebar', 'tooltip',
    'hint', 'placeholder', 'label', 'caption',
    'subtitle', 'title', 'header', 'footer',
    'progress', 'empty', 'error', 'warning', 'info',
    'sync', 'role', 'permission', 'access',
    'send', 'receive', 'author', 'developer',
    'publisher', 'version', 'release', 'build',
    'source', 'license', 'copyright',
    'font', 'layout', 'color', 'shadow',
    'opacity', 'gradient', 'border', 'margin',
    'padding', 'spacing', 'alignment',
    'encoding', 'localization', 'translation',
    'bootloader', 'recovery', 'partition',
    'firmware', 'baseband', 'kernel',
    'selinux', 'root', 'oem', 'vendor',
    'product', 'system', 'metadata', 'misc',
    'persist', 'enforcing', 'permissive',
    'balance', 'quality', 'speed', 'power',
    'battery', 'charging', 'ram', 'rom',
    'buffer', 'swap', 'virtual',
    'architecture', 'instruction',
    'rotation', 'orientation', 'scale', 'zoom',
    'sensitivity', 'deadzone', 'vibration',
    'gyro', 'gesture', 'swipe', 'tap',
    'double tap', 'long press', 'drag', 'scroll',
    'cursor', 'pointer', 'stylus', 'pen',
    'handwriting', 'pressure', 'force',
    'key mapping', 'key bind', 'combo', 'macro',
    'profile', 'preset', 'template', 'scheme',
    'mode', 'type', 'category', 'filter', 'sort',
    'favorite', 'recent', 'trending', 'recommended',
    'popular', 'featured', 'free', 'paid', 'demo',
    'collection', 'wishlist', 'cart', 'wallet',
    'support', 'contact', 'community', 'forum',
    'guide', 'tutorial', 'tips', 'faq',
    'changelog', 'roadmap', 'credits',
    'terms', 'policy', 'cookies', 'analytics',
    'statistics', 'metrics', 'benchmark',
    'rank', 'xp', 'trophy', 'badge',
    'bonus', 'loot', 'drop', 'rarity',
    'common', 'uncommon', 'rare', 'epic', 'legendary',
    'season', 'pass', 'challenge',
    'limited time', 'coming soon', 'released',
    'pre-order', 'in library', 'hidden',
    'transaction', 'receipt', 'invoice', 'refund',
    'sign in', 'sign out', 'log in', 'log out',
    'register', 'account', 'avatar', 'nickname',
    'username', 'password', 'email', 'phone',
    'verification', 'code', 'captcha',
    'two-factor', 'parental controls', 'family',
    'age', 'rating', 'content', 'description',
    'details', 'summary', 'overview', 'introduction',
    'getting started', 'installation', 'configuration',
    'troubleshooting', 'known issues', 'workaround',
    'fix', 'patch', 'hotfix', 'upgrade', 'downgrade',
    'rollback', 'commit', 'branch', 'tag',
    'repository', 'maintainer', 'contributor',
    'translator', 'internationalization',
    'fallback', 'rendering',
    'node', 'tree', 'list', 'grid', 'card', 'tile',
    'row', 'column', 'stack', 'sheet', 'dialog',
    'popup', 'toast', 'notification', 'alert', 'banner',
    'carousel', 'divider', 'separator', 'spacer',
    'determinate', 'indeterminate', 'skeleton',
    'offline', 'host', 'role',
    'tab', 'chip', 'badge', 'poster', 'art',
    'cover', 'thumb', 'preview',
    'frame generation', 'frame rate', 'latency',
    'vsync', 'hdr', 'contrast', 'saturation',
    'sharpness', 'hue', 'gamma', 'exposure', 'focus',
    'pan', 'tilt', 'rotate', 'crop', 'fit', 'fill',
    'stretch', 'shrink', 'expand', 'collapse', 'fold',
    'unfold', 'hide', 'show', 'group', 'ungroup',
    'merge', 'split', 'enable', 'disable', 'activate',
    'deactivate', 'defer', 'resume',
    'sync', 'synchronize',
    'read-only', 'writable', 'hidden',
    'internal', 'external', 'sd card', 'usb', 'otg',
    'hdmi', 'casting', 'mirror', 'extend', 'primary',
    'secondary', 'upside', 'downside',
    'indoor', 'outdoor',
    'setup wizard', 'welcome', 'get started',
    'not now', 'later', 'maybe', 'remind me',
    'learn more', 'got it', 'dismiss', 'snooze',
    'allow', 'don\'t allow', 'while using', 'only this time',
}

def is_internal(s):
    """判断是否为内部字符串（无翻译价值）"""
    s_lower = s.lower().strip()
    # 白名单：有翻译价值的短词
    if s_lower in UI_SHORT_WORDS:
        return False
    for pat in INTERNAL_PATTERNS:
        if re.match(pat, s.strip()):
            return True
    return False

def is_check_not_null_param(content, pos):
    """检查该 const-string 是否用于 checkNotNullParameter"""
    following = content[pos:pos+200]
    return 'checkNotNullParameter' in following

def extract_strings(decoded_dir, mapping_file=None):
    # 加载已有翻译
    translated = set()
    if mapping_file and os.path.exists(mapping_file):
        with open(mapping_file, 'r', encoding='utf-8') as f:
            for line in f:
                if '|||' in line and not line.startswith('#'):
                    translated.add(line.split('|||')[0].strip())

    # 按模块收集
    modules = defaultdict(lambda: {'translated': [], 'untranslated': [], 'internal': 0})

    for smali_file in glob.glob(f'{decoded_dir}/smali*/com/droiddeck/**/*.smali', recursive=True):
        rel = os.path.relpath(smali_file, decoded_dir)
        # 提取模块名
        parts = rel.split('/')
        if len(parts) >= 4:
            module = parts[3]  # e.g., ui, session, runtime
        else:
            module = 'other'

        try:
            with open(smali_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except:
            continue

        for m in re.finditer(r'const-string[^\"]*\"([^\"]+)\"', content):
            s = m.group(1)
            if not s or len(s.strip()) == 0:
                continue

            # 跳过 checkNotNullParameter 参数名
            if is_check_not_null_param(content, m.end()):
                modules[module]['internal'] += 1
                continue

            # 跳过内部字符串
            if is_internal(s):
                modules[module]['internal'] += 1
                continue

            # 跳过纯技术字符串（含特殊字符过多）
            if s.count('.') > 2 and not ' ' in s:
                modules[module]['internal'] += 1
                continue

            entry = {'string': s, 'file': os.path.basename(smali_file)}
            if s in translated:
                modules[module]['translated'].append(entry)
            else:
                modules[module]['untranslated'].append(entry)

    return modules

def main():
    if len(sys.argv) < 2:
        print("用法: extract-ui-strings.py <decoded-dir> [mapping-file]", file=sys.stderr)
        sys.exit(1)

    decoded_dir = sys.argv[1]
    mapping_file = sys.argv[2] if len(sys.argv) > 2 else None

    modules = extract_strings(decoded_dir, mapping_file)

    print("=" * 70)
    print("  UI 字符串提取报告（已过滤内部字符串）")
    print("=" * 70)

    total_translated = 0
    total_untranslated = 0
    total_internal = 0

    for module in sorted(modules.keys()):
        data = modules[module]
        t = len(data['translated'])
        u = len(data['untranslated'])
        i = data['internal']
        total_translated += t
        total_untranslated += u
        total_internal += i
        coverage = (t / (t + u) * 100) if (t + u) > 0 else 0
        print(f"\n【{module}】已翻译 {t} | 未翻译 {u} | 内部跳过 {i} | 覆盖率 {coverage:.0f}%")

        if u > 0:
            print(f"  未翻译 TOP 20（按文件）:")
            seen = set()
            for entry in data['untranslated'][:30]:
                if entry['string'] not in seen:
                    seen.add(entry['string'])
                    display = entry['string'][:60] + ('...' if len(entry['string']) > 60 else '')
                    print(f"    [{entry['file']}] {display}")

    print("\n" + "=" * 70)
    print(f"  总计: 已翻译 {total_translated} | 未翻译 {total_untranslated} | 内部跳过 {total_internal}")
    print(f"  整体覆盖率: {total_translated/(total_translated+total_untranslated)*100:.0f}%")
    print("=" * 70)

    # 输出未翻译列表到文件
    output_file = os.path.join(os.path.dirname(decoded_dir), 'untranslated-report.txt')
    with open(output_file, 'w', encoding='utf-8') as f:
        for module in sorted(modules.keys()):
            f.write(f"\n=== {module} ===\n")
            seen = set()
            for entry in modules[module]['untranslated']:
                if entry['string'] not in seen:
                    seen.add(entry['string'])
                    f.write(f"{entry['string']}\n")
    print(f"\n未翻译列表已写入: {output_file}")

if __name__ == '__main__':
    main()
