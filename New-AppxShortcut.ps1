<#
.Synopsis
   Create shortcuts for UWP Apps-based upon the app's protocol(s).
.DESCRIPTION
   Create shortcuts for UWP Apps-based upon the app's protocol(s). These
   shortcuts could be used by application launcher's such as Launchy so that
   you can start UWP apps.
.NOTES
   Created by: Jason Wasser @wasserja
   Modified: 9/12/2016 10:08:26 AM 
   Version 0.2
.EXAMPLE
   New-AppxShortcut -Name Edge

   Creates a shortcut for all the protocols for Microsoft Edge in C:\Temp\AppX
.EXAMPLE
   New-AppxShortcut -Name Edge -Path $env:AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Appx

   Creates a shortcut for all the protocols for Microsfot Edge in your Start Menu.
.LINK
   http://www.launchy.net
.LINK
    https://github.com/wasserja/MrAAppx
#>
function New-AppxShortcut
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position=0)]
        [string]$Name,

        [switch]$AllUsers,
        
        [string]$Path='c:\temp\Appx'
    )

    Begin
    {
        if (Test-Path $Path) {
            Write-Verbose "$Path exists."
            }
        else {
            Write-Verbose "$Path does not exist. Creating directory."
            New-Item -Path $Path -ItemType Directory
            }
    }
    Process
    {
        $Apps = Get-AppXProtocol -Name $Name -AllUsers:$AllUsers.IsPresent
        foreach ($App in $Apps) {
            Write-Verbose "Creating shortcuts $($App.Name)"
            if ($App.Protocol.count -eq 1) {
                Write-Verbose 'Only one protocol exists.'
                #$Execution = "start $($App.Protocol):"
                $Execution = "$($App.Protocol)://"
                $ShellObject = New-Object -ComObject wscript.shell
                $Shortcut = $ShellObject.CreateShortcut("$Path\$($App.Name).lnk")
                $Shortcut.TargetPath = "$Execution"
                $Shortcut.IconLocation = "$($App.Path)\$($App.Executable),0"
                $Shortcut.Save()
                }
            elseif ($App.Protocol.count -gt 1) {
                Write-Verbose "More than one protocol exists for $($App.Name)."
                foreach ($Protocol in $App.Protocol) {
                    Write-Verbose "Protocol $Protocol"
                    $Execution = "$($Protocol)://"
                    $ShellObject = New-Object -ComObject wscript.shell
                    $Shortcut = $ShellObject.CreateShortcut("$Path\$($App.Name).$Protocol.lnk")
                    $Shortcut.TargetPath = "$Execution"
                    $Shortcut.IconLocation = "$($App.Path)\$($App.Executable),0"
                    $Shortcut.Save()
                    }
                }
            else {
                Write-Verbose "No protocol exists for $($App.Name)."
                }

            }
    }
    End
    {
    }
}