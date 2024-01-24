// client_service_go/go_client/go_client.go

// client_service/go_client/go_client.go
package go_client

import (
	"context"
	"log"
	"client_service/unified_client"
	"client_service/proto/greetings"
	"google.golang.org/grpc"
)

type GoClient struct {
	conn   *grpc.ClientConn
	client greetings.GreeterClient
}

func NewGoClient(serverAddress string) (*GoClient, error) {
	conn, err := grpc.Dial(serverAddress, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	client := greetings.NewGreeterClient(conn)
	return &GoClient{
		conn:   conn,
		client: client,
	}, nil
}

func (gc *GoClient) SendGoRequest() (string, error) {
	ctx := context.Background()
	response, err := gc.client.SayHi(ctx, &greetings.HelloReply{
		Message: "Hello from Go Client",
	})
	if err != nil {
		log.Printf("Go server communication error: %v", err)
		return "", err
	}
	return response.Message, nil
}

func (gc *GoClient) Close() {
	if gc.conn != nil {
		gc.conn.Close()
	}
}

