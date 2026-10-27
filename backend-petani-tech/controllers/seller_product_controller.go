package controllers

import (
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"github.com/gin-gonic/gin"
)

type CreateSellerProductInput struct {
	Name          string  `json:"name" binding:"required"`
	SellerName    string  `json:"seller_name"`
	StoreName     string  `json:"store_name"`
	SellerContact string  `json:"seller_contact"`
	Location      string  `json:"location"`
	Category      string  `json:"category" binding:"required"`
	Subcategory   string  `json:"subcategory"`
	Price         float64 `json:"price" binding:"required"`
	OriginalPrice float64 `json:"original_price"`
	Stock         int     `json:"stock"`
	MinStockAlert int     `json:"min_stock_alert"`
	Unit          string  `json:"unit"`
	Status        string  `json:"status"`
	Image         string  `json:"image"`
	Description   string  `json:"description"`
	SKU           string  `json:"sku"`
}

type UpdateSellerProductInput struct {
	Name          string   `json:"name"`
	SellerName    string   `json:"seller_name"`
	StoreName     string   `json:"store_name"`
	SellerContact string   `json:"seller_contact"`
	Location      string   `json:"location"`
	Category      string   `json:"category"`
	Subcategory   string   `json:"subcategory"`
	Price         *float64 `json:"price"`
	OriginalPrice *float64 `json:"original_price"`
	Stock         *int     `json:"stock"`
	MinStockAlert *int     `json:"min_stock_alert"`
	Unit          string   `json:"unit"`
	Status        string   `json:"status"`
	Image         string   `json:"image"`
	Description   string   `json:"description"`
	SKU           string   `json:"sku"`
}

func GetSellerProducts(c *gin.Context) {
	var products []models.SellerProduct
	query := config.DB.Model(&models.SellerProduct{})

	if search := c.Query("search"); search != "" {
		q := "%" + strings.ToLower(search) + "%"
		query = query.Where("LOWER(name) LIKE ? OR LOWER(category) LIKE ? OR LOWER(sku) LIKE ? OR LOWER(seller_name) LIKE ? OR LOWER(store_name) LIKE ?", q, q, q, q, q)
	}

	if category := c.Query("category"); category != "" && category != "Semua" {
		query = query.Where("LOWER(category) = LOWER(?)", category)
	}

	if status := c.Query("status"); status != "" {
		switch strings.ToLower(status) {
		case "active", "aktif":
			query = query.Where("LOWER(status) = 'aktif'")
		case "low_stock", "stok menipis":
			query = query.Where("LOWER(status) = 'stok menipis' OR (stock > 0 AND stock <= min_stock_alert)")
		case "out_of_stock", "habis":
			query = query.Where("LOWER(status) = 'habis' OR stock = 0")
		case "review", "sedang diperiksa":
			query = query.Where("LOWER(status) = 'sedang diperiksa'")
		default:
			query = query.Where("LOWER(status) = LOWER(?)", status)
		}
	}

	query = query.Order("date_created DESC")

	if err := query.Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch seller products"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": products,
	})
}

func GetSellerProductByID(c *gin.Context) {
	id := c.Param("id")
	var product models.SellerProduct
	if err := config.DB.Where("id = ?", id).First(&product).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": product,
	})
}

