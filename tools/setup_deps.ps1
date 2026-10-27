param([string]$CubeRoot = (Join-Path $PSScriptRoot '../.deps/STM32CubeF4'))
$ErrorActionPreference = 'Stop'
$cubeCommit = '60c8abe0ae88a23bbd1c925358330031e36dd20f'
$halCommit = '1f6451c3e07728b4c830744de380e56bf5bc0026'
$deviceCommit = '9192c7b9df75a142f2027ab266601fe061fc00b3'
$target = [System.IO.Path]::GetFullPath($CubeRoot)
$parent = Split-Path -Parent $target
New-Item -ItemType Directory -Force -Path $parent | Out-Null

function Run-Git([string[]]$GitArgs) {
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "git failed with exit code $LASTEXITCODE" }
}
function Get-Head([string]$Repo) {
    $value = & git -C $Repo rev-parse HEAD
    if ($LASTEXITCODE -ne 0) { throw "Cannot read dependency revision at $Repo" }
    return ($value | Select-Object -Last 1).Trim()
}
function Assert-Dependencies([string]$Repo) {
    $hal = Join-Path $Repo 'Drivers/STM32F4xx_HAL_Driver'
    $device = Join-Path $Repo 'Drivers/CMSIS/Device/ST/STM32F4xx'
    if ((Get-Head $Repo) -ne $cubeCommit -or (Get-Head $hal) -ne $halCommit -or (Get-Head $device) -ne $deviceCommit) {
        throw "Dependency revisions differ from the pinned set at $Repo; inspect rather than overwriting it."
    }
    if (-not (Test-Path (Join-Path $Repo 'Drivers/CMSIS/Include/core_cm4.h')) -or
        -not (Test-Path (Join-Path $hal 'Src/stm32f4xx_hal.c')) -or
        -not (Test-Path (Join-Path $device 'Include/stm32f407xx.h'))) {
        throw "Dependency checkout is incomplete at $Repo; inspect it before retrying."
    }
}

if (Test-Path -LiteralPath $target) {
    Assert-Dependencies $target
    Write-Output "Verified pinned STM32CubeF4 dependencies: $target"
    exit 0
}

$stage = Join-Path $parent ('.cube-staging-' + [guid]::NewGuid().ToString('N'))
try {
    Run-Git -GitArgs @('clone', '--depth', '1', '--filter=blob:none', '--no-checkout', 'https://github.com/STMicroelectronics/STM32CubeF4.git', $stage)
    Run-Git -GitArgs @('-C', $stage, 'sparse-checkout', 'init', '--cone')
    Run-Git -GitArgs @('-C', $stage, 'sparse-checkout', 'set', 'Drivers/CMSIS/Include', 'Drivers/CMSIS/Device/ST/STM32F4xx', 'Drivers/STM32F4xx_HAL_Driver')
    Run-Git -GitArgs @('-C', $stage, 'fetch', '--depth', '1', 'origin', $cubeCommit)
    Run-Git -GitArgs @('-C', $stage, 'checkout', '--detach', $cubeCommit)
    Run-Git -GitArgs @('-C', $stage, 'submodule', 'update', '--init', '--depth', '1', 'Drivers/CMSIS/Device/ST/STM32F4xx', 'Drivers/STM32F4xx_HAL_Driver')
    Assert-Dependencies $stage
    Move-Item -LiteralPath $stage -Destination $target
    Write-Output "Installed pinned STM32CubeF4 dependencies: $target"
} catch {
    throw "Dependency setup failed; temporary checkout was retained at $stage. $($_.Exception.Message)"
}
