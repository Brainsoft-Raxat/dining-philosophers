package service

import (
	"context"
	"errors"
	"fmt"
	"github.com/Brainsoft-Raxat/hacknu/internal/models"
	"github.com/Brainsoft-Raxat/hacknu/internal/repository"
	"github.com/Brainsoft-Raxat/hacknu/pkg/data"
	"math"
	"strconv"
	"strings"
	"time"
)

type orderService struct {
	orderRepo *repository.Repository
}

func (s *orderService) DocumentReady(ctx context.Context, req data.DocumentReadyRequest) (resp data.DocumentReadyResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()

	msg := models.SendSMSRequest{
		Phone:   req.Phone,
		SmsText: fmt.Sprintf(models.SMSTEMPLATE, req.Id, models.URLTEMPLATE+req.Id, req.Id, models.URLTEMPLATE+req.Id),
	}

	fmt.Println(msg.SmsText)
	err = s.orderRepo.Egov.SendSMS(ctx, msg)
	if err != nil {
		return
	}

	return
}

func (s *orderService) CheckIIN(ctx context.Context, req data.CheckIINRequest) (resp data.CheckIINResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()

	eResp, err := s.orderRepo.CheckIIN(ctx, req.IIN)
	if err != nil {
		return
	}

	return data.CheckIINResponse{IsExists: eResp.IsExists}, nil
}

func (s *orderService) CreateOrder(ctx context.Context, req data.CreateOrderRequest) (resp data.CreateOrderResponse, err error) {
	fmt.Println(req)

	deliveries := map[string]int{
		"DHL":                 1,
		"Pony Express":        2,
		"Exline":              3,
		"CDEK":                4,
		"Garant Post Service": 5,
		"Алем-Тат":            6,
	}

	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()

	slc := strings.Split(req.Address, ",")
	home := strings.Split(strings.TrimSpace(slc[2]), " ")

	response, err := s.orderRepo.GetDistance(ctx, home[0], home[1])
	if err != nil {
		return
	}

	// get the distance value
	time := response.Rows[0].Elements[0].Duration.Text

	timeIn := strings.TrimSuffix(time, " mins") // Remove " mins" from the end of the string 	// Extract the first character of the string
	timeInMinute, err := strconv.Atoi(timeIn)
	distanceValue := response.Rows[0].Elements[0].Distance.Value
	//price := math.Round(float64(distanceValue+50)/100) * 100
	price := 300 + math.Round(0.15*float64(distanceValue))

	requestDataResp, err := s.orderRepo.Egov.GetRequestData(ctx, models.GetRequestDataRequest{
		RequestID: req.RequestID,
		IIN:       "860904350504",
	})
	if err != nil {
		return
	}

	orderId, err := s.orderRepo.Postgres.SaveOrder(ctx, models.Orders{
		Iin:               req.IIN,
		RequestId:         req.RequestID,
		ServiceName:       requestDataResp.Data.ServiceType.NameRu,
		OrganizationCode:  requestDataResp.Data.Organization.Code,
		OrganizationName:  requestDataResp.Data.Organization.NameRu,
		RecipientName:     req.FirstName,
		RecipientSurname:  req.LastName,
		RecipientPhone:    req.Phone,
		Region:            strings.TrimSpace(slc[0]),
		City:              strings.TrimSpace(slc[1]),
		Street:            home[0],
		House:             home[2],
		Entrance:          "",
		Floor:             "",
		Corpus:            "",
		CourierPhone:      "",
		AdditionalData:    req.AdditionalData,
		TrustedFaceIin:    req.TrustedFaceIin,
		DeliveryServiceId: deliveries[req.DeliveryService],
		DeliveryPrice:     int(price),
		CourierIIN:        "",
		Status:            "CREATED",
	})
	if err != nil {
		return
	}

	return data.CreateOrderResponse{
		OrderId:    orderId,
		BranchName: "ЦОН ул.Керей, Жанибек хандар 4, Астана",
		Price:      price,
		Time:       timeInMinute,
		Distance:   distanceValue,
	}, nil

}

func (s *orderService) GetCoordinates(ctx context.Context, req data.GetCoordinatesRequest) (resp data.GetCoordinatesResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()

	fmt.Println(req.Street)

	response, err := s.orderRepo.GetCoordinates(ctx, req.Street)
	if err != nil {
		return
	}

	if len(response.Results) != 0 {
		resp.Lat = response.Results[0].Geometry.Location.Lat
		resp.Lng = response.Results[0].Geometry.Location.Lng
	}

	return
}

func (s *orderService) GetClientData(ctx context.Context, req data.GetClientDataRequest) (resp data.GetClientDataResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()

	iinResp, err := s.orderRepo.CheckIIN(ctx, req.IIN)
	if err != nil {
		return
	}

	clientResp, err := s.orderRepo.GetPersonData(ctx, req.IIN)
	if err != nil {
		return
	}

	return data.GetClientDataResponse{
		FirstName:  clientResp.FirstName,
		MiddleName: clientResp.MiddleName,
		LastName:   clientResp.LastName,
		Phone:      iinResp.Phone,
	}, nil
}

