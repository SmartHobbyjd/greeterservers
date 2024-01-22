// client_service/main.go
package main

import (
	"fmt"
	"log"
	"client_service/unified_client"
	"client_service/go_client"
	"client_service/rust_client"
	"client_service/python_client"
	"client_service/sqlite_handler"
	"time"
)

func main() {
	// Initialize the unified clients
	goClient, err := go_client.NewGoClient("localhost:50051")
	if err != nil {
		log.Fatalf("Failed to initialize Go client: %v", err)
	}
	defer goClient.Close()

	rustClient, err := rust_client.NewRustClient("localhost:50052")
	if err != nil {
		log.Fatalf("Failed to initialize Rust client: %v", err)
	}
	defer rustClient.Close()

	pythonClient, err := python_client.NewPythonClient("localhost:50053")
	if err != nil {
		log.Fatalf("Failed to initialize Python client: %v", err)
	}
	defer pythonClient.Close()

	// Initialize SQLite database
	db, err := sqlite_handler.InitializeDB()
	if err != nil {
		log.Fatalf("Failed to initialize SQLite: %v", err)
	}
	defer db.Close()

	// Track the time taken by each server for Go
	startTime := time.Now()

	// Send a request to the Go server using the unified client
	goResponse, err := goClient.SendGoRequest()
	if err != nil {
		log.Printf("Go server communication error: %v", err)
	}

	// Display the Go server's response and time taken
	goDuration := time.Since(startTime)
	fmt.Printf("Go server response: %s\n", goResponse)
	fmt.Printf("Go server response time: %s\n", goDuration)

	// Store communication in SQLite for Go
	if err := sqlite_handler.StoreCommunication(db, "Go", goResponse); err != nil {
		log.Printf("Failed to store communication in SQLite: %v", err)
	}

	// Track the time taken by each server for Rust
	startTime = time.Now()

	// Send a request to the Rust server using the unified client
	rustResponse, err := rustClient.SendRustRequest()
	if err != nil {
		log.Printf("Rust server communication error: %v", err)
	}

	// Display the Rust server's response and time taken
	rustDuration := time.Since(startTime)
	fmt.Printf("Rust server response: %s\n", rustResponse)
	fmt.Printf("Rust server response time: %s\n", rustDuration)

	// Store communication in SQLite for Rust
	if err := sqlite_handler.StoreCommunication(db, "Rust", rustResponse); err != nil {
		log.Printf("Failed to store communication in SQLite: %v", err)
	}

	// Track the time taken by each server for Python
	startTime = time.Now()

	// Send a request to the Python server using the unified client
	pythonResponse, err := pythonClient.SendPythonRequest()
	if err != nil {
		log.Printf("Python server communication error: %v", err)
	}

	// Display the Python server's response and time taken
	pythonDuration := time.Since(startTime)
	fmt.Printf("Python server response: %s\n", pythonResponse)
	fmt.Printf("Python server response time: %s\n", pythonDuration)

	// Store communication in SQLite for Python
	if err := sqlite_handler.StoreCommunication(db, "Python", pythonResponse); err != nil {
		log.Printf("Failed to store communication in SQLite: %v", err)
	}

	// Print the success message after all servers have responded
	fmt.Println("All servers have responded.")
}
