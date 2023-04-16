package repository

import (
	"context"
	"github.com/Brainsoft-Raxat/hacknu/internal/app/config"
	"github.com/Brainsoft-Raxat/hacknu/internal/app/conn"
	"github.com/Brainsoft-Raxat/hacknu/internal/models"
	"github.com/Brainsoft-Raxat/hacknu/pkg/data"
)

type Repository struct {
	Postgres
	Egov
	Google
	InMemory
}

type Postgres interface {
	GetOrder(ctx context.Context, id int) (Orders models.Orders, err error)
	GetDeliveryServices(ctx context.Context) (deliveryServices []models.DeliveryServices, err error)
	GetCouriers(ctx context.Context, id int) (Courier models.Couriers, err error)
	SaveCouriers(ctx context.Context, Couriers models.Couriers) (value int, err error)
	SaveOrder(ctx context.Context, Order models.Orders) (value int, err error)
	SaveDeliveryServices(ctx context.Context, DeliveryServices models.DeliveryServices) (value int, err error)
	UpdateOrder(ctx context.Context, id int, status string) (err error)
	GetOrders(ctx context.Context, status string) (orders []models.Orders, err error)
	UpdateOrderDeliver(ctx context.Context, id int, phone, iin, status string) (err error)
}

type Egov interface {
	GetPersonData(ctx context.Context, iin string) (person models.Person, err error)
	SendSMS(ctx context.Context, msg models.SendSMSRequest) (err error)
	GetRequestData(ctx context.Context, request models.GetRequestDataRequest) (response models.GetRequestDataResponse, err error)
	CheckIIN(ctx context.Context, iin string) (response models.CheckIINResponse, err error)
}

type Google interface {
	GetDistance(ctx context.Context, destinationAddress string, destinationHouse string) (distanceResponse data.DistanceResponse, err error)
	GetCoordinates(ctx context.Context, street string) (geocodingResponse data.GeocodingResponse, err error)
}

type InMemory interface {
	SaveOTP(phone string) (code string)
	CheckOTP(phone, code string) bool
}

func New(conn conn.Conn, cfg *config.Config) *Repository {
	return &Repository{
		Postgres: NewPostgresRepository(conn.DB, cfg.Postgres),
		Egov:     NewEgov(cfg),
		Google:   NewGoogle(cfg),
		InMemory: NewInMemory(),
	}
}
