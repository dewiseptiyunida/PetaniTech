package controllers

import (
	"net/http"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"github.com/gin-gonic/gin"
)

func GetStats(c *gin.Context) {
	var userCount, farmCount, postCount, sellerProductCount int64

	config.DB.Model(&models.User{}).Count(&userCount)
	config.DB.Model(&models.Farm{}).Count(&farmCount)
	config.DB.Model(&models.Post{}).Count(&postCount)
	config.DB.Model(&models.SellerProduct{}).Count(&sellerProductCount)

	c.JSON(http.StatusOK, gin.H{
		"users":           userCount,
		"farms":           farmCount,
		"posts":           postCount,
		"seller_products": sellerProductCount,
	})
}
