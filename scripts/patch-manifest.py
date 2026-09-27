#!/usr/bin/env python3
"""
patch-manifest.py — 修改反编译后的 AndroidManifest.xml（使用 XML 解析器）
用法: python3 patch-manifest.py <decoded-dir> <config-file>
"""
import sys
import json
import xml.etree.ElementTree as ET

ANDROID_NS = 'http://schemas.android.com/apk/res/android'
ET.register_namespace('android', ANDROID_NS)

def patch_manifest(decoded_dir, config_file):
    manifest_path = f"{decoded_dir}/AndroidManifest.xml"
    tree = ET.parse(manifest_path)
    root = tree.getroot()

    with open(config_file, 'r', encoding='utf-8') as f:
        config = json.load(f)

    changes = 0
    orientation_key = f'{{{ANDROID_NS}}}screenOrientation'
    name_key = f'{{{ANDROID_NS}}}name'

    # 修改 screenOrientation
    orientation = config.get('orientation', {})
    for activity_name, new_orient in orientation.items():
        if activity_name.startswith('_'):
            continue
        found = False
        for activity in root.iter('activity'):
            if activity.get(name_key) == activity_name:
                old = activity.get(orientation_key, '(未设置)')
                activity.set(orientation_key, new_orient)
                changes += 1
                found = True
                print(f"  ✓ {activity_name}: {old} → {new_orient}")
                break
        if not found:
            print(f"  ⚠ 未找到 Activity: {activity_name}")

    tree.write(manifest_path, encoding='utf-8', xml_declaration=True)
    print(f"  Manifest 修改完成: {changes} 处")
    return changes

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("用法: patch-manifest.py <decoded-dir> <config-file>", file=sys.stderr)
        sys.exit(1)
    patch_manifest(sys.argv[1], sys.argv[2])
