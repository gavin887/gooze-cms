package handler

import (
	"errors"

	"github.com/gin-gonic/gin"
	"github.com/soryetong/gooze-starter/gooze"
	"github.com/soryetong/gooze-starter/pkg/gzerror"
	"github.com/soryetong/gooze-starter/pkg/gzutil"
	"github.com/spf13/cast"
	"gooze-vben-api/internal/admin/dto"
	"gooze-vben-api/internal/admin/logic"
)

var contentLogic = logic.NewContentLogic()

// --------------------------- 分类管理 ---------------------------

// @Summary CategoryAdd
// @Description CategoryAdd
// @Accept json
// @Produce json
// @Param body dto.UpsertCategoryReq
// @Success 200 string success
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /category/add [post]
func CategoryAdd(ctx *gin.Context) error {
	var req dto.UpsertCategoryReq
	if err := ctx.ShouldBind(&req); err != nil {
		return gzerror.TransErr(err)
	}

	if err := contentLogic.CategoryAdd(ctx, &req); err != nil {
		return err
	}

	gooze.Success(ctx, nil)
	return nil
}

// @Summary CategoryList
// @Description CategoryList
// @Accept json
// @Produce json
// @Param query dto.CategoryListReq
// @Success 200 {object} dto.CommonListResp
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /category/list [get]
func CategoryList(ctx *gin.Context) error {
	var req dto.CategoryListReq
	if err := ctx.ShouldBind(&req); err != nil {
		return gzerror.TransErr(err)
	}

	resp, err := contentLogic.CategoryList(ctx, &req)
	if err != nil {
		return err
	}

	gooze.Success(ctx, resp)
	return nil
}

// @Summary CategoryTree
// @Description CategoryTree
// @Accept json
// @Produce json
// @Param query dto.CategoryListReq
// @Success 200 {object} dto.CommonListResp
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /category/tree [get]
func CategoryTree(ctx *gin.Context) error {
	var req dto.CategoryListReq
	if err := ctx.ShouldBind(&req); err != nil {
		return gzerror.TransErr(err)
	}

	resp, err := contentLogic.CategoryTree(ctx, &req)
	if err != nil {
		return err
	}

	gooze.Success(ctx, resp)
	return nil
}

// @Summary CategoryInfo
// @Description CategoryInfo
// @Accept json
// @Produce json
// @Param id query int64 true "id"
// @Success 200 {object} dto.CategoryInfoResp
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /category/info/:id [get]
func CategoryInfo(ctx *gin.Context) error {
	id := cast.ToInt64(ctx.Param("id"))
	if !gzutil.IsValidNumber(id) {
		return errors.New("参数错误")
	}

	resp, err := contentLogic.CategoryInfo(ctx, id)
	if err != nil {
		return err
	}

	gooze.Success(ctx, resp)
	return nil
}

// @Summary CategoryUpdate
// @Description CategoryUpdate
// @Accept json
// @Produce json
// @Param id query int64 true "id"
// @Param body dto.UpsertCategoryReq
// @Success 200 string success
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /category/update/:id [put]
func CategoryUpdate(ctx *gin.Context) error {
	id := cast.ToInt64(ctx.Param("id"))
	if !gzutil.IsValidNumber(id) {
		return errors.New("参数错误")
	}
	var req dto.UpsertCategoryReq
	if err := ctx.ShouldBind(&req); err != nil {
		return gzerror.TransErr(err)
	}

	if err := contentLogic.CategoryUpdate(ctx, id, &req); err != nil {
		return err
	}

	gooze.Success(ctx, nil)
	return nil
}

// @Summary CategoryDelete
// @Description CategoryDelete
// @Accept json
// @Produce json
// @Param id query int64 true "id"
// @Success 200 string success
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /category/delete/:id [delete]
func CategoryDelete(ctx *gin.Context) error {
	id := cast.ToInt64(ctx.Param("id"))
	if !gzutil.IsValidNumber(id) {
		return errors.New("参数错误")
	}

	if err := contentLogic.CategoryDelete(ctx, id); err != nil {
		return err
	}

	gooze.Success(ctx, nil)
	return nil
}

// --------------------------- 标签管理 ---------------------------

// @Summary TagAdd
// @Description TagAdd
// @Accept json
// @Produce json
// @Param body dto.UpsertTagReq
// @Success 200 string success
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /tag/add [post]
func TagAdd(ctx *gin.Context) error {
	var req dto.UpsertTagReq
	if err := ctx.ShouldBind(&req); err != nil {
		return gzerror.TransErr(err)
	}

	if err := contentLogic.TagAdd(ctx, &req); err != nil {
		return err
	}

	gooze.Success(ctx, nil)
	return nil
}

// @Summary TagList
// @Description TagList
// @Accept json
// @Produce json
// @Param query dto.TagListReq
// @Success 200 {object} dto.CommonListResp
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /tag/list [get]
func TagList(ctx *gin.Context) error {
	var req dto.TagListReq
	if err := ctx.ShouldBind(&req); err != nil {
		return gzerror.TransErr(err)
	}

	resp, err := contentLogic.TagList(ctx, &req)
	if err != nil {
		return err
	}

	gooze.Success(ctx, resp)
	return nil
}

// @Summary TagInfo
// @Description TagInfo
// @Accept json
// @Produce json
// @Param id query int64 true "id"
// @Success 200 {object} dto.TagInfoResp
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /tag/info/:id [get]
func TagInfo(ctx *gin.Context) error {
	id := cast.ToInt64(ctx.Param("id"))
	if !gzutil.IsValidNumber(id) {
		return errors.New("参数错误")
	}

	resp, err := contentLogic.TagInfo(ctx, id)
	if err != nil {
		return err
	}

	gooze.Success(ctx, resp)
	return nil
}

// @Summary TagUpdate
// @Description TagUpdate
// @Accept json
// @Produce json
// @Param id query int64 true "id"
// @Param body dto.UpsertTagReq
// @Success 200 string success
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /tag/update/:id [put]
func TagUpdate(ctx *gin.Context) error {
	id := cast.ToInt64(ctx.Param("id"))
	if !gzutil.IsValidNumber(id) {
		return errors.New("参数错误")
	}
	var req dto.UpsertTagReq
	if err := ctx.ShouldBind(&req); err != nil {
		return gzerror.TransErr(err)
	}

	if err := contentLogic.TagUpdate(ctx, id, &req); err != nil {
		return err
	}

	gooze.Success(ctx, nil)
	return nil
}

// @Summary TagDelete
// @Description TagDelete
// @Accept json
// @Produce json
// @Param id query int64 true "id"
// @Success 200 string success
// @Failure 200 {object} gooze.Response 根据Code表示不同类型的错误
// @Router /tag/delete/:id [delete]
func TagDelete(ctx *gin.Context) error {
	id := cast.ToInt64(ctx.Param("id"))
	if !gzutil.IsValidNumber(id) {
		return errors.New("参数错误")
	}

	if err := contentLogic.TagDelete(ctx, id); err != nil {
		return err
	}

	gooze.Success(ctx, nil)
	return nil
}
