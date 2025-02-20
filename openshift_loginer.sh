#!/bin/bash

# List your cluster name here. Do not add protocols or port.
OPENSHIFT_CLUSTERS=(
    "openshift-prod-eu1.example.com"
    "openshift-prod-eu2.example.com"
    "openshift-prod-asia.example.com"
    "openshift-dev.example.com"
)

# Prompt for username and password
echo -n "Username: "
read -r username

echo -n "Password: "
read -rs password

# Loop over each OpenShift API URL

for cluster in "${OPENSHIFT_CLUSTERS[@]}"; do
    echo -e "\nLogging in to $cluster..."
    # Attempt to log in using oc login
    if oc login -s "https://api.${cluster}:6443" -u "$username" -p "$password" >/dev/null; then
        echo "Successfully logged in to $cluster"
    else
        echo "Failed to log in to $cluster"
    fi
done
