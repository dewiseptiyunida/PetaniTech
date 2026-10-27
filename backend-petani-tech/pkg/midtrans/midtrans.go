package midtrans

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

type Config struct {
	ServerKey    string
	ClientKey    string
	MerchantID   string
	IsProduction bool
}

func GetConfig() Config {
	return Config{
		ServerKey:    os.Getenv("MIDTRANS_SERVER_KEY"),
		ClientKey:    os.Getenv("MIDTRANS_CLIENT_KEY"),
		MerchantID:   os.Getenv("MIDTRANS_MERCHANT_ID"),
		IsProduction: os.Getenv("MIDTRANS_IS_PRODUCTION") == "true",
	}
}

func GetBaseURL() string {
	if GetConfig().IsProduction {
		return "https://api.midtrans.com"
	}
	return "https://api.sandbox.midtrans.com"
}

// Data structures for Core API
type TransactionDetails struct {
	OrderID     string  `json:"order_id"`
	GrossAmount float64 `json:"gross_amount"`
}

type CustomerDetails struct {
	FirstName string `json:"first_name,omitempty"`
	Phone     string `json:"phone,omitempty"`
	Address   string `json:"address,omitempty"`
}

type BankTransferParam struct {
	Bank string `json:"bank"`
}

type QrisParam struct {
	Acquirer string `json:"acquirer,omitempty"`
}

type EchannelParam struct {
	BillInfo1 string `json:"bill_info1"`
	BillInfo2 string `json:"bill_info2"`
}

type ChargePayload struct {
	PaymentType        string             `json:"payment_type"`
	TransactionDetails TransactionDetails `json:"transaction_details"`
	CustomerDetails    *CustomerDetails   `json:"customer_details,omitempty"`
	BankTransfer       *BankTransferParam `json:"bank_transfer,omitempty"`
	Qris               *QrisParam         `json:"qris,omitempty"`
	Echannel           *EchannelParam     `json:"echannel,omitempty"`
}

type Action struct {
	Name   string `json:"name"`
	Method string `json:"method"`
	URL    string `json:"url"`
}

type VaNumber struct {
	Bank     string `json:"bank"`
	VaNumber string `json:"va_number"`
}

type ChargeResponse struct {
	StatusCode        string     `json:"status_code"`
	StatusMessage     string     `json:"status_message"`
	TransactionID     string     `json:"transaction_id"`
	OrderID           string     `json:"order_id"`
	GrossAmount       string     `json:"gross_amount"`
	PaymentType       string     `json:"payment_type"`
	TransactionTime   string     `json:"transaction_time"`
	TransactionStatus string     `json:"transaction_status"`
	Actions           []Action   `json:"actions,omitempty"`
	VaNumbers         []VaNumber `json:"va_numbers,omitempty"`
	PermataVaNumber   string     `json:"permata_va_number,omitempty"`
	BillKey           string     `json:"bill_key,omitempty"`
	BillerCode        string     `json:"biller_code,omitempty"`
	QrString          string     `json:"qr_string,omitempty"`
}

type StatusResponse struct {
	StatusCode        string     `json:"status_code"`
	StatusMessage     string     `json:"status_message"`
	TransactionID     string     `json:"transaction_id"`
	OrderID           string     `json:"order_id"`
	GrossAmount       string     `json:"gross_amount"`
	PaymentType       string     `json:"payment_type"`
	TransactionTime   string     `json:"transaction_time"`
	TransactionStatus string     `json:"transaction_status"`
	FraudStatus       string     `json:"fraud_status,omitempty"`
	VaNumbers         []VaNumber `json:"va_numbers,omitempty"`
	SettlementTime    string     `json:"settlement_time,omitempty"`
}

// Charge handles Core API transaction creation
func Charge(payload ChargePayload) (*ChargeResponse, error) {
	cfg := GetConfig()
	url := fmt.Sprintf("%s/v2/charge", GetBaseURL())

	bodyBytes, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(bodyBytes))
	if err != nil {
		return nil, err
	}

	auth := base64.StdEncoding.EncodeToString([]byte(cfg.ServerKey + ":"))
	req.Header.Set("Authorization", "Basic "+auth)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var chargeResp ChargeResponse
	if err := json.Unmarshal(respBytes, &chargeResp); err != nil {
		return nil, fmt.Errorf("failed to parse Midtrans response: %s", string(respBytes))
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return &chargeResp, fmt.Errorf("Midtrans charge error [%s]: %s", chargeResp.StatusCode, chargeResp.StatusMessage)
	}

	return &chargeResp, nil
}

// CheckStatus queries transaction status from Midtrans
func CheckStatus(orderID string) (*StatusResponse, error) {
	cfg := GetConfig()
	url := fmt.Sprintf("%s/v2/%s/status", GetBaseURL(), strings.TrimSpace(orderID))

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	auth := base64.StdEncoding.EncodeToString([]byte(cfg.ServerKey + ":"))
	req.Header.Set("Authorization", "Basic "+auth)
	req.Header.Set("Accept", "application/json")

	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var statusResp StatusResponse
	if err := json.Unmarshal(respBytes, &statusResp); err != nil {
		return nil, fmt.Errorf("failed to parse Midtrans status: %s", string(respBytes))
	}

	return &statusResp, nil
}
