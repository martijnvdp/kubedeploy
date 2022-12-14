function Unpublish-K8Cluster {
    param (
        $clusterCTLConfigFile = ".\clusterctl.yaml"
    )
    $config = get-content $clusterCTLConfigFile | ConvertFrom-Yaml
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
    connect-viserver  $config.VSPHERE_SERVER -Username  $config.VSPHERE_USERNAME -Password  $config.VSPHERE_PASSWORD
    kind delete clusters kind
    get-vm "$($config.CLUSTER_NAME)*" | stop-VM -Confirm:$false
    get-vm "$($config.CLUSTER_NAME)*" | Remove-VM -DeletePermanently -Confirm:$false
}

function ConvertFrom-Base64 () {
    <#
    .Description
    Decode Text from Base64
    #>
    param(
        # Input string to decode from base64
        [Parameter(ValueFromPipeline = $true)][string]$inputString
    )
    return ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($inputString)))
}

function deploy-K8ClusterAPIRequirements {
    curl.exe -Lo kind.exe https://kind.sigs.k8s.io/dl/v0.17.0/kind-windows-amd64
    curl.exe -Lo kubectl.exe "https://dl.k8s.io/release/v1.26.0/bin/windows/amd64/kubectl.exe"
    curl -o clusterctl.exe "https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.3.0/clusterctl-windows-amd64.exe"
}

function Get-KubeConfig {
    param(
        $clustername
    )
    return (kubectl get "secret/$clustername-kubeconfig" -o json | ConvertFrom-Json).data.value | ConvertFrom-Base64
}

function get-podstatus {
    param(
        [Alias("Status")] 
        [bool]$podstatus = $false,
        [Alias("All")] 
        [bool]$countall = $false
    )
    if (!$countall) {
        return ((kubectl get pods -A -o json | ConvertFrom-Json).items.status.containerStatuses | Where-Object -Property ready -eq $podstatus | Measure-Object).count
    }
    else {
        return ((kubectl get pods -A -o json | ConvertFrom-Json).items.status.containerStatuses | Measure-Object).count
    }
}

function waitForPods {
    $total = get-podstatus -All $True
    for ($notready = get-podstatus; $notready -ne 0; $notready = get-podstatus) {
        $pcs = ((($total - $notready) / $total) * 100)
        Write-Progress -Activity "waiting for pods" -Status "$pcs% ready" -PercentComplete $pcs
        sleep 3;
    }
    return
}

function waitForVMs {
    param(
        $clustername,
        $total
    )
    for ($count = (get-vm "$clustername*" | Measure-Object).count; $count -ne $total; $count = (get-vm "$clustername*" | Measure-Object).count) {
        $pcs = (($count / $total) * 100)
        Write-Progress -Activity "waiting for VMS" -Status "$pcs% ready" -PercentComplete $pcs
        sleep 20;
    }
    return
}

function deploy-K8Cluster {
    param (
        $clusterCTLConfigFile = ".\clusterctl.yaml"
    )
    
    $config = get-content $clusterCTLConfigFile | ConvertFrom-Yaml
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
    connect-viserver  $config.VSPHERE_SERVER -Username  $config.VSPHERE_USERNAME -Password  $config.VSPHERE_PASSWORD
    # bootstrap cluster
    kind create cluster
    clusterctl init --infrastructure vsphere --config $clusterCTLConfigFile
    clusterctl generate cluster $config.CLUSTER_NAME --config $clusterCTLConfigFile `
        --infrastructure vsphere `
        --kubernetes-version $config.KUBE_VERSION `
        --control-plane-machine-count $config.CONTROLLER_COUNT `
        --worker-machine-count $config.WORKER_COUNT > cluster.yaml
    waitForPods
    # deploy cluster on vmware using local bootstrap cluster-api
    code .\cluster.yaml
    pause
    kubectl apply -f .\cluster.yaml
    waitForVMs "$($config.CLUSTER_NAME)*" ($config.CONTROLLER_COUNT + $config.WORKER_COUNT)
    Get-kubeConfig $config.CLUSTER_NAME | Out-file $config.KUBE_CONFIG_OUT_FILE
    $env:KUBECONFIG = $config.KUBE_CONFIG_OUT_FILE
    kubectl get nodes
}
