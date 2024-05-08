$TBB_VERSION = "2021.12.0"
Invoke-WebRequest -Uri "https://github.com/oneapi-src/oneTBB/releases/download/v$TBB_VERSION/oneapi-tbb-$TBB_VERSION-win.zip" -OutFile "./tbb.zip" -UseBasicParsing
Expand-Archive .\tbb.zip
Remove-Item .\tbb.zip

# CMake 3.27 or greater can locate packages from this env var:
$ENV:TBB_ROOT = "$PSScriptRoot\tbb\oneapi-tbb-$TBB_VERSION"