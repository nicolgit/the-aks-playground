# SCENARIO: Deploy a confidential computing cluster nodes

## Pre-requisites

To implement this scenario, you need to install the `AKS-playground` that you find in the home of this repo.

## Solution

In this scenario, You'll use the Azure CLI to deploy an enclave-aware (DCsv2/DCSv3) VM node pool on your AKS cluster. You'll then run a simple Hello World application in the enclave.

* *Secure enclaves* (also known as Trusted Execution Environments or TEE) are at the core of confidential computing. Secure Enclaves are sets of security-related instruction codes built into new CPUs. They protect data in use, because the enclave is decrypted on the fly only within the CPU, and then only for code and data running within the enclave itself. Introduced by Intel as Software Guard Extensions (**SGX**), secure enclaves are based on hardware-level encrypted memory isolation. AMD now offers similar functionality with its SEV technology, built into **Epyc**.
* In a secure enclave, applications run in an environment that is isolated from the host. Memory is completely isolated from anything else on the machine, including the operating system. Private keys are hard-coded at the hardware level. A process called attestation allows enclaves to authenticate the hardware inside which they run as genuine, and to attest to the integrity of enclave memory to a remote party. Secure enclaves protect applications, data, and storage—locally, across the network, and in the cloud—simply and effectively. Application code and data are completely inaccessible to any other entities while running inside a secure enclave. Insiders with root or physical access to the system do not have access to memory. Even privileged users on the guest operating system, hypervisor, or the host operating system are blocked.

Let's proceed: open a BASH cloud shell as onwer of the subscription that contains the `AKS-playground`.

Run the following command to enable the confidential computing add-on:

? va abilitato il monitoring a livello di cluster prima ?

```
myRg="<your resource group name>"
# az aks enable-addons --addons monitoring --name "aks-01" --resource-group $myRg
az aks enable-addons --addons confcom --name "aks-01" --resource-group $myRg
```

Run the following command to add a user node pool of `Standard_DC4s_v3` size with two nodes to the AKS cluster.

```
az aks nodepool add --cluster-name "aks-01" --name confcompool1 --resource-group $myRg --node-vm-size Standard_DC4s_v3 --node-count 2
```

## Test Solution
Get the credentials for your AKS cluster by using the az aks get-credentials command:

```
az aks get-credentials --resource-group $myRg --name "aks-01"
```

Use the kubectl get pods command to verify that the nodes are created properly and the SGX-related DaemonSets are running on DCsv2 node pools:

kubectl get pods --all-namespaces

this row in the output means that SGX-related DaemonSets are properly configured.

```
kube-system     sgx-device-plugin-xxxx     1/1     Running

```

Now deploy the `Hello World from an isolated enclave application`: Create a file named `hello.yaml` and paste in the following YAML manifest.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: sgx-test
  labels:
    app: sgx-test
spec:
  template:
    metadata:
      labels:
        app: sgx-test
    spec:
      containers:
      - name: sgxtest
        image: oeciteam/sgx-test:1.0
        resources:
          limits:
            sgx.intel.com/epc: 5Mi # This limit will automatically place the job into a confidential computing node and mount the required driver volumes. sgx limit setting needs "confcom" AKS Addon as referenced above. 
      restartPolicy: Never
  backoffLimit: 0
```

deploy the sample using:

```
kubectl apply -f hello.yaml
```

wait until the command `kubectl get jobs -l app=sgx-test` gives as result the following: 

```
NAME             READY   STATUS      RESTARTS   AGE
sgx-test-rchvg   0/1     **Completed**   0          25s
```  

`kubectl logs -l app=sgx-test` will show

```
Hello world from the enclave
Enclave called into host to print: Hello World!


```
# More information

* https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-enclave-nodes-aks-get-started  
* https://github.com/openenclave/openenclave/tree/master/samples/helloworld