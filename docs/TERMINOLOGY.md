# DroidDeck 汉化术语表

> Linux / Wine / Steam Deck 中文社区通用术语，确保翻译一致性。
> 翻译时优先参考本表，避免机翻味。

## 一、保留英文（技术专有名词，不翻译）

| 英文 | 说明 |
|---|---|
| Wine | Wine 兼容层，中文圈通用 "Wine" |
| Proton | Valve 的 Wine 分支，通用 "Proton" |
| FEX | x86 模拟层，通用 "FEX" |
| Turnip | 高通 GPU Vulkan 驱动，通用 "Turnip" |
| DXVK | DirectX→Vulkan 转换层，通用 "DXVK" |
| VKD3D | Direct3D 12→Vulkan，通用 "VKD3D" |
| Zink | OpenGL→Vulkan，通用 "Zink" |
| ANGLE | OpenGL ES→DirectX，通用 "ANGLE" |
| gamescope | SteamOS 合成器，通用 "gamescope" |
| Steam | Steam 平台，通用 "Steam" |
| Steam Deck | 掌机名，通用 "Steam Deck" |
| Winlator | 项目名，保留 |
| DroidDeck | 项目名，保留 |
| Vulkan | 图形 API，通用 "Vulkan" |
| OpenGL / OpenGL ES | 图形 API，通用 |
| DirectX / Direct3D | 微软图形 API，通用 |
| ALSA / PulseAudio / PipeWire | 音频系统，通用 |
| X11 / Wayland / XWayland | 显示协议，通用 |
| D-Bus | 消息总线，通用 "D-Bus" |
| proot | 无根容器工具，通用 "proot" |
| seccomp | 安全计算，通用 "seccomp" |
| Mesa | 图形驱动集合，通用 "Mesa" |
| AdrenoTools | 高通工具，保留 |
| MangoHUD | 游戏覆盖层，保留 |
| LSFG | 帧生成技术，保留 |
| CEF / Chromium | 嵌入式浏览器，保留 |
| glibc / musl / bionic | C 运行库，保留 |
| ext4 / f2fs / btrfs / NTFS | 文件系统，保留 |
| APK / AAB / OBB | Android 包格式，保留 |

## 二、统一译法（Linux/Wine 中文圈）

