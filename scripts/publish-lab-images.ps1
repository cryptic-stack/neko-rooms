param(
    [string]$Repository = "crypticstack/ihacknebraska",
    [string[]]$Images = @("xfce", "kali", "firefox", "chromium", "windows"),
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"

$imageDefinitions = @{
    xfce = @{
        Dockerfile = "lab-images/xfce/Dockerfile"
        Tag = "xfce"
        AlsoTagLatest = $true
    }
    kali = @{
        Dockerfile = "lab-images/kali/Dockerfile"
        Tag = "kali"
        AlsoTagLatest = $false
    }
    firefox = @{
        Dockerfile = "lab-images/firefox/Dockerfile"
        Tag = "firefox"
        AlsoTagLatest = $false
    }
    chromium = @{
        Dockerfile = "lab-images/chromium/Dockerfile"
        Tag = "chromium"
        AlsoTagLatest = $false
    }
    windows = @{
        Dockerfile = "lab-images/windows/Dockerfile"
        Tag = "windows"
        AlsoTagLatest = $false
    }
}

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

foreach ($name in $Images) {
    if (-not $imageDefinitions.ContainsKey($name)) {
        throw "Unknown lab image '$name'. Available images: $($imageDefinitions.Keys -join ', ')"
    }

    $definition = $imageDefinitions[$name]
    $taggedImage = "${Repository}:$($definition.Tag)"

    Write-Host "Building ${taggedImage}..."
    Invoke-Docker build `
        -f $definition.Dockerfile `
        -t $taggedImage `
        .

    if ($definition.AlsoTagLatest) {
        $latestImage = "${Repository}:latest"
        Write-Host "Tagging ${taggedImage} as ${latestImage}..."
        Invoke-Docker tag $taggedImage $latestImage
    }

    if ($NoPush) {
        Write-Host "Built ${taggedImage}. Skipping push because -NoPush was provided."
        continue
    }

    Write-Host "Pushing ${taggedImage}..."
    Invoke-Docker push $taggedImage

    if ($definition.AlsoTagLatest) {
        $latestImage = "${Repository}:latest"
        Write-Host "Pushing ${latestImage}..."
        Invoke-Docker push $latestImage
    }
}

Write-Host "Finished HackLab lab image publishing workflow."
