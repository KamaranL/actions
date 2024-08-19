<# Add CA's to LocalMachine cert store for verification #>

Write-Output "::group::pwsh $($PSCommandPath)"

$Certificates = @(
    "$env:PFX_DIR/ca.crt"
    "$env:PFX_DIR/int-ca.crt"
)

'- Adding Certificate Authorities to LocalMachine'
foreach ($Certificate in $Certificates) {
    Import-Certificate $Certificate -CertStoreLocation Cert:\LocalMachine\Root
}

Write-Output '::endgroup::'

exit 0
