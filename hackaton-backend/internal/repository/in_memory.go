package repository

import (
	"github.com/Brainsoft-Raxat/hacknu/internal/models"
	"math/rand"
	"strconv"
	"sync"
	"time"
)

type inMemory struct {
	otps map[string]models.OTP
	mu   sync.Mutex
}

func NewInMemory() InMemory {
	r := &inMemory{
		otps: make(map[string]models.OTP),
		mu:   sync.Mutex{},
	}

	//ticker := time.NewTicker(time.Minute)
	//
	//for range ticker.C {
	//	newOtps := make(map[string]models.OTP)
	//	for key := range r.otps {
	//		if time.Now().Before(r.otps[key].ExpiresIn) {
	//			newOtps[key] = r.otps[key]
	//		}
	//	}
	//
	//	r.mu.Lock()
	//	r.otps = newOtps
	//	r.mu.Unlock()
	//}

	return r
}

func (r *inMemory) SaveOTP(orderID string) (code string) {
	rand.Seed(time.Now().UnixNano())

	// Generate a random number between 100000 and 999999
	randomNum := strconv.Itoa(rand.Intn(900000) + 100000)

	r.mu.Lock()
	r.otps[orderID] = models.OTP{
		Code:      randomNum,
		ExpiresIn: time.Time{},
	}
	r.mu.Unlock()

	return randomNum
}

func (r *inMemory) CheckOTP(orderID, code string) bool {
	if _, ok := r.otps[orderID]; !ok {
		return false
	} else if r.otps[orderID].Code != code {
		return false
	}

	delete(r.otps, orderID)

	return true
}
