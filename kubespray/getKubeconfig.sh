scp $USERNAME@$IP_CONTROLLER_0:/etc/kubernetes/admin.conf kubespray-do.conf
read -p "enter controller node ip: " controlIP
sed -i s/127.0.0.1:6443/$controlIP:6443/g kubespray-do.conf
export KUBECONFIG=$PWD/kubespray-do.conf
