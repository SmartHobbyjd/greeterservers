#!/bin/bash

# Delete existing directories
rm -rf go_service rust_service python_service proto rust_service/src .github/workflows

# Create directories
mkdir -p go_service rust_service python_service proto rust_service/src .github/workflows

# Create .proto file
cat <<'EOF' > proto/greetings.proto
syntax = "proto3";

package greetings;

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

# Create Go service file
cat <<'EOF' > go_service/main.go
package main

import (
    "context"
    "log"
    "net"

    "google.golang.org/grpc"
    pb "github.com/SmartHobbyjd/greeterservers/go_service/proto/greetings"
)

type server struct {
    pb.UnimplementedGreeterServer
}

func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
    return &pb.HelloReply{Message: "Hi from Go"}, nil
}

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }
    s := grpc.NewServer()
    pb.RegisterGreeterServer(s, &server{})
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
EOF
cd go_service
    # Initialize Go module
    go mod init github.com/SmartHobbyjd/greeterservers/go_service

    # Install Go dependencies
    go get -u google.golang.org/grpc

    cd ..

    # Compile .proto file for Go
    protoc --go_out=plugins=grpc:go_service proto/greetings.proto

    # Move generated Go files to the go_service directory
    mv proto/greetings.pb.go go_service/
    mv proto/greetings_grpc.pb.go go_service/

# Create go_service Dockerfile
cat <<'EOF' > go_service/Dockerfile
FROM golang:latest

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o main .

EXPOSE 50051

CMD ["./main"]
EOF

# Create Rust service file
cat <<'EOF' > rust_service/src/main.rs
use tonic::{transport::Server, Request, Response, Status};

pub mod hello_world {
    tonic::include_proto!("greetings");
}

use hello_world::{greeter_server::{Greeter, GreeterServer}, HelloRequest, HelloReply};

#[derive(Default)]
pub struct MyGreeter {}

#[tonic::async_trait]
impl Greeter for MyGreeter {
    async fn say_hello(
        &self,
        request: Request<HelloRequest>,
    ) -> Result<Response<HelloReply>, Status> {
        Ok(Response::new(HelloReply {
            message: format!("Hi from Rust"),
        }))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50052".parse()?;
    let greeter = MyGreeter::default();

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
    tonic_build::compile_protos("proto/greetings.proto")?;
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

# Create Rust service Dockerfile
cat <<'EOF' > rust_service/Dockerfile
FROM rust:latest

WORKDIR /usr/src/app

COPY . .

RUN cargo install --path .

EXPOSE 50052

CMD ["rust_service"]
EOF

# Create Python service file
cat <<'EOF' > python_service/main.py
from concurrent import futures
import grpc
import greetings_pb2
import greetings_pb2_grpc

class Greeter(greetings_pb2_grpc.GreeterServicer):

    def SayHello(self, request, context):
        return greetings_pb2.HelloReply(message='Hi from Python')

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    greetings_pb2_grpc.add_GreeterServicer_to_server(Greeter(), server)
    server.add_insecure_port('[::]:50053')
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
EOF

# Install Python dependencies using pip3
pip3 install grpcio
pip3 install grpcio-tools

# Compile .proto file for Python
python3 -m grpc_tools.protoc -Iproto --python_out=python_service --grpc_python_out=python_service proto/greetings.proto

# Create Python service Dockerfile
cat <<'EOF' > python_service/Dockerfile
FROM python:3.9

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 50053

CMD ["python", "./main.py"]
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
      context: ./go_service
      dockerfile: Dockerfile
    ports:
      - "50051:50051"
    container_name: go_service_container

  rust_service:
    build:
      context: ./rust_service
      dockerfile: Dockerfile
    ports:
      - "50052:50052"
    container_name: rust_service_container

  python_service:
    build:
      context: ./python_service
      dockerfile: Dockerfile
    ports:
      - "50053:50053"
    container_name: python_service_container
EOF

# Create .github/workflows/ci.yml file
cat <<'EOF' > .github/workflows/ci.yml
name: Continuous Integration

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up Go
      uses: actions/setup-go@v2
      with:
        go-version: '^1.20'

    - name: Build Go Service
      run: |
        cd go_service
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
EOF