# Project Notes — phone_call2.0

> **首次对话或继续开发前，先阅读 [PROGRESS.md](./PROGRESS.md) 了解项目进度和架构。**

## Tool Call Limitations

When writing long content (hundreds of lines), tool calls (Write, Edit, Bash) may intermittently fail with `required parameter is missing`. The cause appears to be a serialization bug in the tool call chain, not a hard character limit.

**Workaround:** Break long content into smaller chunks. Write each chunk to a separate file via Write, then concatenate with Bash `cat`. Append to the target file via Edit with short, unique `old_string` → `new_string` replacements.

## 教训：不要手动搭建 Flutter 项目骨架

这个项目一开始跳过了 `flutter create`，手动写了 Gradle、AndroidManifest、settings.gradle 等文件。结果 CI 构建连爆 5 轮、12 个错误——`ifPresent` 语法不存在、mipmap 资源缺失、compileSdk 版本不对、local.properties 没生成、const 构造函数冲突等等。全是 `flutter create` 一行命令就能避免的问题。

**以后：** Flutter 项目必须用 `flutter create` 初始化，不手写脚手架。

