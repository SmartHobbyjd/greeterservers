// client_service_go/main.go
package main

import (
    "fmt"
    "log"
    "client_service/go_client"
    "client_service/sqlite_handler"
)

func main() {
    // Initialize the GoClient with the address of your Go server
    goServerAddress := "localhost:50051" // Change to your Go server's address
    goClient, err := go_client.NewGoClient(goServerAddress)
    if err != nil {
        log.Fatalf("Failed to initialize Go client: %v", err)
    }
    defer goClient.Close()

    // Initialize SQLite database
    db, err := sqlite_handler.InitializeDB()
    if err != nil {
        log.Fatalf("Failed to initialize SQLite: %v", err)
    }
    defer db.Close()

    // Loop to continuously send requests and handle responses
    for {
        // Send a request to the Go server using the GoClient
        goResponse, err := goClient.SendRequest()
        if err != nil {
            log.Printf("Go server communication error: %v", err)
        }

        // Display the Go server's response
        fmt.Printf("Go server response: %s\n", goResponse)

        // Store communication in SQLite
        if err := sqlite_handler.StoreCommunication(db, "Go", goResponse); err != nil {
            log.Printf("Failed to store communication in SQLite: %v", err)
        }

        // Add logic to control the rate of communication or exit the loop based on success criteria
    }
}
