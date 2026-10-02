#!/usr/bin/env python3
"""
analyze-strings.py — 专业字符串分类与翻译价值评估
用法: python3 analyze-strings.py <decoded-dir> [mapping-file] [output-dir]

功能:
1. 提取所有 smali const-string
2. 自动分类: UI文本/内部参数名/测试标签/日志标签/偏好键/路径URL/技术术语/格式串
3. 标注翻译价值: 高/中/低/跳过
4. 对比已有映射，输出未翻译高价值词条清单
5. 检测已翻译词条中的内部字符串误翻
"""
import sys
import os
import re
import glob
import json
from collections import defaultdict

# ===== 分类规则 =====

# Kotlin checkNotNullParameter 参数名（跳过）
PARAM_NAME_PATTERN = re.compile(
    r'const-string[^\"]*\"([^\"]+)\"[\s\S]{0,120}?checkNotNullParameter'
)

# Compose 测试标签/语义描述（低优先级）
TEST_TAG_PATTERN = re.compile(
    r'const-string[^\"]*\"([^\"]+)\"[\s\S]{0,200}?(testTag|semantics|contentDescription)'
)

# 日志标签（低优先级）
LOG_PATTERN = re.compile(
    r'const-string[^\"]*\"([^\"]+)\"[\s\S]{0,150}?Log\.(d|i|w|e|v|wtf)'
)

# 偏好设置键（跳过）
PREF_PATTERN = re.compile(
    r'const-string[^\"]*\"([^\"]+)\"[\s\S]{0,200}?(getSharedPreferences|getString\(|getBoolean\(|getInt\(|getFloat\(|getLong\(|edit\(\))'
)

# 文件路径/URL（跳过）
PATH_URL_PATTERN = re.compile(r'^(/|https?://|content://|file://|android\.resource://)')

# 技术术语（保留英文，中/低优先级）
TECH_TERMS = {
    'wine', 'proton', 'fex', 'turnip', 'dxvk', 'vkd3d', 'zink', 'angle',
    'gamescope', 'steam', 'steamdeck', 'winlator', 'droiddeck',
    'vulkan', 'opengl', 'gles', 'd3d', 'directx', 'direct3d',
    'alsa', 'pulseaudio', 'pipewire', 'jack',
    'x11', 'wayland', 'xwayland',
    'dbus', 'systemd', 'polkit',
    'ext4', 'f2fs', 'btrfs', 'ntfs', 'fat32',
    'apk', 'aab', 'obb',
    'cpu', 'gpu', 'npu', 'dsp', 'isp',
    'ram', 'rom', 'ssd', 'hdd',
    'usb', 'otg', 'hdmi', 'bluetooth', 'wifi',
    'ip', 'tcp', 'udp', 'dns', 'dhcp', 'nat',
    'api', 'sdk', 'ndk', 'jni', 'abi',
    'fps', 'hz', 'ms', 'mb', 'gb', 'kb',
    'lsfg', 'mangohud', 'obs',
    'cef', 'chromium', 'electron',
    'glibc', 'musl', 'bionic',
    'proot', 'chroot', 'container', 'docker',
    'seccomp', 'selinux', 'apparmor',
    'mesa', 'llvmpipe', 'softpipe',
    'adrenotools', 'freedreno', 'panfrost',
}

# 内部标识符模式（全小写单词、含$、含点号的类名等）
INTERNAL_PATTERNS = [
    re.compile(r'^\$this\$'),
    re.compile(r'^\$destruct\$'),
    re.compile(r'^[a-z]+(\.[a-z]+)+$'),  # 包名/类路径
    re.compile(r'^[a-z_]+$'),  # 全小写下划线（通常是键名）
    re.compile(r'^[A-Z][a-z]+([A-Z][a-z]+)+$'),  # CamelCase 类名
]

# 格式串（高优先级，用户可见）
FORMAT_PATTERN = re.compile(r'%[\d\$]*[sdifxX]|%\.\df')

