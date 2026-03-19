# macos-init-skills

新 Mac 开发环境一键初始化工具，基于 Claude Code Skill 实现。

## 包含的 Skill

### `macos-init`

帮助快速初始化一台新 Mac 的完整开发环境，支持交互式选择或一键全装。

**覆盖工具：**

| 工具 | 说明 |
|------|------|
| Homebrew | macOS 包管理器，所有安装的基础 |
| Git | 版本控制，含全局 user.name / email 配置 |
| NVM + Node.js LTS | Node 版本管理器 + 最新 LTS 版本 |
| Python 3 | 系统 Python（via Homebrew） |
| Miniconda | Python 环境 + conda 包管理 |
| Go | Go 语言环境 |
| Rust | Rust 工具链（via rustup） |
| VSCode | 代码编辑器（via Homebrew Cask） |
| Google Chrome | 浏览器（via Homebrew Cask） |
| ClashX | 代理客户端（via Homebrew Cask） |

## 前置要求

使用 Skill 方式需要先安装 Claude Code CLI：

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

> 如果只想用脚本，不需要安装 Claude Code，直接运行 `install.sh` 即可。

## 快速使用

### 方式一：通过 Claude Code Skill 引导安装

在 Claude Code 中触发 skill，Claude 会交互式引导你完成安装：

```
帮我初始化新 Mac 的开发环境
```

### 方式二：直接运行脚本

```bash
# 交互式（逐个选择安装哪些工具）
bash macos-init/scripts/install.sh

# 一键全装
bash macos-init/scripts/install.sh --all

# 只装指定工具
bash macos-init/scripts/install.sh --git --node --apps
```

**可用参数：**

```
--all      安装全部
--git      Git
--node     NVM + Node.js LTS
--python   Python 3
--conda    Miniconda
--go       Go
--rust     Rust
--apps     VSCode + Chrome + ClashX
```

## 关于 GUI 应用安装

VSCode、Chrome、ClashX 均通过 `brew install --cask` 安装，Homebrew 会自动从官方地址下载并安装到 `/Applications/`，无需手动下载安装包。

## 项目结构

```
macos-init-skills/
└── macos-init/
    ├── SKILL.md              # Skill 定义与安装引导
    └── scripts/
        └── install.sh        # 一键安装脚本
```

## 系统要求

- macOS 12 Monterey 及以上
- 支持 Apple Silicon（M 系列）和 Intel 两种架构
- 需要管理员权限（安装 Homebrew 时会提示）
