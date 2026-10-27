package config

import (
	"fmt"
	"log"
	"time"

	"backend-petani-tech/models"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func SeedDatabase(db *gorm.DB) {
	seedSellers(db)
	seedSellerProducts(db)
	seedSellerOrders(db)
	seedSellerTransactions(db)
}

func seedSellers(db *gorm.DB) {
	var count int64
	db.Model(&models.Seller{}).Count(&count)
	if count > 0 {
		return
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("123456"), bcrypt.DefaultCost)

	sellers := []models.Seller{
		{
			ID:                "usr-seller-fahda",
			Name:              "Fahda Febriya",
			Email:             "fahda@petanitech.id",
			Phone:             "0812-3456-7890",
			PasswordHash:      string(hashedPassword),
			Role:              "seller",
			StoreName:         "Toko Tani Makmur Fahda",
			StoreID:           "ID-AGRO-INDRAMAYU-01",
			Status:            "Seller Terverifikasi",
			Avatar:            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80",
			StoreAddress:      "Jl. Raya Indramayu - Cirebon No. 88, Kec. Jatibarang, Kab. Indramayu, Jawa Barat 45214",
			JoinedDate:        "Januari 2025",
			Rating:            4.95,
			TotalReview:       1280,
			Balance:           12850000,
			BankName:          "Bank Rakyat Indonesia (BRI)",
			BankAccountNo:     "4321-01-098765-53-2",
			BankAccountHolder: "FAHDA FEBRIYA",
		},
		{
			ID:                "usr-seller-budi",
			Name:              "Pak Budi Santoso",
			Email:             "budi@petanitech.id",
			Phone:             "0813-8899-7722",
			PasswordHash:      string(hashedPassword),
			Role:              "seller",
			StoreName:         "Agro Subur Mandiri",
			StoreID:           "ID-AGRO-SUBANG-02",
			Status:            "Seller Aktif",
			Avatar:            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80",
			StoreAddress:      "Jl. Raya Subang No. 120, Pagaden, Kab. Subang, Jawa Barat",
			JoinedDate:        "Maret 2025",
			Rating:            4.8,
			TotalReview:       450,
			Balance:           5400000,
			BankName:          "Bank Mandiri",
			BankAccountNo:     "132-00-9876543-1",
			BankAccountHolder: "BUDI SANTOSO",
		},
	}

	for _, s := range sellers {
		if err := db.Create(&s).Error; err != nil {
			log.Printf("Error seeding seller %s: %v", s.Name, err)
		}
	}
	fmt.Println("Seeded sellers successfully")
}

func seedSellerProducts(db *gorm.DB) {
	var count int64
	db.Model(&models.SellerProduct{}).Count(&count)
	if count > 0 {
		return
	}

	defaultSeller := "Fahda Febriya"
	defaultStore := "Toko Tani Makmur Fahda"
	defaultContact := "0812-3456-7890"
	defaultLocation := "Indramayu, Jawa Barat"

	dummyProducts := []models.SellerProduct{
		{
			ID:            "prod-001",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Bionava",
			Category:      "Pupuk",
			Subcategory:   "Pupuk Organik",
			Price:         85000,
			OriginalPrice: 95000,
			Stock:         140,
			MinStockAlert: 20,
			Status:        "Aktif",
			Image:         "asset:bionava",
			Description:   "Bionava adalah pupuk hayati dan biostimulan premium berbasis mikroba menguntungkan untuk meningkatkan kesuburan tanah, penyerapan hara, dan ketahanan tanaman terhadap cekaman lingkungan.",
			Unit:          "Botol (1 Liter)",
			SKU:           "AGR-BIO-001",
			SoldCount:     520,
			Rating:        4.9,
			DateCreated:   time.Now().Add(-60 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-60 * 24 * time.Hour),
		},
		{
			ID:            "prod-002",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Cangkul",
			Category:      "Alat Pertanian",
			Subcategory:   "Peralatan Pertanian",
			Price:         95000,
			OriginalPrice: 110000,
			Stock:         35,
			MinStockAlert: 10,
			Status:        "Aktif",
			Image:         "asset:cangkul",
			Description:   "Cangkul baja tempa berkualitas tinggi dengan mata tajam tahan aus dan sudut ergonomis untuk mempermudah penggemburan dan pembajakan tanah sawah maupun kebun.",
			Unit:          "Pcs",
			SKU:           "AGR-CGK-002",
			SoldCount:     210,
			Rating:        4.8,
			DateCreated:   time.Now().Add(-55 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-55 * 24 * time.Hour),
		},
		{
			ID:            "prod-003",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Cangkul 2",
			Category:      "Alat Pertanian",
			Subcategory:   "Peralatan Pertanian",
			Price:         125000,
			OriginalPrice: 145000,
			Stock:         8,
			MinStockAlert: 15,
			Status:        "Stok Menipis",
			Image:         "asset:cangkul2",
			Description:   "Cangkul baja super tebal edisi heavy duty dengan gagang kayu jati kokoh anti-patah, dirancang khusus untuk lahan tanah keras, berbatu, dan perkebunan intensif.",
			Unit:          "Pcs",
			SKU:           "AGR-CGK-003",
			SoldCount:     165,
			Rating:        4.9,
			DateCreated:   time.Now().Add(-40 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-40 * 24 * time.Hour),
		},
		{
			ID:            "prod-004",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Grao Verde",
			Category:      "Pupuk",
			Subcategory:   "Pupuk Organik",
			Price:         110000,
			OriginalPrice: 130000,
			Stock:         65,
			MinStockAlert: 15,
			Status:        "Aktif",
			Image:         "asset:graoVerde",
			Description:   "Formula nutrisi hijau daun Grao Verde dengan konsentrasi nitrogen organik dan unsur mikro lengkap untuk mempercepat pertumbuhan vegetatif, kehijauan daun, dan fotosintesis optimal.",
			Unit:          "Botol (1 Liter)",
			SKU:           "AGR-GRV-004",
			SoldCount:     380,
			Rating:        4.8,
			DateCreated:   time.Now().Add(-35 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-35 * 24 * time.Hour),
		},
		{
			ID:            "prod-005",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Pintinhos",
			Category:      "Pupuk",
			Subcategory:   "Kompos",
			Price:         78000,
			OriginalPrice: 90000,
			Stock:         0,
			MinStockAlert: 10,
			Status:        "Habis",
			Image:         "asset:pintinhos",
			Description:   "Suplemen multivitamin dan probiotik unggas Pintinhos untuk galinhas, frangos de corte, dan ayam petelur granja guna menunjang produktivitas dan imunitas optimal.",
			Unit:          "Botol (1 Liter)",
			SKU:           "AGR-PIN-005",
			SoldCount:     430,
			Rating:        4.7,
			DateCreated:   time.Now().Add(-70 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-70 * 24 * time.Hour),
		},
		{
			ID:            "prod-006",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Prosil",
			Category:      "Pestisida",
			Subcategory:   "Fungisida",
			Price:         135000,
			OriginalPrice: 150000,
			Stock:         52,
			MinStockAlert: 15,
			Status:        "Aktif",
			Image:         "asset:prosil",
			Description:   "Proteksi tanaman Prosil dengan silika aktif dan pelindung sel tanaman untuk memperkuat dinding sel daun, mencegah infeksi jamur, serta melindungi dari serangan hama pengisap.",
			Unit:          "Botol (500ml)",
			SKU:           "AGR-PRS-006",
			SoldCount:     290,
			Rating:        4.9,
			DateCreated:   time.Now().Add(-25 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-25 * 24 * time.Hour),
		},
		{
			ID:            "prod-007",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Pupuk NPK",
			Category:      "Pupuk",
			Subcategory:   "NPK",
			Price:         450000,
			OriginalPrice: 480000,
			Stock:         28,
			MinStockAlert: 10,
			Status:        "Aktif",
			Image:         "asset:pupukNpk",
			Description:   "Pupuk NPK majemuk berimbang untuk menutrisi tanaman di seluruh fase vegetatif dan generatif. Memperkuat perakaran, memperkokoh batang, dan memaksimalkan bobot buah.",
			Unit:          "Sak (50kg)",
			SKU:           "AGR-NPK-007",
			SoldCount:     640,
			Rating:        5.0,
			DateCreated:   time.Now().Add(-80 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-80 * 24 * time.Hour),
		},
		{
			ID:            "prod-008",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Skop",
			Category:      "Alat Pertanian",
			Subcategory:   "Peralatan Pertanian",
			Price:         75000,
			OriginalPrice: 85000,
			Stock:         0,
			MinStockAlert: 10,
			Status:        "Habis",
			Image:         "asset:skop",
			Description:   "Skop serbaguna baja tahan karat dengan konstruksi kuat dan ringan, sangat praktis untuk memindahkan media tanam, pasir, tanah humus, dan pupuk kompos.",
			Unit:          "Pcs",
			SKU:           "AGR-SKP-008",
			SoldCount:     175,
			Rating:        4.6,
			DateCreated:   time.Now().Add(-65 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-65 * 24 * time.Hour),
		},
		{
			ID:            "prod-009",
			SellerName:    defaultSeller,
			StoreName:     defaultStore,
			SellerContact: defaultContact,
			Location:      defaultLocation,
			Name:          "Sprayer",
			Category:      "Alat Pertanian",
			Subcategory:   "Sprayer",
			Price:         320000,
			OriginalPrice: 360000,
			Stock:         14,
			MinStockAlert: 20,
			Status:        "Stok Menipis",
			Image:         "asset:sprayer",
			Description:   "Tangki semprot sprayer pertanian bertekanan stabil dengan nozzle ganda kuningan, ideal untuk penyemprotan insektisida, fungisida, herbisida, dan pupuk daun secara merata.",
			Unit:          "Unit (16 Liter)",
			SKU:           "AGR-SPR-009",
			SoldCount:     310,
			Rating:        4.8,
			DateCreated:   time.Now().Add(-30 * 24 * time.Hour),
			DateUpdated:   time.Now().Add(-30 * 24 * time.Hour),
		},
	}

	for _, item := range dummyProducts {
		if err := db.Create(&item).Error; err != nil {
			log.Printf("Error seeding seller product %s: %v", item.Name, err)
		}
	}
	fmt.Println("Seeded seller products successfully")
}

func seedSellerOrders(db *gorm.DB) {
	var count int64
	db.Model(&models.SellerOrder{}).Count(&count)
	if count > 0 {
		return
	}

	orders := []models.SellerOrder{
		{
			ID:             "PT20261001",
			OrderNumber:    "#PT20261001",
			SellerID:       "usr-seller-fahda",
			StoreName:      "Toko Tani Makmur Fahda",
			BuyerName:      "Toko Tani Makmur",
			BuyerPhone:     "0812-3456-7890",
			BuyerAddress:   "Jl. Raya Pertanian No. 45, Pagaden, Subang, Jawa Barat 41252",
			Status:         "Diproses",
			TotalAmount:    900000,
			ShippingFee:    35000,
			Courier:        "AgroCargo Express (Kargo Cepat)",
			TrackingNumber: "AGC-SBG-99210",
			PaymentMethod:  "Saldo Petani Tech / Transfer Bank",
			Note:           "Mohon dilapisi plastik ekstra anti hujan saat pengiriman.",
			CreatedAt:      "2026-10-07 14:20",
			Items: []models.SellerOrderItem{
				{
					OrderID:      "PT20261001",
					ProductID:    "prod-007",
					ProductName:  "Pupuk NPK",
					Category:     "Pupuk",
					Quantity:     2,
					UnitPrice:    450000,
					Subtotal:     900000,
					ProductImage: "asset:pupukNpk",
					Unit:         "Sak (50kg)",
				},
			},
		},
		{
			ID:             "PT20261002",
			OrderNumber:    "#PT20261002",
			SellerID:       "usr-seller-fahda",
			StoreName:      "Toko Tani Makmur Fahda",
			BuyerName:      "Kelompok Tani Subur Makmur",
			BuyerPhone:     "0857-1122-3344",
			BuyerAddress:   "Desa Sukamandi Jaya RT 03/02, Ciasem, Subang",
			Status:         "Diproses",
			TotalAmount:    560000,
			ShippingFee:    40000,
			Courier:        "J&T Cargo Pertanian",
			TrackingNumber: "JT-PTN-88421",
			PaymentMethod:  "BCA Virtual Account",
			Note:           "Kirim sore ini jika memungkinkan Pak Fahda.",
			CreatedAt:      "2026-10-07 11:45",
			Items: []models.SellerOrderItem{
				{
					OrderID:      "PT20261002",
					ProductID:    "prod-001",
					ProductName:  "Bionava",
					Category:     "Pupuk",
					Quantity:     4,
					UnitPrice:    85000,
					Subtotal:     340000,
					ProductImage: "asset:bionava",
					Unit:         "Botol (1 Liter)",
				},
				{
					OrderID:      "PT20261002",
					ProductID:    "prod-004",
					ProductName:  "Grao Verde",
					Category:     "Pupuk",
					Quantity:     2,
					UnitPrice:    110000,
					Subtotal:     220000,
					ProductImage: "asset:graoVerde",
					Unit:         "Botol (1 Liter)",
				},
			},
		},
		{
			ID:            "PT20261003",
			OrderNumber:   "#PT20261003",
			SellerID:      "usr-seller-fahda",
			StoreName:     "Toko Tani Makmur Fahda",
			BuyerName:     "Haji Mansyur Agro",
			BuyerPhone:    "0819-7766-5544",
			BuyerAddress:  "Kecamatan Compreng, Kab. Subang, Jawa Barat",
			Status:        "Menunggu Pembayaran",
			TotalAmount:   320000,
			ShippingFee:   20000,
			Courier:       "SiCepat Agro",
			PaymentMethod: "Mandiri Livin Virtual Account",
			CreatedAt:     "2026-10-07 17:10",
			Items: []models.SellerOrderItem{
				{
					OrderID:      "PT20261003",
					ProductID:    "prod-009",
					ProductName:  "Sprayer",
					Category:     "Alat Pertanian",
					Quantity:     1,
					UnitPrice:    320000,
					Subtotal:     320000,
					ProductImage: "asset:sprayer",
					Unit:         "Unit (16 Liter)",
				},
			},
		},
		{
			ID:             "PT20261004",
			OrderNumber:    "#PT20261004",
			SellerID:       "usr-seller-fahda",
			StoreName:      "Toko Tani Makmur Fahda",
			BuyerName:      "CV Berkah Tani Mandiri",
			BuyerPhone:     "0821-9988-7711",
			BuyerAddress:   "Jl. Ahmad Yani No. 12, Indramayu, Jawa Barat",
			Status:         "Dikirim",
			TotalAmount:    675000,
			ShippingFee:    45000,
			Courier:        "AgroCargo Express",
			TrackingNumber: "AGC-IDM-44512",
			PaymentMethod:  "BRI Virtual Account",
			Note:           "Pastikan segel botol rapat.",
			CreatedAt:      "2026-10-06 09:30",
			Items: []models.SellerOrderItem{
				{
					OrderID:      "PT20261004",
					ProductID:    "prod-006",
					ProductName:  "Prosil",
					Category:     "Pestisida",
					Quantity:     5,
					UnitPrice:    135000,
					Subtotal:     675000,
					ProductImage: "asset:prosil",
					Unit:         "Botol (500ml)",
				},
			},
		},
		{
			ID:             "PT20261005",
			OrderNumber:    "#PT20261005",
			SellerID:       "usr-seller-fahda",
			StoreName:      "Toko Tani Makmur Fahda",
			BuyerName:      "Tani Jaya Karawang",
			BuyerPhone:     "0813-4455-6677",
			BuyerAddress:   "Kec. Telagasari, Karawang Timur, Jawa Barat",
			Status:         "Selesai",
			TotalAmount:    380000,
			ShippingFee:    35000,
			Courier:        "JNE Trucking (JTR)",
			TrackingNumber: "JTR-KRW-11029",
			PaymentMethod:  "QRIS Petani Tech",
			CreatedAt:      "2026-10-04 13:15",
			Items: []models.SellerOrderItem{
				{
					OrderID:      "PT20261005",
					ProductID:    "prod-002",
					ProductName:  "Cangkul",
					Category:     "Alat Pertanian",
					Quantity:     4,
					UnitPrice:    95000,
					Subtotal:     380000,
					ProductImage: "asset:cangkul",
					Unit:         "Pcs",
				},
			},
		},
		{
			ID:            "PT20261006",
			OrderNumber:   "#PT20261006",
			SellerID:      "usr-seller-fahda",
			StoreName:     "Toko Tani Makmur Fahda",
			BuyerName:     "Agro Sentosa Cibitung",
			BuyerPhone:    "0878-5544-3322",
			BuyerAddress:  "Cibitung, Bekasi, Jawa Barat",
			Status:        "Dibatalkan",
			TotalAmount:   250000,
			ShippingFee:   25000,
			Courier:       "SiCepat Agro",
			PaymentMethod: "Transfer Bank",
			Note:          "Dibatalkan oleh pembeli: salah memilih alamat pengiriman.",
			CreatedAt:     "2026-10-03 16:40",
			Items: []models.SellerOrderItem{
				{
					OrderID:      "PT20261006",
					ProductID:    "prod-003",
					ProductName:  "Cangkul 2",
					Category:     "Alat Pertanian",
					Quantity:     2,
					UnitPrice:    125000,
					Subtotal:     250000,
					ProductImage: "asset:cangkul2",
					Unit:         "Pcs",
				},
			},
		},
	}

	for _, o := range orders {
		if err := db.Create(&o).Error; err != nil {
			log.Printf("Error seeding seller order %s: %v", o.OrderNumber, err)
		}
	}
	fmt.Println("Seeded seller orders successfully")
}

func seedSellerTransactions(db *gorm.DB) {
	var count int64
	db.Model(&models.SellerTransaction{}).Count(&count)
	if count > 0 {
		return
	}

	txs := []models.SellerTransaction{
		{
			ID:          "TX-20261007-01",
			SellerID:    "usr-seller-fahda",
			ReferenceNo: "WD-882190",
			Date:        "07 Okt 2026, 15:30",
			Type:        "Pencairan",
			Amount:      -2500000,
			Status:      "Berhasil",
			Description: "Penarikan saldo ke Rekening BRI 0123-***-50-8",
		},
		{
			ID:          "TX-20261006-02",
			SellerID:    "usr-seller-fahda",
			ReferenceNo: "ORD-#PT20261005",
			Date:        "06 Okt 2026, 17:45",
			Type:        "Penjualan",
			Amount:      750000,
			Status:      "Berhasil",
			Description: "Pencairan pesanan selesai #PT20261005 - Tani Jaya Karawang",
		},
		{
			ID:          "TX-20261006-01",
			SellerID:    "usr-seller-fahda",
			ReferenceNo: "FEE-449102",
			Date:        "06 Okt 2026, 17:45",
			Type:        "Biaya Layanan",
			Amount:      -15000,
			Status:      "Berhasil",
			Description: "Biaya layanan transaksi 2% pesanan #PT20261005",
		},
		{
			ID:          "TX-20261005-01",
			SellerID:    "usr-seller-fahda",
			ReferenceNo: "ORD-#PT20261000",
			Date:        "05 Okt 2026, 11:20",
			Type:        "Penjualan",
			Amount:      2600000,
			Status:      "Berhasil",
			Description: "Pencairan pesanan selesai #PT20261000 - Gapoktan Maju Bersama",
		},
		{
			ID:          "TX-20261004-02",
			SellerID:    "usr-seller-fahda",
			ReferenceNo: "WD-881900",
			Date:        "04 Okt 2026, 09:15",
			Type:        "Pencairan",
			Amount:      -5000000,
			Status:      "Berhasil",
			Description: "Penarikan saldo ke Rekening BRI 0123-***-50-8",
		},
		{
			ID:          "TX-20261003-01",
			SellerID:    "usr-seller-fahda",
			ReferenceNo: "PRM-991204",
			Date:        "03 Okt 2026, 14:00",
			Type:        "Cashback Promo",
			Amount:      100000,
			Status:      "Berhasil",
			Description: "Bonus Insentif Seller Aktif Kampanye Musim Tanam Oktober",
		},
	}

	for _, tx := range txs {
		if err := db.Create(&tx).Error; err != nil {
			log.Printf("Error seeding seller transaction %s: %v", tx.ReferenceNo, err)
		}
	}
	fmt.Println("Seeded seller transactions successfully")
}
