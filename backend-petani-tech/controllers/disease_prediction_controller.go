package controllers

import (
	"net/http"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"github.com/gin-gonic/gin"
)

type CreatePredictionInput struct {
	ImageURL         string `json:"image_url" binding:"required"`
	PredictionResult string `json:"prediction_result" binding:"required"`
}

type UpdatePredictionInput struct {
	ImageURL         string `json:"image_url"`
	PredictionResult string `json:"prediction_result"`
}

func CreatePrediction(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var input CreatePredictionInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	prediction := models.DiseasePrediction{
		UserID:           userID.(string),
		ImageURL:         input.ImageURL,
		PredictionResult: input.PredictionResult,
	}

	if err := config.DB.Create(&prediction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create prediction"})
		return
	}
	c.JSON(http.StatusCreated, prediction)
}

func GetPredictions(c *gin.Context) {
	var predictions []models.DiseasePrediction
	if err := config.DB.Find(&predictions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch predictions"})
		return
	}
	c.JSON(http.StatusOK, predictions)
}

func GetPredictionByID(c *gin.Context) {
	id := c.Param("id")
	var prediction models.DiseasePrediction
	if err := config.DB.Where("id = ?", id).First(&prediction).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Prediction not found"})
		return
	}
	c.JSON(http.StatusOK, prediction)
}

func UpdatePrediction(c *gin.Context) {
	id := c.Param("id")
	var prediction models.DiseasePrediction
	if err := config.DB.Where("id = ?", id).First(&prediction).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Prediction not found"})
		return
	}

	var input UpdatePredictionInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := config.DB.Model(&prediction).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update prediction"})
		return
	}
	c.JSON(http.StatusOK, prediction)
}

func DeletePrediction(c *gin.Context) {
	id := c.Param("id")
	var prediction models.DiseasePrediction
	if err := config.DB.Where("id = ?", id).First(&prediction).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Prediction not found"})
		return
	}

	if err := config.DB.Delete(&prediction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete prediction"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Prediction deleted successfully"})
}
