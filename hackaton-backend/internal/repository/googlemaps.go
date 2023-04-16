package repository

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"github.com/Brainsoft-Raxat/hacknu/internal/app/config"
	"github.com/Brainsoft-Raxat/hacknu/pkg/data"
	"io/ioutil"
	"net/http"
	"strings"
	"time"
)

type google struct {
	client *http.Client
}

func NewGoogle(cfg *config.Config) Google {
	transport := http.DefaultTransport.(*http.Transport).Clone()
	transport.TLSClientConfig = &tls.Config{InsecureSkipVerify: true} // nolint:gosec
	httpClient := &http.Client{
		Timeout:   60 * time.Second,
		Transport: transport,
	}
	r := &google{
		client: httpClient,
	}
	return r
}

func (r *google) GetDistance(ctx context.Context, destinationAddress string, destinationHouse string) (distanceResponse data.DistanceResponse, err error) {

	originAddress := "Astana%20Kerey%20and%20Zhanibek%20Khans%204/1"
	destinationAddress = strings.ReplaceAll(destinationAddress, " ", "_")

	url := fmt.Sprintf("https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=%s&destinations=Astana%s%%20%s&key=AIzaSyCUf6GIt3soIsxHxfGmg7jBoh8yN2A57z8", originAddress, destinationAddress, destinationHouse)

	method := "GET"
	req, err := http.NewRequestWithContext(ctx, method, url, nil)

	if err != nil {
		fmt.Println(err)
		return
	}
	res, err := r.client.Do(req)
	if err != nil {
		return
	}
	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Println(err)
		return
	}

	err = json.Unmarshal([]byte(body), &distanceResponse)
	if err != nil {
		panic(err)
	}

	return distanceResponse, nil

}

func (r *google) GetCoordinates(ctx context.Context, street string) (geocodingResponse data.GeocodingResponse, err error) {
	slc := strings.Split(street, ",")
	for i, _ := range slc {
		slc[i] = strings.TrimSpace(slc[i])
		if i == 2 {
			slc[i] = strings.ReplaceAll(slc[i], " ", "%20")
		}
	}

	street = strings.Join(slc, "%20")

	fmt.Println(street)

	url := fmt.Sprintf("https://maps.googleapis.com/maps/api/geocode/json?address=%s&key=AIzaSyCUf6GIt3soIsxHxfGmg7jBoh8yN2A57z8", street)

	method := "GET"
	// Send an HTTP GET request to the API
	httpReq, err := http.NewRequestWithContext(ctx, method, url, nil)
	if err != nil {
		return
	}

	resp, err := r.client.Do(httpReq)
	if err != nil {
		return
	}

	defer resp.Body.Close()

	// Decode the JSON response from the API
	err = json.NewDecoder(resp.Body).Decode(&geocodingResponse)
	if err != nil {
		return geocodingResponse, err
	}

	return geocodingResponse, nil
}
