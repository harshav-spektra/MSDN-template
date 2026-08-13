Param (
    [Parameter(Mandatory = $true)]
    [string]$AzureUserName,
    [string]$AzurePassword,
    [string]$AzureTenantID,
    [string]$AzureSubscriptionID,
    [string]$ODLID,
    [string]$DeploymentID,
    [string]$azuserobjectid,
    [string]$InstallCloudLabsShadow,
    [string]$vmAdminUsername,
    [string]$trainerUserName,
    [string]$vmAdminPassword,
    [string]$trainerUserPassword
)

Write-Host "===== PARAMETERS RECEIVED ====="
$PSBoundParameters.GetEnumerator() | Sort-Object Key | Format-Table -AutoSize
Write-Host "==============================="

$ErrorActionPreference = 'Stop'

Start-Transcript -Path 'C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt' -Append

try {

    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.SecurityProtocolType]::Tls12 -bor `
        [Net.SecurityProtocolType]::Tls11 -bor `
        [Net.SecurityProtocolType]::Tls

    $labRoot = 'C:\LabFiles'
    $repoRoot = Join-Path $labRoot 'agent-memory'
    $publicDesktop = 'C:\Users\Public\Desktop'

    # ============================================================
    # Repository ZIP configuration
    # Replace this URL with your Azure Storage Account blob URL
    # ============================================================

    $repoZipUrl = "https://harshav.blob.core.windows.net/agent-memory/agent-memory.zip"
    $repoZipPath = Join-Path $labRoot 'agent-memory.zip'

    # ============================================================
    # Create required directories
    # ============================================================

    New-Item -Path $labRoot -ItemType Directory -Force | Out-Null
    New-Item -Path $publicDesktop -ItemType Directory -Force | Out-Null

    [System.Environment]::SetEnvironmentVariable(
        'DeploymentID',
        $DeploymentID,
        [System.EnvironmentVariableTarget]::Machine
    )

    [System.Environment]::SetEnvironmentVariable(
        'vmAdminUsername',
        $vmAdminUsername,
        [System.EnvironmentVariableTarget]::Machine
    )

    [System.Environment]::SetEnvironmentVariable(
        'vmAdminPassword',
        $vmAdminPassword,
        [System.EnvironmentVariableTarget]::Machine
    )

    # ============================================================
    # Import Common Functions
    # ============================================================

    $commonscriptpath = Join-Path $PSScriptRoot 'cloudlabs-windows-functions.ps1'

    if (!(Test-Path $commonscriptpath)) {
        $commonscriptpath = Join-Path `
            $PSScriptRoot `
            'cloudlabs-common\cloudlabs-windows-functions.ps1'
    }

    if (!(Test-Path $commonscriptpath)) {
        throw "Common script not found: $commonscriptpath"
    }

    . $commonscriptpath

    CloudLabsManualAgent Install
    WindowsServerCommon

    # ============================================================
    # Create Azure Credentials
    # ============================================================

    CreateCredFile `
        -AzureUserName $AzureUserName `
        -AzurePassword $AzurePassword `
        -AzureTenantID $AzureTenantID `
        -AzureSubscriptionID $AzureSubscriptionID `
        -DeploymentID $DeploymentID

    # ============================================================
    # Setting Environment Variables
    # ============================================================

    Write-Host "Adding .env variables"

    if (-not [string]::IsNullOrWhiteSpace($ODLID)) {

        Add-Content `
            -Path (Join-Path $labRoot 'AzureCreds.txt') `
            -Value "ODLID= $ODLID"

        Add-Content `
            -Path (Join-Path $labRoot 'AzureCreds.ps1') `
            -Value "`$ODLID=`"$ODLID`""
    }

    Copy-Item `
        -Path (Join-Path $labRoot 'AzureCreds.txt') `
        -Destination (Join-Path $publicDesktop 'AzureCreds.txt') `
        -Force

    Copy-Item `
        -Path (Join-Path $labRoot 'AzureCreds.ps1') `
        -Destination (Join-Path $publicDesktop 'AzureCreds.ps1') `
        -Force

    # ============================================================
    # Configure CloudLabs Shadow
    # ============================================================

    Function updateVMShadowFile {

        $drivepath = "C:\Users\Public\Documents"

        $shadowFile = Join-Path $drivepath 'Shadow.ps1'

        if (Test-Path $shadowFile) {

            (Get-Content -Path $shadowFile) |
                ForEach-Object {
                    $_ -Replace `
                        "vmAdminUsernameValue",
                        "$vmAdminUsername"
                } |
                Set-Content -Path $shadowFile
        }

        # Update trainer password
        net user $trainerUserName $trainerUserPassword
    }

    updateVMShadowFile

    # ============================================================
    # Install Chocolatey
    # ============================================================

    Write-Host '===== Installing Chocolatey ====='

    InstallChocolatey

    # ============================================================
    # Install Python
    # ============================================================

    Write-Host '===== Installing Python ====='

    choco install python312 -y

    Write-Host 'Python installation completed.'

    # ============================================================
    # Install VS Code
    # ============================================================

    Write-Host '===== Installing VS Code ====='

    InstallVSCode

    $env:Path = `
        [Environment]::GetEnvironmentVariable('Path','Machine') +
        ';' +
        [Environment]::GetEnvironmentVariable('Path','User')

    Write-Host 'VS Code installation completed.'

    # ============================================================
    # Install Azure CLI
    # ============================================================

    Write-Host '===== Installing Azure CLI ====='

    InstallAzCLI

    Write-Host 'Azure CLI installation completed.'

    # ============================================================
    # Install .NET SDK
    # ============================================================

    Write-Host '===== Installing .NET SDK ====='

    Install-ChocoPackage -PackageName 'dotnet-6.0-sdk'

    Get-ChocoInstallReport | Out-Null

    Write-Host '.NET SDK installation completed.'

    $env:Path = `
        [Environment]::GetEnvironmentVariable('Path','Machine') +
        ';' +
        [Environment]::GetEnvironmentVariable('Path','User')

    # ============================================================
    # Install Python packages
    # ============================================================

    Write-Host '===== Installing Python packages ====='

    if (-not (Get-Command uv.exe -ErrorAction SilentlyContinue)) {

        & python.exe -m pip install --upgrade pip

        if ($LASTEXITCODE -ne 0) {
            throw "python.exe -m pip install --upgrade pip failed with exit code $LASTEXITCODE"
        }

        & python.exe -m pip install uv

        if ($LASTEXITCODE -ne 0) {
            throw "python.exe -m pip install uv failed with exit code $LASTEXITCODE"
        }
    }
    else {
        Write-Host 'uv already available.'
    }

    # ============================================================
    # Install VS Code Extensions
    # ============================================================

    Write-Host '===== Installing VS Code extensions ====='

    $extensions = @(
        'ms-python.python',
        'ms-python.vscode-pylance',
        'ms-toolsai.jupyter'
    )

    $codeCmd = Get-Command code.cmd -ErrorAction SilentlyContinue

    if ($null -eq $codeCmd) {

        Write-Warning `
            'code.cmd was not found. Skipping VS Code extension installation.'
    }
    else {

        foreach ($extension in $extensions) {

            & code.cmd --install-extension $extension --force

            if ($LASTEXITCODE -ne 0) {

                Write-Warning `
                    "VS Code extension install skipped for ${extension}. code.cmd exited with code $LASTEXITCODE."
            }
        }
    }

    # ============================================================
    # Download Agent Memory Repository
    # ============================================================

    Write-Host '===== Downloading Agent Memory repository ====='
    Write-Host "Downloading repository ZIP from Azure Storage..."

    if (Test-Path $repoZipPath) {
        Remove-Item $repoZipPath -Force
    }

    if (Test-Path $repoRoot) {
        Remove-Item $repoRoot -Recurse -Force
    }

    $WebClient = New-Object System.Net.WebClient

    $WebClient.DownloadFile(
        $repoZipUrl,
        $repoZipPath
    )

    Write-Host "Repository ZIP downloaded successfully."

    # ============================================================
    # Extract Repository
    # ============================================================

    Write-Host '===== Extracting Agent Memory repository ====='

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    [System.IO.Compression.ZipFile]::ExtractToDirectory(
        $repoZipPath,
        $labRoot
    )

    Write-Host "Repository ZIP extracted successfully."

    # ============================================================
    # Handle ZIP folder structure
    # ============================================================

    # If the ZIP contains an agent-memory folder directly,
    # it will already be available at C:\LabFiles\agent-memory.

    if (-not (Test-Path $repoRoot)) {

        # If the ZIP contains another top-level folder,
        # locate it and rename it to agent-memory.

        $extractedFolders = Get-ChildItem `
            -Path $labRoot `
            -Directory |
            Where-Object {
                $_.Name -ne 'agent-memory'
            }

        if ($extractedFolders.Count -eq 1) {

            Rename-Item `
                -Path $extractedFolders[0].FullName `
                -NewName 'agent-memory'

        }
    }

    # ============================================================
    # Remove ZIP file
    # ============================================================

    if (Test-Path $repoZipPath) {
        Remove-Item $repoZipPath -Force
    }

    # ============================================================
    # Validate Repository
    # ============================================================

    if (-not (Test-Path $repoRoot)) {
        throw "Repository extraction failed. '$repoRoot' was not found."
    }

    Write-Host "Repository is ready at $repoRoot"

    Write-Host `
        'Learner step: Open VS Code, go to C:\LabFiles, and open the agent-memory repo.'

    # ============================================================
    # Deployment Status
    # ============================================================

    $Validstatus = 'Success'

    $Validmessage = `
        'CloudLabs agent-memory VM bootstrap completed successfully.'

    CloudLabsManualAgent setStatus

    Write-Host '===== Deployment completed ====='
    Write-Host `
        'CloudLabs agent-memory VM bootstrap completed successfully.'
}
catch {

    $Validstatus = 'Failed'

    $Validmessage = $_.Exception.Message

    try {
        CloudLabsManualAgent setStatus
    }
    catch {}

    Write-Error $_.Exception.Message

    throw
}
finally {

    Stop-Transcript
}
