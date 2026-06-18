package test

import (
	"context"
	"gooze-vben-api/internal/admin/dto"
	"testing"

	"github.com/soryetong/gooze-starter/gooze"
	_ "github.com/soryetong/gooze-starter/modules/dbmodule"
	"github.com/stretchr/testify/assert"
)

func TestTagAdd(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.UpsertTagReq{
		Name:   "测试标签",
		Sort:   1,
		Status: 1,
	}

	err := contentLogic.TagAdd(context.Background(), params)
	assert.Nil(t, err, "新增标签应该成功")

	t.Log("新增标签成功")
}

func TestTagAddDuplicate(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.UpsertTagReq{
		Name:   "测试标签",
		Sort:   1,
		Status: 1,
	}

	err := contentLogic.TagAdd(context.Background(), params)
	assert.NotNil(t, err, "重复标签应该返回错误")
	assert.Equal(t, "标签已存在！", err.Error())

	t.Log("重复标签验证通过")
}

func TestTagList(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.TagListReq{
		Page:     1,
		PageSize: 10,
	}

	resp, err := contentLogic.TagList(context.Background(), params)
	assert.Nil(t, err, "获取标签列表应该成功")
	assert.NotNil(t, resp, "返回结果不应为空")
	assert.GreaterOrEqual(t, resp.Total, int64(0), "总数应大于等于0")

	t.Logf("获取标签列表成功，总数: %d", resp.Total)
}

func TestTagListWithFilter(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	params := &dto.TagListReq{
		Page:     1,
		PageSize: 10,
		Name:     "测试",
		Status:   1,
	}

	resp, err := contentLogic.TagList(context.Background(), params)
	assert.Nil(t, err, "筛选标签列表应该成功")
	assert.NotNil(t, resp, "返回结果不应为空")

	t.Logf("筛选标签列表成功，总数: %d", resp.Total)
}

func TestTagInfo(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	listParams := &dto.TagListReq{
		Page:     1,
		PageSize: 1,
	}
	listResp, err := contentLogic.TagList(context.Background(), listParams)
	assert.Nil(t, err)
	assert.Greater(t, len(listResp.Items.([]*dto.TagInfoResp)), 0, "需要至少一条数据进行测试")

	firstTag := listResp.Items.([]*dto.TagInfoResp)[0]
	tagId := firstTag.Id

	resp, err := contentLogic.TagInfo(context.Background(), tagId)
	assert.Nil(t, err, "获取标签详情应该成功")
	assert.NotNil(t, resp, "返回结果不应为空")
	assert.Equal(t, tagId, resp.Id, "返回的ID应与请求一致")
	assert.NotEmpty(t, resp.Name, "标签名称不应为空")

	t.Logf("获取标签详情成功，ID: %d, 名称: %s", resp.Id, resp.Name)
}

func TestTagUpdate(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	addParams := &dto.UpsertTagReq{
		Name:   "待更新标签",
		Sort:   100,
		Status: 1,
	}
	err := contentLogic.TagAdd(context.Background(), addParams)
	assert.Nil(t, err)

	listParams := &dto.TagListReq{
		Page:     1,
		PageSize: 10,
		Name:     "待更新标签",
	}
	listResp, err := contentLogic.TagList(context.Background(), listParams)
	assert.Nil(t, err)
	tags := listResp.Items.([]*dto.TagInfoResp)
	assert.Greater(t, len(tags), 0)
	tagId := tags[0].Id

	updateParams := &dto.UpsertTagReq{
		Name:   "已更新标签",
		Sort:   50,
		Status: 2,
	}
	err = contentLogic.TagUpdate(context.Background(), tagId, updateParams)
	assert.Nil(t, err, "更新标签应该成功")

	updatedInfo, err := contentLogic.TagInfo(context.Background(), tagId)
	assert.Nil(t, err)
	assert.Equal(t, "已更新标签", updatedInfo.Name, "名称应已更新")
	assert.Equal(t, int64(50), updatedInfo.Sort, "排序应已更新")
	assert.Equal(t, int64(2), updatedInfo.Status, "状态应已更新")

	t.Log("更新标签成功")
}

func TestTagDelete(t *testing.T) {
	gooze.RunTest("../configs/admin.yaml", "../.env.admin", false)

	addParams := &dto.UpsertTagReq{
		Name:   "待删除标签",
		Sort:   100,
		Status: 1,
	}
	err := contentLogic.TagAdd(context.Background(), addParams)
	assert.Nil(t, err)

	listParams := &dto.TagListReq{
		Page:     1,
		PageSize: 10,
		Name:     "待删除标签",
	}
	listResp, err := contentLogic.TagList(context.Background(), listParams)
	assert.Nil(t, err)
	tags := listResp.Items.([]*dto.TagInfoResp)
	assert.Greater(t, len(tags), 0)
	tagId := tags[0].Id

	err = contentLogic.TagDelete(context.Background(), tagId)
	assert.Nil(t, err, "删除标签应该成功")

	_, err = contentLogic.TagInfo(context.Background(), tagId)
	assert.NotNil(t, err, "已删除的标签不应存在")

	t.Log("删除标签成功")
}
