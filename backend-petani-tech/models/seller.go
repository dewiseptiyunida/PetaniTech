package models

import "time"

type BankAccount struct {
	BankName      string `json:"bankName"`
	AccountNumber string `json:"accountNumber"`
	AccountHolder string `json:"accountHolder"`
}

type Seller struct {
	ID                string    `gorm:"primaryKey;type:varchar(64)" json:"id"`
	UserID            string    `gorm:"type:varchar(64)" json:"userId,omitempty"`
	Name              string    `gorm:"type:varchar(255);not null" json:"name"`
	Email             string    `gorm:"type:varchar(255);uniqueIndex;not null" json:"email"`
	Phone             string    `gorm:"type:varchar(50)" json:"phone"`
	PasswordHash      string    `gorm:"type:varchar(255)" json:"-"`
	Role              string    `gorm:"type:varchar(50);default:'seller'" json:"role"`
	StoreName         string    `gorm:"type:varchar(255);not null" json:"storeName"`
	StoreID           string    `gorm:"type:varchar(100);uniqueIndex" json:"storeId"`
	Status            string    `gorm:"type:varchar(50);default:'Seller Terverifikasi'" json:"status"`
	Avatar            string    `gorm:"type:text" json:"avatar"`
	StoreAddress      string    `gorm:"type:text" json:"storeAddress"`
	JoinedDate        string    `gorm:"type:varchar(100)" json:"joinedDate"`
	Rating            float64   `gorm:"default:5.0" json:"rating"`
	TotalReview       int       `gorm:"default:0" json:"totalReview"`
	Balance           float64   `gorm:"type:numeric(14,2);default:0" json:"balance"`
	BankName          string    `gorm:"type:varchar(100)" json:"-"`
	BankAccountNo     string    `gorm:"type:varchar(100)" json:"-"`
	BankAccountHolder string    `gorm:"type:varchar(100)" json:"-"`
	CreatedAt         time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt         time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}

type UserProfileResponse struct {
	ID           string      `json:"id"`
	Name         string      `json:"name"`
	Email        string      `json:"email"`
	Phone        string      `json:"phone"`
	Role         string      `json:"role"`
	StoreName    string      `json:"storeName"`
	StoreID      string      `json:"storeId"`
	Status       string      `json:"status"`
	Avatar       string      `json:"avatar"`
	StoreAddress string      `json:"storeAddress"`
	JoinedDate   string      `json:"joinedDate"`
	Rating       float64     `json:"rating"`
	TotalReview  int         `json:"totalReview"`
	Balance      float64     `json:"balance"`
	BankAccount  BankAccount `json:"bankAccount"`
}

func (s *Seller) ToUserProfile() UserProfileResponse {
	return UserProfileResponse{
		ID:           s.ID,
		Name:         s.Name,
		Email:        s.Email,
		Phone:        s.Phone,
		Role:         s.Role,
		StoreName:    s.StoreName,
		StoreID:      s.StoreID,
		Status:       s.Status,
		Avatar:       s.Avatar,
		StoreAddress: s.StoreAddress,
		JoinedDate:   s.JoinedDate,
		Rating:       s.Rating,
		TotalReview:  s.TotalReview,
		Balance:      s.Balance,
		BankAccount: BankAccount{
			BankName:      s.BankName,
			AccountNumber: s.BankAccountNo,
			AccountHolder: s.BankAccountHolder,
		},
	}
}
