package main

import (
    "context"
    "log"
    "net"

    "google.golang.org/grpc"
    pb "proto/greetings"
)

type server struct {
    pb.UnimplementedGreeterServer
}

func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
    return &pb.HelloReply{Message: "Hi from Go"}, nil
}

func main() {
    # Initialize Go module
    go mod init github.com/yourusername/go_service

    # Install Go dependencies
    go get -u google.golang.org/grpc

    # Compile .proto file for Go
    protoc --go_out=plugins=grpc:go_service proto/greetings.proto

    # Move generated Go files to the go_service directory
    mv proto/greetings.pb.go go_service/
    mv proto/greetings_grpc.pb.go go_service/

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
