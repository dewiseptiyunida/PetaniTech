package models

import "time"

type User struct {
	ID           string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	FirstName    string    `json:"first_name"`
	LastName     string    `json:"last_name"`
	Email        string    `gorm:"uniqueIndex" json:"email"`
	PasswordHash string    `json:"password"`
	Role         string    `json:"role"`
	Status       string    `json:"status"`
	Avatar             string    `json:"avatar"`
	Phone              string    `json:"phone"`
	Location           string    `json:"location"`
	EmailNotifications bool      `gorm:"default:false" json:"email_notifications"`
	Token              string    `gorm:"-" json:"token,omitempty"`
	CreatedAt          time.Time `gorm:"autoCreateTime" json:"created_at"`
}
