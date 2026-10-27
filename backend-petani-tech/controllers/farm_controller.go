package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"github.com/gin-gonic/gin"
)

type CreateFarmInput struct {
	Name          string `json:"name" binding:"required"`
	AreaSize      string `json:"area_size"`
	AreaUnit      string `json:"area_unit"`
	SoilType      int    `json:"soil_type"`
	OwnershipType string `json:"ownership_type"`
	Address       string `json:"address"`
	Status        string `json:"status"`
}

type UpdateFarmInput struct {
	Name          string `json:"name"`
	AreaSize      string `json:"area_size"`
	AreaUnit      string `json:"area_unit"`
	SoilType      int    `json:"soil_type"`
	OwnershipType string `json:"ownership_type"`
	Address       string `json:"address"`
	Status        string `json:"status"`
}

func CreateFarm(c *gin.Context) {
	var userIDStr string
	if userID, exists := c.Get("user_id"); exists {
		userIDStr = userID.(string)
	} else {
		var defaultUser models.User
		if err := config.DB.First(&defaultUser).Error; err == nil {
			userIDStr = defaultUser.ID
		}
	}

	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var input CreateFarmInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	status := input.Status
	if status == "" || strings.EqualFold(status, "active") {
		status = "published"
	}

	unit := input.AreaUnit
	if unit == "" {
		unit = "m2"
	}

	farm := models.Farm{
		UserID:        userIDStr,
		Name:          input.Name,
		AreaSize:      input.AreaSize,
		AreaUnit:      unit,
		SoilType:      input.SoilType,
		OwnershipType: input.OwnershipType,
		Address:       input.Address,
		Status:        status,
	}

	if err := config.DB.Create(&farm).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create farm"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"data": farm,
	})
}

func GetFarms(c *gin.Context) {
	var farms []models.Farm
	query := config.DB.Model(&models.Farm{})

	if status := c.Query("filter[status][_eq]"); status != "" {
		if strings.EqualFold(status, "published") {
			query = query.Where("LOWER(status) IN (?, ?)", "published", "active")
		} else {
			query = query.Where("LOWER(status) = LOWER(?)", status)
		}
	} else if status := c.Query("status"); status != "" {
		if strings.EqualFold(status, "published") {
			query = query.Where("LOWER(status) IN (?, ?)", "published", "active")
		} else {
			query = query.Where("LOWER(status) = LOWER(?)", status)
		}
	}

	query = query.Order("date_created DESC")

	if limitStr := c.Query("limit"); limitStr != "" {
		if limit, err := strconv.Atoi(limitStr); err == nil && limit > 0 {
			query = query.Limit(limit)
		}
	}
	if offsetStr := c.Query("offset"); offsetStr != "" {
		if offset, err := strconv.Atoi(offsetStr); err == nil && offset >= 0 {
			query = query.Offset(offset)
		}
	}

	if err := query.Find(&farms).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch farms"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": farms,
	})
}

func GetFarmByID(c *gin.Context) {
	id := c.Param("id")
	var farm models.Farm
	if err := config.DB.Where("id = ?", id).First(&farm).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Farm not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": farm,
	})
}

func UpdateFarm(c *gin.Context) {
	id := c.Param("id")
	var farm models.Farm
	if err := config.DB.Where("id = ?", id).First(&farm).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Farm not found"})
		return
	}

	var input UpdateFarmInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := config.DB.Model(&farm).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update farm"})
		return
	}

	config.DB.Where("id = ?", id).First(&farm)
	c.JSON(http.StatusOK, gin.H{
		"data": farm,
	})
}

func DeleteFarm(c *gin.Context) {
	id := c.Param("id")
	var farm models.Farm
	if err := config.DB.Where("id = ?", id).First(&farm).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Farm not found"})
		return
	}

	if err := config.DB.Delete(&farm).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete farm"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Farm deleted successfully"})
}
