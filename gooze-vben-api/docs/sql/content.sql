-- -----------------------------
-- Table structure for c_categories
-- -----------------------------
DROP TABLE IF EXISTS `c_categories`;
CREATE TABLE `c_categories`  (
      `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键字段',
      `parent_id` bigint unsigned NOT NULL DEFAULT 0 COMMENT '父级分类ID',
      `name` varchar(255)  NOT NULL DEFAULT '' COMMENT '分类名称',
      `icon` varchar(64)  NULL DEFAULT '' COMMENT '图标',
      `sort` int NULL DEFAULT 100 COMMENT '排序值',
      `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态（1-启用 2-禁用）',
      `created_at` datetime DEFAULT NULL COMMENT '创建时间戳',
      `updated_at` datetime DEFAULT NULL COMMENT '修改时间戳',
      `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
      PRIMARY KEY (`id`),
      KEY `idx_parent_id` (`parent_id`),
      KEY `idx_status` (`status`)
) ENGINE = InnoDB COMMENT = '分类管理';

-- -----------------------------
-- Table structure for c_tags
-- -----------------------------
DROP TABLE IF EXISTS `c_tags`;
CREATE TABLE `c_tags`  (
      `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键字段',
      `name` varchar(255)  NOT NULL DEFAULT '' COMMENT '标签名称',
      `sort` int NULL DEFAULT 100 COMMENT '排序值',
      `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态（1-启用 2-禁用）',
      `created_at` datetime DEFAULT NULL COMMENT '创建时间戳',
      `updated_at` datetime DEFAULT NULL COMMENT '修改时间戳',
      `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
      PRIMARY KEY (`id`),
      UNIQUE KEY `uk_name` (`name`),
      KEY `idx_status` (`status`)
) ENGINE = InnoDB COMMENT = '标签管理';

-- -----------------------------
-- Ensure unique indexes exist for idempotency
-- -----------------------------
-- For sys_role_auths: ensure unique on (role_id, auth_id)
SET @exist_idx := (SELECT COUNT(*) FROM information_schema.statistics 
    WHERE table_schema = DATABASE() 
    AND table_name = 'sys_role_auths' 
    AND index_name = 'uk_role_auth');