# UI 文本特征（首字母大写、含空格、含标点）
UI_TEXT_HINTS = re.compile(r'^[A-Z][a-z]')


def classify_string(s, context_after):
    """返回 (分类, 翻译价值, 原因)"""
    if not s or len(s) == 0:
        return ('empty', 'skip', '空字符串')

    # 路径/URL
    if PATH_URL_PATTERN.match(s):
        return ('path_url', 'skip', '文件路径或URL')

    # 内部标识符
    for pat in INTERNAL_PATTERNS:
        if pat.match(s) and len(s) > 1:
            # 但如果是常见UI短词（如 "Cancel", "Settings"），不算内部
            if s.lower() not in TECH_TERMS and not s[0].islower():
                break
            return ('internal', 'skip', f'内部标识符模式: {pat.pattern}')

    # checkNotNullParameter 参数名
    if PARAM_NAME_PATTERN.search(context_after):
        return ('param_name', 'skip', 'Kotlin checkNotNullParameter 参数名')

    # 偏好设置键
    if PREF_PATTERN.search(context_after):
        return ('pref_key', 'skip', 'SharedPreferences 键名')

    # 日志标签
    if LOG_PATTERN.search(context_after):
        return ('log_tag', 'low', '日志标签')

    # 测试标签
    if TEST_TAG_PATTERN.search(context_after):
        return ('test_tag', 'low', 'Compose 测试标签/语义描述')

    # 技术术语
    if s.lower() in TECH_TERMS:
        return ('tech_term', 'low', '技术术语，建议保留英文')

    # 格式串
    if FORMAT_PATTERN.search(s):
        return ('format_string', 'high', '含格式符的用户可见文本')

    # 含空格的短语（通常是UI文本）
    if ' ' in s and len(s) > 3:
        if UI_TEXT_HINTS.match(s):
            return ('ui_text', 'high', '首字母大写的短语， likely UI 文本')
        return ('ui_text', 'medium', '含空格的短语')

    # 单个大写开头的词（可能是按钮/标签）
    if UI_TEXT_HINTS.match(s) and len(s) > 2:
        return ('ui_word', 'medium', '首字母大写单词，可能是按钮/标签')

    # 全大写缩写
    if s.isupper() and len(s) <= 10:
        return ('acronym', 'low', '全大写缩写，可能是技术缩写')

    return ('other', 'medium', '其他')


