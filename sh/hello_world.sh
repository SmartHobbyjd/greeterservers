#!/bin/bash

# Go Hello World
cat <<'EOF' > hello_go.go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF

# Rust Hello World
cat <<'EOF' > hello_rust.rs
fn main() {
    println!("Hello, World!");
}
EOF

# Python Hello World
cat <<'EOF' > hello_python.py
print("Hello, World!")
EOF

# Execute Go
echo -e "\nGo:"
go run hello_go.go

# Execute Rust
echo -e "\nRust:"
rustc hello_rust.rs && ./hello_rust

# Execute Python
echo -e "\nPython:"
python3 hello_python.py

# Clean up
rm hello_go.go hello_rust.rs hello_rust hello_python.py
