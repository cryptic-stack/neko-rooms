param(
    [string]$Repository = "crypticstack/ihacknebraska",
    [string]$Tag = "latest",
    [string]$BaseImage = "ghcr.io/m1k1o/neko/xfce:latest",
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"

$image = "${Repository}:${Tag}"

function Invoke-Docker {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    & docker @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "docker $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

Write-Host "Building ${image} from ${BaseImage}..."
Invoke-Docker build `
    -f Dockerfile.workspace `
    -t $image `
    --build-arg BASE_IMAGE=$BaseImage `
    .

if ($NoPush) {
    Write-Host "Built ${image}. Skipping push because -NoPush was provided."
    exit 0
}

Write-Host "Pushing ${image}..."
Invoke-Docker push $image

Write-Host "Published ${image}."
