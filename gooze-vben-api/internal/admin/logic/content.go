package logic

import (
	"context"
	"fmt"
	"gooze-vben-api/internal/admin/dto"
	"gooze-vben-api/models"

	"github.com/jinzhu/copier"
	"github.com/soryetong/gooze-starter/gooze"
	"github.com/soryetong/gooze-starter/services/gzdb"
)

type ContentLogic struct {
}

func NewContentLogic() *ContentLogic {
	return &ContentLogic{}
}

// --------------------------- 分类管理 ---------------------------

// @Summary CategoryAdd
func (self *ContentLogic) CategoryAdd(ctx context.Context, params *dto.UpsertCategoryReq) (err error) {
	var has int64
	gooze.Gorm().Model(&models.CCategories{}).Where("name = ? AND parent_id = ?", params.Name, params.ParentId).Count(&has)
	if has > 0 {
		return fmt.Errorf("分类已存在！")
	}

	if params.Sort == 0 {
		params.Sort = 100
	}
	if params.Status == 0 {
		params.Status = 1
	}

	err = gooze.Gorm().Create(&models.CCategories{
		Name:     params.Name,
		Icon:     params.Icon,
		Sort:     params.Sort,
		Status:   params.Status,
		ParentId: params.ParentId,
	}).Error

	return
}

// @Summary CategoryList
func (self *ContentLogic) CategoryList(ctx context.Context, params *dto.CategoryListReq) (resp *dto.CommonListResp, err error) {
	resp = &dto.CommonListResp{}

	query := gooze.Gorm().Model(&models.CCategories{}).Order("sort asc, id asc")
	if params.Name != "" {
		query.Where("name like ?", "%"+params.Name+"%")
	}
	if params.Status > 0 {
		query.Where("status = ?", params.Status)
	}
	if err = query.Count(&resp.Total).Error; err != nil {
		return
	}

	var list []*models.CCategories
	if err = query.Scopes(gzdb.GormPaginate(params.Page, params.PageSize)).Find(&list).Error; err != nil {
		return
	}

	items := make([]*dto.CategoryInfoResp, 0)
	for _, info := range list {
		item := new(dto.CategoryInfoResp)
		_ = copier.Copy(item, info)
		item.CreatedAt = info.CreatedAt.UnixMilli()
		items = append(items, item)
	}
	resp.Items = items

	return
}

// @Summary CategoryTree
func (self *ContentLogic) CategoryTree(ctx context.Context, params *dto.CategoryListReq) (resp *dto.CommonListResp, err error) {
	resp = &dto.CommonListResp{}

	query := gooze.Gorm().Model(&models.CCategories{}).Order("sort asc, id asc")
	if params.Name != "" {
		query.Where("name like ?", "%"+params.Name+"%")
	}
	if params.Status > 0 {
		query.Where("status = ?", params.Status)
	}

	var list []*models.CCategories
	if err = query.Find(&list).Error; err != nil {
		return
	}

	var items []*dto.CategoryInfoResp
	for _, info := range list {
		item := new(dto.CategoryInfoResp)
		_ = copier.Copy(item, info)
		item.CreatedAt = info.CreatedAt.UnixMilli()
		items = append(items, item)
	}

	tree := self.buildCategoryTree(items, 0)
	resp.Items = tree
	resp.Total = int64(len(tree))

	return
}

func (self *ContentLogic) buildCategoryTree(categories []*dto.CategoryInfoResp, parentId int64) []*dto.CategoryInfoResp {
	var tree []*dto.CategoryInfoResp
	for _, v := range categories {
		if v.ParentId == parentId {
			children := self.buildCategoryTree(categories, v.Id)
			v.Children = children
			tree = append(tree, v)
		}
	}
	return tree
}

// @Summary CategoryInfo
func (self *ContentLogic) CategoryInfo(ctx context.Context, id int64) (resp *dto.CategoryInfoResp, err error) {
	category := &models.CCategories{}
	if err = gooze.Gorm().First(&category, id).Error; err != nil {
		return
	}

	resp = &dto.CategoryInfoResp{}
	_ = copier.Copy(resp, category)
	resp.CreatedAt = category.CreatedAt.UnixMilli()

	return
}