| 英文 | 统一译法 | 避免 | 说明 |
|---|---|---|---|
| Prefix | 前缀 | 前缀目录 | Wine 术语，WINEPREFIX |
| Container | 容器 | 集装箱 | proot 容器 |
| Runtime | 运行时 | 运行环境 | Steam Linux 运行时 |
| Compatibility layer / tool | 兼容层 / 兼容工具 | 兼容性层 | Proton 兼容层 |
| Overlay | 覆盖层 | 叠加层 | 文件系统覆盖 |
| Shader cache | 着色器缓存 | 着色器缓存 | 游戏着色器预编译 |
| Frame generation | 帧生成 | 帧率生成 | LSFG 帧生成 |
| Upscaling | 超分辨率 | 升频 | 图像升频技术 |
| VSync | 垂直同步 | 垂直同步 | 通用 |
| Compositor | 合成器 | 合成器 | gamescope 合成器 |
| Touchpad / Trackpad | 触控板 | 触摸板 | Steam Deck 触控板 |
| Deadzone | 死区 | 盲区 | 摇杆死区 |
| Haptic (feedback) | 触感反馈 | 震动反馈 | HD 震动 |
| Gyro | 陀螺仪 | 陀螺 | 体感控制 |
| Motion controls | 体感控制 | 运动控制 | 陀螺仪控制 |
| Quick Access Menu (QAM) | 快捷访问菜单 | 快速访问菜单 | Steam Deck QAM |
| Big Picture | 大屏模式 | 大图片模式 | Steam 大屏模式 |
| Gamepad | 手柄 | 游戏手柄 | 通用 |
| Controller | 控制器 | 手柄 | 通用控制器 |
| Session | 会话 | 会议/场次 | DroidDeck 会话 |
| Driver | 驱动 | 驱动程序 | GPU 驱动 |
| Renderer | 渲染器 | 渲染器 | 图形渲染器 |
| Resolution | 分辨率 | 解析度 | 显示分辨率 |
| Refresh rate | 刷新率 | 刷新频率 | 屏幕刷新率 |
| Frame rate | 帧率 | 帧数 | FPS |
| Latency | 延迟 | 延时 | 输入延迟 |
| Brightness | 亮度 | 明亮度 | 屏幕亮度 |
| Volume | 音量 | 音量 | 通用 |
| Microphone | 麦克风 | 话筒 | 通用 |
| Storage | 存储 | 储存 | 存储空间 |
| Memory | 内存 | 记忆 | RAM |
| Performance | 性能 | 表现 | 性能模式 |
| Theme | 主题 | 皮肤 | UI 主题 |
| Language | 语言 | 语种 | 系统语言 |
| Desktop | 桌面 | 桌面 | Linux 桌面 |
| Library | 库 | 图书馆 | Steam 游戏库 |
| Launcher | 启动器 | 发射器 | 应用启动器 |
| Install | 安装 | 安装 | 通用 |
| Uninstall | 卸载 | 反安装 | 通用 |
| Update | 更新 | 升级 | 软件更新 |
| Upgrade | 升级 | 更新 | 系统升级 |
| Download | 下载 | 下载 | 通用 |
| Upload | 上传 | 上载 | 通用 |
| Backup | 备份 | 后援 | 通用 |
| Restore | 恢复 | 还原 | 备份恢复 |
| Archive | 归档 | 存档 | 文件归档 |
| Cache | 缓存 | 快取 | 临时缓存 |
| Config / Configuration | 配置 | 设置 | 配置文件 |
| Settings | 设置 | 设定 | 应用设置 |
| Preferences | 首选项 | 偏好设置 | 用户偏好 |
| Permissions | 权限 | 许可 | 应用权限 |
| Accessibility | 无障碍 | 辅助功能 | 无障碍服务 |
| Developer options | 开发者选项 | 开发人员选项 | 通用 |
| Debug | 调试 | 除错 | 调试模式 |
| Log / Logs | 日志 | 记录 | 系统日志 |
| Crash | 崩溃 | 闪退 | 应用崩溃 |
| Report | 报告 | 报表 | 错误报告 |
| Feedback | 反馈 | 回馈 | 用户反馈 |
| About | 关于 | 关于 | 关于页面 |
| Changelog | 更新日志 | 变更日志 | 版本更新记录 |
| License | 许可证 | 授权 | 开源许可证 |
| Privacy | 隐私 | 私隐 | 隐私政策 |
| Terms | 条款 | 条件 | 服务条款 |
| Notification | 通知 | 通告 | 系统通知 |
| Status bar | 状态栏 | 状态列 | 顶部状态栏 |
| Navigation bar | 导航栏 | 导航列 | 底部导航栏 |
| Drawer | 抽屉 | 抽屉菜单 | 侧边抽屉 |
| Dialog | 对话框 | 对话窗口 | 弹窗对话框 |
| Overlay | 覆盖层 | 悬浮窗 | 游戏覆盖层 |
| Widget | 小部件 | 控件 | 桌面小部件 |
| Toggle | 开关 | 切换 | 设置开关 |
| Slider | 滑块 | 滑动条 | 音量滑块 |
| Dropdown | 下拉菜单 | 下拉列表 | 下拉选择 |
| Picker | 选择器 | 拾取器 | 文件选择器 |
| Placeholder | 占位符 | 占位文字 | 输入框占位 |
| Tooltip | 工具提示 | 提示框 | 悬停提示 |
| Hint | 提示 | 暗示 | 输入提示 |
| Label | 标签 | 标注 | UI 标签 |
| Caption | 说明文字 | 字幕 | 图片说明 |
| Subtitle | 副标题 | 字幕 | 页面副标题 |
| Divider | 分隔线 | 分割线 | UI 分隔 |
| Progress | 进度 | 进展 | 进度条 |
| Loading | 加载中 | 载入中 | 加载状态 |
| Processing | 处理中 | 正在处理 | 处理状态 |
| Pending | 待处理 | 挂起 | 任务状态 |
| Retry | 重试 | 再试 | 失败重试 |
| Skip | 跳过 | 略过 | 引导跳过 |
| Dismiss | 关闭 | 解散 | 通知关闭 |
| Confirm | 确认 | 确定 | 对话框确认 |
| Cancel | 取消 | 撤销 | 对话框取消 |
| Apply | 应用 | 套用 | 设置应用 |
| Discard | 放弃 | 丢弃 | 未保存更改 |
| Reset | 重置 | 复位 | 设置重置 |
| Default | 默认 | 缺省 | 默认值 |
| Custom | 自定义 | 定制 | 自定义设置 |
| Auto | 自动 | 自动 | 自动模式 |
| Manual | 手动 | 手控 | 手动模式 |
| Always | 始终 | 总是 | 始终允许 |
| Never | 从不 | 绝不 | 从不允许 |
| Enabled | 已启用 | 已开启 | 功能状态 |
| Disabled | 已禁用 | 已关闭 | 功能状态 |
| Connected | 已连接 | 已链接 | 网络状态 |
| Disconnected | 已断开 | 未连接 | 网络状态 |
| Charging | 充电中 | 正在充电 | 电池状态 |
| Full | 已满 | 充满 | 电池状态 |
| Stable | 稳定版 | 稳定 | 发布通道 |
| Beta | 测试版 | 贝塔 | 发布通道 |
| Preview | 预览版 | 预览 | 发布通道 |
| Prerelease | 预发布版 | 预发布 | 发布类型 |
| Release | 正式版 | 发布 | 发布类型 |
| Build | 构建 | 编译 | 构建号 |
| Version | 版本 | 版本号 | 应用版本 |
| Channel | 通道 | 渠道 | 更新通道 |
| Branch | 分支 | 分部 | 代码分支 |
| Repository | 仓库 | 版本库 | Git 仓库 |
| Source | 源码 | 源代码 | 源代码 |
| Patch | 补丁 | 修补 | 软件补丁 |
| Hotfix | 热修复 | 紧急修复 | 紧急补丁 |
| Commit | 提交 | 提交记录 | Git 提交 |
| Tag | 标签 | 标记 | Git 标签 |
| Author | 作者 | 创作者 | 代码作者 |
| Contributor | 贡献者 | 参与者 | 开源贡献者 |
| Maintainer | 维护者 | 维护人 | 项目维护者 |
| Translator | 翻译者 | 翻译人员 | 汉化贡献者 |
| Localization | 本地化 | 本地化 | 软件本地化 |
| Encoding | 编码 | 编码方式 | 字符编码 |
| Font | 字体 | 字型 | 系统字体 |
| Fallback | 回退 | 后备 | 字体回退 |
| Rendering | 渲染 | 绘制 | 图形渲染 |
| Layout | 布局 | 排版 | UI 布局 |
| Alignment | 对齐 | 排列 | 文本对齐 |
| Margin | 边距 | 外边距 | UI 边距 |
| Padding | 内边距 | 填充 | UI 内边距 |
| Border | 边框 | 边界 | UI 边框 |
| Shadow | 阴影 | 影子 | UI 阴影 |
| Gradient | 渐变 | 梯度 | 颜色渐变 |
| Opacity | 不透明度 | 透明度 | UI 透明度 |
| Dark | 深色 | 暗色 | 深色模式 |
| Light | 浅色 | 亮色 | 浅色模式 |
| Wallpaper | 壁纸 | 墙纸 | 桌面壁纸 |
| Background | 背景 | 后台 | UI 背景 |
| Foreground | 前景 | 前台 | UI 前景 |
| Portrait | 竖屏 | 纵向 | 屏幕方向 |
| Landscape | 横屏 | 横向 | 屏幕方向 |
| Fullscreen | 全屏 | 全屏幕 | 显示模式 |
| Windowed | 窗口化 | 窗口模式 | 显示模式 |
| Borderless | 无边框 | 无边界 | 窗口模式 |
| VSync | 垂直同步 | 垂直同步 | 显示设置 |
| HDR | HDR | 高动态范围 | 显示设置 |
| Refresh rate | 刷新率 | 刷新频率 | 显示设置 |
| Scaling | 缩放 | 缩放比例 | 显示缩放 |
| DPI | DPI | 每英寸点数 | 显示密度 |
| Orientation | 方向 | 朝向 | 屏幕方向 |
| Rotation | 旋转 | 转动 | 屏幕旋转 |
| Sensitivity | 灵敏度 | 敏感度 | 触控灵敏度 |
| Vibration | 震动 | 振动 | 手柄震动 |
| Pressure | 压力 | 按压 | 压感 |
| Gesture | 手势 | 手势操作 | 触控手势 |
| Swipe | 滑动 | 扫动 | 手势滑动 |
| Tap | 点击 | 轻触 | 手势点击 |
| Double tap | 双击 | 连点两次 | 手势 |
| Long press | 长按 | 长按不放 | 手势 |
| Drag | 拖动 | 拖拽 | 手势拖动 |
| Pinch | 捏合 | 双指缩放 | 手势 |
| Scroll | 滚动 | 卷动 | 滚动 |
| Cursor | 光标 | 游标 | 鼠标光标 |
| Pointer | 指针 | 指示器 | 输入指针 |
| Input method | 输入法 | 输入方式 | 键盘输入法 |
| Key mapping | 按键映射 | 键位映射 | 手柄按键映射 |
| Key bind | 按键绑定 | 键位绑定 | 快捷键绑定 |
| Combo | 组合键 | 连招 | 按键组合 |
| Macro | 宏 | 宏命令 | 按键宏 |
| Profile | 配置文件 | 配置 | 设置配置 |
| Preset | 预设 | 预置 | 预设配置 |
| Template | 模板 | 范本 | 配置模板 |
| Scheme | 方案 | 计划 | 配色方案 |
| Mode | 模式 | 方式 | 运行模式 |
| Type | 类型 | 种类 | 内容类型 |
| Category | 分类 | 类别 | 内容分类 |
| Filter | 筛选 | 过滤器 | 列表筛选 |
| Sort | 排序 | 分类 | 列表排序 |
| Search | 搜索 | 搜寻 | 搜索功能 |
| Favorite | 收藏 | 最爱 | 收藏夹 |
| Recent | 最近 | 近期 | 最近使用 |
| Hidden | 已隐藏 | 隐藏 | 隐藏项目 |
| Collection | 收藏集 | 合集 | 游戏集合 |
| Wishlist | 愿望单 | 心愿单 | Steam 愿望单 |
| Achievement | 成就 | 奖杯 | 游戏成就 |
| Trophy | 奖杯 | 成就 | 游戏奖杯 |
| Reward | 奖励 | 报酬 | 游戏奖励 |
| Event | 活动 | 事件 | 游戏活动 |
| Season | 赛季 | 季节 | 游戏赛季 |
| Daily | 每日 | 日常 | 每日任务 |
| Weekly | 每周 | 周常 | 每周任务 |
| Limited time | 限时 | 限定 | 限时活动 |
| Rarity | 稀有度 | 稀有程度 | 物品稀有度 |
| Common | 普通 | 常见 | 稀有度 |
| Uncommon | 罕见 | 不常见 | 稀有度 |
| Rare | 稀有 | 稀少 | 稀有度 |
| Epic | 史诗 | 史诗级 | 稀有度 |
| Legendary | 传说 | 传奇 | 稀有度 |
| Free | 免费 | 自由 | 免费游戏 |
| Demo | 试玩 | 演示 | 游戏试玩 |
| Early access | 抢先体验 | 早期访问 | 游戏状态 |
| Released | 已发布 | 已发行 | 游戏状态 |
| Pre-order | 预购 | 预订 | 游戏预购 |
| In library | 在库中 | 已在库 | Steam 状态 |
| Installed games | 已安装游戏 | 已安装的游戏 | 游戏筛选 |
| All games | 所有游戏 | 全部游戏 | 游戏筛选 |
| Hidden games | 已隐藏游戏 | 隐藏的游戏 | 游戏筛选 |
| Play | 播放/开始 | 玩 | 游戏开始 |
| Pause | 暂停 | 暂停 | 游戏暂停 |
| Stop | 停止 | 停下 | 会话停止 |
| Resume | 恢复 | 继续 | 会话恢复 |
| Restart | 重启 | 重新启动 | 应用重启 |
| Shutdown | 关机 | 关闭 | 系统关机 |
| Sleep | 睡眠 | 休眠 | 系统睡眠 |
| Wake | 唤醒 | 醒来 | 系统唤醒 |
| Reboot | 重启 | 重新引导 | 系统重启 |
| Screenshot | 截图 | 屏幕截图 | 截图功能 |
| Screen recording | 录屏 | 屏幕录制 | 录屏功能 |
| Cast | 投屏 | 投射 | 屏幕投射 |
| Print | 打印 | 列印 | 打印功能 |
| Share | 分享 | 共享 | 分享功能 |
| Send | 发送 | 寄出 | 发送功能 |
| Receive | 接收 | 收到 | 接收功能 |
| Copy | 复制 | 拷贝 | 复制功能 |
| Paste | 粘贴 | 贴上 | 粘贴功能 |
| Cut | 剪切 | 剪下 | 剪切功能 |
| Undo | 撤销 | 复原 | 编辑撤销 |
| Redo | 重做 | 取消复原 | 编辑重做 |
| Select all | 全选 | 全部选取 | 编辑全选 |
| Find | 查找 | 寻找 | 查找功能 |
| Replace | 替换 | 取代 | 查找替换 |
| Navigate | 导航 | 浏览 | 页面导航 |
| Forward | 前进 | 向前 | 浏览器前进 |
| Back | 返回 | 后退 | 页面返回 |
| Home | 主页 | 首页 | 主页按钮 |
| Refresh | 刷新 | 重新整理 | 页面刷新 |
| Reload | 重新加载 | 重载 | 页面重载 |
| Submit | 提交 | 送出 | 表单提交 |
| Save | 保存 | 储存 | 保存更改 |
| Edit | 编辑 | 修改 | 编辑功能 |
| Rename | 重命名 | 重新命名 | 文件重命名 |
| Move | 移动 | 搬移 | 文件移动 |
| Duplicate | 复制 | 重复 | 文件复制 |
| Delete | 删除 | 移除 | 文件删除 |
| Remove | 移除 | 删除 | 项目移除 |
| Add | 添加 | 新增 | 添加项目 |
| Create | 创建 | 建立 | 创建项目 |
| Close | 关闭 | 结束 | 关闭窗口 |
| Open | 打开 | 开启 | 打开文件 |
| Browse | 浏览 | 造访 | 文件浏览 |
| Choose | 选择 | 挑选 | 选择文件 |
| Select | 选择 | 选取 | 选择项目 |
| Import | 导入 | 汇入 | 数据导入 |
| Export | 导出 | 汇出 | 数据导出 |
| Compress | 压缩 | 压损 | 文件压缩 |
| Decompress | 解压 | 解压缩 | 文件解压 |
| Extract | 提取 | 解压缩 | 提取文件 |
| Mount | 挂载 | 挂上 | 挂载分区 |
| Unmount | 卸载 | 取消挂载 | 卸载分区 |
| Eject | 弹出 | 退出 | 弹出介质 |
| Format | 格式化 | 格式化 | 磁盘格式化 |
| Partition | 分区 | 分割 | 磁盘分区 |
| Disk | 磁盘 | 磁碟 | 存储磁盘 |
| Drive | 驱动器 | 驱动 | 磁盘驱动器 |
| Volume | 卷 | 音量 | 存储卷（注意与音量区分） |
| Buffer | 缓冲区 | 缓冲 | 数据缓冲 |
| Swap | 交换 | 置换 | 交换分区 |
| Virtual memory | 虚拟内存 | 虚拟记忆体 | 虚拟内存 |
| Hibernate | 休眠 | 冬眠 | 系统休眠 |
| Bootloader | 引导加载程序 | 启动程序 | 系统引导 |
| Recovery | 恢复模式 | 复原 | 恢复分区 |
| Firmware | 固件 | 韧体 | 设备固件 |
| Baseband | 基带 | 基频 | 通信基带 |
| Kernel | 内核 | 核心 | Linux 内核 |
| Security patch | 安全补丁 | 安全更新 | Android 安全补丁 |
| Build number | 构建号 | 版本号 | 构建编号 |
| SELinux | SELinux | 安全增强 Linux | 保留英文 |
| Enforcing | 强制 | 执行 | SELinux 模式 |
| Permissive | 宽容 | 许可 | SELinux 模式 |
| Root | Root | 根 | Root 权限 |
| Custom ROM | 自定义 ROM | 第三方 ROM | 自定义固件 |
| Stock ROM | 官方 ROM | 原版 ROM | 原厂固件 |
| AOSP | AOSP | 安卓开源项目 | 保留 |
| OTA | OTA | 在线更新 | 保留 |
| ADB | ADB | 安卓调试桥 | 保留 |
| Fastboot | Fastboot | 快速启动 | 保留 |
| IMEI | IMEI | 国际移动设备识别码 | 保留 |
| MAC | MAC | 物理地址 | 保留 |
| IP | IP | 网际协议 | 保留 |
| VPN | VPN | 虚拟专用网络 | 保留 |
| Proxy | 代理 | 代理服务器 | 网络代理 |
| Firewall | 防火墙 | 防火墙 | 网络防火墙 |
| Hotspot | 热点 | 无线热点 | 网络热点 |
| Tethering | 网络共享 |  tethering | USB 网络共享 |
| Airplane mode | 飞行模式 | 航空模式 | 系统设置 |
| Do not disturb | 勿扰模式 | 请勿打扰 | 通知设置 |
| Location | 位置 | 定位 | 位置服务 |
| GPS | GPS | 全球定位系统 | 保留 |
| NFC | NFC | 近场通信 | 保留 |
| Sensor | 传感器 | 感应器 | 设备传感器 |
| Accelerometer | 加速度计 | 加速传感器 | 运动传感器 |
| Magnetometer | 磁力计 | 地磁传感器 | 方向传感器 |
| Proximity | 接近 | 近距离 | 接近传感器 |
| Ambient light | 环境光 | 光线 | 光线传感器 |
| Barometer | 气压计 | 气压表 | 气压传感器 |
| Thermometer | 温度计 | 温度 | 温度传感器 |
