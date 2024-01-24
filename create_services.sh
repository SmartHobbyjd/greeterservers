#!/bin/bash

# Delete existing directories
rm -rf go_service rust_service python_service proto rust_service/src .github/workflows client_service client_service/go_client client_service/sqlite_handler
# Create directories
mkdir -p go_service rust_service python_service proto rust_service/src .github/workflows client_service client_service/go_client client_service/sqlite_handler

# Create .proto file
cat <<'EOF' > proto/greetings.proto
syntax = "proto3";

package greetings;

// Specify the Go package for the generated code.
option go_package = "go_service/proto/greetings";

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
  rpc SayHi (HelloReply) returns (HelloReply) {}
  rpc SayThankYou (ThankYouRequest) returns (WelcomeReply) {}
}

message HelloRequest {
  string name = 1;
}

message HelloReply {
  string message = 1;
}

message ThankYouRequest {
  string message = 1;
}

message WelcomeReply {
  string message = 1;
}

EOF

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

# Create Go service file
cat <<'EOF' > go_service/main.go
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
EOF

# Create Rust service file
cat <<'EOF' > rust_service/src/main.rs
use tonic::{transport::Server, Request, Response, Status};

pub mod hello_world {
    tonic::include_proto!("greetings");
}

use hello_world::{
    greeter_server::{Greeter, GreeterServer},
    HelloRequest, HelloReply, ThankYouRequest, WelcomeReply,
};

#[derive(Default)]
pub struct MyGreeter {}

#[tonic::async_trait]
impl Greeter for MyGreeter {
    async fn say_hello(
        &self,
        request: Request<HelloRequest>,
    ) -> Result<Response<HelloReply>, Status> {
        // Handle the SayHello RPC request here
        let name = request.into_inner().name;
        let response = HelloReply {
            message: format!("Hi, {}! (Rust)", name),
        };
        Ok(Response::new(response))
    }

    async fn say_hi(
        &self,
        request: Request<HelloReply>,
    ) -> Result<Response<HelloReply>, Status> {
        // Handle the SayHi RPC request here
        let message = request.into_inner().message;
        let response = HelloReply {
            message: format!("Hi back, {}! (Rust)", message),
        };
        Ok(Response::new(response))
    }

    async fn say_thank_you(
        &self,
        request: Request<ThankYouRequest>,
    ) -> Result<Response<WelcomeReply>, Status> {
        // Handle the SayThankYou RPC request here
        let message = request.into_inner().message;
        let response = WelcomeReply {
            message: format!("You're welcome, {}! (Rust)", message),
        };
        Ok(Response::new(response))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50052".parse()?;
    let greeter = MyGreeter::default();

    // Create the gRPC server and serve Greeter services
    Server::builder()
        .add_service(GreeterServer::new(greeter))
        .serve(addr)
        .await?;

    Ok(())
}
EOF

# Create build.rs file for Rust service
cat <<'EOF' > rust_service/build.rs
fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::compile_protos("../proto/greetings.proto")?;
    Ok(())
}
EOF

# Create Cargo.toml for Rust service
cat <<EOF > rust_service/Cargo.toml
[package]
name = "rust_service"
version = "0.1.0"
edition = "2021"

[dependencies]
tonic = "0.6"
prost = "0.9"
tokio = { version = "1", features = ["full"] }

[build-dependencies]
tonic-build = "0.6"
EOF

# Create Python service file
cat <<'EOF' > python_service/main.py
import grpc
from greetings_pb2 import HelloRequest, HelloReply, ThankYouRequest
from greetings_pb2_grpc import GreeterStub

def run_python_client():
    # Create channels for the Rust and Go services
    rust_channel = grpc.insecure_channel('localhost:50052')
    go_channel = grpc.insecure_channel('localhost:50051')

    # Create Greeter clients for the Rust and Go services
    rust_client = GreeterStub(rust_channel)
    go_client = GreeterStub(go_channel)

    # Send requests to the Rust service
    rust_request = HelloRequest(name="Python to Rust")
    rust_response = rust_client.SayHello(rust_request)
    print(f"Response from Rust: {rust_response.message}")

    # Send requests to the Go service
    go_request = HelloReply(message="Python to Go")
    go_response = go_client.SayHi(go_request)
    print(f"Response from Go: {go_response.message}")

    # Send a request to the Rust service
    rust_thank_you_request = ThankYouRequest(message="Thanks from Python to Rust")
    rust_thank_you_response = rust_client.SayThankYou(rust_thank_you_request)
    print(f"Response from Rust: {rust_thank_you_response.message}")

if __name__ == "__main__":
    run_python_client()
EOF

# Create utils/api.js file
cat <<'EOF' > client_service/utils/api.js
// utils/api.js
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8585'; // Update with your Go client service address

const api = axios.create({
  baseURL: API_BASE_URL,
});

export const sendRequestToGo = async () => {
  try {
    const response = await api.get('/go-endpoint'); // Update with your actual endpoint
    return response.data;
  } catch (error) {
    console.error('Error sending request to Go:', error);
    throw error;
  }
};

// Repeat similar steps for Rust and Python endpoints
EOF

# Create client_service/pages/index.js file
cat <<'EOF' > client_service/pages/index.js
// pages/index.js
import React from 'react';
import { useQuery } from 'react-query';
import { sendRequestToGo } from '../utils/api';

