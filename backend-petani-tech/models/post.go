package models

import (
	"time"

	"gorm.io/gorm"
)

type ImageModel struct {
	ID               string     `json:"id"`
	Storage          string     `json:"storage"`
	FilenameDisk     string     `json:"filename_disk"`
	FilenameDownload string     `json:"filename_download"`
	Title            string     `json:"title"`
	Type             string     `json:"type"`
	Folder           string     `json:"folder"`
	UploadedBy       string     `json:"uploaded_by"`
	CreatedOn        time.Time  `json:"created_on"`
	ModifiedOn       *time.Time `json:"modified_on,omitempty"`
	Width            int        `json:"width"`
	Height           int        `json:"height"`
	Description      *string    `json:"description,omitempty"`
}

type Post struct {
	ID            string      `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	Title         string      `gorm:"type:varchar(255);not null" json:"title"`
	Content       string      `gorm:"type:text;not null" json:"content"`
	Status        string      `gorm:"type:varchar(50);default:'published'" json:"status"`
	Sort          int         `gorm:"default:0" json:"sort"`
	ImageURL      string      `gorm:"column:image;type:text" json:"image_url"`
	DateCreated   time.Time   `gorm:"autoCreateTime" json:"date_created"`
	DateUpdated   time.Time   `gorm:"autoUpdateTime" json:"date_updated"`
	UserCreatedID *string     `gorm:"type:uuid" json:"-"`
	UserCreated   *User       `gorm:"foreignKey:UserCreatedID" json:"user_created,omitempty"`
	UserUpdatedID *string     `gorm:"type:uuid" json:"-"`
	UserUpdated   *User       `gorm:"foreignKey:UserUpdatedID" json:"user_updated,omitempty"`
	Image         *ImageModel `gorm:"-" json:"image"`
}

func (p *Post) AfterFind(tx *gorm.DB) error {
	p.BuildImageModel()
	return nil
}

func (p *Post) BuildImageModel() {
	if p.Image != nil {
		return
	}
	imgID := p.ImageURL
	if imgID == "" {
		imgID = "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80"
	}
	uploadedBy := ""
	if p.UserCreatedID != nil {
		uploadedBy = *p.UserCreatedID
	}
	p.Image = &ImageModel{
		ID:               imgID,
		Storage:          "local",
		FilenameDisk:     imgID,
		FilenameDownload: imgID,
		Title:            p.Title,
		Type:             "image/jpeg",
		Folder:           "posts",
		UploadedBy:       uploadedBy,
		CreatedOn:        p.DateCreated,
		Width:            800,
		Height:           600,
	}
}
