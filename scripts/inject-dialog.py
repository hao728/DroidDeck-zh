#!/usr/bin/env python3
"""
inject-dialog.py — 在 MainActivity.onCreate 中注入汉化声明弹窗调用
用法: python3 inject-dialog.py <decoded-dir>
在 super.onCreate() 后插入: invoke-static {p0}, Lcom/droiddeck/launcher/ZhDialog;->show(Landroid/content/Context;)V
幂等：已注入则跳过。
"""
import sys
import os
import glob

INJECT_LINE = '    invoke-static {p0}, Lcom/droiddeck/launcher/ZhDialog;->show(Landroid/content/Context;)V'
SUPER_ONCREATE = 'invoke-super {p0, p1}, Landroidx/activity/ComponentActivity;->onCreate(Landroid/os/Bundle;)V'

def inject(decoded_dir):
    # 查找 MainActivity.smali（可能在 smali 或 smali_classes2 等）
    candidates = glob.glob(f"{decoded_dir}/smali*/com/droiddeck/launcher/MainActivity.smali")
    if not candidates:
        print("  ⚠ 未找到 MainActivity.smali，跳过弹窗注入")
        return False

    main_activity = candidates[0]
    with open(main_activity, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # 检查是否已注入
    if any('ZhDialog;->show' in line for line in lines):
        print("  ✓ 弹窗调用已存在，跳过")
        return True

    # 找到 super.onCreate() 并在其后插入
    new_lines = []
    injected = False
    for line in lines:
        new_lines.append(line)
        if not injected and SUPER_ONCREATE in line:
            new_lines.append('\n')
            new_lines.append('    .line 226\n')
            new_lines.append(INJECT_LINE + '\n')
            injected = True
            print(f"  ✓ 已在 super.onCreate() 后注入弹窗调用")

    if not injected:
        print("  ⚠ 未找到 super.onCreate()，跳过")
        return False

    with open(main_activity, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    return True

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("用法: inject-dialog.py <decoded-dir>", file=sys.stderr)
        sys.exit(1)
    inject(sys.argv[1])
