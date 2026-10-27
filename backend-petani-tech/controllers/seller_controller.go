package controllers

import (
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"backend-petani-tech/pkg/utils"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// Helper untuk mendapatkan seller saat ini (dengan fallback ke seller default untuk kemudahan dev)
func getCurrentOrFallbackSeller(c *gin.Context) (*models.Seller, error) {
	authHeader := c.GetHeader("Authorization")
	if authHeader != "" {
		parts := strings.Split(authHeader, " ")
		if len(parts) == 2 && parts[0] == "Bearer" {
			tokenString := parts[1]
			claims, err := utils.ValidateToken(tokenString)
			if err == nil && claims["user_id"] != nil {
				userID := fmt.Sprintf("%v", claims["user_id"])
				var seller models.Seller
				if err := config.DB.Where("id = ? OR user_id = ? OR email = ?", userID, userID, userID).First(&seller).Error; err == nil {
					return &seller, nil
				}
			}
		}
	}

	// Fallback ke seller default pertama di database
	var defaultSeller models.Seller
	if err := config.DB.Where("id = ?", "usr-seller-fahda").First(&defaultSeller).Error; err == nil {
		return &defaultSeller, nil
	}
	if err := config.DB.First(&defaultSeller).Error; err == nil {
		return &defaultSeller, nil
	}

	return nil, fmt.Errorf("no seller available")
}

// ── Auth Seller ─────────────────────────────────────────────────────────────

func GetSellerMe(c *gin.Context) {
	seller, err := getCurrentOrFallbackSeller(c)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Seller session not found"})
		return
	}

	c.JSON(http.StatusOK, seller.ToUserProfile())
}

type SellerLoginInput struct {
	Identifier string `json:"identifier" binding:"required"`
	Password   string `json:"password" binding:"required"`
}

func SellerLogin(c *gin.Context) {
	var input SellerLoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Input tidak valid: " + err.Error()})
		return
	}

	idTrim := strings.ToLower(strings.TrimSpace(input.Identifier))
	var seller models.Seller
	err := config.DB.Where("LOWER(email) = ? OR LOWER(phone) = ? OR LOWER(name) = ? OR id = ?", idTrim, idTrim, idTrim, idTrim).First(&seller).Error
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Email/Nomor HP atau kata sandi salah. Gunakan akun demo (123456)."})
		return
	}

	// Cek password: bisa via bcrypt atau bypass default demo '123456'
	if input.Password != "123456" {
		if err := bcrypt.CompareHashAndPassword([]byte(seller.PasswordHash), []byte(input.Password)); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"message": "Kata sandi salah"})
			return
		}
	}

	token, err := utils.GenerateToken(seller.ID)
	if err != nil {
		token = "jwt-petani-tech-seller-" + seller.ID
	}

	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user":  seller.ToUserProfile(),
	})
}

type SellerRegisterInput struct {
	Name         string `json:"name" binding:"required"`
	Email        string `json:"email" binding:"required,email"`
	Phone        string `json:"phone" binding:"required"`
	StoreName    string `json:"storeName" binding:"required"`
	StoreAddress string `json:"storeAddress"`
	Password     string `json:"password"`
}

