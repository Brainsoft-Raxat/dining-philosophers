package handler

import (
	"github.com/Brainsoft-Raxat/hacknu/pkg/data"
	"github.com/labstack/echo/v4"
	"net/http"
)

func (h *handler) CheckIIN(c echo.Context) error {
	var req data.CheckIINRequest
	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	req.IIN = c.Param("iin")

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.CheckIIN(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) GetClientData(c echo.Context) error {
	var req data.GetClientDataRequest
	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	req.IIN = c.Param("iin")

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.GetClientData(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) GetBranches(c echo.Context) error {
	ctx := c.Request().Context()
	resp, err := h.service.OrderService.GetDeliveryServices(ctx)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) CreateOrder(c echo.Context) error {
	var req data.CreateOrderRequest
	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.CreateOrder(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) GetCoordinates(c echo.Context) error {
	var req data.GetCoordinatesRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.GetCoordinates(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) DocumentReady(c echo.Context) error {
	var req data.DocumentReadyRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.DocumentReady(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) GetOrders(c echo.Context) error {
	var req data.GetOrdersRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.GetOrders(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) ConfirmOrder(c echo.Context) error {
	var req data.ConfirmOrderRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.ConfirmOrder(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) PickUpOrderStart(c echo.Context) error {
	var req data.PickUpOrderStartRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.PickUpOrderStart(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) PickUpOrderFinish(c echo.Context) error {
	var req data.PickUpOrderFinishRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.PickUpOrderFinish(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) CheckOTP(c echo.Context) error {
	var req data.CheckOTPRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.CheckOTP(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) StartDeliver(c echo.Context) error {
	var req data.StartDeliverRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.StartDeliver(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) PreFinish(c echo.Context) error {
	var req data.ConfirmOrderRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.PreFinish(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) Finish(c echo.Context) error {
	var req data.ConfirmOrderRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.Finish(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}

func (h *handler) GetOrdersDeliver(c echo.Context) error {
	var req data.GetOrdersRequest

	err := c.Bind(&req)
	if err != nil {
		return handleError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	resp, err := h.service.OrderService.GetOrdersDeliver(ctx, req)
	if err != nil {
		return handleError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, resp)
}
