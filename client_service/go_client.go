// client_service/go_client/go_client.go

package go_client

import (
    "context"
    "log"
    "go_service/proto/greetings" // Import the generated Go code
    "google.golang.org/grpc"
)

// GoClient represents the Go client for communication with the Go server.
type GoClient struct {
    conn    *grpc.ClientConn
    client  greetings.GreeterClient
}

// NewGoClient initializes a new Go client.
func NewGoClient(serverAddress string) (*GoClient, error) {
    conn, err := grpc.Dial(serverAddress, grpc.WithInsecure())
    if err != nil {
        return nil, err
    }

    client := greetings.NewGreeterClient(conn)
    return &GoClient{
        conn:    conn,
        client:  client,
    }, nil
}

// Close closes the connection to the server.
func (gc *GoClient) Close() {
    if gc.conn != nil {
        gc.conn.Close()
    }
}

// SendRequest sends a request to the Go server and returns the response message.
func (gc *GoClient) SendRequest() (string, error) {
    // Create a context for the request
    ctx := context.Background()

    // Send the request to the Go server
    response, err := gc.client.SayHi(ctx, &greetings.HelloReply{
        Message: "Hello from Go Client",
    })
    if err != nil {
        log.Printf("Go server communication error: %v", err)
        return "", err
    }

    return response.Message, nil
}
