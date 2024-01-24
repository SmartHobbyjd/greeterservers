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

