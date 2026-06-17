<script lang="ts" setup>
import { h } from 'vue';
import { useVbenVxeGrid, type VxeGridProps } from '#/adapter/vxe-table';
import { $t } from '#/locales';
import { Page, useVbenDrawer, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideTrash2, LucidePencil } from '@vben/icons';
import { ElButton } from 'element-plus';
import CategoryDrawer from './drawer.vue';
import {
  deleteCategoryApi,
  getCategoryTreeApi,
  updateCategoryApi,
} from '#/api';
import { statusList } from '#/store';
import { Icon } from '@iconify/vue';
import { useToast, POSITION } from 'vue-toastification';

import { formatDateTime } from '@vben/utils';

const toast = useToast();

const formOptions: VbenFormProps = {
  collapsed: false,
  showCollapseButton: false,
  submitOnEnter: true,
  schema: [
    {
      component: 'Input',
      fieldName: 'name',
      label: '分类名称',
      defaultValue: '',
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Select',
      fieldName: 'status',
      label: $t('ui.table.status'),
      componentProps: {
        options: statusList,
        placeholder: $t('ui.placeholder.select'),
      },
    },
  ],
};

const gridOptions: VxeGridProps = {
  toolbarConfig: {
    custom: true,
    export: true,
    refresh: true,
    zoom: true,
  },
  height: 'auto',
  exportConfig: {},
  pagerConfig: {
    enabled: false,
  },
  rowConfig: {
    isHover: true,
    height: 56,
  },
  stripe: true,
  treeConfig: {
    parentField: 'parentId',
    childrenField: 'children',
    rowField: 'id',
    transform: true,
  },
  proxyConfig: {
    autoLoad: true,
    ajax: {
      query: async ({ page }, formValues) => {
        return await getCategoryTreeApi({
          page: page.currentPage,
          pageSize: page.pageSize,
          name: formValues.name,
          status: formValues.status,
        });
      },
    },
  },

  columns: [
    {
      title: $t('ui.table.seq'),
      type: 'seq',
      width: 70,
    },
    {
      title: '分类名称',
      field: 'name',
      treeNode: true,
      slots: { default: 'name' },
    },
    {
      title: '图标',
      field: 'icon',
      slots: { default: 'icon' },
      width: 80,
      align: 'center',
    },
    {
      title: $t('ui.table.sortId'),
      field: 'sort',
      width: 100,
    },
    {
      title: $t('ui.table.status'),
      field: 'status',
      slots: { default: 'status' },
      width: 100,
    },
    {
      title: $t('ui.table.createTime'),
      field: 'createdAt',
      slots: { default: 'createdAt' },
      width: 160,
    },
    {
      title: $t('ui.table.action'),
      field: 'action',
      fixed: 'right',
      slots: { default: 'action' },
      width: 150,
    },
  ],
};

const [Grid, gridApi] = useVbenVxeGrid({
  gridOptions,
  formOptions,
});

const expandAll = () => {
  gridApi.grid?.setAllTreeExpand(true);
};

const collapseAll = () => {
  gridApi.grid?.setAllTreeExpand(false);
};

async function handleStatusChanged(row: any, checked: boolean) {
  row.pending = true;
  row.status = checked ? 1 : 2;
  try {
    await updateCategoryApi(row.id, row);

    toast.success($t('ui.notification.update_success'), {
      timeout: 1000,
      position: POSITION.TOP_RIGHT,
      toastClassName: 'toastification-success',
    });
  } catch {
  } finally {
    row.pending = false;
    gridApi.query();
  }
}

const [Drawer, drawerApi] = useVbenDrawer({
  connectedComponent: CategoryDrawer,
  onClosed() {
    const data = drawerApi.getData();
    if (data && data.needRefresh) {
      gridApi.query();
    }
  },
});

function openDrawer(create: boolean, row?: any) {
  drawerApi.setData({
    create,
    row,
  });
  drawerApi.open();
}

function handleCreate() {
  openDrawer(true);
}

function handleCreateChild(row: any) {
  openDrawer(true, { parentId: row.id });
}

function handleEdit(row: any) {
  openDrawer(false, row);
}

async function handleDelete(row: any) {
  row.pending = true;
  try {
    await deleteCategoryApi(row.id);

    toast.success($t('ui.notification.delete_success'), {
      timeout: 1000,
      position: POSITION.TOP_RIGHT,
      toastClassName: 'toastification-success',
    });
  } catch {
  } finally {
    row.pending = false;
    gridApi.query();
  }
}
</script>

<template>
  <Page auto-content-height>
    <Grid :table-title="'分类管理'">
      <template #toolbar-tools>
        <el-button
          class="mr-2"
          type="primary"
          @click="handleCreate"
        >
          新增分类
        </el-button>
        <el-button class="mr-2" @click="expandAll">
          {{ $t('ui.tree.expand_all') }}
        </el-button>
        <el-button class="mr-2" @click="collapseAll">
          {{ $t('ui.tree.collapse_all') }}
        </el-button>
      </template>

      <template #name="{ row }">
        <div class="flex items-center gap-2">
          <Icon
            v-if="row.icon"
            :icon="row.icon"
            class="size-4"
          />
          <Icon
            v-else
            icon="lucide:folder-tree"
            class="size-4"
          />
          <span>{{ row.name }}</span>
        </div>
      </template>

      <template #icon="{ row }">
        <div class="flex h-full items-center justify-center">
          <Icon
            v-if="row.icon"
            :icon="row.icon"
            class="size-5"
          />
        </div>
      </template>

      <template #status="{ row }">
        <el-switch
          :model-value="row.status === 1"
          :loading="row.pending"
          :inline-prompt="true"
          :active-text="$t('ui.switch.active')"
          :inactive-text="$t('ui.switch.inactive')"
          @change="(checked: boolean) => handleStatusChanged(row, checked)"
        />
      </template>

      <template #createdAt="{ row }">
        {{ formatDateTime(row.createdAt) }}
      </template>

      <template #action="{ row }">
        <ElButton
          type="success"
          link
          :icon="h(LucidePencil)"
          @click="() => handleCreateChild(row)"
          title="添加子分类"
        />

        <ElButton
          type="primary"
          link
          :icon="h(LucideFilePenLine)"
          @click="() => handleEdit(row)"
        />

        <el-popconfirm
          title="确定要删除该分类吗？如果有子分类，请先删除子分类。"
          :confirm-button-text="$t('ui.button.ok')"
          :cancElButton-text="$t('ui.button.cancel')"
          @confirm="() => handleDelete(row)"
        >
          <template #reference>
            <ElButton
              type="danger"
              link
              :icon="LucideTrash2"
            />
          </template>
        </el-popconfirm>
      </template>
    </Grid>
    <Drawer />
  </Page>
</template>