func SellerRegister(c *gin.Context) {
	var input SellerRegisterInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Input tidak lengkap: " + err.Error()})
		return
	}

	var existing models.Seller
	if err := config.DB.Where("LOWER(email) = ?", strings.ToLower(input.Email)).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Email toko sudah terdaftar"})
		return
	}

	pwd := input.Password
	if pwd == "" {
		pwd = "123456"
	}
	hashed, _ := bcrypt.GenerateFromPassword([]byte(pwd), bcrypt.DefaultCost)

	now := time.Now()
	newSeller := models.Seller{
		ID:                fmt.Sprintf("usr-seller-%d", now.Unix()),
		Name:              input.Name,
		Email:             strings.ToLower(input.Email),
		Phone:             input.Phone,
		PasswordHash:      string(hashed),
		Role:              "seller",
		StoreName:         input.StoreName,
		StoreID:           fmt.Sprintf("ID-AGRO-%d", 1000+rand.Intn(9000)),
		Status:            "Seller Terverifikasi",
		Avatar:            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80",
		StoreAddress:      input.StoreAddress,
		JoinedDate:        now.Format("January 2006"),
		Rating:            5.0,
		TotalReview:       0,
		Balance:           0,
		BankName:          "Bank Rakyat Indonesia (BRI)",
		BankAccountNo:     "4321-01-098765-53-2",
		BankAccountHolder: strings.ToUpper(input.Name),
	}

	if err := config.DB.Create(&newSeller).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal mendaftarkan toko seller"})
		return
	}

	token, err := utils.GenerateToken(newSeller.ID)
	if err != nil {
		token = "jwt-petani-tech-seller-" + newSeller.ID
	}

	c.JSON(http.StatusCreated, gin.H{
		"token": token,
		"user":  newSeller.ToUserProfile(),
	})
}

type UpdateSellerProfileInput struct {
	Name         *string              `json:"name"`
	Phone        *string              `json:"phone"`
	StoreName    *string              `json:"storeName"`
	StoreAddress *string              `json:"storeAddress"`
	Avatar       *string              `json:"avatar"`
	BankAccount  *models.BankAccount  `json:"bankAccount"`
}

func UpdateSellerProfile(c *gin.Context) {
	seller, err := getCurrentOrFallbackSeller(c)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Seller tidak ditemukan"})
		return
	}

	var input UpdateSellerProfileInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	if input.Name != nil {
		seller.Name = *input.Name
	}
	if input.Phone != nil {
		seller.Phone = *input.Phone
	}
	if input.StoreName != nil {
		seller.StoreName = *input.StoreName
	}
	if input.StoreAddress != nil {
		seller.StoreAddress = *input.StoreAddress
	}
	if input.Avatar != nil {
		seller.Avatar = *input.Avatar
	}
	if input.BankAccount != nil {
		seller.BankName = input.BankAccount.BankName
		seller.BankAccountNo = input.BankAccount.AccountNumber
		seller.BankAccountHolder = input.BankAccount.AccountHolder
	}

	if err := config.DB.Save(seller).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal memperbarui profil toko"})
		return
	}

	c.JSON(http.StatusOK, seller.ToUserProfile())
}

// ── Seller Orders ───────────────────────────────────────────────────────────

func GetSellerOrders(c *gin.Context) {
	var orders []models.SellerOrder
	query := config.DB.Model(&models.SellerOrder{}).Preload("Items")

	if search := c.Query("search"); search != "" {
		q := "%" + strings.ToLower(search) + "%"
		query = query.Where("LOWER(order_number) LIKE ? OR LOWER(buyer_name) LIKE ? OR LOWER(buyer_phone) LIKE ?", q, q, q)
	}

	if status := c.Query("status"); status != "" && status != "all" {
		statusMap := map[string]string{
			"unpaid":     "Menunggu Pembayaran",
			"processing": "Diproses",
			"shipped":    "Dikirim",
			"completed":  "Selesai",
			"cancelled":  "Dibatalkan",
		}
		if mapped, ok := statusMap[strings.ToLower(status)]; ok {
			query = query.Where("status = ?", mapped)
		} else {
			query = query.Where("LOWER(status) = LOWER(?)", status)
		}
	}

	query = query.Order("date_created DESC")

	if err := query.Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal memuat pesanan seller"})
		return
	}

	c.JSON(http.StatusOK, orders)
}

func GetSellerOrderByID(c *gin.Context) {
	id := c.Param("id")
	var order models.SellerOrder
	if err := config.DB.Preload("Items").Where("id = ? OR order_number = ?", id, id).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Pesanan tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, order)
}

