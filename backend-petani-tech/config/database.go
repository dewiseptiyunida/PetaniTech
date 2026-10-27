package config

import (
	"fmt"
	"log"
	"os"

	"backend-petani-tech/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database!", err)
	}

	err = database.AutoMigrate(
		&models.User{},
		&models.Farm{},
		&models.Post{},
		&models.Community{},
		&models.DiseasePrediction{},
		&models.SellerProduct{},
		&models.Seller{},
		&models.SellerOrder{},
		&models.SellerOrderItem{},
		&models.SellerTransaction{},
	)
	if err != nil {
		log.Fatal("Failed to migrate database!", err)
	}

	DB = database
	SeedDatabase(database)
	fmt.Println("Database connection successfully opened and migrated")
}
