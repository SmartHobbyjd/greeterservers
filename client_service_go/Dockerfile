# Use an official Golang runtime as a parent image
FROM golang:latest

WORKDIR /client_service_go

# Copy the Go module files
COPY go.mod .
COPY go.sum .

# Copy the entire project
COPY . .

# Build the Go application
RUN go build -o main .

EXPOSE 8585

CMD ["./main"]

