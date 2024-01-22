FROM rust:latest

WORKDIR /rust_service

COPY . .

RUN cargo install --path .

EXPOSE 50052

CMD ["rust_service"]
