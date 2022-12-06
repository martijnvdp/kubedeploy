git clone https://github.com/kubernetes-sigs/kubespray.git
pip install -r kubespray/requirements.txt
cp -r kubespray/inventory/sample inventory/mycluster
read -p "node ips (space seperated) ex 1.2.3.4 1.2.3.5:" nodeIPS
declare -a IPS=($nodeIPS)
CONFIG_FILE=inventory/mycluster/hosts.yml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}