SET @sql := IF(@exist_idx = 0,
    'ALTER TABLE `sys_role_auths` ADD UNIQUE KEY `uk_role_auth` (`role_id`, `auth_id`)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- For sys_role_apis: ensure unique on (role_id, api_id)
SET @exist_idx := (SELECT COUNT(*) FROM information_schema.statistics 
    WHERE table_schema = DATABASE() 
    AND table_name = 'sys_role_apis' 
    AND index_name = 'uk_role_api');
SET @sql := IF(@exist_idx = 0,
    'ALTER TABLE `sys_role_apis` ADD UNIQUE KEY `uk_role_api` (`role_id`, `api_id`)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------
-- Insert default data for c_categories (幂等)
-- -----------------------------
INSERT INTO `c_categories` (`id`, `parent_id`, `name`, `icon`, `sort`, `status`, `created_at`, `updated_at`) VALUES
(1, 0, '技术', 'lucide:code', 1, 1, NOW(), NOW()),
(2, 0, '生活', 'lucide:home', 2, 1, NOW(), NOW()),
(3, 0, '工作', 'lucide:briefcase', 3, 1, NOW(), NOW()),
(4, 1, '前端开发', 'lucide:layout', 1, 1, NOW(), NOW()),
(5, 1, '后端开发', 'lucide:server', 2, 1, NOW(), NOW()),
(6, 1, '移动端开发', 'lucide:smartphone', 3, 1, NOW(), NOW()),
(7, 4, 'Vue.js', 'lucide:layout-dashboard', 1, 1, NOW(), NOW()),
(8, 4, 'React', 'lucide:atom', 2, 1, NOW(), NOW()),
(9, 5, 'Go', 'lucide:cpu', 1, 1, NOW(), NOW()),
(10, 5, 'Java', 'lucide:coffee', 2, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `icon` = VALUES(`icon`),
  `sort` = VALUES(`sort`),
  `status` = VALUES(`status`),
  `updated_at` = NOW();

-- -----------------------------
-- Insert default data for c_tags (幂等)
-- -----------------------------
INSERT INTO `c_tags` (`id`, `name`, `sort`, `status`, `created_at`, `updated_at`) VALUES
(1, 'JavaScript', 1, 1, NOW(), NOW()),
(2, 'TypeScript', 2, 1, NOW(), NOW()),
(3, 'Vue', 3, 1, NOW(), NOW()),
(4, 'React', 4, 1, NOW(), NOW()),
(5, 'Go', 5, 1, NOW(), NOW()),
(6, 'Java', 6, 1, NOW(), NOW()),
(7, 'Python', 7, 1, NOW(), NOW()),
(8, '数据库', 8, 1, NOW(), NOW()),
(9, 'Linux', 9, 1, NOW(), NOW()),
(10, 'Docker', 10, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `sort` = VALUES(`sort`),
  `status` = VALUES(`status`),
  `updated_at` = NOW();

-- -----------------------------
-- Insert menu data for content management (幂等)
-- -----------------------------
-- 内容管理目录 (父菜单)
INSERT INTO `sys_menus` (`id`, `parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(1000, 0, '内容管理', 'MENU', 'Content', '/content', '', '', 1, 0, 0, 0, 0, 0, 0, 100, 'lucide:layers', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `icon` = VALUES(`icon`),
  `sort` = VALUES(`sort`),
  `updated_at` = NOW();

-- 分类管理菜单
INSERT INTO `sys_menus` (`id`, `parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(1001, 1000, '分类管理', 'MENU', 'ContentCategory', '/content/category', 'content/category/index', 'content:category:list', 1, 0, 0, 0, 0, 0, 0, 1, 'lucide:folder-tree', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `icon` = VALUES(`icon`),
  `sort` = VALUES(`sort`),
  `perm` = VALUES(`perm`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `updated_at` = NOW();

-- 标签管理菜单
INSERT INTO `sys_menus` (`id`, `parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(1002, 1000, '标签管理', 'MENU', 'ContentTag', '/content/tag', 'content/tag/index', 'content:tag:list', 1, 0, 0, 0, 0, 0, 0, 2, 'lucide:tags', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `icon` = VALUES(`icon`),
  `sort` = VALUES(`sort`),
  `perm` = VALUES(`perm`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `updated_at` = NOW();

-- 分类管理按钮权限
INSERT INTO `sys_menus` (`id`, `parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(1003, 1001, '分类新增', 'BUTTON', '', '', '', 'content:category:create', 1, 0, 0, 0, 0, 0, 0, 1, '', NOW(), NOW()),
(1004, 1001, '分类编辑', 'BUTTON', '', '', '', 'content:category:update', 1, 0, 0, 0, 0, 0, 0, 2, '', NOW(), NOW()),
(1005, 1001, '分类删除', 'BUTTON', '', '', '', 'content:category:delete', 1, 0, 0, 0, 0, 0, 0, 3, '', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `perm` = VALUES(`perm`),
  `sort` = VALUES(`sort`),
  `updated_at` = NOW();

-- 标签管理按钮权限
INSERT INTO `sys_menus` (`id`, `parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(1006, 1002, '标签新增', 'BUTTON', '', '', '', 'content:tag:create', 1, 0, 0, 0, 0, 0, 0, 1, '', NOW(), NOW()),
(1007, 1002, '标签编辑', 'BUTTON', '', '', '', 'content:tag:update', 1, 0, 0, 0, 0, 0, 0, 2, '', NOW(), NOW()),
(1008, 1002, '标签删除', 'BUTTON', '', '', '', 'content:tag:delete', 1, 0, 0, 0, 0, 0, 0, 3, '', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `perm` = VALUES(`perm`),
  `sort` = VALUES(`sort`),
  `updated_at` = NOW();

-- -----------------------------
-- Assign menu permissions to admin role (role_id = 1) (幂等)
-- -----------------------------
INSERT IGNORE INTO `sys_role_auths` (`role_id`, `auth_id`, `created_at`, `updated_at`) VALUES
(1, 1000, NOW(), NOW()),
(1, 1001, NOW(), NOW()),
(1, 1002, NOW(), NOW()),
(1, 1003, NOW(), NOW()),
(1, 1004, NOW(), NOW()),
(1, 1005, NOW(), NOW()),
(1, 1006, NOW(), NOW()),
(1, 1007, NOW(), NOW()),
(1, 1008, NOW(), NOW());

-- -----------------------------
-- Register content APIs in sys_apis (幂等)
-- -----------------------------
-- 内容管理 API 分组
INSERT INTO `sys_apis` (`id`, `parent_id`, `description`, `method`, `path`, `created_at`, `updated_at`) VALUES
(2000, 0, '内容管理', '', '', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `description` = VALUES(`description`),
  `updated_at` = NOW();

-- 分类管理 API
INSERT INTO `sys_apis` (`id`, `parent_id`, `description`, `method`, `path`, `created_at`, `updated_at`) VALUES
(2001, 2000, '分类管理 - 新增分类', 'POST', '/category/add', NOW(), NOW()),
(2002, 2000, '分类管理 - 分类列表', 'GET', '/category/list', NOW(), NOW()),
(2003, 2000, '分类管理 - 分类树', 'GET', '/category/tree', NOW(), NOW()),
(2004, 2000, '分类管理 - 分类详情', 'GET', '/category/info/:id', NOW(), NOW()),
(2005, 2000, '分类管理 - 修改分类', 'PUT', '/category/update/:id', NOW(), NOW()),
(2006, 2000, '分类管理 - 删除分类', 'DELETE', '/category/delete/:id', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `description` = VALUES(`description`),
  `method` = VALUES(`method`),
  `path` = VALUES(`path`),
  `updated_at` = NOW();

-- 标签管理 API
INSERT INTO `sys_apis` (`id`, `parent_id`, `description`, `method`, `path`, `created_at`, `updated_at`) VALUES
(2007, 2000, '标签管理 - 新增标签', 'POST', '/tag/add', NOW(), NOW()),
(2008, 2000, '标签管理 - 标签列表', 'GET', '/tag/list', NOW(), NOW()),
(2009, 2000, '标签管理 - 标签详情', 'GET', '/tag/info/:id', NOW(), NOW()),
(2010, 2000, '标签管理 - 修改标签', 'PUT', '/tag/update/:id', NOW(), NOW()),
(2011, 2000, '标签管理 - 删除标签', 'DELETE', '/tag/delete/:id', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `description` = VALUES(`description`),
  `method` = VALUES(`method`),
  `path` = VALUES(`path`),
  `updated_at` = NOW();

-- -----------------------------
-- Assign API permissions to admin role (role_id = 1) in sys_role_apis (幂等)
-- -----------------------------
INSERT IGNORE INTO `sys_role_apis` (`role_id`, `api_id`, `created_at`, `updated_at`) VALUES
(1, 2000, NOW(), NOW()),
(1, 2001, NOW(), NOW()),
(1, 2002, NOW(), NOW()),
(1, 2003, NOW(), NOW()),
(1, 2004, NOW(), NOW()),
(1, 2005, NOW(), NOW()),
(1, 2006, NOW(), NOW()),
(1, 2007, NOW(), NOW()),
(1, 2008, NOW(), NOW()),
(1, 2009, NOW(), NOW()),
(1, 2010, NOW(), NOW()),
(1, 2011, NOW(), NOW());

-- -----------------------------
-- Add Casbin rules for content management (幂等)
-- ptype = 'p' means policy rule
-- v0 = role_id (1 = admin)
-- v1 = API path
-- v2 = HTTP method
-- -----------------------------
INSERT IGNORE INTO `casbin_rule` (`ptype`, `v0`, `v1`, `v2`, `v3`, `v4`, `v5`) VALUES
-- 分类管理权限
('p', '1', '/category/add', 'POST', '', '', ''),
('p', '1', '/category/list', 'GET', '', '', ''),
('p', '1', '/category/tree', 'GET', '', '', ''),
('p', '1', '/category/info/:id', 'GET', '', '', ''),
('p', '1', '/category/update/:id', 'PUT', '', '', ''),
('p', '1', '/category/delete/:id', 'DELETE', '', '', ''),
-- 标签管理权限
('p', '1', '/tag/add', 'POST', '', '', ''),
('p', '1', '/tag/list', 'GET', '', '', ''),
('p', '1', '/tag/info/:id', 'GET', '', '', ''),
('p', '1', '/tag/update/:id', 'PUT', '', '', ''),
('p', '1', '/tag/delete/:id', 'DELETE', '', '', '');