def extract_strings(decoded_dir):
    """提取所有 smali const-string，返回 [(string, file, context_after), ...]"""
    results = []
    for smali_file in glob.glob(f'{decoded_dir}/smali*/com/droiddeck/**/*.smali', recursive=True):
        try:
            with open(smali_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            for m in re.finditer(r'const-string[^\"]*\"([^\"]*)\"', content):
                s = m.group(1)
                context_after = content[m.end():m.end()+250]
                rel_path = os.path.relpath(smali_file, decoded_dir)
                results.append((s, rel_path, context_after))
        except Exception:
            pass
    return results


def load_mapping(mapping_file):
    """加载已有映射"""
    mapping = {}
    if not mapping_file or not os.path.exists(mapping_file):
        return mapping
    with open(mapping_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if '|||' in line and not line.startswith('#'):
                parts = line.split('|||', 1)
                if len(parts) == 2:
                    mapping[parts[0].strip()] = parts[1].strip()
    return mapping


def main():
    if len(sys.argv) < 2:
        print("用法: analyze-strings.py <decoded-dir> [mapping-file] [output-dir]", file=sys.stderr)
        sys.exit(1)

    decoded_dir = sys.argv[1]
    mapping_file = sys.argv[2] if len(sys.argv) > 2 else None
    output_dir = sys.argv[3] if len(sys.argv) > 3 else '.'

    mapping = load_mapping(mapping_file)

    print("提取字符串中...")
    all_strings = extract_strings(decoded_dir)
    print(f"共提取 {len(all_strings)} 个 const-string")

    # 去重并统计
    string_info = defaultdict(lambda: {'count': 0, 'files': set(), 'category': None, 'value': None, 'reason': None, 'translated': False, 'translation': None})

    for s, filepath, context in all_strings:
        info = string_info[s]
        info['count'] += 1
        info['files'].add(filepath)
        if info['category'] is None:
            cat, val, reason = classify_string(s, context)
            info['category'] = cat
            info['value'] = val
            info['reason'] = reason
        if s in mapping:
            info['translated'] = True
            info['translation'] = mapping[s]

    # 统计
    stats = defaultdict(int)
    value_stats = defaultdict(int)
    for s, info in string_info.items():
        stats[info['category']] += 1
        value_stats[info['value']] += 1

    print("\n===== 分类统计 =====")
    for cat, count in sorted(stats.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {count}")

    print("\n===== 翻译价值统计 =====")
    for val, count in sorted(value_stats.items(), key=lambda x: -x[1]):
        print(f"  {val}: {count}")

    # 输出未翻译高价值词条
    high_value_untranslated = []
    for s, info in string_info.items():
        if info['value'] == 'high' and not info['translated']:
            high_value_untranslated.append((s, info))

    print(f"\n===== 高价值未翻译词条: {len(high_value_untranslated)} =====")
    for s, info in sorted(high_value_untranslated, key=lambda x: -x[1]['count']):
        print(f"  [{info['count']}次] {s}  ({info['reason']})")

    # 检测已翻译中的内部字符串误翻
    mistranslated_internal = []
    for s, info in string_info.items():
        if info['translated'] and info['value'] == 'skip':
            mistranslated_internal.append((s, info))

    print(f"\n===== 已翻译但应为内部字符串（建议移除）: {len(mistranslated_internal)} =====")
    for s, info in mistranslated_internal:
        print(f"  {s} → {info['translation']}  ({info['reason']})")

    # 写入报告文件
    os.makedirs(output_dir, exist_ok=True)

    # 高价值未翻译
    with open(f'{output_dir}/high-value-untranslated.txt', 'w', encoding='utf-8') as f:
        f.write("# 高价值未翻译词条（按出现次数排序）\n")
        f.write("# 格式: 英文原文|||待翻译\n\n")
        for s, info in sorted(high_value_untranslated, key=lambda x: -x[1]['count']):
            f.write(f"{s}|||\n")

    # 中价值未翻译
    medium_untranslated = [(s, i) for s, i in string_info.items() if i['value'] == 'medium' and not i['translated']]
    with open(f'{output_dir}/medium-value-untranslated.txt', 'w', encoding='utf-8') as f:
        f.write("# 中价值未翻译词条（按出现次数排序）\n")
        f.write("# 格式: 英文原文|||待翻译\n\n")
        for s, info in sorted(medium_untranslated, key=lambda x: -x[1]['count']):
            f.write(f"{s}|||\n")

    # 内部字符串误翻报告
    with open(f'{output_dir}/mistranslated-internal.txt', 'w', encoding='utf-8') as f:
        f.write("# 已翻译但应为内部字符串（建议从映射中移除）\n\n")
        for s, info in mistranslated_internal:
            f.write(f"{s}|||{info['translation']}  # {info['reason']}\n")

    # JSON 完整报告
    report = {
        'total_unique': len(string_info),
        'total_occurrences': len(all_strings),
        'categories': dict(stats),
        'values': dict(value_stats),
        'high_value_untranslated_count': len(high_value_untranslated),
        'medium_value_untranslated_count': len(medium_untranslated),
        'mistranslated_internal_count': len(mistranslated_internal),
        'translated_count': sum(1 for i in string_info.values() if i['translated']),
    }
    with open(f'{output_dir}/analysis-report.json', 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print(f"\n报告已写入: {output_dir}/")
    print(f"  - high-value-untranslated.txt ({len(high_value_untranslated)} 条)")
    print(f"  - medium-value-untranslated.txt ({len(medium_untranslated)} 条)")
    print(f"  - mistranslated-internal.txt ({len(mistranslated_internal)} 条)")
    print(f"  - analysis-report.json")


if __name__ == '__main__':
    main()
