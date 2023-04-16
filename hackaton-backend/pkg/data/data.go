package data

import "github.com/Brainsoft-Raxat/hacknu/internal/models"

type DoSomethingRequest struct {
	Name string `json:"name"`
}

type DoSomethingResponse struct {
	Value string `json:"value"`
}

type DocumentReadyRequest struct {
	Id    string `json:"id"`
	IIN   string `json:"iin"`
	Phone string `json:"phone"`
}

type DocumentReadyResponse struct {
	Message string `json:"message"`
}

type CheckIINRequest struct {
	IIN string `json:"iin"`
}

type CheckIINResponse struct {
	IsExists bool `json:"is_exists"`
}

type CreateOrderRequest struct {
	RequestID       string `json:"requestId"`
	IIN             string `json:"iin"`
	Branch          string `json:"branch"`
	DeliveryService string `json:"deliveryService"`
	FirstName       string `json:"firstName"`
	LastName        string `json:"lastName"`
	MiddleName      string `json:"middleName"`
	Address         string `json:"address"`
	Phone           string `json:"phone"`
	AdditionalData  string `json:"additionalData"`
	TrustedFaceIin  string `json:"trustedFaceIin"`
	//Region         string `json:"region"`
	//City           string `json:"city"`
	//Street         string `json:"street"`
	//House          string `json:"house"`
	//Entrance       string `json:"entrance"`
	//Floor          string `json:"floor"`
	//Corpus         string `json:"corpus"`
	//CourierPhone             string `json:"rc"`
}

type CreateOrderResponse struct {
	OrderId    int     `json:"orderId"`
	BranchName string  `json:"branchName"`
	Price      float64 `json:"price"`
	Time       int     `json:"time"`
	Distance   int     `json:"distance"`
}

type ConfirmOrder struct {
}

type DistanceResponse struct {
	DestinationAddresses []string `json:"destination_addresses"`
	OriginAddresses      []string `json:"origin_addresses"`
	Rows                 []struct {
		Elements []struct {
			Distance struct {
				Text  string `json:"text"`
				Value int    `json:"value"`
			} `json:"distance"`
			Duration struct {
				Text  string `json:"text"`
				Value int    `json:"value"`
			} `json:"duration"`
			Status string `json:"status"`
		} `json:"elements"`
	} `json:"rows"`
	Status string `json:"status"`
}

type GetCoordinatesRequest struct {
	Street string `json:"street"`
}

type GetCoordinatesResponse struct {
	Lat      float64 `json:"lat"`
	Lng      float64 `json:"lng"`
	Distance string  `json:"distance"`
	Time     string  `json:"time"`
}

type GeocodingResponse struct {
	Results []struct {
		Geometry struct {
			Location struct {
				Lat float64 `json:"lat"`
				Lng float64 `json:"lng"`
			} `json:"location"`
		} `json:"geometry"`
	} `json:"results"`
}

type GetClientDataRequest struct {
	IIN string `json:"iin"`
}

type GetClientDataResponse struct {
	FirstName  string `json:"firstName"`
	MiddleName string `json:"middleName"`
	LastName   string `json:"lastName"`
	Phone      string `json:"phone"`
}

type ConfirmOrderRequest struct {
	OrderId int `json:"orderId"`
}

type ConfirmOrderResponse struct {
}

type GetOrdersRequest struct {
}

type GetOrdersResponse struct {
	Orders []models.Orders `json:"orders"`
}

type PickUpOrderStartRequest struct {
	OrderId int    `json:"orderId"`
	Phone   string `json:"phone"`
	IIN     string `json:"iin"`
}

type PickUpOrderStartResponse struct {
	Ok bool `json:"ok"`
}

type CheckOTPRequest struct {
	OrderID string `json:"phone"`
	Code    string `json:"code"`
}

type CheckOTPResponse struct {
	Ok bool `json:"ok"`
}

type StartDeliverRequest struct {
	OrderId int    `json:"orderId"`
	Phone   string `json:"phone"`
	IIN     string `json:"iin"`
}

type StartDeliverResponse struct {
	Ok bool `json:"ok"`
}

type PickUpOrderFinishRequest struct {
	OrderId int `json:"orderId"`
}

type PickUpOrderFinishResponse struct {
	Ok bool `json:"ok"`
}
