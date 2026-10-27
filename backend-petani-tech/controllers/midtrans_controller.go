package controllers

import (
	"net/http"
	"strings"

	"backend-petani-tech/config"
	"backend-petani-tech/models"
	"backend-petani-tech/pkg/midtrans"
	"github.com/gin-gonic/gin"
)

type MidtransChargeInput struct {
	OrderID     string  `json:"orderId" binding:"required"`
	PaymentType string  `json:"paymentType"` // qris, bank_transfer, gopay, echannel
	Bank        string  `json:"bank"`        // bca, bni, bri, permata, mandiri
	GrossAmount float64 `json:"grossAmount"`
}

// ChargeMidtrans initiates a real Midtrans Core API transaction
func ChargeMidtrans(c *gin.Context) {
	var input MidtransChargeInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Parameter tidak lengkap: " + err.Error()})
		return
	}

	var order models.SellerOrder
	if err := config.DB.Where("id = ? OR order_number = ?", input.OrderID, input.OrderID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	amount := input.GrossAmount
	if amount <= 0 {
		amount = order.TotalAmount
	}

	// Tentukan payment type
	paymentType := strings.ToLower(input.PaymentType)
	bank := strings.ToLower(input.Bank)

	// Jika paymentType kosong, deteksi dari PaymentMethod order
	if paymentType == "" {
		pm := strings.ToLower(order.PaymentMethod)
		if strings.Contains(pm, "qris") {
			paymentType = "qris"
		} else if strings.Contains(pm, "bca") || strings.Contains(pm, "transfer") || strings.Contains(pm, "bank") || strings.Contains(pm, "va") {
			paymentType = "bank_transfer"
			if strings.Contains(pm, "bni") {
				bank = "bni"
			} else if strings.Contains(pm, "bri") {
				bank = "bri"
			} else if strings.Contains(pm, "mandiri") {
				paymentType = "echannel"
			} else if strings.Contains(pm, "permata") {
				bank = "permata"
			} else {
				bank = "bca"
			}
		} else if strings.Contains(pm, "gopay") {
			paymentType = "gopay"
		} else {
			paymentType = "qris"
		}
	}

	payload := midtrans.ChargePayload{
		PaymentType: paymentType,
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:     order.OrderNumber,
			GrossAmount: amount,
		},
		CustomerDetails: &midtrans.CustomerDetails{
			FirstName: order.BuyerName,
			Phone:     order.BuyerPhone,
			Address:   order.BuyerAddress,
		},
	}

	switch paymentType {
	case "qris":
		payload.Qris = &midtrans.QrisParam{Acquirer: "gopay"}
	case "gopay":
		payload.PaymentType = "gopay"
	case "echannel":
		payload.PaymentType = "echannel"
		payload.Echannel = &midtrans.EchannelParam{
			BillInfo1: "Pembayaran:",
			BillInfo2: "Pesanan PetaniTech",
		}
	case "bank_transfer":
		if bank == "" {
			bank = "bca"
		}
		if bank == "mandiri" {
			payload.PaymentType = "echannel"
			payload.Echannel = &midtrans.EchannelParam{
				BillInfo1: "Pembayaran:",
				BillInfo2: "Pesanan PetaniTech",
			}
		} else {
			payload.BankTransfer = &midtrans.BankTransferParam{Bank: bank}
		}
	}

	chargeResp, err := midtrans.Charge(payload)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{
			"error":    err.Error(),
			"midtrans": chargeResp,
		})
		return
	}

	// Simpan detail pembayaran yang dihasilkan Midtrans ke database order
	updates := map[string]interface{}{
		"payment_status": "Menunggu Pembayaran",
	}

	// Ambil QR Code URL atau string jika QRIS
	if chargeResp.QrString != "" {
		updates["payment_qr_string"] = chargeResp.QrString
	}
	for _, act := range chargeResp.Actions {
		if act.Name == "generate-qr-code" {
			updates["payment_qr_url"] = act.URL
			break
		}
	}

	// Ambil Virtual Account number jika Bank Transfer
	if len(chargeResp.VaNumbers) > 0 {
		updates["payment_va_number"] = chargeResp.VaNumbers[0].VaNumber
	} else if chargeResp.PermataVaNumber != "" {
		updates["payment_va_number"] = chargeResp.PermataVaNumber
	}

	// Mandiri Bill
	if chargeResp.BillKey != "" {
		updates["payment_bill_key"] = chargeResp.BillKey
		updates["payment_biller_code"] = chargeResp.BillerCode
	}

	config.DB.Model(&order).Updates(updates)

	c.JSON(http.StatusOK, gin.H{
		"message": "Transaksi pembayaran berhasil dibuat",
		"data": gin.H{
			"orderNumber":       order.OrderNumber,
			"grossAmount":       chargeResp.GrossAmount,
			"paymentType":       chargeResp.PaymentType,
			"transactionStatus": chargeResp.TransactionStatus,
			"transactionId":     chargeResp.TransactionID,
			"qrUrl":             updates["payment_qr_url"],
			"qrString":          updates["payment_qr_string"],
			"vaNumber":          updates["payment_va_number"],
			"billKey":           updates["payment_bill_key"],
			"billerCode":        updates["payment_biller_code"],
			"actions":           chargeResp.Actions,
		},
	})
}

