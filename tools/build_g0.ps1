param(
    [string]$CubeRoot = (Join-Path $PSScriptRoot '../.deps/STM32CubeF4'),
    [string]$IdePlugins = 'D:/STM32CubeIDE_2.2.0/STM32CubeIDE/plugins',
    [string]$BuildDir = (Join-Path $PSScriptRoot '../build/f407-g0')
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$cube = (Resolve-Path $CubeRoot).Path
$gccPlugin = Get-ChildItem -LiteralPath $IdePlugins -Directory -Filter 'com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.*.win32_*' | Sort-Object Name -Descending | Select-Object -First 1
$cmakePlugin = Get-ChildItem -LiteralPath $IdePlugins -Directory -Filter 'com.st.stm32cube.ide.mcu.externaltools.cmake.win32_*' | Sort-Object Name -Descending | Select-Object -First 1
if (-not $gccPlugin -or -not $cmakePlugin) { throw 'STM32CubeIDE GCC or CMake plugin not found; specify -IdePlugins.' }
$gccBin = Join-Path $gccPlugin.FullName 'tools/bin'
$cmake = Join-Path $cmakePlugin.FullName 'tools/bin/cmake.exe'
$ninja = (Get-Command ninja.exe -ErrorAction Stop).Source
& $cmake -S (Join-Path $root 'firmware') -B $BuildDir -G Ninja "-DCMAKE_MAKE_PROGRAM=$ninja" "-DCMAKE_TOOLCHAIN_FILE=$root/firmware/cmake/arm-none-eabi.cmake" "-DARM_TOOLCHAIN_BIN=$gccBin" "-DSTM32CUBE_F4_ROOT=$cube" -DCMAKE_BUILD_TYPE=Debug
if ($LASTEXITCODE -ne 0) { throw "CMake configure failed: $LASTEXITCODE" }
& $cmake --build $BuildDir
if ($LASTEXITCODE -ne 0) { throw "Firmware build failed: $LASTEXITCODE" }
