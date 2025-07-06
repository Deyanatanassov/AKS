# Deploy AKS with Azure CNI Overlay and Public API Server

This example demonstrates how to create an AKS cluster using the Azure CNI overlay network plugin. The API server remains publicly accessible via the standard load balancer.

## Requirements

* [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) `2.49` or newer
* `kubectl`
* An Azure subscription with permission to create resource groups and AKS clusters

## Usage

Set the following environment variables or modify them directly in the script:

```bash
export AKS_RG=myOverlayRG
export AKS_NAME=myOverlayCluster
export AKS_LOCATION=eastus
export AKS_NODE_COUNT=3
export AKS_NODE_SIZE=Standard_DS2_v2
export AKS_POD_CIDR=10.240.0.0/16
```

Run the Bash deployment script:

```bash
./deploy-overlay.sh
```

The script will create the resource group, deploy the cluster and configure your kubeconfig. After it completes you can verify the deployment with `kubectl get nodes`.

### Using the Azure Python SDK

Alternatively you can deploy using the provided Python script. Ensure the
[`azure-identity`](https://pypi.org/project/azure-identity/) and
[`azure-mgmt-containerservice`](https://pypi.org/project/azure-mgmt-containerservice/)
packages are installed, then run:

```bash
python deploy_overlay.py
```

## Deploy using Bicep

For repeatable deployments you can use the accompanying `main.bicep` file. It
creates the resource group, a Log Analytics workspace for monitoring and the AKS
cluster with Azure CNI overlay networking.

Deploy the Bicep template at the subscription scope:

```bash
az deployment sub create \
  --location $AKS_LOCATION \
  --template-file main.bicep \
  --parameters resourceGroupName=$AKS_RG \
               clusterName=$AKS_NAME \
               location=$AKS_LOCATION \
               nodeCount=$AKS_NODE_COUNT \
               nodeSize=$AKS_NODE_SIZE \
               podCidr=$AKS_POD_CIDR
```

After deployment, fetch credentials with:

```bash
az aks get-credentials --resource-group $AKS_RG --name $AKS_NAME
```



