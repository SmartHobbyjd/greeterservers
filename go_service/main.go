package main

import (
    "context"
    "fmt"
    "log"
    "../proto/greetings" // Updated import path
    "google.golang.org/grpc"
)

func main() {
    // Set up a connection to the server (Rust or Python)
    conn, err := grpc.Dial("[::1]:50052", grpc.WithInsecure())
    if err != nil {
        log.Fatalf("Failed to dial: %v", err)
    }
    defer conn.Close()

    // Create a Greeter client
    client := greetings.NewGreeterClient(conn)

    // Call the SayHello RPC
    helloResponse, err := client.SayHello(context.Background(), &greetings.HelloRequest{
        Name: "YourName",
    })
    if err != nil {
        log.Fatalf("SayHello failed: %v", err)
    }
    fmt.Printf("Response from server: %s\n", helloResponse.Message)

    // Call the SayHi RPC
    hiResponse, err := client.SayHi(context.Background(), &greetings.HelloReply{
        Message: "Hi from Go",
    })
    if err != nil {
        log.Fatalf("SayHi failed: %v", err)
    }
    fmt.Printf("Response from server: %s\n", hiResponse.Message)

    // Call the SayThankYou RPC
    thankYouResponse, err := client.SayThankYou(context.Background(), &greetings.ThankYouRequest{
        Message: "Thanks from Go",
    })
    if err != nil {
        log.Fatalf("SayThankYou failed: %v", err)
    }
    fmt.Printf("Response from server: %s\n", thankYouResponse.Message)
}
