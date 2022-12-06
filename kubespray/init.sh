git clone https://github.com/kubernetes-sigs/kubespray.git
cp -r kubespray/inventory inventory
read -p "node ips (space seperated) ex 1.2.3.4 1.2.3.5:" nodeIPS
declare -a IPS=($nodeIPS)
CONFIG_FILE=inventory/samplehosts.yml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}
