kind create cluster
cp .\clusterctl-template.yaml ~/.cluster-api/clusterctl.yaml
clusterctl init --infrastructure vsphere

clusterctl generate cluster management `
    --infrastructure vsphere `
    --kubernetes-version v1.21.1 `
    --control-plane-machine-count 1 `
    --worker-machine-count 2 > cluster.yaml
pause
kubectl apply -f .\cluster.yaml
