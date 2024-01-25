docker ps -a
docker-compose down

# Create client_service_go Dockerfile
cat <<'EOF' > client_service_go/Dockerfile
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

EOF

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
EXPOSE 3001

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
      - "3001:3001"
    container_name: client_service_container
  client_service_go:
    build:
      context: .
      dockerfile: client_service_go/Dockerfile  # Specify the path to your Go client Dockerfile
    ports:
      - "8585:8585"  # Specify the desired port for your Go client
    container_name: client_service_go_container
    depends_on:
      - go_service  # Ensure that the Go client service starts after the Go server service    

EOF