package conn

import "github.com/jackc/pgx/v4/pgxpool"

type Conn struct {
	DB *pgxpool.Pool
}
