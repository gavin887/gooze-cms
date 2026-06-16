# 前端 Admin 模块技术架构文档

## 1. 模块概述

**模块名称**: Gooze Vben Admin

**模块定位**: CMS 管理后台前端应用，提供用户友好的管理界面，包括系统管理、素材管理、数据可视化等功能。

**模块位置**: [gooze-vben-admin/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/)

**技术基础**: 基于 [Vue Vben Admin](https://doc.vben.pro/) 二次开发

---

## 2. 技术栈

### 2.1 核心技术栈

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

### 2.2 核心依赖

```json
// apps/admin/package.json
{
  "dependencies": {
    "@wangeditor/editor": "^5.1.23",           // 富文本编辑器
    "@wangeditor/editor-for-vue": "^5.1.12",   // 富文本编辑器 Vue 版
    "@vueuse/core": "catalog:",                // Vue 组合式工具集
    "dayjs": "catalog:",                        // 日期处理
    "element-plus": "catalog:",                 // UI 组件库
    "lucide-vue-next": "0.465.0",               // 图标库
    "pinia": "catalog:",                        // 状态管理
    "vue": "catalog:",                          // 框架
    "vue-router": "catalog:",                   // 路由
    "vue-toastification": "2.0.0-rc.5"          // 消息提示
  }
}
```

### 2.3 内部包依赖 (Workspace)

项目采用 Monorepo 架构，内部包通过 workspace 引用：

| 包名 | 用途 |
|------|------|
| @vben/access | 权限控制 |
| @vben/common-ui | 通用 UI 组件 |
| @vben/constants | 常量定义 |
| @vben/hooks | 组合式函数 |
| @vben/icons | 图标组件 |
| @vben/layouts | 布局组件 |
| @vben/locales | 国际化 |
| @vben/preferences | 偏好设置 |
| @vben/request | HTTP 请求 |
| @vben/stores | 状态管理 |
| @vben/styles | 样式系统 |
| @vben/types | 类型定义 |
| @vben/utils | 工具函数 |

---

## 3. 架构设计

### 3.1 Monorepo 项目结构

```
gooze-vben-admin/
├── apps/                          # 应用目录
│   └── admin/                    # 主应用 - 管理后台
│       ├── public/               # 静态资源
│       ├── src/
│       │   ├── adapter/          # 组件适配器
│       │   ├── api/              # API 请求封装
│       │   ├── components/       # 业务组件
│       │   ├── directives/       # 自定义指令
│       │   ├── layouts/          # 布局组件
│       │   ├── locales/          # 国际化语言包
│       │   ├── router/           # 路由配置
│       │   ├── store/            # 业务状态管理
│       │   ├── views/            # 页面组件
│       │   ├── app.vue           # 根组件
│       │   ├── bootstrap.ts      # 启动引导
│       │   ├── main.ts           # 入口文件
│       │   └── preferences.ts    # 偏好设置
│       ├── .env.*                # 环境变量
│       ├── index.html
│       ├── vite.config.mts       # Vite 配置
│       └── package.json
├── packages/                      # 可复用包
│   ├── @core/                    # 核心包
│   │   ├── base/
│   │   │   ├── design/           # 设计系统
│   │   │   ├── icons/            # 图标
│   │   │   ├── shared/           # 共享工具
│   │   │   └── typings/          # 类型定义
│   │   ├── composables/          # 组合式函数
│   │   ├── preferences/          # 偏好设置
│   │   └── ui-kit/               # UI 组件库
│   │       ├── form-ui/          # 表单组件
│   │       ├── layout-ui/        # 布局组件
│   │       ├── menu-ui/          # 菜单组件
│   │       ├── popup-ui/         # 弹窗组件
│   │       ├── shadcn-ui/        # Shadcn 组件
│   │       └── tabs-ui/          # 标签页组件
│   ├── constants/                # 常量
│   └── effects/
│       ├── access/               # 权限控制
│       └── common-ui/            # 通用 UI
├── internal/                      # 内部工具包
│   ├── lint-configs/             # 代码规范配置
│   ├── node-utils/               # Node 工具
│   ├── tailwind-config/          # Tailwind 配置
│   ├── tsconfig/                 # TypeScript 配置
│   └── vite-config/              # Vite 配置
├── package.json                  # 根 package.json
├── pnpm-workspace.yaml           # pnpm workspace 配置
└── turbo.json                    # Turborepo 配置
```

### 3.2 应用架构

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

### 3.3 分层架构详解

#### 3.3.1 入口层 (main.ts)

**文件**: [apps/admin/src/main.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/main.ts)

```typescript
import { initPreferences } from '@vben/preferences';
import { unmountGlobalLoading } from '@vben/utils';
import { overridesPreferences } from './preferences';

async function initApplication() {
  // 1. 构建命名空间，用于隔离不同环境的数据存储
  const env = import.meta.env.PROD ? 'prod' : 'dev';
  const appVersion = import.meta.env.VITE_APP_VERSION;
  const namespace = `${import.meta.env.VITE_APP_NAMESPACE}-${appVersion}-${env}`;

  // 2. 初始化应用偏好设置（主题、语言、布局等）
  await initPreferences({
    namespace,
    overrides: overridesPreferences,
  });

  // 3. 启动应用并挂载
  const { bootstrap } = await import('./bootstrap');
  await bootstrap(namespace);

  // 4. 移除全局加载动画
  unmountGlobalLoading();
}

initApplication();
```

**职责**:
- 构建应用命名空间
- 初始化偏好设置
- 加载启动引导
- 移除加载动画

#### 3.3.2 启动引导层 (bootstrap.ts)

**文件**: [apps/admin/src/bootstrap.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/bootstrap.ts)

```typescript
async function bootstrap(namespace: string) {
  // 1. 初始化组件适配器
  await initComponentAdapter();

  const app = createApp(App);

  // 2. 注册 Element Plus
  app.use(ElementPlus);

  // 3. 配置国际化 i18n
  await setupI18n(app);

  // 4. 初始化 Pinia Store
  await initStores(app, { namespace });

  // 5. 安装权限指令
  registerAccessDirective(app);

  // 6. 初始化 Tippy 工具提示
  initTippy(app);

  // 7. 配置路由及路由守卫
  app.use(router);

  // 8. 动态更新页面标题
  watchEffect(() => {
    if (preferences.app.dynamicTitle) {
      const routeTitle = router.currentRoute.value.meta?.title;
      const pageTitle =
        (routeTitle ? `${$t(routeTitle)} - ` : '') + preferences.app.name;
      useTitle(pageTitle);
    }
  });

  // 9. 配置消息提示
  app.use(Toast, {
    position: POSITION.TOP_RIGHT,
    timeout: 5000,
  });

  // 10. 注册自定义权限指令
  app.directive('permission', permission);

  // 11. 挂载应用
  app.mount('#app');
}
```

#### 3.3.3 路由层 (router/)

**核心文件**:
- [index.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/router/index.ts) - 路由实例创建
- [guard.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/router/guard.ts) - 路由守卫
- [access.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/router/access.ts) - 动态路由生成
- [routes/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/router/routes/) - 路由配置

**路由创建**:

```typescript
const router = createRouter({
  history:
    import.meta.env.VITE_ROUTER_HISTORY === 'hash'
      ? createWebHashHistory(import.meta.env.VITE_BASE)
      : createWebHistory(import.meta.env.VITE_BASE),
  routes,
  scrollBehavior: (to, _from, savedPosition) => {
    if (savedPosition) return savedPosition;
    return to.hash ? { behavior: 'smooth', el: to.hash } : { left: 0, top: 0 };
  },
});

// 创建路由守卫
createRouterGuard(router);

export { router };
```

**路由守卫流程** [guard.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/router/guard.ts):

```typescript
function setupAccessGuard(router: Router) {
  router.beforeEach(async (to, from) => {
    const accessStore = useAccessStore();
    const userStore = useUserStore();
    const authStore = useAuthStore();

    // 1. 基础路由（登录页、404等）直接放行
    if (coreRouteNames.includes(to.name as string)) {
      if (to.path === LOGIN_PATH && accessStore.accessToken) {
        // 已登录用户访问登录页，重定向到首页
        return userStore.userInfo?.homePath || DEFAULT_HOME_PATH;
      }
      return true;
    }

    // 2. 检查 AccessToken
    if (!accessStore.accessToken) {
      if (to.meta.ignoreAccess) return true;
      // 未登录，跳转登录页
      return {
        path: LOGIN_PATH,
        query: { redirect: encodeURIComponent(to.fullPath) },
        replace: true,
      };
    }

    // 3. 已生成动态路由，直接放行
    if (accessStore.isAccessChecked) return true;

    // 4. 生成动态路由（首次进入或刷新时）
    const userInfo = userStore.userInfo || (await authStore.fetchUserInfo());
    const userRoles = userInfo.roles ?? [];

    const { accessibleMenus, accessibleRoutes } = await generateAccess({
      roles: userRoles,
      router,
      routes: accessRoutes,
    });

    // 5. 保存菜单和路由信息
    accessStore.setAccessMenus(accessibleMenus);
    accessStore.setAccessRoutes(accessibleRoutes);
    accessStore.setIsAccessChecked(true);

    // 6. 重定向到目标页面
    const redirectPath = (from.query.redirect ?? to.fullPath) as string;
    return {
      ...router.resolve(decodeURIComponent(redirectPath)),
      replace: true,
    };
  });
}
```

#### 3.3.4 布局层 (layouts/)

**布局文件**:
- [basic.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/layouts/basic.vue) - 主布局（侧边栏 + 头部 + 内容区）
- [auth.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/layouts/auth.vue) - 认证布局（登录页等）

**主布局结构**:
```
┌─────────────────────────────────────────┐
│              Header (顶部栏)             │
├──────────┬──────────────────────────────┤
│          │                              │
│ Sidebar  │         Content (内容区)     │
│ (侧边栏) │                              │
│          │                              │
└──────────┴──────────────────────────────┘
```

#### 3.3.5 状态层 (store/)

**认证 Store** [apps/admin/src/store/auth.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/store/auth.ts):

```typescript
export const useAuthStore = defineStore('auth', () => {
  const accessStore = useAccessStore();
  const userStore = useUserStore();
  const router = useRouter();
  const loginLoading = ref(false);

  /**
   * 用户登录
   */
  async function authLogin(params: Recordable<any>, onSuccess?: () => Promise<void> | void) {
    try {
      loginLoading.value = true;
      
      // 1. 调用登录接口
      const { accessToken } = await loginApi(params);
      
      if (accessToken) {
        // 2. 保存 AccessToken
        accessStore.setAccessToken(accessToken);

        // 3. 并行获取用户信息和权限码
        const [fetchUserInfoResult, accessCodes] = await Promise.all([
          fetchUserInfo(),
          getAccessCodesApi(),
        ]);

        // 4. 保存用户信息和权限码
        userStore.setUserInfo(fetchUserInfoResult);
        accessStore.setAccessCodes(accessCodes);

        // 5. 跳转页面
        await router.push(userInfo.homePath || DEFAULT_HOME_PATH);

        // 6. 登录成功通知
        ElNotification({
          message: `${$t('authentication.loginSuccessDesc')}:${userInfo?.realName}`,
          title: $t('authentication.loginSuccess'),
          type: 'success',
        });
      }
    } finally {
      loginLoading.value = false;
    }
  }

  /**
   * 用户登出
   */
  async function logout(redirect: boolean = true) {
    try {
      await logoutApi();
    } catch {
      // 忽略登出接口错误
    }
    
    resetAllStores();
    await router.replace({
      path: LOGIN_PATH,
      query: redirect ? { redirect: encodeURIComponent(router.currentRoute.value.fullPath) } : {},
    });
    router.go(0);
  }

  return {
    authLogin,
    logout,
    fetchUserInfo,
    loginLoading,
  };
});
```

**Store 分类**:
- `auth.ts` - 认证状态管理
- `user.ts` - 用户信息管理
- 来自 `@vben/stores` 的共享 Store:
  - `useAccessStore` - 权限相关（Token、权限码、菜单、路由）
  - `useUserStore` - 用户信息

#### 3.3.6 API 层 (api/)

**核心文件**:
- [request.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/api/request.ts) - 请求客户端配置
- [index.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/api/index.ts) - API 导出
- [core/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/api/core/) - API 接口定义

**请求客户端配置** [request.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/api/request.ts):

```typescript
function createRequestClient(baseURL: string, options?: RequestClientOptions) {
  const client = new RequestClient({
    ...options,
    baseURL,
  });

  // 1. 请求拦截器 - 添加 Token 和语言
  client.addRequestInterceptor({
    fulfilled: async (config) => {
      const accessStore = useAccessStore();
      config.headers.Authorization = formatToken(accessStore.accessToken);
      config.headers['Accept-Language'] = preferences.app.locale;
      return config;
    },
  });

  // 2. 响应拦截器 - 统一数据格式处理
  client.addResponseInterceptor(
    defaultResponseInterceptor({
      codeField: 'code',
      dataField: 'data',
      successCode: 200,
    }),
  );

  // 3. 响应拦截器 - Token 过期处理
  client.addResponseInterceptor(
    authenticateResponseInterceptor({
      client,
      doReAuthenticate,
      doRefreshToken,
      enableRefreshToken: preferences.app.enableRefreshToken,
      formatToken,
    }),
  );

  // 4. 响应拦截器 - 通用错误处理
  client.addResponseInterceptor(
    errorMessageResponseInterceptor((msg: string, error) => {
      const responseData = error?.response?.data ?? {};
      const errorMessage = responseData?.error ?? responseData?.message ?? '';
      const code = responseData.code ?? 200;

      toast.error(errorMessage || msg, {
        timeout: 2000,
        position: POSITION.TOP_CENTER,
      });

      if (code == 1007) {
        setTimeout(() => {
          doReAuthenticate();
        }, 1000);
      }
    }),
  );

  return client;
}

export const requestClient = createRequestClient(apiURL, {
  responseReturn: 'data',
});
```

**API 接口示例** [apps/admin/src/api/core/auth.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/api/core/auth.ts):

```typescript
import type { Recordable } from '@vben/types';
import { requestClient } from '#/api/request';

/**
 * 用户登录
 */
export function loginApi(params: Recordable<any>) {
  return requestClient.post<{
    accessToken: string;
  }>('/system/auth/login', params);
}

/**
 * 用户登出
 */
export function logoutApi() {
  return requestClient.post('/system/auth/logout');
}

/**
 * 获取用户信息
 */
export function getUserInfoApi() {
  return requestClient.get('/system/auth/info');
}

/**
 * 获取权限码
 */
export function getAccessCodesApi() {
  return requestClient.get<string[]>('/system/auth/codes');
}
```

#### 3.3.7 视图层 (views/)

**页面目录结构**:
```
views/
├── _core/                    # 核心页面
│   ├── about/               # 关于页面
│   ├── authentication/      # 认证页面（登录、注册等）
│   └── fallback/            # 错误页面（404、403、500等）
├── dashboard/               # 仪表盘
│   ├── analytics/           # 数据分析
│   └── workspace/           # 工作台
├── demos/                   # 演示页面
├── material/                # 素材管理
│   ├── image/               # 图片管理
│   ├── audio/               # 音频管理
│   └── video/               # 视频管理
└── system/                  # 系统管理
    ├── user/                # 用户管理
    ├── role/                # 角色管理
    ├── menu/                # 菜单管理
    ├── api/                 # API 管理
    ├── dict/                # 字典管理
    └── record/              # 操作日志
```

#### 3.3.8 组件层 (components/)

**业务组件**:
- [MaterialPicker.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/MaterialPicker.vue) - 素材选择器
- [MaterialUpload.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/MaterialUpload.vue) - 素材上传器
- [RichEditor.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/RichEditor.vue) - 富文本编辑器

**素材选择器示例** [MaterialPicker.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/MaterialPicker.vue):

```vue
<script setup lang="ts">
interface Props {
  modelValue?: string | string[];
  type?: 'image' | 'audio' | 'video';
  multiple?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  type: 'image',
  multiple: false,
});

const emit = defineEmits<{
  'update:modelValue': [value: string | string[]];
  change: [value: string | string[]];
}>();

// 核心功能：
// 1. 打开素材选择弹窗
// 2. 分页加载素材列表
// 3. 单选/多选素材
// 4. 支持搜索
// 5. 支持上传新素材
// 6. 回显已选择的素材
</script>
```

**组件使用方式**:
```vue
<script setup lang="ts">
const formSchema = [
  {
    component: 'MaterialPicker',
    fieldName: 'imgUrl',
    componentProps: {
      type: 'image',
      multiple: false,
    },
  },
];
</script>
```

---

## 4. 权限系统设计

### 4.1 前端权限架构

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

### 4.2 权限控制方式

#### 4.2.1 路由权限

通过路由守卫动态生成可访问路由：

```typescript
// router/access.ts
export async function generateAccess({ roles, router, routes }) {
  // 1. 根据用户角色过滤路由
  const accessibleRoutes = filterRoutesByRoles(routes, roles);
  
  // 2. 动态添加路由
  accessibleRoutes.forEach((route) => {
    router.addRoute(route);
  });
  
  // 3. 生成菜单数据
  const accessibleMenus = generateMenusFromRoutes(accessibleRoutes);
  
  return { accessibleMenus, accessibleRoutes };
}
```

#### 4.2.2 组件权限 (v-access)

```vue
<!-- 方式一：指令 -->
<button v-access="'system:user:create'">
  新增用户
</button>

<!-- 方式二：函数 -->
<button v-if="hasAccess('system:user:delete')">
  删除
</button>
```

#### 4.2.3 自定义权限指令 (v-permission)

**文件**: [apps/admin/src/directives/permissions.ts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/directives/permissions.ts)

```typescript
import type { Directive, DirectiveBinding } from 'vue';
import { useAccessStore } from '@vben/stores';

export const permission: Directive = {
  mounted(el: HTMLElement, binding: DirectiveBinding) {
    const { value } = binding;
    const accessStore = useAccessStore();
    const accessCodes = accessStore.accessCodes;
    
    if (value && Array.isArray(value) && value.length > 0) {
      const hasPermission = value.some((code) => accessCodes.includes(code));
      if (!hasPermission) {
        el.parentNode && el.parentNode.removeChild(el);
      }
    }
  },
};
```

---

## 5. 核心业务模块

### 5.1 登录认证模块

**页面**: [views/_core/authentication/login.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/_core/authentication/login.vue)

**流程**:
1. 用户输入用户名密码
2. 调用 `loginApi` 获取 AccessToken
3. 保存 Token 到 `accessStore`
4. 获取用户信息和权限码
5. 生成动态路由
6. 跳转首页

### 5.2 用户管理模块

**页面**: [views/system/user/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/user/index.vue)

**功能**:
- 用户列表展示（分页、搜索）
- 新增/编辑用户
- 用户状态管理（启用/禁用）
- 重置密码
- 分配角色

### 5.3 角色管理模块

**页面**: [views/system/role/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/role/index.vue)

**功能**:
- 角色列表
- 新增/编辑角色
- 分配菜单权限
- 分配 API 权限

### 5.4 菜单管理模块

**页面**: [views/system/menu/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/system/menu/index.vue)

**功能**:
- 菜单树状展示
- 新增/编辑/删除菜单
- 菜单排序
- 菜单元信息配置（图标、路径、组件等）

### 5.5 素材管理模块

**页面**:
- [views/material/image/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/material/image/index.vue) - 图片管理
- [views/material/video/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/material/video/index.vue) - 视频管理
- [views/material/audio/index.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/views/material/audio/index.vue) - 音频管理

**功能**:
- 素材上传（支持拖拽、多选）
- 素材列表展示
- 素材预览
- 素材搜索
- 素材删除
- 素材分类管理

### 5.6 扩展组件

#### 5.6.1 富文本编辑器

**组件**: [RichEditor.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/RichEditor.vue)

**基于**: @wangeditor/editor

**使用方式**:
```vue
<script setup lang="ts">
const formSchema = [
  {
    component: 'RichEditor',
    fieldName: 'content',
    componentProps: {
      height: '400px',
      placeholder: '请输入内容...',
    },
  },
];
</script>
```

#### 5.6.2 素材上传器

**组件**: [MaterialUpload.vue](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/components/MaterialUpload.vue)

**使用方式**:
```vue
<script setup lang="ts">
const formSchema = [
  {
    component: 'MaterialUpload',
    fieldName: 'images',
    componentProps: {
      limit: 9,
      maxSize: 500,
      sizeUnit: 'KB',
      accept: 'image/jpeg,image/png',
    },
  },
];
</script>
```

---

## 6. 国际化 (i18n)

### 6.1 语言包结构

**目录**: [apps/admin/src/locales/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/src/locales/)

```
locales/
├── langs/
│   ├── zh-CN/           # 简体中文
│   │   ├── demos.json
│   │   ├── enum.json
│   │   ├── page.json
│   │   └── ui.json
│   └── en-US/           # 英语
│       ├── demos.json
│       ├── enum.json
│       ├── page.json
│       └── ui.json
└── index.ts             # i18n 配置
```

### 6.2 使用方式

```vue
<script setup lang="ts">
import { $t } from '#/locales';

// 方式一：函数调用
const title = $t('authentication.login');

// 方式二：模板中使用
</script>

<template>
  <div>{{ $t('authentication.loginSuccess') }}</div>
</template>
```

---

## 7. 主题与样式系统

### 7.1 设计系统

**目录**: [packages/@core/base/design/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/packages/@core/base/design/)

包含：
- CSS 变量定义（亮/暗主题）
- 全局样式
- 过渡动画
- SCSS BEM 工具

### 7.2 Tailwind CSS 配置

**配置文件**:
- [tailwind.config.mjs](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/tailwind.config.mjs)
- [internal/tailwind-config/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/internal/tailwind-config/)

### 7.3 主题定制

通过偏好设置动态切换主题：

```typescript
import { preferences } from '@vben/preferences';

// 切换主题
preferences.theme.mode = 'dark'; // 'light' | 'dark' | 'auto'

// 切换主题色
preferences.theme.primaryColor = '#1677ff';
```

---

## 8. 配置与环境

### 8.1 环境变量

**文件**:
- [.env](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/.env) - 通用配置
- [.env.development](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/.env.development) - 开发环境
- [.env.production](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/.env.production) - 生产环境
- [.env.analyze](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/.env.analyze) - 分析模式

**示例配置**:
```env
# 应用名称
VITE_APP_TITLE=Gooze Admin

# API 地址
VITE_API_BASE_URL=http://localhost:18002

# 路由模式
VITE_ROUTER_HISTORY=hash

# 应用命名空间
VITE_APP_NAMESPACE=gooze-admin
```

### 8.2 Vite 配置

**文件**: [vite.config.mts](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/apps/admin/vite.config.mts)

基于 `@vben/vite-config` 扩展配置。

---

## 9. 开发规范与工具

### 9.1 代码规范

- **ESLint**: 配置见 [internal/lint-configs/eslint-config/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/internal/lint-configs/eslint-config/)
- **Prettier**: 配置见 [internal/lint-configs/prettier-config/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/internal/lint-configs/prettier-config/)
- **Stylelint**: 配置见 [internal/lint-configs/stylelint-config/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/internal/lint-configs/stylelint-config/)
- **Commitlint**: 配置见 [internal/lint-configs/commitlint-config/](file:///e:/trae-playground/gooze-cms/gooze-vben-admin/internal/lint-configs/commitlint-config/)

### 9.2 常用命令

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 类型检查
pnpm check:type

# 代码检查
pnpm lint

# 代码格式化
pnpm format

# 构建生产版本
pnpm build

# 预览构建结果
pnpm preview

# 提交代码（规范格式）
pnpm commit
```

### 9.3 Git 钩子

使用 Husky 配置 Git 钩子：
- `pre-commit`: 运行 lint-staged
- `commit-msg`: 校验提交信息格式
- `post-merge`: 自动安装依赖

---

## 10. 部署与运行

### 10.1 开发环境

```bash
# 1. 安装依赖
pnpm install

# 2. 启动开发服务器
pnpm dev

# 3. 访问 http://localhost:5173
```

### 10.2 生产构建

```bash
# 1. 构建
pnpm build

# 2. 预览
pnpm preview

# 3. 部署 dist 目录到静态服务器
```

### 10.3 Docker 部署

项目提供 Docker 构建脚本：
```bash
pnpm build:docker
```

---

## 11. 最佳实践

### 11.1 组件开发

- 使用 `<script setup>` 语法
- 优先使用 TypeScript 类型注解
- 组件命名使用大驼峰（PascalCase）
- Props 定义使用 `withDefaults`
- 合理使用 `defineExpose` 暴露方法

### 11.2 状态管理

- 优先使用组件局部状态
- 跨组件共享数据使用 Pinia
- 异步操作放在 actions 中
- 使用 Store 组合式 API 风格

### 11.3 API 调用

- 所有 API 调用在 `api/` 目录封装
- 使用 `requestClient` 统一处理请求
- 定义清晰的返回类型
- 错误处理统一处理

### 11.4 性能优化

- 合理使用 `defineAsyncComponent` 进行代码分割
- 列表渲染使用 `v-memo`
- 避免不必要的重新渲染
- 使用 `@vueuse/core` 的优化工具

---

## 12. 扩展阅读

- [Vue 3 官方文档](https://vuejs.org/)
- [TypeScript 官方文档](https://www.typescriptlang.org/)
- [Vite 官方文档](https://vitejs.dev/)
- [Pinia 官方文档](https://pinia.vuejs.org/)
- [Element Plus 官方文档](https://element-plus.org/)
- [Vben Admin 文档](https://doc.vben.pro/)
- [Tailwind CSS 文档](https://tailwindcss.com/)
