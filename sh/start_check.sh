chmod +x sh/steps/grpc.sh sh/steps/client_service.sh sh/steps/client_service_go.sh sh/steps/go_service.sh sh/steps/python_service.sh sh/steps/rust_service.sh sh/steps/docker.sh


./check_versions.sh
./hello_world.sh
./create_services.sh
git status
git add .
git commit -m "Project updated"
git push
./run_services.sh