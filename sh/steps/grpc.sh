# Create .proto file
cat <<'EOF' > proto/greetings.proto
syntax = "proto3";

package greetings;

// Specify the Go package for the generated code.
option go_package = "go_service/proto/greetings";

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
  rpc SayHi (HelloReply) returns (HelloReply) {}
  rpc SayThankYou (ThankYouRequest) returns (WelcomeReply) {}
}

message HelloRequest {
  string name = 1;
}

message HelloReply {
  string message = 1;
}

message ThankYouRequest {
  string message = 1;
}

message WelcomeReply {
  string message = 1;
}

EOF