const HomePage = () => {
  const { data, error, isLoading } = useQuery('goData', sendRequestToGo);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error loading data</div>;
  }

  return (
    <div>
      <h1>Data from Go Service</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
};

export default HomePage;
EOF

# List all files with names and extensions
echo -e "\nList of Files:"
find go_service rust_service python_service proto -type f -exec basename {} \;

# Create Docker Compose file
cat <<'EOF' > docker-compose.yml
version: '3.8'
services:
  go_service:
    build:
      context: .
      dockerfile: go_service/Dockerfile
    ports:
      - "50051:50051"
    container_name: go_service_container

  rust_service:
    build:
      context: .
      dockerfile: rust_service/Dockerfile
    ports:
      - "50052:50052"
    container_name: rust_service_container

  python_service:
    build:
      context: .
      dockerfile: python_service/Dockerfile
    ports:
      - "50053:50053"
    container_name: python_service_container

  client_service:
    build:
      context: .
      dockerfile: client_service/Dockerfile
    ports:
      - "3000:3000"
    container_name: client_service_container


EOF

  #go_client_service:
  #  build:
  #    context: .
  #    dockerfile: client_service/Dockerfile  # Specify the path to your Go client Dockerfile
  #  ports:
  #    - "8585:8585"  # Specify the desired port for your Go client
  #  container_name: go_client_container
  #  depends_on:
  #    - go_service  # Ensure that the Go client service starts after the Go server service

# Create .github/workflows/ci.yml file
cat <<'EOF' > .github/workflows/ci.yml
name: Continuous Integration

on:
  push:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Repository
      uses: actions/checkout@v2

    - name: Set up Go
      uses: actions/setup-go@v2
      with:
        go-version: '^1.20'

    - name: Build Go Service
      run: |
        cd go_service
        go build

    - name: Build Client Service
      run: |
        cd client_service
        go build

    - name: Build Python Service
      run: |
        cd python_service
        pip install -r requirements.txt
        python -m grpc_tools.protoc -I ../proto --python_out=. --grpc_python_out=. ../proto/greetings.proto

    - name: Build Rust Service
      uses: actions-rs/cargo@v1
      with:
        command: build
        args: --manifest-path rust_service/Cargo.toml

    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '14'

    - name: Build Next.js App
      run: |
        cd client_service
        npm install
        npm run build

    - name: Dockerize Next.js App
      run: |
        cd client_service
        docker build -t client_service:latest .

EOF

cd client_service
go mod init client_service
#go mod tidy
cd ..

cd go_service
 # Initialize Go module
 go mod init go_service

 # Install Go dependencies
 go get google.golang.org/grpc

 go get github.com/golang/protobuf/protoc-gen-go

    # Move generated Go files to the go_service directory
    #mv ./proto/greetings.pb.go go_service/
    #mv ./proto/greetings_grpc.pb.go go_service/
cd ..

    # Compile .proto file for Go
    #protoc --go_out=plugins=grpc:go_service proto/greetings.proto
    protoc --go_out=. --go-grpc_out=. proto/greetings.proto


cd python_service
# Create requirements.txt file
touch requirements.txt

# Install Python dependencies using pip3
pip3 install grpcio
pip3 install grpcio-tools

# Compile .proto file for Python
#python3 -m grpc_tools.protoc -Iproto --python_out=python_service --grpc_python_out=python_service proto/greetings.proto

python3 -m grpc_tools.protoc -I../proto --python_out=. --grpc_python_out=. ../proto/greetings.proto
cd ..

docker ps -a
docker-compose down

# Create client_service Dockerfile
#cat <<'EOF' > client_service/Dockerfile
# Use an official Golang runtime as a parent image
#FROM golang:latest

#WORKDIR /client_service

# Copy the Go module files
#COPY go.mod .
#COPY go.sum .

# Copy the entire project
#COPY . .

# Build the Go application
#RUN go build -o main .

#EXPOSE 8585

#CMD ["./main"]

#EOF

# Create client_service Dockerfile
cat <<'EOF' > client_service/Dockerfile
# Use the official Node.js LTS image as the base image
FROM node:lts-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the Next.js application
RUN npm run build

# Use a lighter-weight image for production
FROM node:lts-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the build artifacts from the build stage to the final image
COPY --from=build /app/.next ./.next
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./

# Expose the port on which the application will run
EXPOSE 3000

# Start the Next.js application
CMD ["npm", "start"]
EOF

# Create go_service Dockerfile
cat <<'EOF' > go_service/Dockerfile
FROM golang:latest

WORKDIR /go_service

# Copy the Go module files and download dependencies
COPY ./go_service/go.mod ./go_service/go.sum ./
RUN go mod download

# Copy the entire service code
COPY ./go_service/ .

# Build the application
RUN go build -o main .

EXPOSE 50051

CMD ["./main"]

EOF

# Create Python service Dockerfile
cat <<'EOF' > python_service/Dockerfile
FROM python:3.9

WORKDIR /python_service

# Copy the requirements.txt file into the container
COPY ./python_service/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your Python service's files into the container
COPY ./python_service/ .

EXPOSE 50053

CMD ["python", "./main.py"]

EOF

# Create Rust service Dockerfile
cat <<'EOF' > rust_service/Dockerfile
FROM rust:latest

WORKDIR ./rust_service

# Copy the contents of your Rust project into the Docker container
COPY ./rust_service/ .

# Build your Rust application
RUN cargo install --path .

EXPOSE 50052

CMD ["rust","./src/main.rs"]

EOF