type UpdateOrderStatusInput struct {
	Status         string `json:"status" binding:"required"`
	TrackingNumber string `json:"trackingNumber"`
	Note           string `json:"note"`
}

func UpdateSellerOrderStatus(c *gin.Context) {
	id := c.Param("id")
	var order models.SellerOrder
	if err := config.DB.Preload("Items").Where("id = ? OR order_number = ?", id, id).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Pesanan tidak ditemukan"})
		return
	}

	var input UpdateOrderStatusInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Status tidak valid"})
		return
	}

	order.Status = input.Status
	if input.TrackingNumber != "" {
		order.TrackingNumber = input.TrackingNumber
	}
	if input.Note != "" {
		order.Note = input.Note
	}

	if err := config.DB.Save(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal memperbarui status pesanan"})
		return
	}

	c.JSON(http.StatusOK, order)
}

type CreateOrderItemInput struct {
	ProductID    string  `json:"productId"`
	ProductName  string  `json:"productName"`
	Category     string  `json:"category"`
	Quantity     int     `json:"quantity"`
	UnitPrice    float64 `json:"unitPrice"`
	Subtotal     float64 `json:"subtotal"`
	ProductImage string  `json:"productImage"`
	Unit         string  `json:"unit"`
	Variant      string  `json:"variant"`
}

type CreateOrderInput struct {
	ID             string                 `json:"id"`
	OrderNumber    string                 `json:"orderNumber"`
	SellerID       string                 `json:"sellerId"`
	StoreName      string                 `json:"storeName"`
	BuyerName      string                 `json:"buyerName"`
	BuyerPhone     string                 `json:"buyerPhone"`
	BuyerAddress   string                 `json:"buyerAddress"`
	Status         string                 `json:"status"`
	TotalAmount    float64                `json:"totalAmount"`
	ShippingFee    float64                `json:"shippingFee"`
	Courier        string                 `json:"courier"`
	TrackingNumber string                 `json:"trackingNumber"`
	PaymentMethod  string                 `json:"paymentMethod"`
	PaymentStatus  string                 `json:"paymentStatus"`
	Note           string                 `json:"note"`
	Items          []CreateOrderItemInput `json:"items"`
}

