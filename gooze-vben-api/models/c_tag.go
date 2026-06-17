package models

// CTags 标签管理
type CTags struct {
	GnModel
	Name   string `json:"name" gorm:"name"`     // 标签名称
	Sort   int64  `json:"sort" gorm:"sort"`     // 排序值（默认100）
	Status int64  `json:"status" gorm:"status"` // 状态（1-启用 2-禁用）
}

// TableName 表名称
func (*CTags) TableName() string {
	return "c_tags"
}
