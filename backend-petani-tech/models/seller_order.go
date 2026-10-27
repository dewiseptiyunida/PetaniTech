package models

import "time"

type SellerOrderItem struct {
	ID           uint    `gorm:"primaryKey;autoIncrement" json:"id,omitempty"`
	OrderID      string  `gorm:"type:varchar(64);index;not null" json:"orderId,omitempty"`
	ProductID    string  `gorm:"type:varchar(64)" json:"productId"`
	ProductName  string  `gorm:"type:varchar(255)" json:"productName"`
	Category     string  `gorm:"type:varchar(100)" json:"category"`
	Quantity     int     `gorm:"default:1" json:"quantity"`
	UnitPrice    float64 `gorm:"type:numeric(12,2)" json:"unitPrice"`
	Subtotal     float64 `gorm:"type:numeric(12,2)" json:"subtotal"`
	ProductImage string  `gorm:"type:text" json:"productImage"`
	Unit         string  `gorm:"type:varchar(50)" json:"unit"`
}

type SellerOrder struct {
	ID             string            `gorm:"primaryKey;type:varchar(64)" json:"id"`
	OrderNumber    string            `gorm:"type:varchar(64);uniqueIndex;not null" json:"orderNumber"`
	SellerID       string            `gorm:"type:varchar(64);index" json:"sellerId,omitempty"`
	StoreName      string            `gorm:"type:varchar(255)" json:"storeName,omitempty"`
	BuyerName      string            `gorm:"type:varchar(255);not null" json:"buyerName"`
	BuyerPhone     string            `gorm:"type:varchar(50)" json:"buyerPhone"`
	BuyerAddress   string            `gorm:"type:text" json:"buyerAddress"`
	Status         string            `gorm:"type:varchar(50);default:'Diproses'" json:"status"`
	TotalAmount    float64           `gorm:"type:numeric(12,2)" json:"totalAmount"`
	ShippingFee    float64           `gorm:"type:numeric(12,2)" json:"shippingFee"`
	Courier        string            `gorm:"type:varchar(100)" json:"courier"`
	TrackingNumber string            `gorm:"type:varchar(100)" json:"trackingNumber,omitempty"`
	PaymentMethod     string            `gorm:"type:varchar(100)" json:"paymentMethod"`
	PaymentStatus     string            `gorm:"type:varchar(50);default:'Belum Dibayar'" json:"paymentStatus,omitempty"`
	PaymentToken      string            `gorm:"type:text" json:"paymentToken,omitempty"`
	PaymentQrUrl      string            `gorm:"type:text" json:"paymentQrUrl,omitempty"`
	PaymentQrString   string            `gorm:"type:text" json:"paymentQrString,omitempty"`
	PaymentVaNumber   string            `gorm:"type:varchar(100)" json:"paymentVaNumber,omitempty"`
	PaymentBillKey    string            `gorm:"type:varchar(100)" json:"paymentBillKey,omitempty"`
	PaymentBillerCode string            `gorm:"type:varchar(100)" json:"paymentBillerCode,omitempty"`
	Note              string            `gorm:"type:text" json:"note,omitempty"`
	Items             []SellerOrderItem `gorm:"foreignKey:OrderID;references:ID" json:"items"`
	CreatedAt         string            `gorm:"type:varchar(50)" json:"createdAt"`
	DateCreated       time.Time         `gorm:"autoCreateTime" json:"dateCreated"`
}
