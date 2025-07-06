#!/bin/bash

# Deploy an AKS cluster using Azure CNI overlay with a public API server.
# Requires Azure CLI and kubectl to be installed and logged in.

set -euo pipefail

# Configuration. These can be overridden with environment variables.
RESOURCE_GROUP="${AKS_RG:-aks-overlay-rg}"
CLUSTER_NAME="${AKS_NAME:-aks-overlay}"
LOCATION="${AKS_LOCATION:-eastus}"
NODE_SIZE="${AKS_NODE_SIZE:-Standard_DS2_v2}"
NODE_COUNT="${AKS_NODE_COUNT:-3}"
POD_CIDR="${AKS_POD_CIDR:-10.240.0.0/16}"

# Create resource group if it doesn't exist
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Create the AKS cluster
az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --location "$LOCATION" \
  --node-count "$NODE_COUNT" \
  --node-vm-size "$NODE_SIZE" \
  --enable-managed-identity \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --pod-cidr "$POD_CIDR" \
  --load-balancer-sku standard \
  --generate-ssh-keys

# Fetch cluster credentials
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME"

echo "Cluster $CLUSTER_NAME deployed in $RESOURCE_GROUP."

