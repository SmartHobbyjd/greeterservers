FROM rust:latest

WORKDIR /rust_service

# Copy the contents of your Rust project into the Docker container
COPY . .

# Build your Rust application
RUN cargo install --path .

EXPOSE 50052

CMD ["name_of_your_executable"]

