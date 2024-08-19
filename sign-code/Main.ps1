<# Sign binaries with Windows signtool #>

Write-Output "::group::pwsh $($PSCommandPath)"

try {
    $InDir = $env:INPUTS_IN

    "- Searching for artifacts in `"$InDir`""
    $Artifacts = Get-ChildItem $InDir -Recurse -File | Where-Object {$_.Directory.BaseName -like 'win*'}

    if (!($Artifacts)) {throw [System.Exception]::new("No artifacts found in `"$InDir`".")}

    foreach ($Artifact in $Artifacts) {
        "- Signing `"$Artifact`""
        signtool.exe sign /n $env:PFX_ID /t http://timestamp.digicert.com /fd SHA256 $Artifact | Out-Host

        signtool.exe verify /pa $Artifact | Out-Host

        if (!($?)) {throw [System.Exception]::new("Failed to sign `"$Artifact`" as $env:PFX_ID")}
    }
} catch {
    Write-Output "::error::$($_.Exception)"
    Write-Output '::endgroup::'

    exit 1
}

Write-Output '::endgroup::'

exit 0
