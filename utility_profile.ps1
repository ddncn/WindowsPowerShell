
function Get-ScriptDirectory {
    # FROM: https://stackoverflow.com/a/6985381/2200627
    Split-Path $script:MyInvocation.MyCommand.Path
}

function Get-Path () {
    $($env:PATH).Replace(";","`r`n")
}

function Copy-Path () {
    $(Get-Location).Path.ToString().Trim() | clip
}


function Get-Body {
    param (
        $Page, # [BasicHtmlWebResponseObject]
        [switch] $ExcludePRE
    )
    process {

        # Get the body portion of the content.
        $text = $Page.Content.ToString()
        $bodyStartPosition = $text.ToLower().IndexOf("<body") # can't close body tag in case they extend it
        $bodyEndPosition = $text.ToLower().IndexOf("</body>")
        $bodyLength = $bodyEndPosition - $bodyStartPosition
        $body = $text.Substring($bodyStartPosition, $bodyLength)

        $body = Remove-Tag -HTML $body -Tag "body"

        if ($ExcludePRE) {
            $body = Remove-Tag -HTML $body -Tag "pre"
        }
        # $body = $body.TrimEnd()

        return $body
    }
}

function Remove-Tag {
    param ( $HTML, $Tag )
    process {
        $text = $HTML.ToString()

        $closingTag = "</" + $Tag.ToLower() +">"

        # remove the body start/end tags.
        $text = $text.Replace($closingTag,"")
        $greaterThanSymbolPosition = $text.ToLower().IndexOf(">") + 1 # +1 to skip it
        $text = $text.Substring($greaterThanSymbolPosition)

        return $text
    }
}

function Get-Weather {
    param (
        $Location = "tulsa"
    )
    process {
        $URL = "wttr.in/$($Location)?0nQT"
        try {
            Get-Body $(Invoke-WebRequest $URL) -ExcludePRE
        } catch {}
    }
}

function Test-IsAdmin
{
    <#
    .SYNOPSIS
        Checks if the current context is Administrative.
    .NOTES
        Shortened version of the file: https://github.com/nickrod518/PowerShell-Scripts/blob/master/Test-IsAdmin.ps1
        For a few extra features, check out this technet file: https://gallery.technet.microsoft.com/scriptcenter/1b5df952-9e10-470f-ad7c-dc2bdc2ac946
        Referenced in article: https://blogs.technet.microsoft.com/heyscriptingguy/2011/05/11/check-for-admin-credentials-in-a-powershell-script/
    .EXAMPLE
        Test-IsAdmin
    #>
    $ret = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    Write-Verbose "Is the current context Administrative? $($ret)"
    return $ret
}

function Test-IsDotNetCoreInstalled
{
    <#
    .SYNOPSIS
        Checks to see if dotnet cli is installed.
    .EXAMPLE
        Test-IsDotNetCoreInstalled
    #>
    $ret = $true
    try {
        & dotnet | Out-Null
    }
    catch {
        $ret = $true
    }
    Write-Verbose "Is dotnetcore installed? $($ret)"
    return $ret
}

function Test-IsModuleInstalled
{
    <#
    .SYNOPSIS
        Checks to see if a given module is installed.
    .NOTES
        Inspired by https://stackoverflow.com/a/28740512/2200627
    .EXAMPLE
        Test-IsModuleInstalled -Name "Posh-GIT"
    #>
    param(
        [parameter(Mandatory=$true)][string]$Name
    )
    process {
        $ret = [boolean](Get-Module -ListAvailable -Name $Name)
        Write-Verbose "Is the module $($Name) installed? $($ret)"
        return $ret
    }
}

function Find-InFiles
{
    <#
        stolen unabashedly from:
        https://twitter.com/terrajobst/status/1066915423344451584?s=12
        Because I want to find in files fast...

        Was originally function called 'f'. Renamed to Find-InFiles.
        Also added alias as fif.
    #>
    param(
        $text = $(throw "param 'text' required")
        ,$files = "*.*"
        ,[switch] $Paged
    )
    process {
        if ($Paged) { findstr /sipn $text $files | less }
        else { findstr /sipn $text $files }
    }
}
Set-Alias -Name "fif" -Value "Find-InFiles"

function Backup-Git {
    param()
    process {
        # Run Git Status in CurDir, get list of modified files, and copy them
        # to appropriate directory.
    }
}
Set-Alias -Name "git-bak" -Value "Backup-Git"

function Touch {
    param(
         [parameter(Mandatory=$true)]  [string] $path
        ,[parameter(Mandatory=$false)] [switch] $Directory
    )
    process {
        if ($Directory) {
            New-Item -ItemType Container -Path $path -Force
        } else {
            New-Item -ItemType File -Path $path -Force
        }
    }
}

function Show-Tail {
    <#
    .SYNOPSIS
        Display lines in a given file. This'll display the entire file, or the
        last given number of lines.
    .EXAMPLE
        Show-Tail -file "C:\Temp\git-output.txt"
        Show-Tail -file "C:\Temp\git-output.txt" -lastLines
    #>
    param(
        [parameter(Mandatory=$true)] [string] $file,
        [parameter(Mandatory=$false, HelpMessage="Number of lines to show")]
            [Alias("n")] [int] $lastLines = $null
    )
    process {
        if ($null -eq $lastLines) {
            Get-Content $file -Wait
        } else {
            Get-Content $file -Wait -Tail $lastLines
        }
    }
}
Set-Alias -Name "tail" -Value "Show-Tail"

Set-Alias -Name "ll" -Value "ls" # ls -> Get-ChildItem
Set-Alias -Name "gh" -Value "Get-Help"
Set-Alias -Name "less" -Value "C:\Program Files\Git\usr\bin\less.exe"

<#
    Enable bash-like double-tapping TAB to peek path options
    Found at: https://stackoverflow.com/a/37715242/2200627
#>
Set-PSReadlineKeyHandler -Key Tab -Function Complete
