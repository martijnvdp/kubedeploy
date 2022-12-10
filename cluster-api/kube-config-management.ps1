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

(kubectl get secret/management-kubeconfig -o json |ConvertFrom-Json).data.value|ConvertFrom-Base64 |Out-file -filepath kube-config-mgmt.json
$env:KUBECONFIG=".\kube-config-mgmt.json"
