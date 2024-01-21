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