func CreateOrder(c *gin.Context) {
	var input CreateOrderInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	orderID := input.ID
	if orderID == "" {
		orderID = fmt.Sprintf("PT-ORD-%d", time.Now().UnixMilli()%1000000)
	}

	orderNumber := input.OrderNumber
	if orderNumber == "" {
		orderNumber = orderID
	}

	sellerID := input.SellerID
	if sellerID == "" {
		sellerID = "usr-seller-fahda"
	}

	storeName := input.StoreName
	if storeName == "" {
		storeName = "Toko Tani Makmur Fahda"
	}

	buyerName := input.BuyerName
	if buyerName == "" {
		buyerName = "Petani Pengguna"
	}

	status := input.Status
	if status == "" {
		if strings.Contains(strings.ToLower(input.PaymentMethod), "cod") {
			status = "Diproses"
		} else {
			status = "Menunggu Pembayaran"
		}
	}

	now := time.Now()
	order := models.SellerOrder{
		ID:             orderID,
		OrderNumber:    orderNumber,
		SellerID:       sellerID,
		StoreName:      storeName,
		BuyerName:      buyerName,
		BuyerPhone:     input.BuyerPhone,
		BuyerAddress:   input.BuyerAddress,
		Status:         status,
		TotalAmount:    input.TotalAmount,
		ShippingFee:    input.ShippingFee,
		Courier:        input.Courier,
		TrackingNumber: input.TrackingNumber,
		PaymentMethod:  input.PaymentMethod,
		Note:           input.Note,
		CreatedAt:      now.Format("2006-01-02 15:04"),
		DateCreated:    now,
	}

	var items []models.SellerOrderItem
	var computedTotal float64
	for _, itm := range input.Items {
		sub := itm.Subtotal
		if sub <= 0 {
			sub = float64(itm.Quantity) * itm.UnitPrice
		}
		computedTotal += sub

		unit := itm.Unit
		if unit == "" {
			if itm.Variant != "" {
				unit = itm.Variant
			} else {
				unit = "Pcs"
			}
		}

		itemModel := models.SellerOrderItem{
			OrderID:      orderID,
			ProductID:    itm.ProductID,
			ProductName:  itm.ProductName,
			Category:     itm.Category,
			Quantity:     itm.Quantity,
			UnitPrice:    itm.UnitPrice,
			Subtotal:     sub,
			ProductImage: itm.ProductImage,
			Unit:         unit,
		}

		// Kurangi stok produk dan tambahkan sold_count di database
		if itm.ProductID != "" || itm.ProductName != "" {
			var prod models.SellerProduct
			if err := config.DB.Where("id = ? OR LOWER(name) = LOWER(?)", itm.ProductID, itm.ProductName).First(&prod).Error; err == nil {
				if itemModel.ProductImage == "" && prod.Image != "" {
					itemModel.ProductImage = prod.Image
				}
				if itemModel.ProductID == "" {
					itemModel.ProductID = prod.ID
				}
				newStock := prod.Stock - itm.Quantity
				if newStock < 0 {
					newStock = 0
				}
				newStatus := prod.Status
				if newStock == 0 {
					newStatus = "Habis"
				} else if newStock <= prod.MinStockAlert {
					newStatus = "Stok Menipis"
				}
				config.DB.Model(&prod).Updates(map[string]interface{}{
					"stock":      newStock,
					"status":     newStatus,
					"sold_count": prod.SoldCount + itm.Quantity,
				})
			}
		}

		items = append(items, itemModel)
	}

	if order.TotalAmount <= 0 {
		order.TotalAmount = computedTotal + order.ShippingFee
	}

	order.Items = items

	if err := config.DB.Create(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pesanan: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Pesanan berhasil dibuat",
		"data":    order,
	})
}

func CancelOrder(c *gin.Context) {
	id := c.Param("id")
	var order models.SellerOrder
	if err := config.DB.Preload("Items").Where("id = ? OR order_number = ?", id, id).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Pesanan tidak ditemukan"})
		return
	}

	order.Status = "Dibatalkan"
	config.DB.Save(&order)

	// Kembalikan stok produk jika dibatalkan
	for _, itm := range order.Items {
		if itm.ProductID != "" || itm.ProductName != "" {
			var prod models.SellerProduct
			if err := config.DB.Where("id = ? OR LOWER(name) = LOWER(?)", itm.ProductID, itm.ProductName).First(&prod).Error; err == nil {
				config.DB.Model(&prod).Update("stock", prod.Stock+itm.Quantity)
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Pesanan berhasil dibatalkan",
		"data":    order,
	})
}

// ── Seller Finance ──────────────────────────────────────────────────────────

func GetSellerFinanceSummary(c *gin.Context) {
	seller, _ := getCurrentOrFallbackSeller(c)
	balance := 12850000.0
	if seller != nil {
		balance = seller.Balance
	}

	var totalWithdrawn float64
	config.DB.Model(&models.SellerTransaction{}).Where("type = ? AND status = ?", "Pencairan", "Berhasil").Select("COALESCE(ABS(SUM(amount)), 0)").Scan(&totalWithdrawn)
	if totalWithdrawn == 0 {
		totalWithdrawn = 34500000
	}

	var monthlyRevenue float64
	config.DB.Model(&models.SellerTransaction{}).Where("type = ? AND status = ?", "Penjualan", "Berhasil").Select("COALESCE(SUM(amount), 0)").Scan(&monthlyRevenue)
	if monthlyRevenue == 0 {
		monthlyRevenue = 15200000
	}

	c.JSON(http.StatusOK, gin.H{
		"availableBalance": balance,
		"monthlyRevenue":   monthlyRevenue,
		"pendingBalance":   1605000,
		"totalWithdrawn":   totalWithdrawn,
	})
}

