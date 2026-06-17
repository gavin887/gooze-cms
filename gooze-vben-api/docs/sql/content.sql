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
-- Insert default data for c_categories
-- -----------------------------
INSERT INTO `c_categories` (`parent_id`, `name`, `icon`, `sort`, `status`, `created_at`, `updated_at`) VALUES
(0, '技术', 'lucide:code', 1, 1, NOW(), NOW()),
(0, '生活', 'lucide:home', 2, 1, NOW(), NOW()),
(0, '工作', 'lucide:briefcase', 3, 1, NOW(), NOW()),
(1, '前端开发', 'lucide:layout', 1, 1, NOW(), NOW()),
(1, '后端开发', 'lucide:server', 2, 1, NOW(), NOW()),
(1, '移动端开发', 'lucide:smartphone', 3, 1, NOW(), NOW()),
(4, 'Vue.js', 'lucide:layout-dashboard', 1, 1, NOW(), NOW()),
(4, 'React', 'lucide:atom', 2, 1, NOW(), NOW()),
(5, 'Go', 'lucide:cpu', 1, 1, NOW(), NOW()),
(5, 'Java', 'lucide:coffee', 2, 1, NOW(), NOW());

-- -----------------------------
-- Insert default data for c_tags
-- -----------------------------
INSERT INTO `c_tags` (`name`, `sort`, `status`, `created_at`, `updated_at`) VALUES
('JavaScript', 1, 1, NOW(), NOW()),
('TypeScript', 2, 1, NOW(), NOW()),
('Vue', 3, 1, NOW(), NOW()),
('React', 4, 1, NOW(), NOW()),
('Go', 5, 1, NOW(), NOW()),
('Java', 6, 1, NOW(), NOW()),
('Python', 7, 1, NOW(), NOW()),
('数据库', 8, 1, NOW(), NOW()),
('Linux', 9, 1, NOW(), NOW()),
('Docker', 10, 1, NOW(), NOW());

-- -----------------------------
-- Insert menu data for content management
-- -----------------------------
-- 内容管理目录 (父菜单)
INSERT INTO `sys_menus` (`parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(0, '内容管理', 'MENU', 'Content', '/content', '', '', 1, 0, 0, 0, 0, 0, 0, 100, 'lucide:layers', NOW(), NOW());

-- 获取刚插入的内容管理菜单ID
SET @content_menu_id = LAST_INSERT_ID();

-- 分类管理菜单
INSERT INTO `sys_menus` (`parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(@content_menu_id, '分类管理', 'MENU', 'ContentCategory', '/content/category', 'content/category/index', 'content:category:list', 1, 0, 0, 0, 0, 0, 0, 1, 'lucide:folder-tree', NOW(), NOW());

-- 标签管理菜单
INSERT INTO `sys_menus` (`parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(@content_menu_id, '标签管理', 'MENU', 'ContentTag', '/content/tag', 'content/tag/index', 'content:tag:list', 1, 0, 0, 0, 0, 0, 0, 2, 'lucide:tags', NOW(), NOW());

-- 获取分类和标签菜单ID
SET @category_menu_id = LAST_INSERT_ID() - 1;
SET @tag_menu_id = LAST_INSERT_ID();

-- 分类管理按钮权限
INSERT INTO `sys_menus` (`parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(@category_menu_id, '分类新增', 'BUTTON', '', '', '', 'content:category:create', 1, 0, 0, 0, 0, 0, 0, 1, '', NOW(), NOW()),
(@category_menu_id, '分类编辑', 'BUTTON', '', '', '', 'content:category:update', 1, 0, 0, 0, 0, 0, 0, 2, '', NOW(), NOW()),
(@category_menu_id, '分类删除', 'BUTTON', '', '', '', 'content:category:delete', 1, 0, 0, 0, 0, 0, 0, 3, '', NOW(), NOW());

-- 标签管理按钮权限
INSERT INTO `sys_menus` (`parent_id`, `name`, `type`, `route_name`, `path`, `component`, `perm`, `status`, `affix_tab`, `hide_children_in_menu`, `hide_in_breadcrumb`, `hide_in_menu`, `hide_in_tab`, `keep_alive`, `sort`, `icon`, `created_at`, `updated_at`) VALUES
(@tag_menu_id, '标签新增', 'BUTTON', '', '', '', 'content:tag:create', 1, 0, 0, 0, 0, 0, 0, 1, '', NOW(), NOW()),
(@tag_menu_id, '标签编辑', 'BUTTON', '', '', '', 'content:tag:update', 1, 0, 0, 0, 0, 0, 0, 2, '', NOW(), NOW()),
(@tag_menu_id, '标签删除', 'BUTTON', '', '', '', 'content:tag:delete', 1, 0, 0, 0, 0, 0, 0, 3, '', NOW(), NOW());

-- -----------------------------
-- Assign content management permissions to admin role (role_id = 1)
-- -----------------------------
SET @admin_role_id = 1;

-- 获取所有内容管理相关的菜单ID
SET @category_create_btn_id = LAST_INSERT_ID() - 5;
SET @category_update_btn_id = LAST_INSERT_ID() - 4;
SET @category_delete_btn_id = LAST_INSERT_ID() - 3;
SET @tag_create_btn_id = LAST_INSERT_ID() - 2;
SET @tag_update_btn_id = LAST_INSERT_ID() - 1;
SET @tag_delete_btn_id = LAST_INSERT_ID();

-- 分配权限给管理员角色
INSERT INTO `sys_role_auths` (`role_id`, `auth_id`, `created_at`, `updated_at`) VALUES
(@admin_role_id, @content_menu_id, NOW(), NOW()),
(@admin_role_id, @category_menu_id, NOW(), NOW()),
(@admin_role_id, @tag_menu_id, NOW(), NOW()),
(@admin_role_id, @category_create_btn_id, NOW(), NOW()),
(@admin_role_id, @category_update_btn_id, NOW(), NOW()),
(@admin_role_id, @category_delete_btn_id, NOW(), NOW()),
(@admin_role_id, @tag_create_btn_id, NOW(), NOW()),
(@admin_role_id, @tag_update_btn_id, NOW(), NOW()),
(@admin_role_id, @tag_delete_btn_id, NOW(), NOW());
