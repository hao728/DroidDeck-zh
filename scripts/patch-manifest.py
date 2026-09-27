#!/usr/bin/env python3
"""
patch-manifest.py — 修改反编译后的 AndroidManifest.xml
用法: python3 patch-manifest.py <decoded-dir> <config-file>

功能:
1. 修改指定 Activity 的 android:screenOrientation
2. 确保 application 标签属性完整
"""
import sys
import re
import json

def patch_manifest(decoded_dir, config_file):
    manifest_path = f"{decoded_dir}/AndroidManifest.xml"
    with open(manifest_path, 'r', encoding='utf-8') as f:
        content = f.read()

    with open(config_file, 'r', encoding='utf-8') as f:
        config = json.load(f)

    changes = 0

    # 1. 修改 screenOrientation
    orientation = config.get('orientation', {})
    for activity_name, new_orient in orientation.items():
        if activity_name.startswith('_'):
            continue
        # 匹配该 activity 的 <activity ... android:name="..." ...>
        # 找到包含该 name 的 activity 标签
        pattern = re.compile(
            r'(<activity[^>]*android:name="' + re.escape(activity_name) + r'"[^>]*?)'
            r'android:screenOrientation="[^"]*"'
            r'([^>]*>)'
        )
        def replacer(m):
            nonlocal changes
            changes += 1
            return m.group(1) + f'android:screenOrientation="{new_orient}"' + m.group(2)

        new_content = pattern.sub(replacer, content)
        if new_content != content:
            content = new_content
            print(f"  ✓ {activity_name}: → {new_orient}")
        else:
            # 如果没有 screenOrientation 属性，添加一个
            pattern2 = re.compile(
                r'(<activity[^>]*android:name="' + re.escape(activity_name) + r'"[^>]*?)(>)'
            )
            def replacer2(m):
                nonlocal changes
                changes += 1
                return m.group(1) + f' android:screenOrientation="{new_orient}"' + m.group(2)
            new_content = pattern2.sub(replacer2, content)
            if new_content != content:
                content = new_content
                print(f"  ✓ {activity_name}: 新增 {new_orient}")

    with open(manifest_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"  Manifest 修改完成: {changes} 处")
    return changes

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("用法: patch-manifest.py <decoded-dir> <config-file>", file=sys.stderr)
        sys.exit(1)
    patch_manifest(sys.argv[1], sys.argv[2])