func GetSellerTransactions(c *gin.Context) {
	var txs []models.SellerTransaction
	query := config.DB.Model(&models.SellerTransaction{}).Order("date_created DESC")

	if err := query.Find(&txs).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal memuat mutasi transaksi"})
		return
	}

	c.JSON(http.StatusOK, txs)
}

type WithdrawInput struct {
	Amount      float64 `json:"amount" binding:"required,gt=0"`
	BankDetails string  `json:"bankDetails" binding:"required"`
}

func WithdrawSellerBalance(c *gin.Context) {
	seller, err := getCurrentOrFallbackSeller(c)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Akun seller tidak ditemukan"})
		return
	}

	var input WithdrawInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Jumlah penarikan tidak valid"})
		return
	}

	if input.Amount > seller.Balance {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Jumlah penarikan melebihi saldo tersedia"})
		return
	}

	now := time.Now()
	newTx := models.SellerTransaction{
		ID:          fmt.Sprintf("TX-%d", now.UnixNano()/1000000),
		SellerID:    seller.ID,
		ReferenceNo: fmt.Sprintf("WD-%d", 100000+rand.Intn(900000)),
		Date:        now.Format("02 Jan 2006, 15:04"),
		Type:        "Pencairan",
		Amount:      -input.Amount,
		Status:      "Berhasil",
		Description: fmt.Sprintf("Penarikan saldo ke Rekening %s", input.BankDetails),
		DateCreated: now,
	}

	seller.Balance -= input.Amount
	config.DB.Save(seller)
	config.DB.Create(&newTx)

	c.JSON(http.StatusCreated, newTx)
}

// ── Seller Analytics ────────────────────────────────────────────────────────

