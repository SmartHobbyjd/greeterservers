#!/bin/bash

# Run Go service
echo "Running Go service..."
cd go_service
go run main.go &
GO_PID=$!
cd ..

# Run Rust service
echo "Running Rust service..."
cd rust_service
cargo run &
RUST_PID=$!
cd ..

# Run Python service
echo "Running Python service..."
cd python_service
python3 main.py &
PYTHON_PID=$!
cd ..

# Wait for user input to stop the services
echo "Press Enter to stop services..."
read -r

# Stop the services
echo "Stopping services..."
kill $GO_PID $RUST_PID $PYTHON_PID

# Cleanup
wait $GO_PID $RUST_PID $PYTHON_PID 2>/dev/null
echo "Services stopped."
