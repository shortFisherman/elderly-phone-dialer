# 项目进度

## 已完成

**老年人电话助手 App** — Flutter Android 应用，帮助不识字老人通过长按头像拨打电话。

### 核心功能
- **主界面**：3列圆形头像网格，纯视觉识别，无文字。长按头像约1秒触发拨号，拨号前头像放大动画，其他头像变暗
- **自动免提**：拨号后通过 Platform Channel 调用 `AudioManager.setSpeakerphoneOn(true)` 开启免提
- **防误触**：长按才拨号，短按无效
- **管理模式**：右下角小「+」按钮连续点击5次进入（3秒超时重置），可添加/编辑/删除联系人
- **联系人管理**：从相册选照片，填写姓名和电话号码，最多30人
- **首次启动**：无联系人时自动进入管理模式

### 技术栈
- Flutter 3.27 / Dart / Kotlin
- Platform Channel 调用原生 Android 电话 API
- JSON 文件本地持久化（path_provider）
- image_picker 相册选图，permission_handler 运行时权限

### 架构
```
lib/
├── main.dart / app.dart          # 入口、模式切换
├── models/contact.dart           # 数据模型
├── services/
│   ├── contact_service.dart      # CRUD + JSON 持久化
│   ├── phone_service.dart        # 拨号 + 免提 + 权限
│   ├── photo_service.dart        # 相册选图 + 本地存储
│   └── colors.dart               # 10色联系人背景
├── screens/
│   ├── home_screen.dart          # 老人主界面（3列网格）
│   └── manage_screen.dart        # 管理界面（列表 + 添加/编辑）
└── widgets/
    └── contact_avatar.dart       # 头像组件（长按动画）
```

### 测试
55个测试：Contact模型、ContactService、PhoneService、PhotoService、颜色常量、ContactAvatar组件、HomeScreen、ManageScreen

### CI/CD
GitHub Actions 自动构建：push → flutter pub get → flutter test → flutter build apk → 上传 APK artifact

### 仓库
https://github.com/shortFisherman/elderly-phone-dialer

### 构建状态
最后一次成功构建：2026-05-13，55测试全部通过，APK 已生成并安装验证可用

---

## 待做

暂无。功能完整可用。