func GetSellerAnalytics(c *gin.Context) {
	// Ambil top products dari database
	var products []models.SellerProduct
	config.DB.Model(&models.SellerProduct{}).Order("sold_count DESC").Limit(5).Find(&products)

	type TopProductMetric struct {
		ID        string  `json:"id"`
		Name      string  `json:"name"`
		Category  string  `json:"category"`
		SoldCount int     `json:"soldCount"`
		Revenue   float64 `json:"revenue"`
		Growth    float64 `json:"growth"`
	}

	var topMetrics []TopProductMetric
	for i, p := range products {
		growth := 18.5 + float64(i*4)
		topMetrics = append(topMetrics, TopProductMetric{
			ID:        p.ID,
			Name:      p.Name,
			Category:  p.Category,
			SoldCount: p.SoldCount,
			Revenue:   float64(p.SoldCount) * p.Price,
			Growth:    growth,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"summary": gin.H{
			"totalVisitors":     4820,
			"conversionRate":    3.8,
			"totalOrders":       184,
			"averageOrderValue": 450000,
		},
		"dailyData": []gin.H{
			{"date": "01 Okt", "penjualan": 1250000, "pesanan": 6, "pengunjung": 380},
			{"date": "02 Okt", "penjualan": 2100000, "pesanan": 9, "pengunjung": 520},
			{"date": "03 Okt", "penjualan": 1800000, "pesanan": 7, "pengunjung": 460},
			{"date": "04 Okt", "penjualan": 3400000, "pesanan": 14, "pengunjung": 680},
			{"date": "05 Okt", "penjualan": 2900000, "pesanan": 11, "pengunjung": 590},
			{"date": "06 Okt", "penjualan": 4100000, "pesanan": 18, "pengunjung": 810},
			{"date": "07 Okt", "penjualan": 3850000, "pesanan": 15, "pengunjung": 740},
		},
		"weeklyData": []gin.H{
			{"week": "Minggu 1", "penjualan": 8200000, "pesanan": 35, "pengunjung": 1850},
			{"week": "Minggu 2", "penjualan": 11400000, "pesanan": 48, "pengunjung": 2400},
			{"week": "Minggu 3", "penjualan": 14200000, "pesanan": 62, "pengunjung": 3100},
			{"week": "Minggu 4", "penjualan": 19500000, "pesanan": 84, "pengunjung": 4200},
		},
		"monthlyData": []gin.H{
			{"month": "Mei", "penjualan": 16200000, "pesanan": 72, "pengunjung": 3800},
			{"month": "Jun", "penjualan": 18500000, "pesanan": 85, "pengunjung": 4200},
			{"month": "Jul", "penjualan": 21000000, "pesanan": 96, "pengunjung": 5100},
			{"month": "Agu", "penjualan": 23400000, "pesanan": 110, "pengunjung": 5800},
			{"month": "Sep", "penjualan": 24800000, "pesanan": 122, "pengunjung": 6200},
			{"month": "Okt", "penjualan": 25500000, "pesanan": 134, "pengunjung": 6700},
		},
		"topProducts": topMetrics,
	})
}

// ── Admin Panel Specific Controllers ────────────────────────────────────────

func GetAdminSellers(c *gin.Context) {
	var sellers []models.Seller
	query := config.DB.Model(&models.Seller{}).Order("created_at DESC")

	if search := c.Query("search"); search != "" {
		q := "%" + strings.ToLower(search) + "%"
		query = query.Where("LOWER(name) LIKE ? OR LOWER(store_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(phone) LIKE ?", q, q, q, q)
	}

	if status := c.Query("status"); status != "" && status != "all" {
		query = query.Where("LOWER(status) = LOWER(?)", status)
	}

	if err := query.Find(&sellers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data penjual"})
		return
	}

	type SellerWithStats struct {
		models.Seller
		TotalProducts int64 `json:"totalProducts"`
		TotalOrders   int64 `json:"totalOrders"`
	}

	var result []SellerWithStats
	for _, s := range sellers {
		var prodCount int64
		config.DB.Model(&models.SellerProduct{}).Where("LOWER(seller_name) = LOWER(?) OR LOWER(store_name) = LOWER(?)", s.Name, s.StoreName).Count(&prodCount)

		var orderCount int64
		config.DB.Model(&models.SellerOrder{}).Where("seller_id = ? OR LOWER(store_name) = LOWER(?)", s.ID, s.StoreName).Count(&orderCount)

		result = append(result, SellerWithStats{
			Seller:        s,
			TotalProducts: prodCount,
			TotalOrders:   orderCount,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"data": result,
	})
}

type UpdateAdminSellerStatusInput struct {
	Status string `json:"status" binding:"required"`
}

func UpdateAdminSellerStatus(c *gin.Context) {
	id := c.Param("id")
	var seller models.Seller
	if err := config.DB.Where("id = ?", id).First(&seller).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Penjual tidak ditemukan"})
		return
	}

	var input UpdateAdminSellerStatusInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status tidak valid"})
		return
	}

	seller.Status = input.Status
	if err := config.DB.Save(&seller).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status seller"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Status seller berhasil diperbarui",
		"data":    seller,
	})
}

func GetAdminSellerStats(c *gin.Context) {
	var totalSellers int64
	var totalProducts int64
	var totalOrders int64
	var totalRevenue float64

	config.DB.Model(&models.Seller{}).Count(&totalSellers)
	config.DB.Model(&models.SellerProduct{}).Count(&totalProducts)
	config.DB.Model(&models.SellerOrder{}).Count(&totalOrders)
	config.DB.Model(&models.SellerOrder{}).Where("status != ?", "Dibatalkan").Select("COALESCE(SUM(total_amount), 0)").Scan(&totalRevenue)

	c.JSON(http.StatusOK, gin.H{
		"totalSellers":  totalSellers,
		"totalProducts": totalProducts,
		"totalOrders":   totalOrders,
		"totalRevenue":  totalRevenue,
	})
}
