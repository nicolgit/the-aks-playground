<h1 align="center">the AKS (Azure Kubernetes Service)🤯 playground </h1>

<div align="center">
  <sub>Built with ❤︎ by
  <a href="https://github.com/nicolgit">nicolgit</a>,  <a href="https://github.com/lucapisano">lucapisano</a> and  <a href="https://github.com/mela125">mela125</a>
  </a>
</div>

[DRAWIO FILE HERE]

This repo contains a preconfigured Azure Kubernetes Service cluster embedded inside an hub-and-spoke network topology, aligned to the Azure enterprise-scale landing zone reference architecture, useful for testing and studying network configurations in a controlled, repeatable environment.

As bonus many scenarios with step-by-step solutions for studying and learning are also available.

The "playground" is composed by:
  * a hub and spoke network topologies aligned with the <a href="https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/architecture" target="_blank">Microsoft Enterprise scale landing zone</a> reference architecture
  * an AKS cluster deployed in one spoke
  * routing table(s) and firewall policy configured so that all the AKS outbound traffic is routed through the firewall

# Deploy to Azure

You can use the following button to deploy the demo to your Azure subscription:

| | &nbsp; | &nbsp; |
|---|---|---|
|1| the **AKS** playground<br/><sub>deploys `hub-lab-net` spokes `01`-`02`-`03` and an `AKS Cluster` | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](http://www.google.com)


# Architecture

This diagram shows a detailed version with also all subnets, virtual machines, NVAs, IPs and Firewalls.

[DRAWIO detailed schema]

the ARM template [xxx](hub-01-bicep/xxx.json) deploys:

* 4 Azure Virtual Networks:
    * `hub-lab-net` with 4 subnets:
        * default subnet: this subnet is used to connect the hub-vm-01 machine
        * AzureFirewallSubet: this subnet is used by Azure Firewall
        * AzureBastionSubnet: this subnet is used bu Azure Bastion
        * GatewaySubnet: this subnet is used by Azure Gateway
    * `spoke-01` with 2 subnets 
    * `spoke-02` with 2 subnets 
    * `spoke-03` with 2 subnets and located in North Europe
* An Azure Firewall **premium** on the `hub-lab-net`  network
* `aks-01`: an Azure Kubernetes cluster deployed on a `spoke-01` subnet

