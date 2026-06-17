package dto

type CategoryListReq struct {
	Page     int64  `json:"page" form:"page"`
	PageSize int64  `json:"pageSize" form:"pageSize"`
	Name     string `json:"name" form:"name"`
	Status   int64  `json:"status" form:"status"`
}

type UpsertCategoryReq struct {
	Name     string `json:"name"`
	Icon     string `json:"icon"`
	Sort     int64  `json:"sort"`
	Status   int64  `json:"status"`
	ParentId int64  `json:"parentId"`
}

type CategoryInfoResp struct {
	Id        int64                `json:"id"`
	Name      string               `json:"name"`
	Icon      string               `json:"icon"`
	Sort      int64                `json:"sort"`
	Status    int64                `json:"status"`
	ParentId  int64                `json:"parentId"`
	CreatedAt int64                `json:"createdAt"`
	Children  []*CategoryInfoResp `json:"children"`
}

type TagListReq struct {
	Page     int64  `json:"page" form:"page"`
	PageSize int64  `json:"pageSize" form:"pageSize"`
	Name     string `json:"name" form:"name"`
	Status   int64  `json:"status" form:"status"`
}

type UpsertTagReq struct {
	Name   string `json:"name"`
	Sort   int64  `json:"sort"`
	Status int64  `json:"status"`
}

type TagInfoResp struct {
	Id        int64  `json:"id"`
	Name      string `json:"name"`
	Sort      int64  `json:"sort"`
	Status    int64  `json:"status"`
	CreatedAt int64  `json:"createdAt"`
}
