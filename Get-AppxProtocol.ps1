<#
.Synopsis
   Get the protocol used by Windows Store (UWP) Apps installed on the local system.
.DESCRIPTION
   Windows Store Apps, also known as Universal Windows Platform apps (UWP), register
   protocols when they are installed on Windows via AppX packages.
   The protocol(s) of the app can be used to launch the app via command line tools.
   Get-AppxProtocol is a PowerShell function get gather the protocols for UWP apps 
   installed on the local system.

.NOTES
   Created by: Jason Wasser @wasserja
   Modified: 9/12/2016 09:55:52 AM 
   Version 0.2

.EXAMPLE
   PS C:\> Get-AppxProtocol -Name edge | Format-List
    
    Name       : Microsoft.MicrosoftEdge
    Protocol   : {http, https, read, microsoft-edge}
    Path       : C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe
    Executable : MicrosoftEdge.exe

    List the protocols for Microsoft Edge app.

.EXAMPLE
   PS C:\> Get-AppxProtocol -Name feedback -AllUsers | Format-List

   Name       : Microsoft.WindowsFeedbackHub
   Protocol   : {windows-feedback, insiderhub, feedback-hub}
   Path       : C:\Program Files\WindowsApps\Microsoft.WindowsFeedbackHub_1.3.1741.0_x64__8wekyb3d8bbwe
   Executable : PilotshubApp.exe

   List the protocols for Feedback Hub from all users.
.LINK
   https://github.com/wasserja/MrAAppx
#>
function Get-AppxProtocol
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position=0)]
        [string[]]$Name,

        # AllUsers requires elevated permission
        [switch]$AllUsers
    )

    Begin
    {
    }
    Process
    {
        
        foreach ($AppName in $Name) {
            Write-Verbose "Getting AppX package information for $AppName"
            $Apps = Get-AppxPackage -Name "*$AppName*" -AllUsers:$AllUsers.isPresent
            foreach ($App in $Apps) {
                Write-Verbose "Getting AppX package manifest for $($App.Name)"
                [xml]$AppXManifest = $App | Get-AppxPackageManifest
                
                $Protocol = ($AppXManifest.Package.Applications.Application.Extensions.Extension | Where-Object -FilterScript {$_.Category -eq 'windows.protocol'} | Select-Object -Property ChildNodes).ChildNodes.Name
                $AppXProtocolProperties = [ordered]@{
                        Name = $App.Name
                        Protocol = $Protocol
                        Path = $App.InstallLocation
                        Executable = $AppXManifest.Package.Applications.Application.Executable
                        }
                
                $AppXProtocol = New-Object -TypeName PSCustomObject -Property $AppXProtocolProperties
                Write-Output $AppXProtocol
                }
            }
    }
    End
    {
    }
}