# SCENARIO: Enable autoscaling

## Pre-requisites

To implement this scenario, you need to install the `AKS-public-playground` that you find in the home of this repo.

what is autoscale
how it works

## Solution

To enable autoscale go to:

Azure Portal > Kubernetes Services > `aks-01` > node pools > `systempool` > autoscaling

configure:
* Scale method: `autoscale`
* minimum nodes: 1
* maximum nodes: 5
* click [apply]
  
# Test autoscale

To test the autoscale we will use Helm to install a number of applications on the cluster.

open https://shell.azure.com (bash) and connect `kubectl` with your cluster

```
rg='the-aks-playground'
az aks get-credentials --resource-group $rg --name aks-01

kubectl get nodes
```
response will be something like

```
NAME                                 STATUS   ROLES   AGE   VERSION
aks-systempool-15151523-vmss000000   Ready    agent   86m   v1.27.9
```

Helm CLI it is already available on cloud shell so the only step to do is connect it to a repository. In this case we will use bitnami and will install drupal from there:

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo list
helm repo update

helm install instance01 bitnami/drupal
```

to check the installation status you can use `kubectl get all`


# more information
* Develop on Azure Kubernetes Service (AKS) with Helm: https://learn.microsoft.com/en-us/azure/aks/quickstart-helm?tabs=azure-cli 
* What is https://helm.sh/ 
* Helm 101 training https://kube.academy/courses/helm-101 
