$datasetname = "name"
$workspacename = $env:qa_workspacename

try{

$clientsec = "$(client_secret)" | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:client_id, $clientsec
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantID $env:tenant_id

$workspace = Get-PowerBIWorkspace -Name $workspacename

$DatasetRespone = Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets" -Method Get | ConvertFrom-Json

$datasets = $DatasetRespone.value

foreach($dataset in $datasets){
    if($dataset.name -eq $datasetname){
        $datasetid = $dataset.id;
        break;
    }
}

$postParams = @{
    updateDetails = @(
    @{
        name = "DataBase"
        newValue = "$($env:qa_database)"
    }
    )
} | ConvertTo-Json

Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.TakeOver" -Method POST

$postParams
Write-Host "dataset: " $datasetid
Write-Host "workspace: " $workspace.id


$response = Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.UpdateParameters" -Method Post -Body $postParams | ConvertFrom-Json

}

catch{
Resolve -PowerBIError
}