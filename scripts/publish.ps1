[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$OutputDirectoryPath,

    [Parameter()]
    [string]$Runtime = "win-x64",

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 5.0

if (!(Get-Command "dotnet" -ErrorAction SilentlyContinue)) {
    throw ".NET Core SDK is not installed. You need to install it before publishing."
}

$cliProjectDir = Join-Path $PSScriptRoot "..\src\Certes.Cli"
$cliProjectDir = (Resolve-Path $cliProjectDir).ProviderPath

if (Test-Path $OutputDirectoryPath) {
    if (!$Force) {
        throw """$OutputDirectoryPath"" already exists. Use the -Force parameter if you want to delete / recreate it."
    }

    $OutputDirectoryPath = (Resolve-Path $OutputDirectoryPath).ProviderPath
    [IO.Directory]::Delete($OutputDirectoryPath, $true)
}

New-Item -ItemType Directory $OutputDirectoryPath | Out-Null
$OutputDirectoryPath = (Resolve-Path $OutputDirectoryPath).ProviderPath

Push-Location
try {
    Set-Location $cliProjectDir

    dotnet publish `
        --framework netcoreapp2.0 `
        --runtime $Runtime `
        --self-contained `
        --configuration release `
        --output $OutputDirectoryPath

    $publishResult = $LASTEXITCODE

} finally {
    Pop-Location
}

if ($publishResult -ne 0) {
    throw "dotnet command exited with code $publishResult."
}