func (s *orderService) GetDeliveryServices(ctx context.Context) (deliveryServices []models.DeliveryServices, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	return s.orderRepo.GetDeliveryServices(ctx)
}

func (s *orderService) ConfirmOrder(ctx context.Context, request data.ConfirmOrderRequest) (response data.ConfirmOrderResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	err = s.orderRepo.UpdateOrder(ctx, request.OrderId, models.PENDING)
	if err != nil {
		return
	}

	return
}

func (s *orderService) GetOrders(ctx context.Context, request data.GetOrdersRequest) (resp data.GetOrdersResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	orders, err := s.orderRepo.Postgres.GetOrders(ctx, models.PENDING)
	resp.Orders = orders

	return
}

func (s *orderService) GetOrdersDeliver(ctx context.Context, request data.GetOrdersRequest) (resp data.GetOrdersResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	orders, err := s.orderRepo.Postgres.GetOrders(ctx, models.IN_PROGRESS)
	resp.Orders = orders

	return
}

func (s *orderService) PickUpOrderStart(ctx context.Context, request data.PickUpOrderStartRequest) (response data.PickUpOrderStartResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	order, err := s.orderRepo.GetOrder(ctx, request.OrderId)
	if err != nil {
		return
	}

	if order.Status != models.IN_PROGRESS {
		return data.PickUpOrderStartResponse{}, errors.New("низя")
	}

	code := s.orderRepo.InMemory.SaveOTP(strconv.Itoa(order.Id))
	fmt.Println(code)

	response.Ok = true

	//send sms
	err = s.orderRepo.Egov.SendSMS(ctx, models.SendSMSRequest{
		Phone:   request.Phone,
		SmsText: "Ваш OTP код - " + code,
	})
	if err != nil {
		return
	}

	return
}

func (s *orderService) CheckOTP(ctx context.Context, request data.CheckOTPRequest) (response data.CheckOTPResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	ok := s.orderRepo.CheckOTP(request.OrderID, request.Code)
	response.Ok = ok

	return
}

func (s *orderService) PickUpOrderFinish(ctx context.Context, request data.PickUpOrderFinishRequest) (response data.PickUpOrderFinishResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	order, err := s.orderRepo.Postgres.GetOrder(ctx, request.OrderId)
	if err != nil {
		return
	}

	err = s.orderRepo.Postgres.UpdateOrder(ctx, request.OrderId, models.PICKUP)
	if err != nil {
		return
	}

	fmt.Println(order.RecipientPhone)
	err = s.orderRepo.Egov.SendSMS(ctx, models.SendSMSRequest{
		Phone:   order.RecipientPhone,
		SmsText: "Ваш заказ N" + strconv.Itoa(request.OrderId) + " был вручен курьеру. Ожидайте доставки",
	})
	if err != nil {
		return
	}

	return
}

func (s *orderService) StartDeliver(ctx context.Context, request data.StartDeliverRequest) (response data.StartDeliverResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	err = s.orderRepo.Postgres.UpdateOrderDeliver(ctx, request.OrderId, request.Phone, request.IIN, models.IN_PROGRESS)
	if err != nil {
		return
	}
	response.Ok = true

	return
}

func (s *orderService) PreFinish(ctx context.Context, request data.ConfirmOrderRequest) (response data.PickUpOrderStartResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	order, err := s.orderRepo.GetOrder(ctx, request.OrderId)
	if err != nil {
		return
	}

	if order.Status != models.PICKUP {
		return data.PickUpOrderStartResponse{}, errors.New("низя")
	}

	code := s.orderRepo.InMemory.SaveOTP(strconv.Itoa(order.Id))
	fmt.Println(code)

	response.Ok = true

	//send sms
	err = s.orderRepo.Egov.SendSMS(ctx, models.SendSMSRequest{
		Phone:   order.RecipientPhone,
		SmsText: "Ваш OTP код - " + code,
	})
	if err != nil {
		return
	}

	return
}

func (s *orderService) Finish(ctx context.Context, request data.ConfirmOrderRequest) (response data.PickUpOrderFinishResponse, err error) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()

	order, err := s.orderRepo.GetOrder(ctx, request.OrderId)
	if err != nil {
		return
	}

	err = s.orderRepo.Postgres.UpdateOrder(ctx, request.OrderId, models.FINISHED)
	if err != nil {
		return
	}
	response.Ok = true

	err = s.orderRepo.Egov.SendSMS(ctx, models.SendSMSRequest{
		Phone:   order.RecipientPhone,
		SmsText: "Ваш заказ N" + strconv.Itoa(request.OrderId) + " завершен. Спасибо!",
	})
	if err != nil {
		return
	}

	return
}

func NewOrderService(repo *repository.Repository) OrderService {
	return &orderService{
		orderRepo: repo,
	}
}
