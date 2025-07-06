import os
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.containerservice import ContainerServiceClient
from azure.mgmt.containerservice.models import (
    ManagedCluster,
    ManagedClusterAgentPoolProfile,
    ManagedClusterIdentity,
    ManagedClusterAddonProfile,
    ContainerServiceNetworkProfile,
)


def main():
    subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID")
    if not subscription_id:
        raise SystemExit("AZURE_SUBSCRIPTION_ID environment variable is required")

    credential = DefaultAzureCredential()

    rg_name = os.environ.get("AKS_RG", "aks-overlay-rg")
    location = os.environ.get("AKS_LOCATION", "eastus")
    cluster_name = os.environ.get("AKS_NAME", "aks-overlay")
    node_size = os.environ.get("AKS_NODE_SIZE", "Standard_DS2_v2")
    node_count = int(os.environ.get("AKS_NODE_COUNT", "3"))
    pod_cidr = os.environ.get("AKS_POD_CIDR", "10.240.0.0/16")

    resource_client = ResourceManagementClient(credential, subscription_id)
    resource_client.resource_groups.create_or_update(
        rg_name, {"location": location}
    )

    container_client = ContainerServiceClient(credential, subscription_id)

    agent_pool = ManagedClusterAgentPoolProfile(
        name="nodepool1",
        count=node_count,
        vm_size=node_size,
        os_type="Linux",
        mode="System",
        type="VirtualMachineScaleSets",
    )

    network_profile = ContainerServiceNetworkProfile(
        network_plugin="azure",
        network_plugin_mode="overlay",
        pod_cidr=pod_cidr,
        load_balancer_sku="standard",
    )

    addon_profile = ManagedClusterAddonProfile(
        enabled=True,
        config={},
    )

    managed_cluster = ManagedCluster(
        location=location,
        dns_prefix=cluster_name,
        agent_pool_profiles=[agent_pool],
        network_profile=network_profile,
        identity=ManagedClusterIdentity(type="SystemAssigned"),
        addon_profiles={"omsAgent": addon_profile},
    )

    poller = container_client.managed_clusters.begin_create_or_update(
        rg_name, cluster_name, managed_cluster
    )
    poller.result()

    print(f"Cluster {cluster_name} deployed in {rg_name}.")


if __name__ == "__main__":
    main()
