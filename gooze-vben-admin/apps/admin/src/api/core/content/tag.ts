import { requestClient } from '#/api/request';

export interface TagInfo {
  id: number;
  name: string;
  sort: number;
  status: number;
  createdAt: number;
}

export interface TagListParams {
  page?: number;
  pageSize?: number;
  name?: string;
  status?: number;
}

export interface UpsertTagParams {
  name: string;
  sort?: number;
  status?: number;
}

export const getTagListApi = async (params: any) => {
  return requestClient.getWithParams('/tag/list', params);
};

export const getTagInfoApi = async (id: number) => {
  return requestClient.get(`/tag/info/${id}`);
};

export const createTagApi = async (param: any) => {
  return await requestClient.post('/tag/add', param);
};

export const updateTagApi = async (id: number, param: any) => {
  return await requestClient.put(`/tag/update/${id}`, param);
};

export const deleteTagApi = async (id: number) => {
  return await requestClient.delete(`/tag/delete/${id}`);
};
