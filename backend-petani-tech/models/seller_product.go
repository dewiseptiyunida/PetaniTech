package models

import "time"

type SellerProduct struct {
	ID            string    `gorm:"primaryKey;type:varchar(64)" json:"id"`
	SellerName    string    `gorm:"type:varchar(255)" json:"seller_name"`
	StoreName     string    `gorm:"type:varchar(255)" json:"store_name"`
	SellerContact string    `gorm:"type:varchar(50)" json:"seller_contact"`
	Location      string    `gorm:"type:varchar(255)" json:"location"`
	Name          string    `gorm:"type:varchar(255);not null" json:"name"`
	Category      string    `gorm:"type:varchar(100)" json:"category"`
	Subcategory   string    `gorm:"type:varchar(100)" json:"subcategory"`
	Price         float64   `gorm:"type:numeric(12,2)" json:"price"`
	OriginalPrice float64   `gorm:"type:numeric(12,2)" json:"original_price"`
	Stock         int       `gorm:"default:0" json:"stock"`
	MinStockAlert int       `gorm:"default:10" json:"min_stock_alert"`
	Unit          string    `gorm:"type:varchar(50);default:'Pcs'" json:"unit"`
	Status        string    `gorm:"type:varchar(50);default:'Aktif'" json:"status"`
	Image         string    `gorm:"type:text" json:"image"`
	Description   string    `gorm:"type:text" json:"description"`
	SKU           string    `gorm:"type:varchar(100)" json:"sku"`
	SoldCount     int       `gorm:"default:0" json:"sold_count"`
	Rating        float64   `gorm:"default:5.0" json:"rating"`
	DateCreated   time.Time `gorm:"autoCreateTime" json:"date_created"`
	DateUpdated   time.Time `gorm:"autoUpdateTime" json:"date_updated"`
}
