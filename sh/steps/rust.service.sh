# Create Rust service file
cat <<'EOF' > rust_service/src/main.rs
use tonic::{transport::Server, Request, Response, Status};

pub mod hello_world {
    tonic::include_proto!("greetings");
}

use hello_world::{
    greeter_server::{Greeter, GreeterServer},
    HelloRequest, HelloReply, ThankYouRequest, WelcomeReply,
};

#[derive(Default)]
pub struct MyGreeter {}

#[tonic::async_trait]
impl Greeter for MyGreeter {
    async fn say_hello(
        &self,
        request: Request<HelloRequest>,
    ) -> Result<Response<HelloReply>, Status> {
        // Handle the SayHello RPC request here
        let name = request.into_inner().name;
        let response = HelloReply {
            message: format!("Hi, {}! (Rust)", name),
        };
        Ok(Response::new(response))
    }

    async fn say_hi(
        &self,
        request: Request<HelloReply>,
    ) -> Result<Response<HelloReply>, Status> {
        // Handle the SayHi RPC request here
        let message = request.into_inner().message;
        let response = HelloReply {
            message: format!("Hi back, {}! (Rust)", message),
        };
        Ok(Response::new(response))
    }

    async fn say_thank_you(
        &self,
        request: Request<ThankYouRequest>,
    ) -> Result<Response<WelcomeReply>, Status> {
        // Handle the SayThankYou RPC request here
        let message = request.into_inner().message;
        let response = WelcomeReply {
            message: format!("You're welcome, {}! (Rust)", message),
        };
        Ok(Response::new(response))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50052".parse()?;
    let greeter = MyGreeter::default();

    // Create the gRPC server and serve Greeter services
    Server::builder()
        .add_service(GreeterServer::new(greeter))
        .serve(addr)
        .await?;

    Ok(())
}
EOF

# Create build.rs file for Rust service
cat <<'EOF' > rust_service/build.rs
fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::compile_protos("../proto/greetings.proto")?;
    Ok(())
}
EOF

# Create Cargo.toml for Rust service
cat <<EOF > rust_service/Cargo.toml
[package]
name = "rust_service"
version = "0.1.0"
edition = "2021"

[dependencies]
tonic = "0.6"
prost = "0.9"
tokio = { version = "1", features = ["full"] }

[build-dependencies]
tonic-build = "0.6"
EOF