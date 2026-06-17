<script lang="ts" setup>
import { computed, ref } from 'vue';
import { useVbenDrawer, z } from '@vben/common-ui';
import { $t } from '@vben/locales';
import { useVbenForm } from '#/adapter/form';
import {
  createTagApi,
  updateTagApi,
} from '#/api';
import { statusList } from '#/store';
import { useToast, POSITION } from 'vue-toastification';

const toast = useToast();
const data = ref();

const getTitle = computed(() =>
  data.value?.create
    ? '新增标签'
    : '编辑标签',
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
      label: '标签名称',
      componentProps: {
        placeholder: '请输入标签名称',
        allowClear: true,
      },
      rules: z.string().min(1, { message: '请输入标签名称' }),
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

    try {
      await (data.value?.create
        ? createTagApi(values)
        : updateTagApi(data.value.row.id, values));

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

      baseFormApi.setValues(data.value?.row);

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
