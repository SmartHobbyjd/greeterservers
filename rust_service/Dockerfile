FROM rust:latest

WORKDIR ./rust_service

# Copy the contents of your Rust project into the Docker container
COPY ./rust_service/ .

# Build your Rust application
RUN cargo install --path .

EXPOSE 50052

CMD ["rust","./src/main.rs"]

