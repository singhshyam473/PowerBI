#update the Datasource Credentials
$datasetname = "name"
$workspacename = $env:dev_workspacename

$clientsec = "$(client_secret)" | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:client_id, $clientsec
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantID $env:tenant_id

#GetWorkspace

$workspace = Get-PowerBIWorkspace -Name $workspacename

#GetDataSets
$DatasetRespone = Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets" -Method Get | ConvertFrom-Json

#Get Dataset
$datasets = $DatasetRespone.value

foreach($dataset in $datasets){
    if($dataset.name -eq $datasetname){
        $datasetid = $dataset.id;
        break;
    }
}

#Takeover Dataset
Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.TakeOver" -Method POST

#update Datasource credentials
$BounGateway = Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.GetBoundGatewayDataSources" -Method GET | ConvertFrom-Json

$UpdateUserCredential = @{
        credentialType = "Basic"
        basicCredentials = @{
        username = $($env:sqlusername)
        password = "$(credentialPassword)"
        }
} | ConvertTo-Json

Invoke-PowerBIRestMethod -Url "gateways/$($BounGateway.value.gatewayId)/datasources/$($BounGateway.value.id)" -Method PATCH -Body $UpdateUserCredential | ConvertFrom-Json
