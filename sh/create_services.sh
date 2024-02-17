#!/bin/bash

# Delete existing directories
rm -rf go_service rust_service python_service proto rust_service/src .github/workflows client_service_go client_service client_service/pages client_service/utils client_service_go/go_client client_service_go/sqlite_handler

# Create directories
mkdir -p go_service rust_service python_service proto rust_service/src .github/workflows client_service_go client_service client_service/pages client_service/utils client_service_go/go_client client_service_go/sqlite_handler

chmod +x sh/steps/grpc.sh sh/steps/client_service.sh sh/steps/client_service_go.sh sh/steps/go_service.sh sh/steps/python_service.sh sh/steps/rust_service.sh sh/steps/docker.sh

./sh/steps/grpc.sh
./sh/steps/client_service.sh
./sh/steps/client_service_go.sh
./sh/steps/go_service.sh
./sh/steps/python_service.sh
./sh/steps/rust_service.sh
./sh/steps/docker.sh


# List all files with names and extensions
echo -e "\nList of Files:"
find go_service rust_service python_service proto -type f -exec basename {} \;

cd client_service_go
go mod init client_service_go
#go mod tidy
cd ..

cd client_service
npm install axios react-query

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
pip3 install --upgrade grpcio grpcio-tools

# Compile .proto file for Python
#python3 -m grpc_tools.protoc -Iproto --python_out=python_service --grpc_python_out=python_service proto/greetings.proto

python3 -m grpc_tools.protoc -I../proto --python_out=. --grpc_python_out=. ../proto/greetings.proto
cd ..

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
        node-version: '148'

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






