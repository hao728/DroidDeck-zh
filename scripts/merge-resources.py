#!/usr/bin/env python3
"""
merge-resources.py — 将汉化补丁的 strings.xml / arrays.xml 合并到上游已有的资源中
用法: python3 merge-resources.py <patch-file> <target-file>

逻辑:
- 如果目标文件不存在: 直接复制补丁
- 如果目标文件存在: 解析两者，补丁中的条目追加或覆盖到目标中，保留目标中未被补丁覆盖的条目
- 输出写回目标文件
"""
import sys
import xml.etree.ElementTree as ET

def merge_strings(patch_path, target_path):
    """合并 strings.xml: 补丁中的 <string> 覆盖或追加到目标"""
    patch_tree = ET.parse(patch_path)
    patch_root = patch_tree.getroot()

    try:
        target_tree = ET.parse(target_path)
        target_root = target_tree.getroot()
    except (FileNotFoundError, ET.ParseError):
        # 目标不存在或损坏，直接用补丁
        import shutil
        shutil.copy2(patch_path, target_path)
        return 0, len(patch_root.findall('string'))

    # 建立目标中已有 name → element 的映射
    existing = {}
    for elem in list(target_root):
        name = elem.get('name')
        if name:
            existing[name] = elem

    added = 0
    replaced = 0
    for elem in patch_root.findall('string'):
        name = elem.get('name')
        if not name:
            continue
        if name in existing:
            # 替换: 保留目标元素的属性，更新文本
            target_elem = existing[name]
            target_elem.text = elem.text
            # 复制 formatted/translatable 等属性
            for k, v in elem.attrib.items():
                if k != 'name':
                    target_elem.set(k, v)
            replaced += 1
        else:
            # 追加
            target_root.append(elem)
            added += 1

    # 写回，保持 XML 声明和缩进
    ET.indent(target_tree, space='    ')
    target_tree.write(target_path, encoding='utf-8', xml_declaration=True)
    return added, replaced

def merge_arrays(patch_path, target_path):
    """合并 arrays.xml: 补丁中的 <string-array>/<integer-array> 覆盖或追加"""
    patch_tree = ET.parse(patch_path)
    patch_root = patch_tree.getroot()

    try:
        target_tree = ET.parse(target_path)
        target_root = target_tree.getroot()
    except (FileNotFoundError, ET.ParseError):
        import shutil
        shutil.copy2(patch_path, target_path)
        return 0, len(patch_root.findall('./*'))

    existing = {}
    for elem in list(target_root):
        name = elem.get('name')
        if name:
            existing[name] = elem

    added = 0
    replaced = 0
    for elem in patch_root:
        tag = elem.tag
        name = elem.get('name')
        if not name:
            continue
        if name in existing:
            # 替换整个数组元素
            idx = list(target_root).index(existing[name])
            target_root.remove(existing[name])
            target_root.insert(idx, elem)
            replaced += 1
        else:
            target_root.append(elem)
            added += 1

    ET.indent(target_tree, space='    ')
    target_tree.write(target_path, encoding='utf-8', xml_declaration=True)
    return added, replaced

def main():
    if len(sys.argv) != 3:
        print("用法: merge-resources.py <patch-file> <target-file>", file=sys.stderr)
        sys.exit(1)

    patch_path = sys.argv[1]
    target_path = sys.argv[2]

    fname = patch_path.split('/')[-1]
    if fname == 'strings.xml':
        added, replaced = merge_strings(patch_path, target_path)
        print(f"  strings.xml 合并: 新增 {added} 条, 覆盖 {replaced} 条")
    elif fname == 'arrays.xml':
        added, replaced = merge_arrays(patch_path, target_path)
        print(f"  arrays.xml 合并: 新增 {added} 组, 覆盖 {replaced} 组")
    else:
        # 其他文件直接复制
        import shutil
        shutil.copy2(patch_path, target_path)
        print(f"  复制: {fname}")

if __name__ == '__main__':
    main()