// @Summary CategoryUpdate
func (self *ContentLogic) CategoryUpdate(ctx context.Context, id int64, params *dto.UpsertCategoryReq) (err error) {
	var has int64
	gooze.Gorm().Model(&models.CCategories{}).Where("name = ? AND parent_id = ? AND id != ?", params.Name, params.ParentId, id).Count(&has)
	if has > 0 {
		return fmt.Errorf("分类已存在！")
	}

	err = gooze.Gorm().Model(&models.CCategories{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"name":      params.Name,
			"icon":      params.Icon,
			"sort":      params.Sort,
			"status":    params.Status,
			"parent_id": params.ParentId,
		}).Error

	return
}

// @Summary CategoryDelete
func (self *ContentLogic) CategoryDelete(ctx context.Context, id int64) (err error) {
	var count int64
	gooze.Gorm().Model(&models.CCategories{}).Where("parent_id = ?", id).Count(&count)
	if count > 0 {
		return fmt.Errorf("请先删除子分类后再操作")
	}

	err = gooze.Gorm().Delete(&models.CCategories{}, "id = ?", id).Error

	return
}

// --------------------------- 标签管理 ---------------------------

// @Summary TagAdd
func (self *ContentLogic) TagAdd(ctx context.Context, params *dto.UpsertTagReq) (err error) {
	var has int64
	gooze.Gorm().Model(&models.CTags{}).Where("name = ?", params.Name).Count(&has)
	if has > 0 {
		return fmt.Errorf("标签已存在！")
	}

	if params.Sort == 0 {
		params.Sort = 100
	}
	if params.Status == 0 {
		params.Status = 1
	}

	err = gooze.Gorm().Create(&models.CTags{
		Name:   params.Name,
		Sort:   params.Sort,
		Status: params.Status,
	}).Error

	return
}

// @Summary TagList
func (self *ContentLogic) TagList(ctx context.Context, params *dto.TagListReq) (resp *dto.CommonListResp, err error) {
	resp = &dto.CommonListResp{}

	query := gooze.Gorm().Model(&models.CTags{}).Order("sort asc, id asc")
	if params.Name != "" {
		query.Where("name like ?", "%"+params.Name+"%")
	}
	if params.Status > 0 {
		query.Where("status = ?", params.Status)
	}
	if err = query.Count(&resp.Total).Error; err != nil {
		return
	}

	var list []*models.CTags
	if err = query.Scopes(gzdb.GormPaginate(params.Page, params.PageSize)).Find(&list).Error; err != nil {
		return
	}

	items := make([]*dto.TagInfoResp, 0)
	for _, info := range list {
		item := new(dto.TagInfoResp)
		_ = copier.Copy(item, info)
		item.CreatedAt = info.CreatedAt.UnixMilli()
		items = append(items, item)
	}
	resp.Items = items

	return
}

// @Summary TagInfo
func (self *ContentLogic) TagInfo(ctx context.Context, id int64) (resp *dto.TagInfoResp, err error) {
	tag := &models.CTags{}
	if err = gooze.Gorm().First(&tag, id).Error; err != nil {
		return
	}

	resp = &dto.TagInfoResp{}
	_ = copier.Copy(resp, tag)
	resp.CreatedAt = tag.CreatedAt.UnixMilli()

	return
}

// @Summary TagUpdate
func (self *ContentLogic) TagUpdate(ctx context.Context, id int64, params *dto.UpsertTagReq) (err error) {
	var has int64
	gooze.Gorm().Model(&models.CTags{}).Where("name = ? AND id != ?", params.Name, id).Count(&has)
	if has > 0 {
		return fmt.Errorf("标签已存在！")
	}

	err = gooze.Gorm().Model(&models.CTags{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"name":   params.Name,
			"sort":   params.Sort,
			"status": params.Status,
		}).Error

	return
}

// @Summary TagDelete
func (self *ContentLogic) TagDelete(ctx context.Context, id int64) (err error) {
	err = gooze.Gorm().Delete(&models.CTags{}, "id = ?", id).Error

	return
}
