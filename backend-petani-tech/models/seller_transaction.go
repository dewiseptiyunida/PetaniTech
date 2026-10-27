package models

import "time"

type SellerTransaction struct {
	ID          string    `gorm:"primaryKey;type:varchar(64)" json:"id"`
	SellerID    string    `gorm:"type:varchar(64);index" json:"sellerId,omitempty"`
	ReferenceNo string    `gorm:"type:varchar(100);not null" json:"referenceNo"`
	Date        string    `gorm:"type:varchar(50);not null" json:"date"`
	Type        string    `gorm:"type:varchar(50);not null" json:"type"`
	Amount      float64   `gorm:"type:numeric(14,2);not null" json:"amount"`
	Status      string    `gorm:"type:varchar(50);default:'Berhasil'" json:"status"`
	Description string    `gorm:"type:text" json:"description"`
	DateCreated time.Time `gorm:"autoCreateTime" json:"dateCreated"`
}
