package repository

import (
	"context"
	"github.com/Brainsoft-Raxat/hacknu/internal/app/config"
	"github.com/Brainsoft-Raxat/hacknu/internal/models"
	"github.com/jackc/pgx/v4/pgxpool"
)

type postgres struct {
	db  *pgxpool.Pool
	cfg config.Postgres
}

// всё взаимодействие с постгрес
func (r *postgres) GetOrder(ctx context.Context, id int) (Orders models.Orders, err error) {

	q := `SELECT * FROM Orders WHERE id = $1 `
	err = r.db.QueryRow(ctx, q, id).Scan(&Orders.Id, &Orders.Iin, &Orders.RequestId, &Orders.ServiceName, &Orders.OrganizationCode, &Orders.OrganizationName, &Orders.RecipientName, &Orders.RecipientSurname, &Orders.RecipientPhone, &Orders.Region, &Orders.City, &Orders.Street, &Orders.House, &Orders.Entrance, &Orders.Floor, &Orders.Corpus, &Orders.CourierPhone, &Orders.AdditionalData, &Orders.TrustedFaceIin, &Orders.DeliveryServiceId, &Orders.DeliveryPrice, &Orders.CourierIIN, &Orders.Status)
	if err != nil {
		return Orders, err
	}
	return Orders, nil
}

func (r *postgres) GetOrders(ctx context.Context, status string) (orders []models.Orders, err error) {
	q := `SELECT * FROM orders WHERE status = $1`
	rows, err := r.db.Query(ctx, q, status)
	if err != nil {
		return
	}

	orders = make([]models.Orders, 0)

	for rows.Next() {
		row := models.Orders{}

		err = rows.Scan(&row.Id, &row.Iin, &row.RequestId, &row.ServiceName, &row.OrganizationCode, &row.OrganizationName, &row.RecipientName, &row.RecipientSurname, &row.RecipientPhone, &row.Region, &row.City, &row.Street, &row.House, &row.Entrance, &row.Floor, &row.Corpus, &row.CourierPhone, &row.AdditionalData, &row.TrustedFaceIin, &row.DeliveryServiceId, &row.DeliveryPrice, &row.CourierIIN, &row.Status)
		if err != nil {
			return
		}

		orders = append(orders, row)
	}

	return
}

func (r *postgres) SaveOrder(ctx context.Context, order models.Orders) (value int, err error) {
	var id int
	q := `insert into orders (iin, request_id, service_name, organization_code, organization_name, recipient_name,
                    recipient_surname, recipient_phone, region, city, street, house, entrance, floor, corpus, rc,
                    additional_data, trusted_face_iin, delivery_service_id, delivery_price, courier_iin, status)
values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22) RETURNING id;`

	err = r.db.QueryRow(ctx, q, order.Iin, order.RequestId, order.ServiceName, order.OrganizationCode, order.OrganizationName, order.RecipientName,
		order.RecipientSurname, order.RecipientPhone, order.Region, order.City, order.Street, order.House, order.Entrance, order.Floor, order.Corpus, order.CourierPhone, order.AdditionalData, order.TrustedFaceIin, order.DeliveryServiceId, order.DeliveryPrice, order.CourierIIN, order.Status).Scan(&id)

	if err != nil {
		return 0, err
	}
	return id, nil
}

func (r *postgres) UpdateOrder(ctx context.Context, id int, status string) (err error) {
	q := `update orders set status = $1 WHERE id = $2;`

	_, err = r.db.Exec(ctx, q, status, id)
	if err != nil {
		return
	}

	return
}

func (r *postgres) UpdateOrderDeliver(ctx context.Context, id int, phone, iin, status string) (err error) {
	q := `update orders set status = $1, rc = $2, courier_iin = $3 WHERE id = $4;`

	_, err = r.db.Exec(ctx, q, status, phone, iin, id)
	if err != nil {
		return
	}

	return
}

func (r *postgres) SaveDeliveryServices(ctx context.Context, DeliveryServices models.DeliveryServices) (value int, err error) {
	var id int
	q := `insert into delivery_services (id, name) values ($1, $2) RETURNING id`

	err = r.db.QueryRow(ctx, q, DeliveryServices.Id, DeliveryServices.Name).Scan(&DeliveryServices.Id)
	if err != nil {
		return 0, err
	}
	return id, nil
}

func (r *postgres) GetDeliveryServices(ctx context.Context) (deliveryServices []models.DeliveryServices, err error) {
	q := `SELECT * FROM delivery_services`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return
	}

	deliveryServices = make([]models.DeliveryServices, 0)

	for rows.Next() {
		item := models.DeliveryServices{}
		err = rows.Scan(&item.Id, &item.Name)
		if err != nil {
			return
		}

		deliveryServices = append(deliveryServices, item)
	}

	return deliveryServices, nil
}

func (r *postgres) SaveCouriers(ctx context.Context, Couriers models.Couriers) (value int, err error) {

	var id int
	q := `insert into couriers (id, delivery_service_id, firstname, surname, phone) values ($1, $2) RETURNING id`

	err = r.db.QueryRow(ctx, q, Couriers.Id, Couriers.DeliveryServiceId, Couriers.Firstname, Couriers.Surname, Couriers.Phone).Scan(&Couriers.Id)
	if err != nil {
		return 0, err
	}
	return id, nil
}

func (r *postgres) GetCouriers(ctx context.Context, id int) (Courier models.Couriers, err error) {
	q := `SELECT * FROM Orders WHERE id = $1 `
	err = r.db.QueryRow(ctx, q, id).Scan(&Courier.Id, &Courier.DeliveryServiceId, &Courier.Firstname, &Courier.Surname, &Courier.Phone)
	if err != nil {
		return Courier, err
	}
	return Courier, nil
}

func NewPostgresRepository(db *pgxpool.Pool, cfg config.Postgres) Postgres {
	return &postgres{
		db:  db,
		cfg: cfg,
	}
}
