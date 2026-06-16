# Gooze-CMS 项目 AGENTS 配置

## 项目概述

Gooze-CMS 是一个基于前后端分离架构的内容管理系统，采用现代化技术栈构建。

- **后端**: Go + Gin + GORM + Casbin
- **前端**: Vue 3 + TypeScript + Vite + Element Plus + Vben Admin
- **项目类型**: 管理后台 CMS 系统

## 项目结构

```
gooze-cms/
├── gooze-vben-admin/      # 前端管理后台（Monorepo 架构）
│   ├── apps/
│   │   └── admin/        # 主应用
│   ├── packages/          # 公共组件包
│   └── internal/          # 内部工具包
├── gooze-vben-api/        # 后端 API 服务
│   ├── api/               # API 描述文件
│   ├── cmd/               # 服务入口
│   ├── configs/           # 配置文件
│   ├── internal/          # 核心业务代码
│   ├── models/            # 数据模型
│   └── middleware/        # 中间件
├── docs/                  # 项目文档
└── AGENTS.md              # 本文件
```

## Agent 分工与职责

### 1. 后端开发 Agent

**负责模块**: `gooze-vben-api/`

**技术栈**:
- 语言: Go 1.24+
- Web 框架: Gin v1.10.1
- ORM: GORM v1.30.0
- 权限控制: Casbin v2.109.0
- 配置管理: Viper v1.20.1
- 日志: Zap v1.27.0
- 数据库: MySQL (主), 支持 PostgreSQL/SQLite/SQL Server

**核心职责**:
- API 接口开发与维护
- 数据库模型设计与迁移
- 业务逻辑实现
- 权限控制（Casbin RBAC）
- 中间件开发
- 代码生成（gooze-starter）

**常用操作**:
```bash
# 启动服务
sh ./build/scripts/start_admin.sh

# 代码生成
sh ./build/scripts/gen_admin.sh

# 运行测试
go test ./...
```

---

### 2. 前端开发 Agent

**负责模块**: `gooze-vben-admin/`

**技术栈**:
- 框架: Vue 3.5+
- 语言: TypeScript 5.x
- 构建工具: Vite 5.x
- UI 组件库: Element Plus 2.x
- 状态管理: Pinia 2.x
- 路由: Vue Router 4.x
- 样式: Tailwind CSS 3.x
- 包管理: pnpm 9.15+
- Monorepo 工具: Turborepo

**核心职责**:
- 管理后台页面开发
- 组件封装与复用
- 状态管理设计
- 路由与权限控制
- API 接口封装
- 国际化支持
- 主题定制

**常用操作**:
```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 构建生产版本
pnpm build

# 类型检查
pnpm check:type

# 代码格式化
pnpm format
```

---

### 3. 全栈开发 Agent

**职责范围**: 跨前后端的完整功能开发

**工作流程**:
1. 定义 API 接口描述文件（`.api`）
2. 生成后端代码（handler/dto/router/logic）
3. 实现后端业务逻辑
4. 封装前端 API 请求
5. 开发前端页面组件
6. 联调测试

**关键文件**:
- API 定义: `gooze-vben-api/api/admin/*.api`
- 后端路由: `gooze-vben-api/internal/admin/router/`
- 前端 API: `gooze-vben-admin/apps/admin/src/api/`
- 前端页面: `gooze-vben-admin/apps/admin/src/views/`

---

## 开发规范

### 代码风格

#### 后端 (Go)
- 遵循 [Effective Go](https://go.dev/doc/effective_go)
- 包名: 小写、简洁、有意义
- 变量名: 小驼峰（camelCase）
- 结构体名: 大驼峰（PascalCase）
- 错误处理: 显式检查，不忽略错误

#### 前端 (TypeScript/Vue)
- 遵循 [Vue 风格指南](https://vuejs.org/style-guide/)
- 组件名: 大驼峰（PascalCase）
- 变量/函数: 小驼峰（camelCase）
- 常量: 全大写下划线分隔
- 使用 TypeScript 类型注解

### Git 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式
refactor: 重构
perf: 性能优化
test: 测试相关
chore: 构建/工具链
```

### 目录规范

**新增功能时**:
1. 后端: 在 `internal/admin/` 对应层添加代码
2. 前端: 在 `apps/admin/src/views/` 添加页面，`api/` 添加接口

---

## 快速开始

### 环境要求

- Node.js >= 20.10.0
- pnpm >= 9.12.0
- Go >= 1.24.0
- MySQL >= 5.7

### 启动步骤

1. **启动后端**:
```bash
cd gooze-vben-api
# 修改 configs/admin.yaml 数据库配置
sh ./build/scripts/start_admin.sh
```

2. **启动前端**:
```bash
cd gooze-vben-admin
pnpm install
pnpm dev
```

3. **访问**: http://localhost:5173 (默认)
   - 账号: admin / admin

---

## 核心功能模块

### 系统管理
- 用户管理: 用户增删改查、状态管理
- 角色管理: 角色定义、权限分配
- 菜单管理: 菜单配置、权限控制
- API 管理: 接口注册、权限绑定
- 字典管理: 系统字典配置
- 操作日志: 用户操作记录

### 素材管理
- 图片管理: 上传、预览、分类
- 视频管理: 上传、转码、播放
- 音频管理: 上传、播放列表

### 扩展组件
- 富文本编辑器: @wangeditor
- 素材选择器: MaterialPicker
- 素材上传器: MaterialUpload

---

## 权限系统

### 后端权限
- **认证**: JWT Token
- **授权**: Casbin RBAC
- **中间件**: JWT 验证 + Casbin 权限检查

### 前端权限
- **路由权限**: 动态路由生成
- **组件权限**: 自定义指令 `v-access`
- **按钮权限**: 权限码控制

---

## 文档索引

- 后端架构文档: [backend-api-architecture.md](./docs/backend-api-architecture.md)
- 前端架构文档: [frontend-admin-architecture.md](./docs/frontend-admin-architecture.md)
- API 文档: `gooze-vben-api/docs/swagger/`
- 数据库脚本: `gooze-vben-api/docs/sql/`

---

## 联系方式

- 项目地址: https://github.com/soryetong/gooze-vben
- 演示地址: http://8.137.16.100:5003/
