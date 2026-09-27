# Builds and runs a local, disposable Perforce server for manually testing UnrealGameSync against.

$ErrorActionPreference = "Stop"

docker build --tag ugs-test-perforce $PSScriptRoot
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

docker run -it --rm `
	--publish 1666:1666 `
	--ulimit nofile=65536:65536 `
	--ulimit nproc=32768:32768 `
	ugs-test-perforce
