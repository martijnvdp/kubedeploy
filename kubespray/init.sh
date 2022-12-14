git clone https://github.com/kubernetes-sigs/kubespray.git
mkdir inventory
cp -rfp kubespray/inventory/sample inventory/mycluster
read -p "node ips (space seperated) ex 1.2.3.4 1.2.3.5:" nodeIPS
declare -a IPS=($nodeIPS)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}
