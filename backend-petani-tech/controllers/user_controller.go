package controllers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"github.com/gin-gonic/gin"
)

type UpdateProfileInput struct {
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Phone     string `json:"phone"`
	Avatar    string `json:"avatar"`
	Location  string `json:"location"`
}

func GetProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var user models.User
	if err := config.DB.Where("id = ?", userID).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	user.PasswordHash = ""
	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"id":                  user.ID,
			"first_name":          user.FirstName,
			"last_name":           user.LastName,
			"email":               user.Email,
			"role":                user.Role,
			"status":              user.Status,
			"avatar":              user.Avatar,
			"phone":               user.Phone,
			"location":            user.Location,
			"email_notifications": false,
		},
	})
}

func UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var user models.User
	if err := config.DB.Where("id = ?", userID).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	updates := map[string]interface{}{}

	if strings.Contains(c.ContentType(), "multipart/form-data") {
		firstName := c.PostForm("first_name")
		lastName := c.PostForm("last_name")
		phone := c.PostForm("phone")
		location := c.PostForm("location")
		avatarText := c.PostForm("avatar")

		if firstName != "" {
			updates["first_name"] = firstName
		}
		if lastName != "" {
			updates["last_name"] = lastName
		}
		if phone != "" {
			updates["phone"] = phone
		}
		if location != "" {
			updates["location"] = location
		}
		if avatarText != "" {
			updates["avatar"] = avatarText
		}

		file, err := c.FormFile("avatar")
		if err != nil {
			file, err = c.FormFile("file")
		}
		if err == nil && file != nil {
			_ = os.MkdirAll("uploads", os.ModePerm)
			ext := strings.ToLower(filepath.Ext(file.Filename))
			if ext == "" {
				ext = ".jpg"
			}
			filename := fmt.Sprintf("avatar_%d%s", time.Now().UnixNano(), ext)
			dst := filepath.Join("uploads", filename)
			if saveErr := c.SaveUploadedFile(file, dst); saveErr == nil {
				updates["avatar"] = filename
			}
		}
	} else {
		var input UpdateProfileInput
		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if input.FirstName != "" {
			updates["first_name"] = input.FirstName
		}
		if input.LastName != "" {
			updates["last_name"] = input.LastName
		}
		if input.Phone != "" {
			updates["phone"] = input.Phone
		}
		if input.Avatar != "" {
			updates["avatar"] = input.Avatar
		}
		if input.Location != "" {
			updates["location"] = input.Location
		}
	}

	if len(updates) > 0 {
		config.DB.Model(&user).Updates(updates)
	}

	// Fetch data terbaru
	config.DB.Where("id = ?", userID).First(&user)
	user.PasswordHash = ""

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"id":                  user.ID,
			"first_name":          user.FirstName,
			"last_name":           user.LastName,
			"email":               user.Email,
			"role":                user.Role,
			"status":              user.Status,
			"avatar":              user.Avatar,
			"phone":               user.Phone,
			"location":            user.Location,
			"email_notifications": false,
		},
	})
}

func UploadAvatar(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	file, err := c.FormFile("avatar")
	if err != nil {
		file, err = c.FormFile("file")
	}
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	if err := os.MkdirAll("uploads", os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create uploads directory"})
		return
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	if ext == "" {
		ext = ".jpg"
	}
	filename := fmt.Sprintf("avatar_%d%s", time.Now().UnixNano(), ext)
	dst := filepath.Join("uploads", filename)

	if err := c.SaveUploadedFile(file, dst); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}

	var user models.User
	if err := config.DB.Where("id = ?", userID).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	config.DB.Model(&user).Update("avatar", filename)
	user.Avatar = filename
	user.PasswordHash = ""

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"id":                  user.ID,
			"first_name":          user.FirstName,
			"last_name":           user.LastName,
			"email":               user.Email,
			"role":                user.Role,
			"status":              user.Status,
			"avatar":              user.Avatar,
			"phone":               user.Phone,
			"location":            user.Location,
			"email_notifications": false,
		},
	})
}

func GetUsers(c *gin.Context) {
	var users []models.User
	if err := config.DB.Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch users"})
		return
	}
	
	for i := range users {
		users[i].PasswordHash = "" // hide password
	}
	
	c.JSON(http.StatusOK, users)
}
