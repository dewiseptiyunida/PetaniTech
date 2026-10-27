package models

import "time"

type DiseasePrediction struct {
	ID               string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID           string    `gorm:"type:uuid" json:"user_id"`
	User             User      `gorm:"foreignKey:UserID" json:"-"`
	ImageURL         string    `json:"image_url"`
	PredictionResult string    `json:"prediction_result"`
	CreatedAt        time.Time `gorm:"autoCreateTime" json:"created_at"`
}
