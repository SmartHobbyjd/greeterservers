# Use an official Golang runtime as a parent image
FROM golang:latest

# Set the working directory inside the container
WORKDIR /client_service

# Copy the Go module files
COPY go.mod .
COPY go.sum .

# Copy the rest of the source code
COPY . /client_service .

# Build the Go application
RUN go build -o main .

# Expose port 8585 for the Go client to listen on
EXPOSE 8585

# Run the Go client on port 8585 when the container starts
CMD ["./main", "-port", "8585"]
