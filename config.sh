sed -i -r 's/^(container_manager:).*/\1 containerd/g' inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml
sed -i -r 's/^(kube_network_plugin:).*/\1 cni/g' inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml
sed -i -r 's/^(etcd_deployment_type:).*/\1 host/g' inventory/sample/group_vars/etcd.yml
echo "kube_proxy_remove: true" >> inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml
