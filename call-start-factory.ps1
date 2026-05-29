[CmdletBinding()]
param(
    [ValidateSet('manual', 'auto')]
    [string]$Adapter = 'auto',

    [switch]$DryRun,

    [string]$TaskId,

    [string]$Role,

    [int]$MaxIterations = 300,

    [string]$BashPath
)

$ErrorActionPreference = 'Stop'

function Resolve-BashExecutable {
    param([string]$PreferredPath)

    if ($PreferredPath) {
        return (Resolve-Path -LiteralPath $PreferredPath).Path
    }

    foreach ($candidate in @('bash.exe', 'bash')) {
        $command = Get-Command -Name $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) {
            return $command.Source
        }
    }

    foreach ($fallback in @(
        'C:\Program Files\Git\bin\bash.exe',
        'C:\Program Files\Git\usr\bin\bash.exe'
    )) {
        if (Test-Path -LiteralPath $fallback) {
            return $fallback
        }
    }

    throw 'Unable to locate bash.exe. Install Git Bash or pass -BashPath explicitly.'
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bashExecutable = Resolve-BashExecutable -PreferredPath $BashPath

if (-not (Test-Path -LiteralPath (Join-Path $scriptDir 'df\agent-router\start-factory.bash'))) {
    throw "Router start script not found under $scriptDir\df\agent-router"
}

$commandParts = @(
    "./df/agent-router/start-factory.bash --adapter $Adapter --max-iterations $MaxIterations"
)

if ($TaskId) {
    $commandParts[0] += " --task-id $TaskId"
}

if ($Role) {
    $commandParts[0] += " --role $Role"
}

if ($DryRun) {
    $commandParts[0] += ' --dry-run'
}

$bashCommand = $commandParts -join '; '
Push-Location -LiteralPath $scriptDir
try {
    & $bashExecutable -lc $bashCommand
}
finally {
    Pop-Location
}
exit $LASTEXITCODE
