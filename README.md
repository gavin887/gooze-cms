<h1 align="center">Gooze-CMS</h1>

<p align="center">
  基于前后端分离架构的现代化内容管理系统
</p>
<p align="center">
  <a href="http://8.137.16.100:5003/">在线演示</a> ·
  <a href="https://github.com/soryetong/gooze-vben">项目地址</a>
</p>

---

## 目录

- [项目简介](#项目简介)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [架构设计](#架构设计)
- [核心功能模块](#核心功能模块)
- [权限系统](#权限系统)
- [环境要求](#环境要求)
- [配置指引](#配置指引)
- [启动方式](#启动方式)
- [开发规范](#开发规范)
- [部署构建](#部署构建)
- [文档索引](#文档索引)
- [联系方式](#联系方式)

---

## 项目简介

Gooze-CMS 是一个基于前后端分离架构的现代化内容管理系统，提供完整的用户权限体系、素材管理、内容管理等功能。后端采用 Go + Gin + GORM + Casbin 技术栈，前端采用 Vue 3 + TypeScript + Vite + Element Plus + Vben Admin 技术栈，具有高性能、易扩展、开发效率高等特点。

**主要特性**：

- 完整的 RBAC 权限管理（用户、角色、菜单、API 四级权限）
- 丰富的素材管理（图片、视频、音频）
- 可扩展的内容管理（分类、标签）
- 开箱即用的扩展组件（富文本编辑器、素材选择器、素材上传器）
- 国际化支持（简体中文、英文）
- 主题定制（亮/暗主题切换）
- 操作日志审计

---

## 技术栈

### 后端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Go | 1.24+ | 开发语言 |
| Gin | v1.10.1 | Web 框架 |
| GORM | v1.30.0 | ORM 框架 |
| Casbin | v2.109.0 | 权限控制框架 |
| Viper | v1.20.1 | 配置管理 |
| Zap | v1.27.0 | 日志框架 |
| gooze-starter | v1.0.1 | 项目脚手架 |
| MySQL | 5.7+ | 主数据库 |
| Redis | - | 缓存和会话管理 |

### 前端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Vue | 3.5+ | 前端框架 |
| TypeScript | 5.x | 类型系统 |
| Vite | 5.x | 构建工具 |
| Vue Router | 4.x | 路由管理 |
| Pinia | 2.x | 状态管理 |
| Element Plus | 2.x | UI 组件库 |
| Tailwind CSS | 3.x | CSS 框架 |
| pnpm | 9.15+ | 包管理器 |
| Turborepo | - | Monorepo 构建工具 |
| @wangeditor | ^5.1.23 | 富文本编辑器 |

---

## 项目结构

```
gooze-cms/
├── gooze-vben-admin/          # 前端管理后台（Monorepo 架构）
│   ├── apps/
│   │   └── admin/            # 主应用 - 管理后台
│   │       ├── public/       # 静态资源
│   │       ├── src/
│   │       │   ├── adapter/          # 组件适配器
│   │       │   ├── api/              # API 请求封装
│   │       │   ├── components/       # 业务组件
│   │       │   ├── directives/       # 自定义指令
│   │       │   ├── layouts/          # 布局组件
│   │       │   ├── locales/          # 国际化语言包
│   │       │   ├── router/           # 路由配置
│   │       │   ├── store/            # 业务状态管理
│   │       │   ├── views/            # 页面组件
│   │       │   ├── app.vue           # 根组件
│   │       │   ├── bootstrap.ts      # 启动引导
│   │       │   ├── main.ts           # 入口文件
│   │       │   └── preferences.ts    # 偏好设置
│   │       ├── .env.*         # 环境变量
│   │       └── vite.config.mts
│   ├── packages/                      # 可复用包
│   │   ├── @core/                    # 核心包
│   │   │   ├── base/
│   │   │   │   ├── design/           # 设计系统
│   │   │   │   ├── icons/            # 图标
│   │   │   │   ├── shared/           # 共享工具
│   │   │   │   └── typings/          # 类型定义
│   │   │   ├── composables/          # 组合式函数
│   │   │   ├── preferences/          # 偏好设置
│   │   │   └── ui-kit/               # UI 组件库
│   │   ├── constants/                # 常量
│   │   └── effects/
│   │       ├── access/               # 权限控制
│   │       └── common-ui/            # 通用 UI
│   └── internal/                      # 内部工具包
│       ├── lint-configs/             # 代码规范配置
│       ├── node-utils/               # Node 工具
│       ├── tailwind-config/          # Tailwind 配置
│       ├── tsconfig/                 # TypeScript 配置
│       └── vite-config/              # Vite 配置
├── gooze-vben-api/            # 后端 API 服务
│   ├── api/                   # API 描述文件（用于代码生成）
│   │   └── admin/
│   ├── build/
│   │   ├── docker/            # Docker 构建
│   │   └── scripts/           # 启动和代码生成脚本
│   ├── cmd/
│   │   └── admin/             # 服务入口
│   ├── configs/               # 配置文件
│   ├── docs/
│   │   ├── sql/               # 数据库脚本
│   │   └── swagger/           # Swagger API 文档
│   ├── internal/
│   │   ├── admin/
│   │   │   ├── bootstrap/     # 服务启动引导
│   │   │   ├── dto/           # 数据传输对象
│   │   │   ├── handler/       # 控制器
│   │   │   ├── logic/         # 业务逻辑
│   │   │   └── router/        # 路由定义
│   │   └── common/            # 公共模块
│   ├── middleware/            # 中间件
│   ├── models/                # 数据模型
│   └── static/                # 静态资源
├── docs/                      # 项目文档
│   ├── backend-api-architecture.md
│   └── frontend-admin-architecture.md
└── AGENTS.md                  # Agent 配置
```

---

## 架构设计

### 整体调用链路

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 用户浏览器                                    │
│                         (Chrome / Edge / Firefox 等)                          │
└───────────────────────────────────────┬─────────────────────────────────────┘
                                        │
                                        │ HTTP 请求
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            前端 Vue 应用 (gooze-vben-admin)                   │
│                                                                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   views/    │───▶│    api/     │───▶│  request.ts │───▶│   拦截器    │    │
│  │  (页面层)   │    │ (接口封装层) │    │ (请求客户端) │    │ (加Token等) │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    │
└───────────────────────────────────────┬─────────────────────────────────────┘
                                        │
                                        │ HTTP / RESTful API
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         后端 Gin 服务 (gooze-vben-api)                        │
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                         Gin Engine + 中间件                            │   │
│  │   ┌─────────┐  ┌─────────┐  ┌────────┐  ┌──────────┐  ┌───────────┐   │   │
│  │   │  CORS   │  │   JWT   │  │ Casbin │  │  Record  │  │  Error    │   │   │
│  │   │  跨域   │  │ 认证校验 │  │ 权限校验│  │ 操作日志  │  │ 异常处理  │   │   │
│  │   └─────────┘  └─────────┘  └────────┘  └──────────┘  └───────────┘   │   │
│  └───────────────────────────────────┬───────────────────────────────────┘   │
│                                      │                                       │
│                                      ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                           路由层 (router/)                             │   │
│  │    公开路由组 (无需认证)     /     私有路由组 (JWT + Casbin)            │   │
│  └───────────────────────────────────┬───────────────────────────────────┘   │
│                                      │                                       │
│                                      ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                         控制器层 (handler/)                            │   │
│  │              请求参数解析  →  参数校验  →  调用 Logic                   │   │
│  └───────────────────────────────────┬───────────────────────────────────┘   │
│                                      │                                       │
│                                      ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                        业务逻辑层 (logic/)                             │   │
│  │         业务规则处理  →  数据模型操作  →  事务控制                       │   │
│  └───────────────────────────────────┬───────────────────────────────────┘   │
│                                      │                                       │
│                                      ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                         数据模型层 (models/)                            │   │
│  │                GORM 模型  →  数据库操作  →  关联查询                    │   │
│  └───────────────────────────────────┬───────────────────────────────────┘   │
│                                      │                                       │
│                                      ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                      数据传输层 (dto/)                                 │   │
│  │              请求/响应结构体  →  数据转换  →  类型校验                   │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────┬─────────────────────────────────────┘
                                        │
                                        │ SQL / Redis 协议
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            数据存储层 (Database)                              │
│                                                                               │
│     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐      │
│     │      MySQL      │     │      Redis      │     │    本地/OSS      │      │
│     │   (主数据存储)   │     │  (缓存/会话管理) │     │   (素材文件存储)  │      │
│     └─────────────────┘     └─────────────────┘     └─────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 后端分层架构

```
┌─────────────────────────────────────────────────────────┐
│                     HTTP 请求层                          │
│  Gin Engine + Middleware (CORS/JWT/Casbin/Record)        │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                     路由层 (Router)                      │
│  InitRouter() -> 公开路由 / 私有路由分组                 │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                    控制器层 (Handler)                    │
│  请求参数解析 -> 调用 Logic -> 返回响应                  │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                    业务逻辑层 (Logic)                    │
│  业务规则处理 -> 数据模型操作 -> 事务控制                │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                    数据模型层 (Models)                   │
│  GORM 模型定义 -> 数据库操作 -> 关联查询                 │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                    数据传输层 (DTO)                      │
│  请求/响应结构体 -> 参数校验 -> 数据转换                 │
└─────────────────────────────────────────────────────────┘
```

### 前端分层架构

```
┌─────────────────────────────────────────────────────────┐
│                     入口层 (main.ts)                     │
│  initApplication() -> 初始化偏好设置 -> bootstrap()     │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                   启动引导层 (bootstrap.ts)              │
│  注册插件 -> 初始化 Store -> 配置路由 -> 挂载应用        │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                     布局层 (layouts/)                    │
│  basic.vue (主布局) / auth.vue (认证布局)                │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                     路由层 (router/)                     │
│  路由守卫 -> 动态路由生成 -> 权限控制                    │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                     视图层 (views/)                      │
│  页面组件 -> 业务逻辑 -> 组件组合                        │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                     状态层 (store/)                      │
│  Pinia Store -> 认证状态 -> 用户信息 -> 权限码           │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                     API 层 (api/)                        │
│  请求拦截 -> 响应拦截 -> 接口封装                        │
└─────────────────────────────────────────────────────────┘
```

### 用户登录认证链路

```
用户输入用户名密码
       │
       ▼
前端 login.vue 页面
       │
       ▼
authStore.authLogin() 调用 loginApi()
       │
       ▼
requestClient 发送 POST /api/v1/system/auth/login
       │
       ▼
后端路由匹配 → JWT 中间件跳过(公开路由)
       │
       ▼
handler.SystemAuthLogin() → 参数解析
       │
       ▼
logic.AuthLogic.SystemAuthLogin()
  ├── 查询用户 (SysUsers 表)
  ├── 检查用户状态
  ├── 验证密码 (Salt + Hash)
  └── 生成 JWT Token (含 id/username/role_id)
       │
       ▼
返回 AccessToken 给前端
       │
       ▼
前端 accessStore.setAccessToken()
       │
       ▼
并行调用:
  ├── getUserInfoApi() → userStore.setUserInfo()
  └── getAccessCodesApi() → accessStore.setAccessCodes()
       │
       ▼
路由守卫 generateAccess()
  ├── 根据角色过滤路由
  ├── 动态注册路由
  └── 生成侧边栏菜单
       │
       ▼
跳转首页，登录完成
```

---

## 核心功能模块

### 系统管理

| 模块 | 功能说明 | 后端关键文件 | 前端关键页面 |
|------|----------|-------------|-------------|
| **用户管理** | 用户增删改查、状态管理（启用/禁用）、密码重置、角色分配 | [system.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/system.go) | [user/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/user/index.vue) |
| **角色管理** | 角色增删改查、菜单权限分配、API 权限分配 | [sys_role.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_role.go) | [role/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/role/index.vue) |
| **菜单管理** | 菜单树状结构管理、菜单权限配置、菜单元信息 | [sys_menu.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_menu.go) | [menu/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/menu/index.vue) |
| **API 管理** | API 接口注册、API 分组管理、API 与角色绑定 | [sys_api.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_api.go) | [api/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/api/index.vue) |
| **字典管理** | 字典类型管理、字典数据管理、系统配置项 | [sys_dict.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_dict.go) | [dict/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/dict/index.vue) |
| **操作日志** | 用户操作记录、敏感数据脱敏、执行耗时统计 | [record.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/middleware/record.go) | [record/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/record/index.vue) |

### 内容管理

| 模块 | 功能说明 | 后端关键文件 | 前端关键页面 |
|------|----------|-------------|-------------|
| **分类管理** | 内容分类树状管理、分类排序、分类状态 | [content.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/content.go) | [category/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/content/category/index.vue) |
| **标签管理** | 标签增删改查、标签颜色配置 | [content.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/content.go) | [tag/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/content/tag/index.vue) |

### 素材管理

| 模块 | 功能说明 | 后端关键文件 | 前端关键页面 |
|------|----------|-------------|-------------|
| **图片管理** | 图片上传/预览/删除、图片分类、拖拽上传 | [material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/material.go) | [image/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/material/image/index.vue) |
| **视频管理** | 视频上传/转码/播放、视频分类 | [material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/material.go) | [video/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/material/video/index.vue) |
| **音频管理** | 音频上传/播放列表、音频分类 | [material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/material.go) | [audio/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/material/audio/index.vue) |

### 扩展组件

| 组件 | 说明 | 文件 |
|------|------|------|
| **RichEditor** | 富文本编辑器（基于 @wangeditor） | [RichEditor.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/RichEditor.vue) |
| **MaterialPicker** | 素材选择器（图片/音频/视频，支持单选多选） | [MaterialPicker.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/MaterialPicker.vue) |
| **MaterialUpload** | 素材上传器（支持数量/大小限制、格式校验） | [MaterialUpload.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/MaterialUpload.vue) |

---

## 权限系统

### 后端权限

后端采用 **JWT 认证 + Casbin RBAC 授权** 的双层权限机制。

```
1. 用户登录 -> POST /api/v1/system/auth/login
   ├─ 验证用户名密码
   ├─ 生成 JWT Token (含用户ID、角色ID)
   └─ 返回 AccessToken

2. 后续请求 -> Header: Authorization: Bearer <token>
   ├─ JWT 中间件验证 Token 有效性
   ├─ 解析 Token 获取用户信息
   ├─ Casbin 中间件检查角色权限
   └─ 执行业务逻辑
```

**Casbin RBAC 模型配置** ([rbac_model.conf](file:///e:/trae-playground/gooze-cms/gooze-vben-api/configs/rbac_model.conf)):

```conf
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act

[role_definition]
g = _, _

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) && r.act == p.act
```

- `sub`: 用户角色
- `obj`: API 路径 (如 `/api/v1/user/list`)
- `act`: HTTP 方法 (GET/POST/PUT/DELETE)

### 前端权限

前端通过 **路由权限、菜单权限、组件权限、按钮权限** 四级控制。

```
┌─────────────────────────────────────────────────────────┐
│                    路由权限                              │
│  动态路由生成 -> 基于角色过滤 -> 可访问路由注册           │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                    菜单权限                              │
│  权限码过滤 -> 树状菜单渲染 -> 菜单隐藏/显示              │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                    组件权限                              │
│  v-access 指令 -> 权限码判断 -> 组件显示/隐藏             │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                    按钮权限                              │
│  useAccess hook -> 权限码检查 -> 按钮禁用/启用            │
└─────────────────────────────────────────────────────────┘
```

**使用示例**:

```vue
<!-- v-access 指令控制按钮显示 -->
<button v-access="'system:user:create'">
  新增用户
</button>

<!-- v-permission 自定义指令（数组形式） -->
<button v-permission="['system:user:delete', 'system:user:update']">
  删除
</button>

<!-- 函数式判断 -->
<button v-if="hasAccess('system:user:delete')">
  删除
</button>
```

---

## 环境要求

| 依赖 | 最低版本 | 推荐版本 | 说明 |
|------|---------|---------|------|
| Node.js | 20.10.0 | 20.11.0+ | 前端运行环境 |
| pnpm | 9.12.0 | 9.15.5+ | 包管理器 |
| Go | 1.24.0 | 1.24.1+ | 后端运行环境 |
| MySQL | 5.7 | 8.0+ | 主数据库 |
| Redis | 5.0 | 7.0+ | 缓存（可选） |

---

## 配置指引

### 后端配置

后端配置文件位于 [gooze-vben-api/configs/admin.yaml](file:///e:/trae-playground/gooze-cms/gooze-vben-api/configs/admin.yaml)，支持通过 `.env.admin` 环境变量覆盖。

#### 核心配置项说明

```yaml
# 应用配置
app:
  name: gooze-cli              # 应用名称
  env: debug                   # 运行环境: debug/release/test
  addr: ":18002"               # 服务监听地址
  timeout: 1                    # 请求超时时间（秒）
  routerPrefix: /api/v1        # API 路由前缀

# 数据库配置（支持多数据源）
databases:
  - name: master               # 数据源名称
    driver: mysql              # 驱动: mysql/postgres/sqlite/sqlserver
    dsn: user:pass@tcp(host:port)/dbname?charset=utf8&parseTime=True&loc=Local&timeout=5s
    useGorm: true              # 是否使用 GORM
    maxIdleConn: 10            # 最大空闲连接数
    maxConn: 200               # 最大连接数
    slowThreshold: 2           # 慢查询阈值（秒）

# Redis 配置
redis:
  addr: "127.0.0.1:6379"       # Redis 地址
  password: ""                  # 密码
  db: 0                         # 数据库编号

# 日志配置
log:
  path: ./logs/                 # 日志文件路径
  mode: both                    # 输出模式: console/file/both
  maxSize: 1                    # 单文件大小上限（MB）
  maxBackups: 3                 # 最大备份文件数
  maxAge: 1                     # 日志保留天数

# JWT 配置
jwt:
  secretKey: 123456             # JWT 密钥（生产环境请修改为强随机字符串）
  expire: 86400                 # Token 过期时间（秒），默认 24 小时

# Casbin 权限配置
casbin:
  modePath: "./configs/rbac_model.conf"  # RBAC 模型文件路径
  dbName: master                          # 使用的数据库名

# OSS 素材存储配置
oss:
  type: local                   # 存储类型: local/aliyun/qiniu
  url: "http://localhost:18002" # 访问地址
  accessKey: ""                 # OSS AccessKey
  secretKey: ""                 # OSS SecretKey
  bucketName: ""                # 存储桶名称
```

#### 环境变量覆盖

创建或修改 [gooze-vben-api/.env.admin](file:///e:/trae-playground/gooze-cms/gooze-vben-api/.env.admin)，优先级高于 YAML 配置：

```dotenv
# 格式: APP_配置项（大写，下划线分隔）
APP_NAME=gooze-vben-api
APP_ADDR=:18002
APP_ROUTERPREFIX=/api/v1
```

### 前端配置

前端配置通过环境变量文件实现，位于 [gooze-vben-admin/apps/admin/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/) 目录下。

#### 环境变量文件

| 文件名 | 说明 |
|-------|------|
| `.env` | 通用配置，所有环境共享 |
| `.env.development` | 开发环境配置 |
| `.env.production` | 生产环境配置 |
| `.env.analyze` | 打包分析模式配置 |

#### 核心配置项说明

**.env** (通用配置):

```dotenv
# 应用标题
VITE_APP_TITLE=Gooze-Admin

# 应用命名空间，用于缓存、store等功能的前缀，确保隔离
VITE_APP_NAMESPACE=gooze-web-admin

# 主题
VITE_APP_THEME=light
```

**.env.development** (开发环境):

```dotenv
# 开发服务器端口
VITE_PORT=5003

# 应用基础路径
VITE_BASE=/

# 后端 API 地址（重要！需要与后端保持一致）
VITE_GLOB_API_URL=http://localhost:18002/api/v1

# 是否开启 Nitro Mock 服务
VITE_NITRO_MOCK=false

# 是否打开 Vue Devtools
VITE_DEVTOOLS=false

# 是否注入全局 loading
VITE_INJECT_APP_LOADING=true
```

#### Vite 配置

配置文件位于 [gooze-vben-admin/apps/admin/vite.config.mts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/vite.config.mts)，基于 `@vben/vite-config` 扩展。

---

## 启动方式

### 步骤一：初始化数据库

1. 创建 MySQL 数据库，例如 `gooze-admin`
2. 导入初始化 SQL 脚本：

```bash
# SQL 脚本位置
gooze-vben-api/docs/sql/default.sql
```

该脚本包含：
- 默认管理员账号 (admin / admin)
- 默认角色和权限配置
- 系统菜单数据
- 基础 API 配置

### 步骤二：启动后端服务

```bash
cd gooze-vben-api

# 1. 修改数据库配置
# 编辑 configs/admin.yaml，修改 databases.dsn 为你的数据库连接地址

# 2. 方式一：使用启动脚本
sh ./build/scripts/start_admin.sh

# 3. 方式二：直接运行
cd cmd/admin
go run main.go
```

服务启动后，API 默认监听 `http://localhost:18002`。

### 步骤三：启动前端服务

```bash
cd gooze-vben-admin

# 1. 启用 corepack（如果尚未启用）
npm i -g corepack
corepack enable

# 2. 安装依赖
pnpm install

# 3. 修改 API 地址
# 编辑 apps/admin/.env.development，修改 VITE_GLOB_API_URL

# 4. 启动开发服务器
pnpm dev
```

服务启动后，默认访问地址为 `http://localhost:5003`。

### 步骤四：访问系统

- 地址：http://localhost:5003
- 默认账号：`admin` / `admin`

> 演示地址：http://8.137.16.100:5003/ （演示账号权限受限，建议本地搭建）

---

## 开发规范

### 代码风格

#### 后端 (Go)

- 遵循 [Effective Go](https://go.dev/doc/effective_go) 规范
- 包名：小写、简洁、有意义
- 变量名：小驼峰（camelCase）
- 结构体名：大驼峰（PascalCase）
- 错误处理：显式检查，不忽略错误

```go
// 良好示例
func (s *UserService) GetUserByID(ctx context.Context, id int64) (*User, error) {
    user, err := s.repo.FindByID(ctx, id)
    if err != nil {
        gooze.Log.Error("查询用户失败", zap.Error(err), zap.Int64("id", id))
        return nil, fmt.Errorf("查询用户失败: %w", err)
    }
    return user, nil
}
```

#### 前端 (TypeScript/Vue)

- 遵循 [Vue 风格指南](https://vuejs.org/style-guide/)
- 组件名：大驼峰（PascalCase）
- 变量/函数：小驼峰（camelCase）
- 常量：全大写下划线分隔
- 使用 TypeScript 类型注解，避免使用 `any`

```typescript
// 使用 <script setup> 语法
<script setup lang="ts">
import { ref, computed } from 'vue'

interface Props {
  title?: string
  count?: number
}

const props = withDefaults(defineProps<Props>(), {
  title: '默认标题',
  count: 0,
})

const doubled = computed(() => props.count * 2)
</script>
```

### Git 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 Bug |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构（非新功能非修复） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具链变更 |

```bash
# 良好示例
feat(system): 新增用户导出功能
fix(auth): 修复 Token 过期时间计算错误
docs(readme): 更新启动说明
```

### 全栈开发流程

新增功能时按以下顺序开发：

```
1. 定义 API 接口描述文件 (gooze-vben-api/api/admin/*.api)
2. 运行代码生成脚本，生成后端骨架代码
3. 完善后端业务逻辑 (logic/*.go)
4. 封装前端 API 请求 (gooze-vben-admin/apps/admin/src/api/core/)
5. 开发前端页面组件 (gooze-vben-admin/apps/admin/src/views/)
6. 前后端联调测试
```

后端代码生成命令：

```bash
cd gooze-vben-api
sh ./build/scripts/gen_admin.sh
```

---

## 部署构建

### 前端构建

```bash
cd gooze-vben-admin

# 生产环境构建
pnpm build

# 构建分析
pnpm build:analyze

# 预览构建结果
pnpm preview
```

构建产物位于 `apps/admin/dist/` 目录，可部署到 Nginx 等静态文件服务器。

**Nginx 配置示例**:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    root /path/to/dist;
    index index.html;

    # 前端路由 fallback（重要！）
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API 反向代理
    location /api/ {
        proxy_pass http://backend-server:18002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 后端构建

```bash
cd gooze-vben-api

# 编译 Linux 版本
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o admin-server cmd/admin/main.go

# 编译 Windows 版本
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o admin-server.exe cmd/admin/main.go

# 运行后端
./admin-server
```

### Docker 部署

后端可通过 Docker 容器化部署，将编译好的二进制文件、配置文件、静态资源打包进镜像即可。

---

## 文档索引

| 文档 | 说明 |
|------|------|
| [AGENTS.md](file:///e:/trae-playground/gooze-cms/AGENTS.md) | Agent 开发配置与分工 |
| [backend-api-architecture.md](file:///e:/trae-playground/gooze-cms/docs/backend-api-architecture.md) | 后端 API 技术架构文档 |
| [frontend-admin-architecture.md](file:///e:/trae-playground/gooze-cms/docs/frontend-admin-architecture.md) | 前端 Admin 技术架构文档 |
| [Swagger API 文档](file:///e:/trae-playground/gooze-cms/gooze-vben-api/docs/swagger/) | 后端接口文档（自动生成） |
| [数据库脚本](file:///e:/trae-playground/gooze-cms/gooze-vben-api/docs/sql/) | 数据库初始化脚本 |
| [Vben Admin 文档](https://doc.vben.pro/) | 前端框架官方文档 |

---

## 联系方式

- **项目地址**：https://github.com/soryetong/gooze-vben
- **演示地址**：http://8.137.16.100:5003/
- **默认账号**：admin / admin

---

## License

[MIT](LICENSE)
