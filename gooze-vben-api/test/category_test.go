package test

import (
	"context"
	"gooze-vben-api/internal/admin/dto"
	"gooze-vben-api/internal/admin/logic"
	"testing"

	"github.com/soryetong/gooze-starter/gooze"
	_ "github.com/soryetong/gooze-starter/modules/dbmodule"
	"github.com/stretchr/testify/assert"
)

var contentLogic = logic.NewContentLogic()

func TestCategoryAdd(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.UpsertCategoryReq{
		Name:     "测试分类",
		Icon:     "lucide:folder",
		Sort:     1,
		Status:   1,
		ParentId: 0,
	}

	err := contentLogic.CategoryAdd(context.Background(), params)
	assert.Nil(t, err, "新增分类应该成功")

	t.Log("新增分类成功")
}

func TestCategoryAddDuplicate(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.UpsertCategoryReq{
		Name:     "测试分类",
		Sort:     1,
		Status:   1,
		ParentId: 0,
	}

	err := contentLogic.CategoryAdd(context.Background(), params)
	assert.NotNil(t, err, "重复分类应该返回错误")
	assert.Equal(t, "分类已存在！", err.Error())

	t.Log("重复分类验证通过")
}

func TestCategoryList(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.CategoryListReq{
		Page:     1,
		PageSize: 10,
	}

	resp, err := contentLogic.CategoryList(context.Background(), params)
	assert.Nil(t, err, "获取分类列表应该成功")
	assert.NotNil(t, resp, "返回结果不应为空")
	assert.GreaterOrEqual(t, resp.Total, int64(0), "总数应大于等于0")

	t.Logf("获取分类列表成功，总数: %d", resp.Total)
}

func TestCategoryListWithFilter(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.CategoryListReq{
		Page:     1,
		PageSize: 10,
		Name:     "测试",
		Status:   1,
	}

	resp, err := contentLogic.CategoryList(context.Background(), params)
	assert.Nil(t, err, "筛选分类列表应该成功")
	assert.NotNil(t, resp, "返回结果不应为空")

	t.Logf("筛选分类列表成功，总数: %d", resp.Total)
}

func TestCategoryTree(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.CategoryListReq{}

	resp, err := contentLogic.CategoryTree(context.Background(), params)
	assert.Nil(t, err, "获取分类树应该成功")
	assert.NotNil(t, resp, "返回结果不应为空")

	t.Logf("获取分类树成功，总数: %d", resp.Total)
}

func TestCategoryInfo(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	listParams := &dto.CategoryListReq{
		Page:     1,
		PageSize: 1,
	}
	listResp, err := contentLogic.CategoryList(context.Background(), listParams)
	assert.Nil(t, err)
	assert.Greater(t, len(listResp.Items.([]*dto.CategoryInfoResp)), 0, "需要至少一条数据进行测试")

	firstCategory := listResp.Items.([]*dto.CategoryInfoResp)[0]
	categoryId := firstCategory.Id

	resp, err := contentLogic.CategoryInfo(context.Background(), categoryId)
	assert.Nil(t, err, "获取分类详情应该成功")
	assert.NotNil(t, resp, "返回结果不应为空")
	assert.Equal(t, categoryId, resp.Id, "返回的ID应与请求一致")
	assert.NotEmpty(t, resp.Name, "分类名称不应为空")

	t.Logf("获取分类详情成功，ID: %d, 名称: %s", resp.Id, resp.Name)
}

func TestCategoryUpdate(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	addParams := &dto.UpsertCategoryReq{
		Name:     "待更新分类",
		Sort:     100,
		Status:   1,
		ParentId: 0,
	}
	err := contentLogic.CategoryAdd(context.Background(), addParams)
	assert.Nil(t, err)

	listParams := &dto.CategoryListReq{
		Page:     1,
		PageSize: 10,
		Name:     "待更新分类",
	}
	listResp, err := contentLogic.CategoryList(context.Background(), listParams)
	assert.Nil(t, err)
	categories := listResp.Items.([]*dto.CategoryInfoResp)
	assert.Greater(t, len(categories), 0)
	categoryId := categories[0].Id

	updateParams := &dto.UpsertCategoryReq{
		Name:     "已更新分类",
		Icon:     "lucide:folder-open",
		Sort:     50,
		Status:   2,
		ParentId: 0,
	}
	err = contentLogic.CategoryUpdate(context.Background(), categoryId, updateParams)
	assert.Nil(t, err, "更新分类应该成功")

	updatedInfo, err := contentLogic.CategoryInfo(context.Background(), categoryId)
	assert.Nil(t, err)
	assert.Equal(t, "已更新分类", updatedInfo.Name, "名称应已更新")
	assert.Equal(t, int64(50), updatedInfo.Sort, "排序应已更新")
	assert.Equal(t, int64(2), updatedInfo.Status, "状态应已更新")

	t.Log("更新分类成功")
}

func TestCategoryDelete(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	addParams := &dto.UpsertCategoryReq{
		Name:     "待删除分类",
		Sort:     100,
		Status:   1,
		ParentId: 0,
	}
	err := contentLogic.CategoryAdd(context.Background(), addParams)
	assert.Nil(t, err)

	listParams := &dto.CategoryListReq{
		Page:     1,
		PageSize: 10,
		Name:     "待删除分类",
	}
	listResp, err := contentLogic.CategoryList(context.Background(), listParams)
	assert.Nil(t, err)
	categories := listResp.Items.([]*dto.CategoryInfoResp)
	assert.Greater(t, len(categories), 0)
	categoryId := categories[0].Id

	err = contentLogic.CategoryDelete(context.Background(), categoryId)
	assert.Nil(t, err, "删除分类应该成功")

	_, err = contentLogic.CategoryInfo(context.Background(), categoryId)
	assert.NotNil(t, err, "已删除的分类不应存在")

	t.Log("删除分类成功")
}

func TestCategoryDeleteWithChildren(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	parentParams := &dto.UpsertCategoryReq{
		Name:     "父分类",
		Sort:     100,
		Status:   1,
		ParentId: 0,
	}
	err := contentLogic.CategoryAdd(context.Background(), parentParams)
	assert.Nil(t, err)

	listParams := &dto.CategoryListReq{
		Page:     1,
		PageSize: 10,
		Name:     "父分类",
	}
	listResp, err := contentLogic.CategoryList(context.Background(), listParams)
	assert.Nil(t, err)
	categories := listResp.Items.([]*dto.CategoryInfoResp)
	assert.Greater(t, len(categories), 0)
	parentId := categories[0].Id

	childParams := &dto.UpsertCategoryReq{
		Name:     "子分类",
		Sort:     100,
		Status:   1,
		ParentId: parentId,
	}
	err = contentLogic.CategoryAdd(context.Background(), childParams)
	assert.Nil(t, err)

	err = contentLogic.CategoryDelete(context.Background(), parentId)
	assert.NotNil(t, err, "有子分类时删除应失败")
	assert.Equal(t, "请先删除子分类后再操作", err.Error())

	t.Log("有子分类时删除验证通过")
}
