package app

import (
	"context"
	"github.com/Brainsoft-Raxat/hacknu/internal/app/config"
	"github.com/Brainsoft-Raxat/hacknu/internal/app/conn"
	"github.com/Brainsoft-Raxat/hacknu/internal/handler"
	"github.com/Brainsoft-Raxat/hacknu/internal/repository"
	"github.com/Brainsoft-Raxat/hacknu/internal/repository/connection"
	"github.com/Brainsoft-Raxat/hacknu/internal/service"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/sirupsen/logrus"
)

func Run(filenames ...string) {
	cfg, err := config.New(filenames...)
	if err != nil {
		panic(err)
	}

	e := echo.New()
	log := logrus.New()
	e.Use(middleware.Recover())
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogURI:    true,
		LogStatus: true,
		LogValuesFunc: func(c echo.Context, values middleware.RequestLoggerValues) error {
			log.WithFields(logrus.Fields{
				"method": c.Request().Method,
				"URI":    values.URI,
				"status": values.Status,
			}).Info()

			return nil
		},
	}))

	ctx := context.Background()

	db, err := connection.DialPostgres(ctx, cfg.Postgres)
	if err != nil {
		logrus.Fatalf("unable to connect to postgres: %v", err)
	}

	repos := repository.New(conn.Conn{
		DB: db,
	}, cfg)
	services := service.New(repos)
	handlers := handler.New(services)
	handlers.Register(e)

	//person, err := repos.Egov.GetPersonData(ctx, "020302551191")
	//if err != nil {
	//	fmt.Println(err)
	//}
	//
	//fmt.Println(person)
	//resp, err := repos.Egov.GetRequestData(ctx, models.GetRequestDataRequest{
	//	RequestID: "002241054097",
	//	IIN:       "860904350504",
	//})
	//if err != nil {
	//	fmt.Println(err.Error())
	//} else {
	//	fmt.Println(resp)
	//}
	//
	//os.Exit(1)

	//_, err = services.OrderService.DocumentReady(ctx, data.DocumentReadyRequest{
	//	Id:    "1234564",
	//	IIN:   "02030255191",
	//	Phone: "77073946626",
	//})
	//if err != nil {
	//	fmt.Println(err.Error())
	//}

	//rp, err := repos.Google.GetCoordinates(ctx, "Kazakhstan, Astana, Kenesary 9")
	//if err != nil {
	//	fmt.Println(err)
	//}

	//fmt.Printf("Latitude: %f, Longitude: %f\n", rp.Results[0].Geometry.Location.Lat, rp.Results[0].Geometry.Location.Lng)

	e.Logger.Fatal(e.Start(":" + cfg.Port))
}
