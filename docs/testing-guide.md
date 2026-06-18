# Gooze CMS 测试指南

## 测试框架选择

### 后端（Go + Gin + GORM）
- **测试框架**: Go 标准库 `testing` + `testify/assert`
- **优势**: 无需额外依赖，与项目现有测试风格一致，直接调用 Logic 层进行单元测试
- **测试类型**: Logic 层单元测试

### 前端（Vue 3 + TypeScript + Vite）
- **测试框架**: `@playwright/test`（E2E 测试）
- **优势**: Playwright 是现代前端 E2E 测试的首选，支持多浏览器，稳定性高，与 Vue 生态集成良好
- **测试类型**: 端到端测试（E2E）

---

## 测试文件结构

### 后端测试文件
```
gooze-vben-api/
└── test/
    ├── example_test.go          # 已有示例测试
    ├── category_test.go         # 分类管理测试
    ├── tag_test.go              # 标签管理测试
    ├── run_tests.ps1            # Windows 测试运行脚本
    └── run_tests.sh             # Linux/Mac 测试运行脚本
```

### 前端测试文件
```
gooze-vben-admin/apps/admin/
├── playwright.config.ts       # Playwright 配置
├── e2e/
│   ├── utils/
│   │   └── auth.ts            # 登录辅助工具
│   ├── category.spec.ts       # 分类管理 E2E 测试
│   └── tag.spec.ts            # 标签管理 E2E 测试
└── package.json               # 已添加测试脚本
```

---

## 后端测试（API Logic 层）

### 分类管理测试覆盖范围
| 测试用例 | 描述 |
|---------|------|
| TestCategoryAdd | 测试新增分类功能 |
| TestCategoryAddDuplicate | 测试重复分类名称验证 |
| TestCategoryList | 测试获取分类列表 |
| TestCategoryListWithFilter | 测试分类列表筛选（名称、状态） |
| TestCategoryTree | 测试获取分类树形结构 |
| TestCategoryInfo | 测试获取分类详情 |
| TestCategoryUpdate | 测试更新分类信息 |
| TestCategoryDelete | 测试删除分类 |
| TestCategoryDeleteWithChildren | 测试删除含子分类的父分类（应失败） |

### 标签管理测试覆盖范围
| 测试用例 | 描述 |
|---------|------|
| TestTagAdd | 测试新增标签功能 |
| TestTagAddDuplicate | 测试重复标签名称验证 |
| TestTagList | 测试获取标签列表 |
| TestTagListWithFilter | 测试标签列表筛选（名称、状态） |
| TestTagInfo | 测试获取标签详情 |
| TestTagUpdate | 测试更新标签信息 |
| TestTagDelete | 测试删除标签 |

### 运行后端测试

**Windows (PowerShell):**
```powershell
# 运行所有测试
.\test\run_tests.ps1

# 运行特定测试
.\test\run_tests.ps1 TestCategoryAdd
.\test\run_tests.ps1 TestTag
```

**Linux/Mac (Bash):**
```bash
# 运行所有测试
chmod +x ./test/run_tests.sh
./test/run_tests.sh

# 运行特定测试
./test/run_tests.sh TestCategoryAdd
./test/run_tests.sh TestTag
```

**直接使用 Go 命令:**
```bash
# 运行所有测试
cd gooze-vben-api
go test -v ./test/...

# 运行分类管理测试
go test -v ./test -run TestCategory

# 运行标签管理测试
go test -v ./test -run TestTag

# 运行单个测试用例
go test -v ./test -run TestCategoryAdd
```

### 测试前置条件
1. MySQL 数据库已启动并配置正确
2. 配置文件 `configs/admin.yaml` 和 `.env.admin` 已正确配置
3. 数据库表 `c_categories` 和 `c_tags` 已创建

---

## 前端测试（E2E）

