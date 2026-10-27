package controllers

import (
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
)

// GetAsset handles asset requests (e.g. from Flutter's ApiClient.getAsset)
// If filepath is an external URL, it redirects to it.
// If filepath matches a local file in assets/ or uploads/, it serves it.
// Otherwise, it serves a high-quality agriculture placeholder.
func GetAsset(c *gin.Context) {
	raw := c.Param("filepath")
	raw = strings.TrimPrefix(raw, "/")

	// Menormalkan URL jika ada prefix http:/ atau https:/
	if strings.HasPrefix(raw, "http:/") && !strings.HasPrefix(raw, "http://") {
		raw = "http://" + strings.TrimPrefix(raw, "http:/")
	} else if strings.HasPrefix(raw, "https:/") && !strings.HasPrefix(raw, "https://") {
		raw = "https://" + strings.TrimPrefix(raw, "https:/")
	}

	// Jika berupa URL internet langsung (Unsplash, Cloudinary, S3, dll)
	if strings.HasPrefix(raw, "http://") || strings.HasPrefix(raw, "https://") {
		c.Redirect(http.StatusFound, raw)
		return
	}

	cleanName := strings.TrimPrefix(raw, "asset:")
	// Cek apakah file fisik ada di folder lokal uploads atau assets
	candidates := []string{
		filepath.Join("uploads", raw),
		filepath.Join("assets", raw),
		filepath.Join("assets", cleanName),
		filepath.Join("assets", cleanName+".jpg"),
		filepath.Join("assets", cleanName+".png"),
		filepath.Join("assets", strings.ToLower(cleanName)+".jpg"),
		filepath.Join("assets", strings.ToLower(cleanName)+".png"),
		filepath.Join("uploads", cleanName),
		filepath.Join("uploads", cleanName+".jpg"),
		filepath.Join("uploads", cleanName+".png"),
	}
	for _, p := range candidates {
		if info, err := os.Stat(p); err == nil && !info.IsDir() {
			c.File(p)
			return
		}
	}

	// Fallback gambar pertanian dari Unsplash yang stabil
	c.Redirect(http.StatusFound, "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80")
}

// UploadFile handles multipart file uploads (e.g. avatars, pictures)
func UploadFile(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		file, err = c.FormFile("avatar")
		if err != nil {
			file, err = c.FormFile("image")
		}
	}

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded or invalid form field"})
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
	filename := strings.ReplaceAll(filepath.Base(file.Filename), " ", "_")
	// Prepend timestamp to make unique
	uniqueName := strings.TrimSuffix(filename, ext) + "_" + strings.ReplaceAll(c.ClientIP(), ":", "") + "_" + ext
	if len(uniqueName) > 60 {
		uniqueName = "upload_" + ext
	}
	// Use timestamp
	uniqueName = strings.ToLower(filepath.Clean(uniqueName))
	dst := filepath.Join("uploads", file.Filename)
	// If exists or for uniqueness:
	dst = filepath.Join("uploads", file.Filename)
	if err := c.SaveUploadedFile(file, dst); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"filename": file.Filename,
			"url":      file.Filename,
		},
	})
}
