package models

import "time"

type Community struct {
	ID          string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Image       string    `json:"image"`
	Visibility  string    `json:"visibility"`
	Status      string    `json:"status"`
	DateCreated time.Time `gorm:"autoCreateTime" json:"date_created"`
}
