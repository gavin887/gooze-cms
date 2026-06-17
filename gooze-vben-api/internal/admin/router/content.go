package router

import (
	"github.com/gin-gonic/gin"
	"github.com/soryetong/gooze-starter/gooze"
	"gooze-vben-api/internal/admin/handler"
)

func InitCategoryAuthRouter(routerGroup *gin.RouterGroup) {
	categoryGroup := routerGroup.Group("/category")
	{
		categoryGroup.POST("/add", gooze.HandlerAdapter(handler.CategoryAdd))
		categoryGroup.GET("/tree", gooze.HandlerAdapter(handler.CategoryTree))
		categoryGroup.GET("/list", gooze.HandlerAdapter(handler.CategoryList))
		categoryGroup.GET("/info/:id", gooze.HandlerAdapter(handler.CategoryInfo))
		categoryGroup.PUT("/update/:id", gooze.HandlerAdapter(handler.CategoryUpdate))
		categoryGroup.DELETE("/delete/:id", gooze.HandlerAdapter(handler.CategoryDelete))
	}
}

func InitTagAuthRouter(routerGroup *gin.RouterGroup) {
	tagGroup := routerGroup.Group("/tag")
	{
		tagGroup.POST("/add", gooze.HandlerAdapter(handler.TagAdd))
		tagGroup.GET("/list", gooze.HandlerAdapter(handler.TagList))
		tagGroup.GET("/info/:id", gooze.HandlerAdapter(handler.TagInfo))
		tagGroup.PUT("/update/:id", gooze.HandlerAdapter(handler.TagUpdate))
		tagGroup.DELETE("/delete/:id", gooze.HandlerAdapter(handler.TagDelete))
	}
}
