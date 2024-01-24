# Create Python service file
cat <<'EOF' > python_service/main.py
import grpc
from greetings_pb2 import HelloRequest, HelloReply, ThankYouRequest
from greetings_pb2_grpc import GreeterStub

def run_python_client():
    # Create channels for the Rust and Go services
    rust_channel = grpc.insecure_channel('localhost:50052')
    go_channel = grpc.insecure_channel('localhost:50051')

    # Create Greeter clients for the Rust and Go services
    rust_client = GreeterStub(rust_channel)
    go_client = GreeterStub(go_channel)

    # Send requests to the Rust service
    rust_request = HelloRequest(name="Python to Rust")
    rust_response = rust_client.SayHello(rust_request)
    print(f"Response from Rust: {rust_response.message}")

    # Send requests to the Go service
    go_request = HelloReply(message="Python to Go")
    go_response = go_client.SayHi(go_request)
    print(f"Response from Go: {go_response.message}")

    # Send a request to the Rust service
    rust_thank_you_request = ThankYouRequest(message="Thanks from Python to Rust")
    rust_thank_you_response = rust_client.SayThankYou(rust_thank_you_request)
    print(f"Response from Rust: {rust_thank_you_response.message}")

if __name__ == "__main__":
    run_python_client()
EOF