package routes

import (
	"backend-petani-tech/controllers"
	"backend-petani-tech/middleware"
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(router *gin.Engine) {
	// Public Assets Routes (Diakses Flutter via ApiClient.getAsset)
	router.GET("/assets/*filepath", controllers.GetAsset)

	// Public Directus items compatibility alias di root level
	router.GET("/items/posts", controllers.GetPosts)
	router.GET("/items/posts/", controllers.GetPosts)
	router.GET("/items/posts/:id", controllers.GetPostByID)

	router.GET("/items/farms", controllers.GetFarms)
	router.GET("/items/farms/", controllers.GetFarms)
	router.GET("/items/farms/:id", controllers.GetFarmByID)
	router.POST("/items/farms", controllers.CreateFarm)
	router.POST("/items/farms/", controllers.CreateFarm)
	router.PUT("/items/farms/:id", controllers.UpdateFarm)
	router.DELETE("/items/farms/:id", controllers.DeleteFarm)

	v1 := router.Group("/api/v1")
	{
		auth := v1.Group("/auth")
		{
			auth.POST("/register", controllers.Register)
			auth.POST("/login", controllers.Login)

			// Seller Center Auth Routes
			auth.GET("/seller/me", controllers.GetSellerMe)
			auth.GET("/seller/me/", controllers.GetSellerMe)
			auth.POST("/seller/login", controllers.SellerLogin)
			auth.POST("/seller/login/", controllers.SellerLogin)
			auth.POST("/seller/register", controllers.SellerRegister)
			auth.POST("/seller/register/", controllers.SellerRegister)
			auth.PATCH("/seller/profile", controllers.UpdateSellerProfile)
			auth.PUT("/seller/profile", controllers.UpdateSellerProfile)
		}

		// Public Stats Endpoint (Real-time count dari database untuk Admin Panel)
		v1.GET("/stats", controllers.GetStats)
		v1.GET("/stats/", controllers.GetStats)

		// Public Asset Route di bawah /api/v1
		v1.GET("/assets/*filepath", controllers.GetAsset)
		v1.POST("/upload", controllers.UploadFile)

		// Public Users Routes (Akses daftar pengguna untuk Admin Panel)
		v1.GET("/users", controllers.GetUsers)
		v1.GET("/users/", controllers.GetUsers)

		// Public Posts Routes (Bisa diakses mobile Flutter & Admin Panel)
		postsPublic := v1.Group("/posts")
		{
			postsPublic.GET("", controllers.GetPosts)
			postsPublic.GET("/", controllers.GetPosts)
			postsPublic.GET("/:id", controllers.GetPostByID)
			postsPublic.POST("", controllers.CreatePost)
			postsPublic.POST("/", controllers.CreatePost)
			postsPublic.PUT("/:id", controllers.UpdatePost)
			postsPublic.DELETE("/:id", controllers.DeletePost)
		}

		// Public Farms Routes (Bisa diakses mobile Flutter & Admin Panel)
		farmsPublic := v1.Group("/farms")
		{
			farmsPublic.GET("", controllers.GetFarms)
			farmsPublic.GET("/", controllers.GetFarms)
			farmsPublic.GET("/:id", controllers.GetFarmByID)
			farmsPublic.POST("", controllers.CreateFarm)
			farmsPublic.POST("/", controllers.CreateFarm)
			farmsPublic.PUT("/:id", controllers.UpdateFarm)
			farmsPublic.DELETE("/:id", controllers.DeleteFarm)
		}

		// Public Seller Products Routes (Untuk Petani-Tech Seller Center & Admin Panel)
		sellerProducts := v1.Group("/seller/products")
		{
			sellerProducts.GET("", controllers.GetSellerProducts)
			sellerProducts.GET("/", controllers.GetSellerProducts)
			sellerProducts.GET("/:id", controllers.GetSellerProductByID)
			sellerProducts.POST("", controllers.CreateSellerProduct)
			sellerProducts.POST("/", controllers.CreateSellerProduct)
			sellerProducts.PUT("/:id", controllers.UpdateSellerProduct)
			sellerProducts.DELETE("/:id", controllers.DeleteSellerProduct)
		}

		// Direct Alias /api/v1/products
		productsPublic := v1.Group("/products")
		{
			productsPublic.GET("", controllers.GetSellerProducts)
			productsPublic.GET("/", controllers.GetSellerProducts)
			productsPublic.GET("/:id", controllers.GetSellerProductByID)
			productsPublic.POST("", controllers.CreateSellerProduct)
			productsPublic.POST("/", controllers.CreateSellerProduct)
			productsPublic.PUT("/:id", controllers.UpdateSellerProduct)
			productsPublic.DELETE("/:id", controllers.DeleteSellerProduct)
		}

		// Seller Center Orders Routes
		sellerOrders := v1.Group("/seller/orders")
		{
			sellerOrders.GET("", controllers.GetSellerOrders)
			sellerOrders.GET("/", controllers.GetSellerOrders)
			sellerOrders.GET("/:id", controllers.GetSellerOrderByID)
			sellerOrders.POST("", controllers.CreateOrder)
			sellerOrders.POST("/", controllers.CreateOrder)
			sellerOrders.PUT("/:id", controllers.UpdateSellerOrderStatus)
			sellerOrders.PATCH("/:id", controllers.UpdateSellerOrderStatus)
			sellerOrders.PUT("/:id/status", controllers.UpdateSellerOrderStatus)
			sellerOrders.PUT("/:id/cancel", controllers.CancelOrder)
		}

		// Direct Alias /api/v1/orders (digunakan mobile Flutter & Client)
		ordersPublic := v1.Group("/orders")
		{
			ordersPublic.GET("", controllers.GetSellerOrders)
			ordersPublic.GET("/", controllers.GetSellerOrders)
			ordersPublic.GET("/:id", controllers.GetSellerOrderByID)
			ordersPublic.POST("", controllers.CreateOrder)
			ordersPublic.POST("/", controllers.CreateOrder)
			ordersPublic.PUT("/:id", controllers.UpdateSellerOrderStatus)
			ordersPublic.PATCH("/:id", controllers.UpdateSellerOrderStatus)
			ordersPublic.PUT("/:id/status", controllers.UpdateSellerOrderStatus)
			ordersPublic.PUT("/:id/cancel", controllers.CancelOrder)
		}

		// Payment Routes (Midtrans Core API & Sync)
		payments := v1.Group("/payments/midtrans")
		{
			payments.POST("/charge", controllers.ChargeMidtrans)
			payments.GET("/status/:orderId", controllers.CheckMidtransStatus)
			payments.POST("/notification", controllers.MidtransNotification)
		}

		// Seller Center Finance Routes
		sellerFinance := v1.Group("/seller/finance")
		{
			sellerFinance.GET("/summary", controllers.GetSellerFinanceSummary)
			sellerFinance.GET("/transactions", controllers.GetSellerTransactions)
			sellerFinance.POST("/withdraw", controllers.WithdrawSellerBalance)
		}

		// Seller Center Analytics Routes
		v1.GET("/seller/analytics", controllers.GetSellerAnalytics)

		// Admin Panel Management for Seller Center
		adminGroup := v1.Group("/admin")
		{
			adminGroup.GET("/sellers", controllers.GetAdminSellers)
			adminGroup.GET("/sellers/", controllers.GetAdminSellers)
			adminGroup.PUT("/sellers/:id/status", controllers.UpdateAdminSellerStatus)
			adminGroup.GET("/seller-orders", controllers.GetSellerOrders)
			adminGroup.GET("/seller-stats", controllers.GetAdminSellerStats)
		}
		// Direct Alias untuk kemudahan akses
		v1.GET("/seller/stores", controllers.GetAdminSellers)

		// Public alias untuk Flutter ($appUrl/items/posts, commodities, communities, farms)
		itemsPublic := v1.Group("/items")
		{
			itemsPublic.GET("/posts", controllers.GetPosts)
			itemsPublic.GET("/posts/", controllers.GetPosts)
			itemsPublic.GET("/posts/:id", controllers.GetPostByID)

			itemsPublic.GET("/farms", controllers.GetFarms)
			itemsPublic.GET("/farms/", controllers.GetFarms)
			itemsPublic.GET("/farms/:id", controllers.GetFarmByID)
			itemsPublic.POST("/farms", controllers.CreateFarm)
			itemsPublic.POST("/farms/", controllers.CreateFarm)
			itemsPublic.PUT("/farms/:id", controllers.UpdateFarm)
			itemsPublic.DELETE("/farms/:id", controllers.DeleteFarm)

			itemsPublic.GET("/communities", controllers.GetCommunities)
			itemsPublic.GET("/communities/", controllers.GetCommunities)
			itemsPublic.GET("/communities/:id", controllers.GetCommunityByID)

			itemsPublic.GET("/commodities", func(c *gin.Context) {
				c.JSON(200, gin.H{
					"data": []gin.H{
						{"id": "1", "name": "Padi", "status": "published"},
						{"id": "2", "name": "Jagung", "status": "published"},
						{"id": "3", "name": "Cabai", "status": "published"},
						{"id": "4", "name": "Bawang", "status": "published"},
					},
				})
			})
			itemsPublic.GET("/commodities/", func(c *gin.Context) {
				c.JSON(200, gin.H{
					"data": []gin.H{
						{"id": "1", "name": "Padi", "status": "published"},
						{"id": "2", "name": "Jagung", "status": "published"},
						{"id": "3", "name": "Cabai", "status": "published"},
						{"id": "4", "name": "Bawang", "status": "published"},
					},
				})
			})
		}

		// Public Communities Routes
		communitiesPublic := v1.Group("/communities")
		{
			communitiesPublic.GET("", controllers.GetCommunities)
			communitiesPublic.GET("/", controllers.GetCommunities)
			communitiesPublic.GET("/:id", controllers.GetCommunityByID)
		}

		// Protected Routes (Memerlukan token login Admin/User)
		protected := v1.Group("/")
		protected.Use(middleware.AuthMiddleware())
		{
			users := protected.Group("/users")
			{
				users.GET("/profile", controllers.GetProfile)
				users.GET("/me", controllers.GetProfile)
				users.PUT("/profile", controllers.UpdateProfile)
				users.PUT("/me", controllers.UpdateProfile)
				users.PATCH("/profile", controllers.UpdateProfile)
				users.PATCH("/me", controllers.UpdateProfile)
				users.POST("/avatar", controllers.UploadAvatar)
				users.POST("/upload", controllers.UploadAvatar)
			}

			communitiesProtected := protected.Group("/communities")
			{
				communitiesProtected.POST("", controllers.CreateCommunity)
				communitiesProtected.POST("/", controllers.CreateCommunity)
				communitiesProtected.PUT("/:id", controllers.UpdateCommunity)
				communitiesProtected.DELETE("/:id", controllers.DeleteCommunity)
			}

			predictions := protected.Group("/predictions")
			{
				predictions.POST("", controllers.CreatePrediction)
				predictions.POST("/", controllers.CreatePrediction)
				predictions.GET("", controllers.GetPredictions)
				predictions.GET("/", controllers.GetPredictions)
				predictions.GET("/:id", controllers.GetPredictionByID)
				predictions.PUT("/:id", controllers.UpdatePrediction)
				predictions.DELETE("/:id", controllers.DeletePrediction)
			}
		}
	}
}