func CreateSellerProduct(c *gin.Context) {
	var input CreateSellerProductInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	sellerName := input.SellerName
	if sellerName == "" {
		sellerName = "Fahda Febriya"
	}

	storeName := input.StoreName
	if storeName == "" {
		storeName = "Toko Tani Makmur Fahda"
	}

	contact := input.SellerContact
	if contact == "" {
		contact = "0812-3456-7890"
	}

	loc := input.Location
	if loc == "" {
		loc = "Indramayu, Jawa Barat"
	}

	minStock := input.MinStockAlert
	if minStock <= 0 {
		minStock = 10
	}

	status := input.Status
	if status == "" {
		if input.Stock == 0 {
			status = "Habis"
		} else if input.Stock <= minStock {
			status = "Stok Menipis"
		} else {
			status = "Aktif"
		}
	}

	unit := input.Unit
	if unit == "" {
		unit = "Pcs"
	}

	origPrice := input.OriginalPrice
	if origPrice <= 0 {
		origPrice = input.Price
	}

	sku := input.SKU
	if sku == "" {
		catPrefix := "AGR"
		if len(input.Category) >= 3 {
			catPrefix = strings.ToUpper(input.Category[:3])
		}
		sku = fmt.Sprintf("AGR-%s-%03d", catPrefix, rand.Intn(900)+100)
	}

	id := fmt.Sprintf("prod-%d", time.Now().UnixMilli()%100000)

	img := input.Image
	if img == "" {
		img = "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=500&auto=format&fit=crop&q=80"
	}

	product := models.SellerProduct{
		ID:            id,
		SellerName:    sellerName,
		StoreName:     storeName,
		SellerContact: contact,
		Location:      loc,
		Name:          input.Name,
		Category:      input.Category,
		Subcategory:   input.Subcategory,
		Price:         input.Price,
		OriginalPrice: origPrice,
		Stock:         input.Stock,
		MinStockAlert: minStock,
		Unit:          unit,
		Status:        status,
		Image:         img,
		Description:   input.Description,
		SKU:           sku,
		SoldCount:     0,
		Rating:        5.0,
		DateCreated:   time.Now(),
		DateUpdated:   time.Now(),
	}

	if err := config.DB.Create(&product).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create seller product: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"data": product,
	})
}

func UpdateSellerProduct(c *gin.Context) {
	id := c.Param("id")
	var product models.SellerProduct
	if err := config.DB.Where("id = ?", id).First(&product).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
		return
	}

	var input UpdateSellerProductInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updates := map[string]interface{}{}
	if input.Name != "" {
		updates["name"] = input.Name
	}
	if input.SellerName != "" {
		updates["seller_name"] = input.SellerName
	}
	if input.StoreName != "" {
		updates["store_name"] = input.StoreName
	}
	if input.SellerContact != "" {
		updates["seller_contact"] = input.SellerContact
	}
	if input.Location != "" {
		updates["location"] = input.Location
	}
	if input.Category != "" {
		updates["category"] = input.Category
	}
	if input.Subcategory != "" {
		updates["subcategory"] = input.Subcategory
	}
	if input.Price != nil {
		updates["price"] = *input.Price
	}
	if input.OriginalPrice != nil {
		updates["original_price"] = *input.OriginalPrice
	}
	if input.Stock != nil {
		updates["stock"] = *input.Stock
		// Auto adjust status if not explicitly given
		if input.Status == "" {
			minStock := product.MinStockAlert
			if input.MinStockAlert != nil {
				minStock = *input.MinStockAlert
			}
			if *input.Stock == 0 {
				updates["status"] = "Habis"
			} else if *input.Stock <= minStock {
				updates["status"] = "Stok Menipis"
			} else if product.Status == "Habis" || product.Status == "Stok Menipis" {
				updates["status"] = "Aktif"
			}
		}
	}
	if input.MinStockAlert != nil {
		updates["min_stock_alert"] = *input.MinStockAlert
	}
	if input.Unit != "" {
		updates["unit"] = input.Unit
	}
	if input.Status != "" {
		updates["status"] = input.Status
	}
	if input.Image != "" {
		updates["image"] = input.Image
	}
	if input.Description != "" {
		updates["description"] = input.Description
	}
	if input.SKU != "" {
		updates["sku"] = input.SKU
	}

	updates["date_updated"] = time.Now()

	if err := config.DB.Model(&product).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update seller product"})
		return
	}

	config.DB.Where("id = ?", id).First(&product)
	c.JSON(http.StatusOK, gin.H{
		"data": product,
	})
}

func DeleteSellerProduct(c *gin.Context) {
	id := c.Param("id")
	var product models.SellerProduct
	if err := config.DB.Where("id = ?", id).First(&product).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
		return
	}

	if err := config.DB.Delete(&product).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete seller product"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Product deleted successfully"})
}
