# 后端 API 模块技术架构文档

## 1. 模块概述

**模块名称**: Gooze Vben API

**模块定位**: 提供 CMS 管理后台的 RESTful API 服务，处理用户认证、权限控制、系统管理、素材管理等核心业务逻辑。

**模块位置**: [gooze-vben-api/](file:///e:/trae-playground/gooze-cms/gooze-vben-api/)

---

## 2. 技术栈

### 2.1 核心技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Go | 1.24.1 | 开发语言 |
| Gin | v1.10.1 | Web 框架 |
| GORM | v1.30.0 | ORM 框架 |
| Casbin | v2.109.0 | 权限控制框架 |
| Viper | v1.20.1 | 配置管理 |
| Zap | v1.27.0 | 日志框架 |
| gooze-starter | v1.0.1 | 项目脚手架 |

### 2.2 数据库支持

- **主数据库**: MySQL 5.7+
- **支持数据库**: MySQL / PostgreSQL / SQLite / SQL Server
- **Redis**: 用于缓存和会话管理
- **MongoDB**: 可选，用于非结构化数据存储

### 2.3 核心依赖

```go
// go.mod
require (
    github.com/casbin/gorm-adapter/v3 v3.33.0    // Casbin GORM 适配器
    github.com/gin-gonic/gin v1.10.1             // Web 框架
    github.com/jinzhu/copier v0.4.0              // 结构体复制
    github.com/soryetong/gooze-starter v1.0.1    // 项目脚手架
    github.com/spf13/cast v1.9.2                 // 类型转换
    github.com/spf13/viper v1.20.1               // 配置管理
    go.uber.org/zap v1.27.0                      // 日志
    gorm.io/gorm v1.30.0                         // ORM
)
```

---

## 3. 架构设计

### 3.1 整体架构

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

### 3.2 分层架构详解

#### 3.2.1 入口层 (cmd/)

**文件**: [cmd/admin/main.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/cmd/admin/main.go)

```go
package main

import (
    _ "gooze-vben-api/internal/admin/bootstrap"
    _ "github.com/soryetong/gooze-starter/modules/casbinmodule"
    _ "github.com/soryetong/gooze-starter/modules/dbmodule"
    "github.com/soryetong/gooze-starter/gooze"
)

func main() {
    gooze.Run()
}
```

**职责**:
- 导入必要的模块初始化
- 注册服务
- 启动应用

#### 3.2.2 启动层 (bootstrap/)

**文件**: [internal/admin/bootstrap/AdminServer.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/bootstrap/AdminServer.go)

```go
type AdminServer struct {
    *gooze.IServer
    httpModule httpmodule.IHttp
}

func (self *AdminServer) OnStart() (err error) {
    // 缓存 API 信息
    new(logic.SystemLogic).CacheApiInfo()
    
    // 初始化 HTTP 模块
    self.httpModule.Init(self, addr, timeout, router.InitRouter())
    return self.httpModule.Start()
}
```

**职责**:
- 服务启动钩子
- 预加载数据（如 API 信息缓存）
- 初始化 HTTP 服务
- 注册退出回调

#### 3.2.3 路由层 (router/)

**文件**: [internal/admin/router/router.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/router/router.go)

**路由分组**:

```go
func InitRouter() *gin.Engine {
    r := gin.New()
    
    // 全局中间件
    r.Use(gzmiddleware.Begin())
    r.Use(gzmiddleware.ErrorHandler())
    r.Use(gzmiddleware.Cross())
    r.Use(middleware.Record())
    
    // 公开路由组 - 不需要认证
    publicGroup := r.Group("api/v1")
    {
        publicGroup.GET("/health", healthCheck)
        InitSystemAuthPublicRouter(publicGroup)  // 登录、注册等
    }
    
    // 私有路由组 - 需要 JWT + Casbin 认证
    privateAuthGroup := r.Group("api/v1")
    privateAuthGroup.Use(gzmiddleware.Jwt(), gzmiddleware.Casbin())
    {
        InitMaterialAuthRouter(privateAuthGroup)  // 素材管理
        InitApiAuthRouter(privateAuthGroup)       // API 管理
        InitDictAuthRouter(privateAuthGroup)      // 字典管理
        InitMenuAuthRouter(privateAuthGroup)      // 菜单管理
        InitRecordAuthRouter(privateAuthGroup)    // 操作日志
        InitRoleAuthRouter(privateAuthGroup)      // 角色管理
        InitUserAuthRouter(privateAuthGroup)      // 用户管理
    }
    
    return r
}
```

**路由文件**:
- [auth.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/router/auth.go) - 认证相关路由
- [system.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/router/system.go) - 系统管理路由
- [material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/router/material.go) - 素材管理路由

#### 3.2.4 中间件层 (middleware/)

**核心中间件**:

1. **操作日志中间件** [middleware/record.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/middleware/record.go)

```go
func Record() gin.HandlerFunc {
    return func(ctx *gin.Context) {
        startTime := time.Now()
        
        // 跳过 GET 请求和指定路径
        path, id := gzutil.GetRequestPath(ctx.Request.URL.Path, "/api")
        if _, ok := notRecord[path]; ok || ctx.Request.Method == gzhttp.Method_GET {
            ctx.Next()
            return
        }
        
        // 1. 采集请求参数（含敏感数据脱敏）
        reqData := collectRequestData(ctx)
        maskSensitive(reqData)
        
        // 2. 包装响应写入器以捕获响应
        writer := &responseBodyWriter{
            ResponseWriter: ctx.Writer,
            body:           bytes.NewBuffer(nil),
        }
        ctx.Writer = writer
        
        // 3. 执行业务逻辑
        ctx.Next()
        
        // 4. 异步记录操作日志
        record := models.SysRecords{
            Method:      ctx.Request.Method,
            Path:        path,
            Request:     string(reqJson),
            UserId:      gzauth.GetTokenValue[int64](ctx, "id"),
            Username:    gzauth.GetTokenValue[string](ctx, "username"),
            Platform:    gzutil.GetPlatform(userAgent),
            Description: new(logic.SystemLogic).GetRecordDescription(...),
            Ip:          gzutil.GetClientRealIP(ctx),
            Elapsed:     fmt.Sprintf("%.2f", time.Since(startTime).Seconds()*1000),
            StatusCode:  int64(ctx.Writer.Status()),
            Response:    writer.body.String(),
        }
        
        asyncSaveRecord(record)
    }
}
```

**功能特性**:
- 请求参数采集（Query + Body）
- 敏感数据脱敏（password/token 等）
- 响应数据捕获
- 执行耗时统计
- 异步写入数据库，不影响主流程

2. **JWT 认证中间件** (gooze-starter 内置)
   - 验证 Authorization Header
   - 解析 Token 载荷
   - 将用户信息注入 Context

3. **Casbin 权限中间件** (gooze-starter 内置)
   - 基于 RBAC 模型的权限校验
   - 检查用户角色对 API 的访问权限

4. **CORS 跨域中间件** (gooze-starter 内置)
   - 处理跨域请求
   - 配置允许的 Origin/Method/Header

#### 3.2.5 控制器层 (handler/)

**代码生成**: 通过 `.api` 文件定义，由 gooze-starter 自动生成

**API 定义示例** [api/admin/auth.api](file:///e:/trae-playground/gooze-cms/gooze-vben-api/api/admin/auth.api):

```
type LoginReq {
    Username string `json:"username" binding:"required"`
    Password string `json:"password" binding:"required"`
}

type LoginResp {
    Id int64 `json:"id"`
    RealName string `json:"realName"`
    Username string `json:"username"`
    AccessToken string `json:"accessToken"`
}

service SystemAuth Group Public {
    post login (LoginReq) returns (LoginResp)
    post logout (LogoutReq) returns
}
```

**生成的 Handler** [internal/admin/handler/auth_gen.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/handler/auth_gen.go):

```go
func SystemAuthLogin(ctx *gin.Context) {
    var req dto.LoginReq
    if err := ctx.ShouldBindJSON(&req); err != nil {
        gzhttp.Fail(ctx, http.StatusBadRequest, err.Error())
        return
    }
    
    resp, err := new(logic.AuthLogic).SystemAuthLogin(ctx, &req)
    if err != nil {
        gzhttp.Fail(ctx, http.StatusInternalServerError, err.Error())
        return
    }
    
    gzhttp.Ok(ctx, resp)
}
```

#### 3.2.6 业务逻辑层 (logic/)

**文件示例** [internal/admin/logic/auth.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/auth.go):

```go
type AuthLogic struct{}

func NewAuthLogic() *AuthLogic {
    return &AuthLogic{}
}

func (self *AuthLogic) SystemAuthLogin(ctx context.Context, params *dto.LoginReq) (resp *dto.LoginResp, err error) {
    // 1. 查询用户
    user := new(models.SysUsers)
    if err = gooze.Gorm().Model(&models.SysUsers{}).
        Where("username = ?", params.Username).
        First(user).Error; err != nil {
        return nil, errors.New("用户不存在")
    }
    
    // 2. 检查用户状态
    if user.Status != models.SysUserStatusNormal {
        return nil, errors.New("用户已被禁用")
    }
    
    // 3. 验证密码
    if !gzutil.ValidatePasswd(params.Password, user.Salt, user.Password) {
        return nil, errors.New("密码错误")
    }
    
    // 4. 生成 JWT Token
    token, err := gzauth.GenerateJwtToken(map[string]interface{}{
        "id":       user.Id,
        "username": user.Username,
        "role_id":  user.RoleId,
        "exp":      time.Now().Add(time.Minute * 20).Unix(),
    })
    if err != nil {
        gooze.Log.Error("生成 token 失败", zap.Error(err))
        return nil, errors.New("生成 token 失败")
    }
    
    // 5. 组装响应
    resp = &dto.LoginResp{
        AccessToken: token,
        Id:          user.Id,
        RealName:    user.Username,
        Username:    user.Username,
    }
    
    return resp, nil
}
```

**Logic 层文件**:
- [auth.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/auth.go) - 认证逻辑
- [system.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/system.go) - 系统管理逻辑
- [material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/material.go) - 素材管理逻辑

#### 3.2.7 数据传输层 (dto/)

**文件示例** [internal/admin/dto/auth.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/dto/auth.go):

```go
type LoginReq struct {
    Username string `json:"username" binding:"required"`
    Password string `json:"password" binding:"required"`
}

type LoginResp struct {
    Id          int64    `json:"id"`
    RealName    string   `json:"realName"`
    Roles       []string `json:"roles"`
    Username    string   `json:"username"`
    AccessToken string   `json:"accessToken"`
}
```

**DTO 层文件**:
- [auth.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/dto/auth.go) - 认证 DTO
- [system.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/dto/system.go) - 系统管理 DTO
- [material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/dto/material.go) - 素材管理 DTO

#### 3.2.8 数据模型层 (models/)

**基础模型** [models/model.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/model.go):

```go
type GnModel struct {
    Id        int64          `gorm:"primary" json:"id"`
    CreatedAt time.Time      `json:"createdAt" gorm:"created_at"`
    UpdatedAt time.Time      `json:"-"`
    DeletedAt gorm.DeletedAt `json:"-"`
}
```

**用户模型** [models/sys_user.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_user.go):

```go
type SysUsers struct {
    GnModel
    Username      string    `json:"username" gorm:"username"`
    Nickname      string    `json:"nickname" gorm:"nickname"`
    Password      string    `json:"password" gorm:"password"`
    Salt          string    `json:"salt" gorm:"salt"`
    Mobile        string    `json:"mobile" gorm:"mobile"`
    Gender        int64     `json:"gender" gorm:"gender"`
    Email         string    `json:"email" gorm:"email"`
    Avatar        string    `json:"avatar" gorm:"avatar"`
    Status        int64     `json:"status" gorm:"status"`
    RoleId        int64     `json:"roleId" gorm:"role_id"`
    LastLoginTime int64     `json:"lastLoginTime" gorm:"last_login_time"`
    LastLoginIp   string    `json:"lastLoginIp" gorm:"last_login_ip"`
    
    SysRole SysRoles `json:"sysRole" gorm:"foreignKey:RoleId;references:Id"`
}

func (*SysUsers) TableName() string {
    return "sys_users"
}
```

**所有数据模型**:
- [model.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/model.go) - 基础模型
- [sys_user.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_user.go) - 用户模型
- [sys_role.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_role.go) - 角色模型
- [sys_menu.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_menu.go) - 菜单模型
- [sys_api.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_api.go) - API 模型
- [sys_dict.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_dict.go) - 字典模型
- [sys_record.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_record.go) - 操作日志模型
- [sys_role_auth.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_role_auth.go) - 角色权限关联
- [sys_role_api.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_role_api.go) - 角色 API 关联
- [c_materials.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/c_materials.go) - 素材模型

---

## 4. 权限系统设计

### 4.1 认证流程

```
1. 用户登录 -> POST /api/v1/login
   ├─ 验证用户名密码
   ├─ 生成 JWT Token (含用户ID、角色ID)
   └─ 返回 AccessToken

2. 后续请求 -> Header: Authorization: Bearer <token>
   ├─ JWT 中间件验证 Token 有效性
   ├─ 解析 Token 获取用户信息
   ├─ Casbin 中间件检查角色权限
   └─ 执行业务逻辑
```

### 4.2 Casbin RBAC 模型

**配置文件**: [configs/rbac_model.conf](file:///e:/trae-playground/gooze-cms/gooze-vben-api/configs/rbac_model.conf)

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

**权限检查逻辑**:
- `sub`: 用户角色
- `obj`: API 路径 (如 `/api/v1/user/list`)
- `act`: HTTP 方法 (GET/POST/PUT/DELETE)

---

## 5. 配置管理

### 5.1 配置文件

**主配置**: [configs/admin.yaml](file:///e:/trae-playground/gooze-cms/gooze-vben-api/configs/admin.yaml)

```yaml
app:
  name: gooze-cli
  env: debug                    # debug/release/test
  addr: ":18002"                # 服务端口
  timeout: 1                    # 请求超时(秒)
  routerPrefix: /api/v1

databases:
  - name: master
    driver: mysql
    dsn: root:123456@tcp(127.0.0.1:3307)/gooze-admin?charset=utf8&parseTime=True&loc=Local&timeout=5s
    useGorm: true
    maxIdleConn: 10
    maxConn: 200
    slowThreshold: 2            # 慢查询阈值(秒)

redis:
  addr: "127.0.0.1:6379"
  password: ""
  db: 0

log:
  path: ./logs/
  mode: both                    # console/file/both
  maxSize: 1                    # 单文件大小(MB)
  maxBackups: 3                 # 最大备份数
  maxAge: 1                     # 保留天数

jwt:
  secretKey: 123456
  expire: 86400                 # Token 过期时间(秒)

casbin:
  modePath: "./configs/rbac_model.conf"
  dbName: master

oss:
  type: local                   # local/aliyun/qiniu
  url: "http://192.168.5.122:18002"
```

### 5.2 环境变量覆盖

**文件**: [.env.admin](file:///e:/trae-playground/gooze-cms/gooze-vben-api/.env.admin)

支持通过环境变量覆盖配置，优先级高于 YAML 文件。

---

## 6. 核心业务模块

### 6.1 用户管理模块

**功能**:
- 用户增删改查
- 用户状态管理（启用/禁用）
- 密码重置
- 用户角色分配
- 登录日志记录

**关键文件**:
- API: [api/admin/system.api](file:///e:/trae-playground/gooze-cms/gooze-vben-api/api/admin/system.api)
- Logic: `SystemUserList`, `SystemUserCreate`, `SystemUserUpdate`, `SystemUserDelete`

### 6.2 角色管理模块

**功能**:
- 角色增删改查
- 角色权限分配（菜单权限 + API 权限）
- 角色数据权限配置

**关键文件**:
- 模型: [models/sys_role.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_role.go)
- 关联: [models/sys_role_auth.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_role_auth.go), [models/sys_role_api.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/models/sys_role_api.go)

### 6.3 菜单管理模块

**功能**:
- 菜单树状结构管理
- 菜单权限配置
- 菜单元信息（图标、排序、隐藏等）

### 6.4 API 管理模块

**功能**:
- API 接口注册
- API 分组管理
- API 与角色绑定

### 6.5 字典管理模块

**功能**:
- 字典类型管理
- 字典数据管理
- 系统配置项

### 6.6 素材管理模块

**功能**:
- 图片上传/预览/删除
- 视频上传/转码/播放
- 音频上传/播放
- 素材分类管理
- OSS 存储支持（本地/阿里云/七牛云）

**关键文件**:
- Logic: [internal/admin/logic/material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/logic/material.go)
- DTO: [internal/admin/dto/material.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/admin/dto/material.go)
- OSS: [internal/common/oss.go](file:///e:/trae-playground/gooze-cms/gooze-vben-api/internal/common/oss.go)

---

## 7. 代码生成机制

### 7.1 API 定义驱动开发

**工作流程**:

```
1. 编写 .api 定义文件 (api/admin/*.api)
2. 运行代码生成脚本: sh ./build/scripts/gen_admin.sh
3. 自动生成:
   ├─ handler/*_gen.go      - 控制器代码
   ├─ dto/*.go              - 数据传输对象
   ├─ router/*.go           - 路由注册
   ├─ logic/*_gen.go        - 业务逻辑骨架
   └─ docs/swagger/*.yaml   - Swagger 文档
4. 手动完善 logic/*.go 中的业务逻辑
```

### 7.2 生成脚本

**文件**: [build/scripts/gen_admin.sh](file:///e:/trae-playground/gooze-cms/gooze-vben-api/build/scripts/gen_admin.sh)

---

## 8. 数据库设计

### 8.1 核心表结构

| 表名 | 说明 |
|------|------|
| sys_users | 用户表 |
| sys_roles | 角色表 |
| sys_menus | 菜单表 |
| sys_apis | API 接口表 |
| sys_dicts | 字典表 |
| sys_records | 操作日志表 |
| sys_role_auths | 角色菜单权限关联表 |
| sys_role_apis | 角色 API 权限关联表 |
| c_materials | 素材表 |

### 8.2 初始化脚本

**文件**: [docs/sql/default.sql](file:///e:/trae-playground/gooze-cms/gooze-vben-api/docs/sql/default.sql)

包含初始数据：
- 默认管理员账号 (admin/admin)
- 默认角色
- 系统菜单
- 基础 API 配置

---

## 9. 部署与运行

### 9.1 启动方式

```bash
# 方式一: 使用启动脚本
sh ./build/scripts/start_admin.sh

# 方式二: 直接运行
cd cmd/admin
go run main.go
```

### 9.2 项目构建

```bash
# 编译 Linux 版本
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o admin-server cmd/admin/main.go

# 编译 Windows 版本
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o admin-server.exe cmd/admin/main.go
```

---

## 10. 最佳实践

### 10.1 错误处理

- 统一使用 `gzhttp.Fail(ctx, code, msg)` 返回错误
- 错误信息需要用户友好，避免暴露内部细节
- 关键错误必须记录日志

### 10.2 日志规范

```go
// 使用 gooze.Log 记录日志
gooze.Log.Info("操作成功", zap.String("module", "user"), zap.Int64("userId", id))
gooze.Log.Error("操作失败", zap.Error(err), zap.Any("params", params))
```

### 10.3 数据库操作

- 使用事务处理多表操作
- 避免 N+1 查询，合理使用 Preload
- 敏感字段（密码）加密存储

### 10.4 安全建议

- JWT Secret 使用强随机字符串
- 配置文件中的敏感信息使用环境变量
- 接口请求频率限制
- SQL 注入防护（GORM 已内置）
- XSS 攻击防护

---

## 11. 扩展阅读

- [Gin 官方文档](https://gin-gonic.com/)
- [GORM 官方文档](https://gorm.io/)
- [Casbin 官方文档](https://casbin.org/)
- [gooze-starter 文档](https://soryetong.github.io/gooze-docs/)
