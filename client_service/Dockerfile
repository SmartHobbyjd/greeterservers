# Use an official Golang runtime as a parent image
FROM golang:latest

# Set the working directory inside the container
WORKDIR /go/src/app

# Copy the local Go code into the container
COPY . .

# Install any dependencies if needed (e.g., go get ...)

# Build the Go application
RUN go build -o main .

# Expose port 8585 for the Go client to listen on
EXPOSE 8585

# Run the Go client on port 8585 when the container starts
CMD ["./main", "-port", "8585"]
