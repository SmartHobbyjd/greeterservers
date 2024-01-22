# Use an official Golang runtime as a parent image
FROM golang:latest

WORKDIR /client_service

# Copy the Go module files
COPY go.mod .
COPY go.sum .

# Copy the rest of the source code
COPY . .

# Build the Go application
RUN go build -o main .

EXPOSE 8585

CMD ["./main", "-port", "8585"]

