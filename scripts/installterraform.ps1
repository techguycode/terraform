Function Install-Terraform
{
    # Ensure to run the function with administrator privilege 
   if (-not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
   { Write-Host -ForegroundColor Red -Object "!!! Please run as Administrator !!!"; return }
    
    # Get Terraform Latest Version
    $Url = 'https://checkpoint-api.hashicorp.com/v1/check/terraform'
    $web = (Invoke-WebRequest -Uri $Url).Content | ConvertFrom-Json
    $currentversion = $web[0].current_version


    # Local path to download the terraform zip file
    $DownloadPath = 'C:\Terraform\'
    # Reg Key to set the persistent PATH 
    $RegPathKey = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'
 
    # Create the local folder if it doesn't exist
    if ((Test-Path -Path $DownloadPath) -eq $false) { $null = New-Item -Path $DownloadPath -ItemType Directory -Force }
 
    # Download the Terraform exe in zip format for amd_64
    $DownloadLink = "https://releases.hashicorp.com/terraform/$($currentversion)/terraform_$($currentversion)_windows_amd64.zip"
    $DownloadFile = "c:\Terraform\tf_$($currentversion).zip"
    Invoke-RestMethod -Method Get -Uri $DownloadLink -OutFile $DownloadFile
  
    # Extract & delete the zip file
    Expand-Archive -Path $DownloadFile -DestinationPath $DownloadPath -Force
    Remove-Item -Path $DownloadFile -Force
 
    # Setting the persistent path in the registry if it is not set already
    if ($DownloadPath -notin $($ENV:Path -split ';'))
    {
        $PathString = (Get-ItemProperty -Path $RegPathKey -Name PATH).Path
        $PathString += ";$DownloadPath"
        Set-ItemProperty -Path $RegPathKey -Name PATH -Value $PathString
 
        # Setting the path for the current session
        $ENV:Path += ";$DownloadPath"
    }
 
    # Verify the download
    Invoke-Expression -Command "terraform version"
}

Install-Terraform
