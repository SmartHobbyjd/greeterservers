FROM rust:latest

WORKDIR /usr/src/app

COPY . .

RUN cargo install --path .

EXPOSE 50052

CMD ["rust_service"]
