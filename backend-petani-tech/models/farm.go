package models

import "time"

type Farm struct {
	ID            string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID        string    `gorm:"type:uuid" json:"user_id"`
	User          User      `gorm:"foreignKey:UserID" json:"-"`
	Name          string    `json:"name"`
	AreaSize      string    `json:"area_size"`
	AreaUnit      string    `json:"area_unit"`
	SoilType      int       `json:"soil_type"`
	OwnershipType string    `json:"ownership_type"`
	Address       string    `json:"address"`
	Status        string    `json:"status"`
	DateCreated   time.Time `gorm:"autoCreateTime" json:"date_created"`
	DateUpdated   time.Time `gorm:"autoUpdateTime" json:"date_updated"`
}
