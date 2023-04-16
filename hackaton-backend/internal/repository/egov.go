package repository

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/Brainsoft-Raxat/hacknu/internal/app/config"
	"github.com/Brainsoft-Raxat/hacknu/internal/models"
	"io/ioutil"
	"net/http"
	"strings"
	"sync"
	"time"
)

type egov struct {
	client *http.Client
	token  string
	mutex  sync.Mutex
}

func NewEgov(cfg *config.Config) Egov {
	transport := http.DefaultTransport.(*http.Transport).Clone()
	//transport.Proxy = http.ProxyFromEnvironment
	transport.TLSClientConfig = &tls.Config{InsecureSkipVerify: true} // nolint:gosec
	httpClient := &http.Client{
		Timeout:   60 * time.Second,
		Transport: transport,
	}

	r := &egov{
		client: httpClient,
		mutex:  sync.Mutex{},
	}

	token, err := r.GetToken(context.Background())
	if err != nil {
		panic(err)
	}

	r.token = token
	return r
}

func (r *egov) GetToken(ctx context.Context) (token string, err error) {
	url := "http://hakaton-idp.gov4c.kz/auth/realms/con-web/protocol/openid-connect/token"
	method := "POST"

	payload := strings.NewReader("username=test-operator&password=DjrsmA9RMXRl&client_id=cw-queue-service&grant_type=password")

	req, err := http.NewRequestWithContext(ctx, method, url, payload)

	if err != nil {
		return
	}
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	res, err := r.client.Do(req)
	if err != nil {
		return
	}
	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return
	}

	var auth models.Auth
	err = json.Unmarshal(body, &auth)
	if err != nil {
		return
	}

	r.mutex.Lock()
	r.token = auth.AccessToken
	token = auth.AccessToken
	r.mutex.Unlock()

	return
}

func (r *egov) GetPersonData(ctx context.Context, iin string) (person models.Person, err error) {
	url := "http://hakaton-fl.gov4c.kz/api/persons/" + iin
	method := "GET"

	req, err := http.NewRequestWithContext(ctx, method, url, nil)
	if err != nil {
		return
	}

REQ:
	req.Header.Add("Authorization", "Bearer "+r.token)

	res, err := r.client.Do(req)
	if err != nil {
		return
	}

	if res.StatusCode == http.StatusUnauthorized || res.StatusCode == http.StatusForbidden {
		_, getTokenErr := r.GetToken(ctx)
		if getTokenErr != nil {
			return
		}

		goto REQ
	} else if res.StatusCode != http.StatusOK {
		return person, errors.New(res.Status)
	}

	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return
	}

	err = json.Unmarshal(body, &person)
	if err != nil {
		return
	}

	return
}

func (r *egov) SendSMS(ctx context.Context, msg models.SendSMSRequest) (err error) {
	url := "http://hak-sms123.gov4c.kz/api/smsgateway/send"
	method := "POST"

	byteData, err := json.Marshal(msg)
	if err != nil {
		return
	}

	reader := bytes.NewReader(byteData)
	req, err := http.NewRequestWithContext(ctx, method, url, reader)

	if err != nil {
		return
	}
REQ:
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+r.token)

	res, err := r.client.Do(req)
	if err != nil {
		return
	}
	if res.StatusCode == http.StatusUnauthorized || res.StatusCode == http.StatusForbidden {
		_, getTokenErr := r.GetToken(ctx)
		if getTokenErr != nil {
			return
		}

		goto REQ
	} else if res.StatusCode != http.StatusOK {
		return errors.New(res.Status)
	}

	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return
	}

	resp := models.SendSMSResponse{}
	err = json.Unmarshal(body, &resp)
	if err != nil {
		return err
	}

	if resp.Status == "OK" {
		return nil
	}

	return errors.New(resp.StatusMessage)
}

func (r *egov) GetRequestData(ctx context.Context, request models.GetRequestDataRequest) (response models.GetRequestDataResponse, err error) {
	method := "GET"
	url := fmt.Sprintf("http://89.218.80.61/vshep-api/con-sync-service?requestId=%s&requestIIN=%s&token=eyJG6943LMReKj_kqdAVrAiPbpRloAfE1fqp0eVAJ-IChQcV-kv3gW-gBAzWztBEdFY", request.RequestID, request.IIN)
	req, err := http.NewRequestWithContext(ctx, method, url, nil)

	if err != nil {
		fmt.Println(err)
		return
	}
	req.Header.Add("Cookie", "JSESSIONID=H_1MFsSNbQQn_og0PL-exHkLIVKCaIYuZ_H1dlrp")

	res, err := r.client.Do(req)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(string(body))

	err = json.Unmarshal(body, &response)
	if err != nil {
		return
	}

	return
}

func (r *egov) CheckIIN(ctx context.Context, iin string) (response models.CheckIINResponse, err error) {
	method := "GET"
	url := "http://hakaton.gov4c.kz/api/bmg/check/" + iin
	req, err := http.NewRequestWithContext(ctx, method, url, nil)
	if err != nil {
		fmt.Println(err)
		return
	}

REQ:
	req.Header.Add("Authorization", "Bearer "+r.token)

	res, err := r.client.Do(req)
	if err != nil {
		fmt.Println(err)
		return
	}
	if res.StatusCode == http.StatusUnauthorized || res.StatusCode == http.StatusForbidden {
		_, getTokenErr := r.GetToken(ctx)
		if getTokenErr != nil {
			return
		}

		goto REQ
	} else if res.StatusCode != http.StatusOK {
		return response, errors.New(res.Status)
	}

	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(string(body))

	err = json.Unmarshal(body, &response)
	if err != nil {
		return
	}

	return
}
