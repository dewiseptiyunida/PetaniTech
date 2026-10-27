package controllers

import (
	"net/http"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"github.com/gin-gonic/gin"
)

type CreateCommunityInput struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Image       string `json:"image"`
	Visibility  string `json:"visibility"`
	Status      string `json:"status"`
}

type UpdateCommunityInput struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Image       string `json:"image"`
	Visibility  string `json:"visibility"`
	Status      string `json:"status"`
}

func CreateCommunity(c *gin.Context) {
	var input CreateCommunityInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	community := models.Community{
		Name:        input.Name,
		Description: input.Description,
		Image:       input.Image,
		Visibility:  input.Visibility,
		Status:      input.Status,
	}

	if err := config.DB.Create(&community).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create community"})
		return
	}
	c.JSON(http.StatusCreated, community)
}

func GetCommunities(c *gin.Context) {
	var communities []models.Community
	if err := config.DB.Find(&communities).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch communities"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"data": communities,
	})
}

func GetCommunityByID(c *gin.Context) {
	id := c.Param("id")
	var community models.Community
	if err := config.DB.Where("id = ?", id).First(&community).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Community not found"})
		return
	}
	c.JSON(http.StatusOK, community)
}

func UpdateCommunity(c *gin.Context) {
	id := c.Param("id")
	var community models.Community
	if err := config.DB.Where("id = ?", id).First(&community).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Community not found"})
		return
	}

	var input UpdateCommunityInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := config.DB.Model(&community).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update community"})
		return
	}
	c.JSON(http.StatusOK, community)
}

func DeleteCommunity(c *gin.Context) {
	id := c.Param("id")
	var community models.Community
	if err := config.DB.Where("id = ?", id).First(&community).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Community not found"})
		return
	}

	if err := config.DB.Delete(&community).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete community"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Community deleted successfully"})
}
