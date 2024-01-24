# Create client_service_go/unified_client/unified_client.go file
cat <<'EOF' > client_service_go/unified_client/unified_client.go
// client_service_go/unified_client/unified_client.go
package unified_client

type UnifiedClient interface {
	SendGoRequest() (string, error)
	SendRustRequest() (string, error)
	SendPythonRequest() (string, error)
	Close()
}
EOF


# Create client_service_go/main.go file
cat <<'EOF' > client_service_go/main.go
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
EOF

# creatin client_service_go/go_client/go_client.go file
cat <<'EOF' > client_service_go/go_client/go_client.go
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

EOF

# Create client_service_go/rust_client/rust_client.go
cat <<'EOF' > client_service_go/rust_client/rust_client.go
// client_service_go/rust_client/rust_client.go
package rust_client

import (
	"context"
	"log"
	"client_service/unified_client"
	"client_service/proto/greetings"
	"google.golang.org/grpc"
)

type RustClient struct {
	conn   *grpc.ClientConn
	client greetings.GreeterClient
}

func NewRustClient(serverAddress string) (*RustClient, error) {
	conn, err := grpc.Dial(serverAddress, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	client := greetings.NewGreeterClient(conn)
	return &RustClient{
		conn:   conn,
		client: client,
	}, nil
}

func (rc *RustClient) SendRustRequest() (string, error) {
	ctx := context.Background()
	response, err := rc.client.SayHi(ctx, &greetings.HelloReply{
		Message: "Hello from Rust Client",
	})
	if err != nil {
		log.Printf("Rust server communication error: %v", err)
		return "", err
	}
	return response.Message, nil
}

func (rc *RustClient) Close() {
	if rc.conn != nil {
		rc.conn.Close()
	}
}
EOF

# Create client_service_go/python_client/python_client.go
cat <<'EOF' > client_service_go/python_client/python_client.go
// client_service_go/python_client/python_client.go
package python_client

import (
	"context"
	"log"
	"client_service/unified_client"
	"client_service/proto/greetings"
	"google.golang.org/grpc"
)

type PythonClient struct {
	conn   *grpc.ClientConn
	client greetings.GreeterClient
}

func NewPythonClient(serverAddress string) (*PythonClient, error) {
	conn, err := grpc.Dial(serverAddress, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	client := greetings.NewGreeterClient(conn)
	return &PythonClient{
		conn:   conn,
		client: client,
	}, nil
}

func (pc *PythonClient) SendPythonRequest() (string, error) {
	ctx := context.Background()
	response, err := pc.client.SayHi(ctx, &greetings.HelloReply{
		Message: "Hello from Python Client",
	})
	if err != nil {
		log.Printf("Python server communication error: %v", err)
		return "", err
	}
	return response.Message, nil
}

func (pc *PythonClient) Close() {
	if pc.conn != nil {
		pc.conn.Close()
	}
}
EOF

# Create client_service_go/sqlite_handler/sqlite_handler.go file
cat <<'EOF' > client_service_go/sqlite_handler/sqlite_handler.go
// client_service_go/sqlite_handler/sqlite_handler.go

package sqlite_handler

import (
    "database/sql"
    "log"
    _ "github.com/mattn/go-sqlite3" // Import SQLite driver
)

// InitializeDB initializes an SQLite database and returns a database connection.
func InitializeDB() (*sql.DB, error) {
    db, err := sql.Open("sqlite3", "client_communication.db")
    if err != nil {
        return nil, err
    }

    // Create a table for storing communication records
    createTableSQL := `
        CREATE TABLE IF NOT EXISTS communication (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            service TEXT NOT NULL,
            message TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    `
    _, err = db.Exec(createTableSQL)
    if err != nil {
        return nil, err
    }

    return db, nil
}

// StoreCommunication stores a communication record in the SQLite database.
func StoreCommunication(db *sql.DB, service, message string) error {
    insertSQL := "INSERT INTO communication (service, message) VALUES (?, ?)"
    _, err := db.Exec(insertSQL, service, message)
    if err != nil {
        log.Printf("Failed to store communication record in SQLite: %v", err)
        return err
    }
    return nil
}

// RetrieveCommunication retrieves communication records from the SQLite database.
func RetrieveCommunication(db *sql.DB) ([]CommunicationRecord, error) {
    query := "SELECT service, message, timestamp FROM communication ORDER BY timestamp ASC"
    rows, err := db.Query(query)
    if err != nil {
        log.Printf("Failed to retrieve communication records from SQLite: %v", err)
        return nil, err
    }
    defer rows.Close()

    var records []CommunicationRecord
    for rows.Next() {
        var record CommunicationRecord
        err := rows.Scan(&record.Service, &record.Message, &record.Timestamp)
        if err != nil {
            log.Printf("Error scanning communication record: %v", err)
            continue
        }
        records = append(records, record)
    }
    return records, nil
}

// CommunicationRecord represents a communication record in the database.
type CommunicationRecord struct {
    Service   string
    Message   string
    Timestamp string
}
EOF
