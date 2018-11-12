<#
    Only required in the VSCode Environment, since the powershell process
    instance's ExecutionPolicy is set to Restricted.
#>
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

# Dot-source required resources.
. $( $(Split-Path $script:MyInvocation.MyCommand.Path) + "\utility_profile.ps1" )

if (Test-IsModuleInstalled -Name "posh-git") {
    <#
        posh-git powershell module
        github    > https://github.com/dahlbyk/posh-git
        github.io > http://dahlbyk.github.io/posh-git/
        install   > https://github.com/dahlbyk/posh-git/blob/master/README.md#installing-posh-git-via-powershellget
        configure > https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    #>
    $desiredPrefixText = "`n" # Newline so each line starts clear
    $desiredPrefixText += $env:USERNAME
    $desiredPrefixText += "@$($env:COMPUTERNAME.Substring(0,6))..."
    $desiredPrefixText += "VSCode" # VSCode to denote different profile loaded
    If (Test-IsAdmin) {
        $desiredPrefixText += " as ADMIN!"
    }

    Import-Module posh-git
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
    # The following makes your prompt span 2 lines, like *nix CLIs (& mingw64).
    $GitPromptSettings.DefaultPromptPrefix.Text = "$($desiredPrefixText) "
    $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
} else {
    # still notify user of context
    Write-Host "Admin? $(if (Test-IsAdmin) { `"Yes`" } else { `"No`" })"
}

if (Test-IsDotNetCoreInstalled) {
    # PowerShell parameter completion shim for the dotnet CLI
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
            dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }
}
