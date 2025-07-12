#!/bin/bash

# Script to generate a new cluster-admin user.
# Good enough after a fresh cluster install, and you want to move
# to your own user instead of the default kubeadmin user.

# 1. Ask for username, group name, and cluster name
read -p "Enter user name: " USERNAME
read -p "Enter group name: " GROUPNAME
read -p "Enter cluster name: " CLUSTERNAME

# 2. Create a folder with the name $USERNAME@$CLUSTERNAME
echo "Creating user directory..."
DIR_NAME="${USERNAME}@${CLUSTERNAME}"
mkdir -p "$DIR_NAME"

# 3. Create a private key
echo "Creating private key..."
openssl genrsa -out "$DIR_NAME/${USERNAME}@${CLUSTERNAME}.key" 2048

# 4. Create the CSR
echo "Creating CSR..."
openssl req -new -key "$DIR_NAME/${USERNAME}@${CLUSTERNAME}.key" -out "$DIR_NAME/${USERNAME}@${CLUSTERNAME}.csr" \
    -subj "/CN=${DIR_NAME}/O=${GROUPNAME}"

# 5. Create a base64-encoded CSR for YAML file
BASE64_CSR=$(cat "$DIR_NAME/${USERNAME}@${CLUSTERNAME}.csr" | base64 | tr -d '\n')

# 6. Create the CertificateSigningRequest YAML file
echo "Creating CertificateSigningRequest resource..."
cat <<EOF > "$DIR_NAME/${USERNAME}@${CLUSTERNAME}.csr.yaml"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $DIR_NAME
spec:
  request: $BASE64_CSR
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 315360000  # 1 year (optional)
  usages:
  - client auth
EOF

# 7. Apply the CSR in Kubernetes
echo "Submitting the CertificateSigning Request to the cluster..."
kubectl apply -f "$DIR_NAME/${USERNAME}@${CLUSTERNAME}.csr.yaml"

# 8. Approve the CSR
echo "Approving the CSR..."
kubectl certificate approve "${USERNAME}@${CLUSTERNAME}"

# 9. Retrieve the signed certificate and save it
echo "Retrieving the signed certificate..."
kubectl get csr "${USERNAME}@${CLUSTERNAME}" -o jsonpath='{.status.certificate}' | base64 --decode > "$DIR_NAME/${USERNAME}@${CLUSTERNAME}.crt"

# 10. Generate cluster-role
echo "Creating role for the user..."
kubectl create clusterrolebinding "${USERNAME}"-x-cluster-admin  --clusterrole=cluster-admin --user="${DIR_NAME}"

# 11. Set kubectl credentials
echo "Setting up user credential in kubeconfig..."
kubectl config set-credentials "${DIR_NAME}" \
  --client-certificate="$DIR_NAME/${USERNAME}@${CLUSTERNAME}.crt" \
  --client-key="$DIR_NAME/${USERNAME}@${CLUSTERNAME}.key"

# 12. Set kubectl context for the new user
echo "Setting up new context in kubeconfig..."
kubectl config set-context "${USERNAME}@${CLUSTERNAME}" --cluster="$CLUSTERNAME" --user="${USERNAME}@${CLUSTERNAME}"

# Epilogue
echo "All steps completed. You can use the context using the following command:"
echo ""
echo "kubectl config use-context ${USERNAME}@${CLUSTERNAME}"
