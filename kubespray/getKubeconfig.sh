read -p "enter controller node ip: " controlIP
scp ubuntu@$controlIP:/etc/kubernetes/admin.conf kubespray-do.conf
sed -i s/127.0.0.1:6443/$controlIP:6443/g kubespray-do.conf
export KUBECONFIG=$PWD/kubespray-do.conf
