# SCENARIO: Deploy Azure Monitor on AKS Cluster

## Pre-requisites

To implement this scenario, you need to install the `AKS-playground` that you find in the home of this repo.

## Solution

In this section we will implement Azure Monitor for Container Insights.
Monitoring is one of the **most important** things that you need to implement, if you want to have a big picture of you infrastructure.

Let's proceed: open a BASH cloud shell as onwer of the subscription that contains the `AKS-playground`.

Run the following command to enable the confidential computing add-on:

```
myRg="<your resource group name>"
myclustername="<your cluster name>"
myworkspaceid="<the id of your workspace>"

# az aks enable-addons -a monitoring -n <cluster-name> -g <cluster-resource-group-name> --workspace-resource-id <workspace-resource-id>
```
Remember that you need to specify the workspace if of your Log Analytics Workspace, an easy way to find that is to look in the section properties of your LAW. or you can use this command line

```
myworkspaceid = az resource list --resource-group "<your resource group name>" --name "<your cluster name>" --query [*].id --output tsv

```


## Test Solution
Get the credentials for your AKS cluster by using the az aks get-credentials command:

```
az aks get-credentials --resource-group $myRg --name "aks-01"
```

and after that, you can run 

```
kubectl get ds ama-logs --namespace=kube-system

```
The output will be very similar to :
```
NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ama-logs   1         1         1       1            1           <none>          138d
```

Now you can go to Azure Monitor and click on Container section.

# More information

* https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-onboard