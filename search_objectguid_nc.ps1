
# 
# NextCloud UUID (in AD is this attrib ObjectGUID) to samAccountName resolve script
# Pieter De Ridder
# Created : 04/06/2020
# Changed : -
#

#
# >> note:
# default Nextcloud UUID should be 36 chars to find in AD (ObjectGUID)
# example, get length of a UUID in the pwsh cli
# C:\> "CCBBFF7-5DEFG-1234-9ABC-BB886600AADD".Length
# 36
#


# load AD Module
If (-not (Get-Module -Name ActiveDirectory)) {
    Import-Module -Name ActiveDirectory
}

# NextCloud -> go to storage folder -> ls -lahrt -> copy/paste recent UUID's to file listed in var $inputFile
[string]$inputFile = ".\search_objectguid_nc.txt"
[string]$outputFile = ".\output.txt"

[string]$targetDomain = $env:USERDNSDOMAIN.ToLowerInvariant() # resolve AD domain where computer is part of
[string]$BaseDN = ""

# build custom base ldap DN from domainname
if ($targetDomain.Length -gt 0) {
    $dnParams = @($targetDomain.Split('.'))

    for($i = 0; $i -le ($dnParams.Length -1); $i++) {
        $BaseDN += "dc=$($dnParams[$i])"

        if ($i -lt ($dnParams.Length -1)) {
            $BaseDN += ","
        }
    }
}

# resolve NextCloud UUID in AD and export to csv file
If (Test-Path $inputFile) {
    $input = @(Get-Content -Path $inputFile)
    $userADCache = @()  # temporary cache to hold found AD users

    # lookup NextCloud UUID in AD (ObjectGUID)
    foreach($nextcloudUUID in $input) {
        $UUID = $nextcloudUUID.SubString(0, 36)  # cutoff to 36 chars, because in AD we have as ObjectGUID only 36 chars
        $ldap_filter = 'ObjectGUID -eq "' + $($UUID) + '"'  # LDAP filter to search for

        $ADUser = Get-ADUser -Filter $ldap_filter -SearchBase $BaseDN -Properties @("ObjectGUID", "SamAccountName", "UserPrincipalName", "Displayname", "Enabled") -ErrorAction SilentlyContinue

        if ($ADUser) {
            $userADCache += $ADUser
        }
    }

    # delete old file
    if (Test-Path $outputFile) {
        Remove-Item -Path $outputFile -Force -ErrorAction SilentlyContinue
    }

    # export to plain csv file (and stdout)
    foreach($userAD in $userADCache) {
        [string]$outputline = "$($userAD.ObjectGUID);$($userAD.SamAccountName);$($userAD.DisplayName)"
        Write-Host $outputline
        Add-Content -Path $outputFile -Value $outputline -Force
    }
} else {
    # woops, no input file?
    Write-Warning "No file found with name $($inputfile)!"
}
