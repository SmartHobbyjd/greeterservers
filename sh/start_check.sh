chmod +x sh/steps/grpc.sh sh/steps/client_service.sh sh/steps/client_service_go.sh sh/steps/go_service.sh sh/steps/python_service.sh sh/steps/rust_service.sh sh/steps/docker.sh


./sh/check_versions.sh
./sh/hello_world.sh
./sh/create_services.sh
# Prompt the user for input
read -p "Do you want to perform 'git push' before starting? (yes/no): " gitPushOption

# Check the user's response
if [[ "$gitPushOption" == "yes" ]]; then
    # Execute 'git push' if the user chooses yes
git status
git add .
git commit -m "Project updated"
git push
elif [[ "$gitPushOption" == "no" ]]; then
    echo "Skipping 'git push'."
else
    echo "Invalid option. Please enter 'yes' or 'no'."
fi
./sh/run_services.sh