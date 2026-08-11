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
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

    $labRoot = 'C:\LabFiles'
    $repoRoot = Join-Path $labRoot 'agent-memory'
    $publicDesktop = 'C:\Users\Public\Desktop'
    # Set the repository clone URL here.
    $githubPAT    = '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'   # your fork's test token
    $repoCloneUrl = "https://x-access-token:$PAT@github.com/harshav-spektra/test-repo.git"

    New-Item -Path $labRoot -ItemType Directory -Force | Out-Null
    New-Item -Path $publicDesktop -ItemType Directory -Force | Out-Null

    [System.Environment]::SetEnvironmentVariable('DeploymentID', $DeploymentID, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('vmAdminUsername', $vmAdminUsername, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('vmAdminPassword', $vmAdminPassword, [System.EnvironmentVariableTarget]::Machine)

    #Import Common Functions
    $commonscriptpath = Join-Path $PSScriptRoot 'cloudlabs-windows-functions.ps1'

    if (!(Test-Path $commonscriptpath)) {
    $commonscriptpath = Join-Path $PSScriptRoot 'cloudlabs-common\cloudlabs-windows-functions.ps1'
    }

    if (!(Test-Path $commonscriptpath)) {
    throw "Common script not found: $commonscriptpath"
    }

    . $commonscriptpath

    CloudLabsManualAgent Install
    WindowsServerCommon

    CreateCredFile -AzureUserName $AzureUserName -AzurePassword $AzurePassword -AzureTenantID $AzureTenantID -AzureSubscriptionID $AzureSubscriptionID -DeploymentID $DeploymentID

    #Setting Env Variables
    Write-Host "Adding .env variables"

    if (-not [string]::IsNullOrWhiteSpace($ODLID)) {
        Add-Content -Path (Join-Path $labRoot 'AzureCreds.txt') -Value "ODLID= $ODLID"
        Add-Content -Path (Join-Path $labRoot 'AzureCreds.ps1') -Value "`$ODLID=`"$ODLID`""
    }

    Copy-Item -Path (Join-Path $labRoot 'AzureCreds.txt') -Destination (Join-Path $publicDesktop 'AzureCreds.txt') -Force
    Copy-Item -Path (Join-Path $labRoot 'AzureCreds.ps1') -Destination (Join-Path $publicDesktop 'AzureCreds.ps1') -Force

    if ($InstallCloudLabsShadow -and $InstallCloudLabsShadow.ToString().ToLowerInvariant() -in @('false', 'no')) {
    Write-Host 'InstallCloudLabsShadow disabled. Skipping trainer embedded shadow setup.'
    }
    else {
        if ([string]::IsNullOrWhiteSpace($trainerUserName) -or [string]::IsNullOrWhiteSpace($trainerUserPassword)) {
            throw 'Trainer credentials were not provided, but InstallCloudLabsShadow is enabled.'
        }

        $existingUser = Get-LocalUser -Name $trainerUserName -ErrorAction SilentlyContinue

        if ($null -ne $existingUser) {
            Write-Host "Trainer user '$trainerUserName' already exists. Removing existing user before re-running Enable-CloudLabsEmbeddedShadow..."
            try {
                Remove-LocalUser -Name $trainerUserName -ErrorAction Stop
            }
            catch {
                Write-Warning "Failed to remove existing trainer user '$trainerUserName'. Error: $($_.Exception.Message)"
                throw
            }
        }

        Write-Host "Running Enable-CloudLabsEmbeddedShadow for trainer user '$trainerUserName'..."
        Enable-CloudLabsEmbeddedShadow `
            -vmAdminUsername $vmAdminUsername `
            -trainerUserName $trainerUserName `
            -trainerUserPassword $trainerUserPassword
    }

    Write-Host '===== Installing Chocolatey ====='
    InstallChocolatey

    Write-Host '===== Installing Git ====='
    InstallGitTools
    Write-Host 'Git installation completed.'

    Write-Host '===== Installing Python ====='
    choco install python312 -y
    Write-Host 'Python installation completed.'

    Write-Host '===== Installing VS Code ====='
    InstallVSCode
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
    Write-Host 'VS Code installation completed.'

    Write-Host '===== Installing Azure CLI ====='
    InstallAzCLI
    Write-Host 'Azure CLI installation completed.'

    Write-Host '===== Installing .NET SDK ====='
    Install-ChocoPackage -PackageName 'dotnet-6.0-sdk'
    Get-ChocoInstallReport | Out-Null
    Write-Host '.NET SDK installation completed.'

    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')

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

    Write-Host '===== Installing VS Code extensions ====='
    $extensions = @(
        'ms-python.python',
        'ms-python.vscode-pylance',
        'ms-toolsai.jupyter'
    )

    $codeCmd = Get-Command code.cmd -ErrorAction SilentlyContinue

    if ($null -eq $codeCmd) {
        Write-Warning 'code.cmd was not found. Skipping VS Code extension installation.'
    }
    else {
        foreach ($extension in $extensions) {
            & code.cmd --install-extension $extension --force
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "VS Code extension install skipped for ${extension}. code.cmd exited with code $LASTEXITCODE."
            }
        }
    }

    if (-not (Test-Path $repoRoot)) {
        if ([string]::IsNullOrWhiteSpace($repoCloneUrl)) {
            throw 'repoCloneUrl is empty. Set $repoCloneUrl in this script to a valid Git clone URL before running bootstrap.'
        }

        Write-Host '===== Cloning repository ====='
        Write-Host "Cloning repository to $repoRoot"

        & git.exe clone --depth 1 $repoCloneUrl $repoRoot 2>&1 |
        ForEach-Object { $_.ToString() -replace [regex]::Escape($githubPAT), '***REDACTED***' } |
        Write-Host

        Write-Host "Git exit code = $LASTEXITCODE"

        if ($LASTEXITCODE -ne 0) {
            throw "Git clone failed with exit code $LASTEXITCODE"
        }

        Write-Host "Repository cloned successfully."
    }
    else {
        $gitMetadataPath = Join-Path $repoRoot '.git'

        if (Test-Path $gitMetadataPath) {
            Write-Host "Repository already present at $repoRoot"
        }
        else {
            throw "Path '$repoRoot' exists but '$gitMetadataPath' was not found. Repository folder is incomplete or corrupted."
        }
    }

    Write-Host "Repository is ready at $repoRoot"
    Write-Host 'Learner step: open VS Code, go to C:\LabFiles, and open the agent-memory repo.'

    $Validstatus = 'Success'
    $Validmessage = 'CloudLabs agent-memory VM bootstrap completed successfully.'
    CloudLabsManualAgent setStatus

    Write-Host '===== Deployment completed ====='
    Write-Host 'CloudLabs agent-memory VM bootstrap completed successfully.'
}
catch {
    $Validstatus = 'Failed'
    $Validmessage = $_.Exception.Message
    try { CloudLabsManualAgent setStatus } catch {}
    Write-Error $_.Exception.Message
    throw
}
finally {
    Stop-Transcript
}
