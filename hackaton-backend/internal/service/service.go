package service

import (
	"context"
	"github.com/Brainsoft-Raxat/hacknu/internal/models"
	"github.com/Brainsoft-Raxat/hacknu/internal/repository"
	"github.com/Brainsoft-Raxat/hacknu/pkg/data"
)

type SomeService interface {
	DoSomething(ctx context.Context, request data.DoSomethingRequest) (response data.DoSomethingResponse, err error)
}

type OrderService interface {
	DocumentReady(ctx context.Context, req data.DocumentReadyRequest) (resp data.DocumentReadyResponse, err error)
	CheckIIN(ctx context.Context, req data.CheckIINRequest) (resp data.CheckIINResponse, err error)
	GetCoordinates(ctx context.Context, req data.GetCoordinatesRequest) (resp data.GetCoordinatesResponse, err error)
	GetClientData(ctx context.Context, req data.GetClientDataRequest) (resp data.GetClientDataResponse, err error)
	GetDeliveryServices(ctx context.Context) (deliveryServices []models.DeliveryServices, err error)
	CreateOrder(ctx context.Context, req data.CreateOrderRequest) (resp data.CreateOrderResponse, err error)
	GetOrders(ctx context.Context, request data.GetOrdersRequest) (resp data.GetOrdersResponse, err error)
	ConfirmOrder(ctx context.Context, request data.ConfirmOrderRequest) (response data.ConfirmOrderResponse, err error)
	PickUpOrderStart(ctx context.Context, request data.PickUpOrderStartRequest) (response data.PickUpOrderStartResponse, err error)
	CheckOTP(ctx context.Context, request data.CheckOTPRequest) (response data.CheckOTPResponse, err error)
	StartDeliver(ctx context.Context, request data.StartDeliverRequest) (response data.StartDeliverResponse, err error)
	PreFinish(ctx context.Context, request data.ConfirmOrderRequest) (response data.PickUpOrderStartResponse, err error)
	Finish(ctx context.Context, request data.ConfirmOrderRequest) (response data.PickUpOrderFinishResponse, err error)
	GetOrdersDeliver(ctx context.Context, request data.GetOrdersRequest) (resp data.GetOrdersResponse, err error)
	PickUpOrderFinish(ctx context.Context, request data.PickUpOrderFinishRequest) (response data.PickUpOrderFinishResponse, err error)
}

type Service struct {
	SomeService
	OrderService
}

func New(repos *repository.Repository) *Service {
	return &Service{
		SomeService:  NewSomeService(repos),
		OrderService: NewOrderService(repos),
	}
}
