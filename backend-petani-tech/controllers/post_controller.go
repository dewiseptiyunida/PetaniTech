package controllers

import (
	"net/http"
	"strconv"
	"time"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"github.com/gin-gonic/gin"
)

type CreatePostInput struct {
	Title    string `json:"title" binding:"required"`
	Content  string `json:"content" binding:"required"`
	Status   string `json:"status"`
	ImageURL string `json:"image_url"`
	Image    string `json:"image"`
	Sort     int    `json:"sort"`
}

type UpdatePostInput struct {
	Title    string `json:"title"`
	Content  string `json:"content"`
	Status   string `json:"status"`
	ImageURL string `json:"image_url"`
	Image    string `json:"image"`
	Sort     *int   `json:"sort"`
}

func CreatePost(c *gin.Context) {
	var userCreatedID *string
	if userID, exists := c.Get("user_id"); exists {
		if uIDStr, ok := userID.(string); ok && uIDStr != "" {
			userCreatedID = &uIDStr
		}
	}

	if userCreatedID == nil {
		var defaultAdmin models.User
		if err := config.DB.Where("role = ?", "admin").First(&defaultAdmin).Error; err == nil {
			userCreatedID = &defaultAdmin.ID
		} else if err := config.DB.First(&defaultAdmin).Error; err == nil {
			userCreatedID = &defaultAdmin.ID
		}
	}

	var input CreatePostInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	img := input.ImageURL
	if img == "" {
		img = input.Image
	}

	status := input.Status
	if status == "" {
		status = "published"
	}

	post := models.Post{
		UserCreatedID: userCreatedID,
		Title:         input.Title,
		Content:       input.Content,
		Status:        status,
		Sort:          input.Sort,
		ImageURL:      img,
	}

	if err := config.DB.Create(&post).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create post"})
		return
	}

	// Preload relasi UserCreated untuk respons yang utuh
	config.DB.Preload("UserCreated").First(&post, "id = ?", post.ID)
	if post.UserCreated != nil {
		post.UserCreated.PasswordHash = ""
	}
	post.BuildImageModel()

	c.JSON(http.StatusCreated, gin.H{
		"data": post,
	})
}

func GetPosts(c *gin.Context) {
	var posts []models.Post
	query := config.DB.Model(&models.Post{}).Preload("UserCreated").Preload("UserUpdated")

	// Filter status jika diberikan (misal dari Flutter: filter[status][_eq]=published)
	statusFilter := c.Query("filter[status][_eq]")
	if statusFilter == "" {
		statusFilter = c.Query("status")
	}
	if statusFilter != "" {
		query = query.Where("LOWER(status) = LOWER(?)", statusFilter)
	}

	// Filter search
	if search := c.Query("search"); search != "" {
		query = query.Where("title ILIKE ?", "%"+search+"%")
	}

	// Sorting: sort ASC, date_created DESC
	query = query.Order("sort ASC, date_created DESC")

	// Pagination
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

	if err := query.Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch posts"})
		return
	}

	for i := range posts {
		if posts[i].UserCreated != nil {
			posts[i].UserCreated.PasswordHash = ""
		}
		if posts[i].UserUpdated != nil {
			posts[i].UserUpdated.PasswordHash = ""
		}
		posts[i].BuildImageModel()
	}

	// Format response dengan wrapper {"data": [...]} agar 100% kompatibel dengan Flutter
	c.JSON(http.StatusOK, gin.H{
		"data": posts,
	})
}

func GetPostByID(c *gin.Context) {
	id := c.Param("id")
	var post models.Post
	if err := config.DB.Preload("UserCreated").Preload("UserUpdated").Where("id = ?", id).First(&post).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Post not found"})
		return
	}

	if post.UserCreated != nil {
		post.UserCreated.PasswordHash = ""
	}
	if post.UserUpdated != nil {
		post.UserUpdated.PasswordHash = ""
	}
	post.BuildImageModel()

	// Format response dengan wrapper {"data": {...}} agar 100% kompatibel dengan Flutter
	c.JSON(http.StatusOK, gin.H{
		"data": post,
	})
}

func UpdatePost(c *gin.Context) {
	id := c.Param("id")
	var post models.Post
	if err := config.DB.Where("id = ?", id).First(&post).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Post not found"})
		return
	}

	var input UpdatePostInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	img := input.ImageURL
	if img == "" {
		img = input.Image
	}

	updates := map[string]interface{}{}
	if input.Title != "" {
		updates["title"] = input.Title
	}
	if input.Content != "" {
		updates["content"] = input.Content
	}
	if input.Status != "" {
		updates["status"] = input.Status
	}
	if img != "" {
		updates["image"] = img
	}
	if input.Sort != nil {
		updates["sort"] = *input.Sort
	}

	userID, exists := c.Get("user_id")
	if exists {
		if uIDStr, ok := userID.(string); ok && uIDStr != "" {
			updates["user_updated_id"] = uIDStr
		}
	}
	updates["date_updated"] = time.Now()

	if err := config.DB.Model(&post).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update post"})
		return
	}

	config.DB.Preload("UserCreated").Preload("UserUpdated").First(&post, "id = ?", post.ID)
	if post.UserCreated != nil {
		post.UserCreated.PasswordHash = ""
	}
	if post.UserUpdated != nil {
		post.UserUpdated.PasswordHash = ""
	}
	post.BuildImageModel()

	c.JSON(http.StatusOK, gin.H{
		"data": post,
	})
}

func DeletePost(c *gin.Context) {
	id := c.Param("id")
	var post models.Post
	if err := config.DB.Where("id = ?", id).First(&post).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Post not found"})
		return
	}

	if err := config.DB.Delete(&post).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete post"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Post deleted successfully"})
}
