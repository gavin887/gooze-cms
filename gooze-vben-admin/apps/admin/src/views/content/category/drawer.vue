<script lang="ts" setup>
import { computed, ref } from 'vue';
import { useVbenDrawer, z } from '@vben/common-ui';
import { $t } from '@vben/locales';
import { useVbenForm } from '#/adapter/form';
import {
  createCategoryApi,
  updateCategoryApi,
  getCategoryTreeApi,
} from '#/api';
import { statusList } from '#/store';
import { useToast, POSITION } from 'vue-toastification';

const toast = useToast();
const data = ref();

const getTitle = computed(() =>
  data.value?.create
    ? '新增分类'
    : '编辑分类',
);

const [BaseForm, baseFormApi] = useVbenForm({
  showDefaultActions: false,
  commonConfig: {
    componentProps: {
      class: 'w-full',
    },
  },
  schema: [
    {
      component: 'Input',
      fieldName: 'name',
      label: '分类名称',
      componentProps: {
        placeholder: '请输入分类名称',
        allowClear: true,
      },
      rules: z.string().min(1, { message: '请输入分类名称' }),
    },
    {
      component: 'ApiTreeSelect',
      fieldName: 'parentId',
      label: '上级分类',
      componentProps: {
        checkStrictly: true,
        placeholder: '请选择上级分类（不选则为顶级分类）',
        api: async () => {
          const result = await getCategoryTreeApi({});
          return [
            {
              id: 0,
              parentId: -1,
              name: '顶级分类',
              children: result.items || [],
            },
          ];
        },
        childrenField: 'children',
        labelField: 'name',
        valueField: 'id',
      },
    },
    {
      component: 'IconPicker',
      fieldName: 'icon',
      label: '图标',
      componentProps: {
        prefix: 'lucide',
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'sort',
      label: $t('ui.table.sortId'),
      defaultValue: 100,
      componentProps: {
        placeholder: '请输入排序值',
        min: 0,
        allowClear: true,
      },
    },
    {
      component: 'RadioGroup',
      fieldName: 'status',
      defaultValue: 1,
      label: $t('ui.table.status'),
      rules: 'selectRequired',
      componentProps: {
        optionType: 'button',
        class: 'flex flex-wrap',
        options: statusList,
      },
    },
  ],
});

const [Drawer, drawerApi] = useVbenDrawer({
  onCancel() {
    drawerApi.close();
  },

  async onConfirm() {
    const validate = await baseFormApi.validate();
    if (!validate.valid) {
      return;
    }

    setLoading(true);

    const values = await baseFormApi.getValues();

    if (!values.parentId || values.parentId === '') {
      values.parentId = 0;
    }

    try {
      await (data.value?.create
        ? createCategoryApi(values)
        : updateCategoryApi(data.value.row.id, values));

      toast.success(
        data.value?.create
          ? $t('ui.notification.create_success')
          : $t('ui.notification.update_success'),
        {
          timeout: 1000,
          position: POSITION.TOP_RIGHT,
          toastClassName: 'toastification-success',
        },
      );
      drawerApi.setData({ needRefresh: true });
    } catch {
    } finally {
      drawerApi.close();
      setLoading(false);
    }
  },

  onOpenChange(isOpen) {
    if (isOpen) {
      data.value = drawerApi.getData<Record<string, any>>();

      const formData = { ...data.value?.row };
      if (data.value?.create && !formData.parentId) {
        formData.parentId = 0;
      }

      baseFormApi.setValues(formData);

      setLoading(false);
    }
  },
});

function setLoading(loading: boolean) {
  drawerApi.setState({ loading });
}
</script>

<template>
  <Drawer :title="getTitle">
    <BaseForm />
  </Drawer>
</template>