### 分类管理 E2E 测试覆盖范围
| 测试用例 | 描述 |
|---------|------|
| 页面加载验证 | 验证页面元素正确显示 |
| 搜索筛选功能 | 测试按名称和状态筛选 |
| 新增分类功能 | 测试完整的新增分类流程 |
| 编辑分类功能 | 测试完整的编辑分类流程 |
| 状态切换功能 | 测试启用/禁用状态切换 |
| 删除分类功能 | 测试删除分类流程 |
| 展开/收起全部 | 测试树形结构展开收起 |
| 列表导出功能 | 测试数据导出功能 |

### 标签管理 E2E 测试覆盖范围
| 测试用例 | 描述 |
|---------|------|
| 页面加载验证 | 验证页面元素正确显示 |
| 搜索筛选功能 | 测试按名称和状态筛选 |
| 新增标签功能 | 测试完整的新增标签流程 |
| 编辑标签功能 | 测试完整的编辑标签流程 |
| 状态切换功能 | 测试启用/禁用状态切换 |
| 删除标签功能 | 测试删除标签流程 |
| 列表导出功能 | 测试数据导出功能 |
| 分页功能 | 测试分页切换功能 |

### 安装 Playwright 浏览器

```bash
cd gooze-vben-admin/apps/admin
pnpm exec playwright install
```

### 运行前端 E2E 测试

```bash
cd gooze-vben-admin/apps/admin

# 运行所有测试（无头模式）
pnpm test:e2e

# 运行分类管理测试
pnpm test:e2e:category

# 运行标签管理测试
pnpm test:e2e:tag

# 运行测试并显示浏览器
pnpm test:e2e:headed

# 使用 UI 模式运行
pnpm test:e2e:ui

# 调试模式
pnpm test:e2e:debug

# 指定浏览器运行
pnpm test:e2e -- --project=chromium
pnpm test:e2e -- --project=firefox
pnpm test:e2e -- --project=webkit
```

### 测试前置条件
1. 后端 API 服务已启动（默认端口 8000）
2. 前端开发服务器已启动（默认端口 5173）
3. 测试账号 admin/admin 可用
4. Playwright 浏览器已安装

### 环境变量配置

创建 `.env.test` 文件：
```env
# 测试环境配置
VITE_API_BASE_URL=http://localhost:8000
PLAYWRIGHT_BASE_URL=http://localhost:5173
```

---

## 测试数据清理

测试过程中会创建以下测试数据，请在测试完成后清理：

**分类管理测试数据:**
- `测试分类`
- `待更新分类` → `已更新分类`
- `待删除分类`
- `父分类`、`子分类`

**标签管理测试数据:**
- `测试标签`
- `待更新标签` → `已更新标签`
- `待删除标签`
- `E2E测试分类_*`
- `E2E测试标签_*`
- `分页测试标签_*`

---

## CI/CD 集成示例

### GitHub Actions
```yaml
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.24'
      - name: Run backend tests
        working-directory: gooze-vben-api
        run: go test -v ./test/...

  frontend-e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - name: Install dependencies
        working-directory: gooze-vben-admin
        run: pnpm install
      - name: Install Playwright browsers
        working-directory: gooze-vben-admin/apps/admin
        run: pnpm exec playwright install --with-deps
      - name: Run E2E tests
        working-directory: gooze-vben-admin/apps/admin
        run: pnpm test:e2e
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: gooze-vben-admin/apps/admin/playwright-report/
```

---

## 测试报告

### 后端测试
- 终端输出详细的测试结果
- 使用 `-json` 参数生成 JSON 格式报告：`go test -v -json ./test/... > test-report.json`

### 前端测试
- Playwright 自动生成 HTML 报告，位于 `playwright-report/` 目录
- 失败测试自动截图，位于 `test-results/` 目录
- 查看报告：`pnpm exec playwright show-report`

---

## 扩展测试建议

1. **性能测试**: 可添加 `k6` 或 `vegeta` 进行 API 性能测试
2. **安全测试**: 添加 SQL 注入、XSS 等安全测试用例
3. **并发测试**: 测试并发操作时的数据一致性
4. **边界测试**: 测试空数据、超长字符串、特殊字符等边界情况
5. **Mock 测试**: 对于依赖外部服务的功能，使用 Mock 进行隔离测试