// CheckMidtransStatus handles Manual Cek Status / Sync API
func CheckMidtransStatus(c *gin.Context) {
	orderID := c.Param("orderId")
	if orderID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Order ID diperlukan"})
		return
	}

	var order models.SellerOrder
	if err := config.DB.Where("id = ? OR order_number = ?", orderID, orderID).Preload("Items").First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	statusResp, err := midtrans.CheckStatus(order.OrderNumber)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"message": "Status lokal digunakan (Midtrans: " + err.Error() + ")",
			"data":    order,
			"sync":    false,
		})
		return
	}

	// Update status pesanan berdasarkan respon Midtrans
	txStatus := strings.ToLower(statusResp.TransactionStatus)
	var newOrderStatus = order.Status
	var newPaymentStatus = order.PaymentStatus

	switch txStatus {
	case "settlement", "capture":
		newOrderStatus = "Diproses"
		newPaymentStatus = "Lunas"
	case "pending":
		newOrderStatus = "Menunggu Pembayaran"
		newPaymentStatus = "Menunggu Pembayaran"
	case "expire", "cancel", "deny":
		newOrderStatus = "Dibatalkan"
		newPaymentStatus = "Dibatalkan"
	}

	if newOrderStatus != order.Status || newPaymentStatus != order.PaymentStatus {
		config.DB.Model(&order).Updates(map[string]interface{}{
			"status":         newOrderStatus,
			"payment_status": newPaymentStatus,
		})
		order.Status = newOrderStatus
		order.PaymentStatus = newPaymentStatus
	}

	c.JSON(http.StatusOK, gin.H{
		"message":           "Sinkronisasi status berhasil",
		"sync":              true,
		"transactionStatus": txStatus,
		"data":              order,
		"midtrans":          statusResp,
	})
}

// MidtransNotification handles webhook callbacks from Midtrans
func MidtransNotification(c *gin.Context) {
	var notif map[string]interface{}
	if err := c.ShouldBindJSON(&notif); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	orderID, _ := notif["order_id"].(string)
	txStatus, _ := notif["transaction_status"].(string)

	if orderID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid order_id"})
		return
	}

	var order models.SellerOrder
	if err := config.DB.Where("id = ? OR order_number = ?", orderID, orderID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Order not found"})
		return
	}

	status := strings.ToLower(txStatus)
	var newOrderStatus = order.Status
	var newPaymentStatus = order.PaymentStatus

	switch status {
	case "settlement", "capture":
		newOrderStatus = "Diproses"
		newPaymentStatus = "Lunas"
	case "pending":
		newOrderStatus = "Menunggu Pembayaran"
		newPaymentStatus = "Menunggu Pembayaran"
	case "expire", "cancel", "deny":
		newOrderStatus = "Dibatalkan"
		newPaymentStatus = "Dibatalkan"
	}

	config.DB.Model(&order).Updates(map[string]interface{}{
		"status":         newOrderStatus,
		"payment_status": newPaymentStatus,
	})

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
