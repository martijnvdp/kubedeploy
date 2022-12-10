![cluster-api](https://www.vxav.fr/img/capv-diagram_1.png)
## requirements
- esxi server 
- install ova templates from : https://github.com/kubernetes-sigs/cluster-api-provider-vsphere/blob/main/README.md#kubernetes-versions-with-published-ovas
- or build your own https://github.com/kubernetes-sigs/image-builder

## deploy
start powershell import module `import-module .\vsphere-cluster-api.psd1`
- edit clusterctl.yaml
- deploy cluster with `deploy-K8Cluster`
- get kubeconfig `get-KubeConfig clustername`

## post deploy
- install a CNI to get the nodes ready

## cleanup
cleanup: `unpublish-K8Cluster

## accessing nodes
`ssh capv@nodeip` (when a public ssh key has been specified in clusterctl.yaml)

## refs
https://github.com/kubernetes-sigs/cluster-api-provider-vsphere/blob/main/docs/getting_started.md#creating-a-test-management-cluster
ttps://github.com/kubernetes-sigs/image-builder
