import { requestClient } from '#/api/request';

export interface CategoryInfo {
  id: number;
  name: string;
  icon: string;
  sort: number;
  status: number;
  parentId: number;
  createdAt: number;
  children?: CategoryInfo[];
}

export interface CategoryListParams {
  page?: number;
  pageSize?: number;
  name?: string;
  status?: number;
}

export interface UpsertCategoryParams {
  name: string;
  icon?: string;
  sort?: number;
  status?: number;
  parentId?: number;
}

export const getCategoryTreeApi = async (params?: any) => {
  return requestClient.getWithParams('/category/tree', params || {});
};

export const getCategoryListApi = async (params: any) => {
  return requestClient.getWithParams('/category/list', params);
};

export const getCategoryInfoApi = async (id: number) => {
  return requestClient.get(`/category/info/${id}`);
};

export const createCategoryApi = async (param: any) => {
  return await requestClient.post('/category/add', param);
};

export const updateCategoryApi = async (id: number, param: any) => {
  return await requestClient.put(`/category/update/${id}`, param);
};

export const deleteCategoryApi = async (id: number) => {
  return await requestClient.delete(`/category/delete/${id}`);
};
