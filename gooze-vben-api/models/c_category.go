package models

// CCategories 分类管理
type CCategories struct {
	GnModel
	Name     string       `json:"name" gorm:"name"`          // 分类名称
	Icon     string       `json:"icon" gorm:"icon"`          // 图标（可空）
	Sort     int64        `json:"sort" gorm:"sort"`          // 排序值（默认100）
	Status   int64        `json:"status" gorm:"status"`      // 状态（1-启用 2-禁用）
	ParentId int64        `json:"parentId" gorm:"parent_id"` // 父级ID
	Children []CCategories `json:"children" gorm:"-"`        // 子分类（不映射到数据库）
}

// TableName 表名称
func (*CCategories) TableName() string {
	return "c_categories"
}
