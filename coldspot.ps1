
<#
    Wifi ColdSpot
    https://github.com/DiamoonWolf/wificoldspot
#>

# Ben N.'s await function for IAsyncOperation and IAsyncAction in PowerShell:
try {


    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    Function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
    }

    Function AwaitAction($WinRtAction) {
        $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
        $netTask = $asTask.Invoke($null, @($WinRtAction))
        $netTask.Wait(-1) | Out-Null
    }


    $connectionProfile = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetInternetConnectionProfile()
    $tetheringManager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($connectionProfile)

    $configuration = new-object Windows.Networking.NetworkOperators.NetworkOperatorTetheringAccessPointConfiguration
    <# SSID for hotspot name
         The SSID is encoded using the Microsoft code page for the system's default locale.
         This SSID may appear differently in the Windows network selection UI on a system 
         that uses a different system locale. It is highly recommended that you set the 
         value using characters from the standard ASCII printable character set to avoid 
         any cross-locale inconsistencies.
    #>
    $configuration.Ssid = "sdefault"

    # Passphrase (As detailed in the 802.11 specification, a passphrase must contain between 8 and 63 characters in the standard ASCII printable character set.)
    $configuration.Passphrase = "pdefault"

    # Wifi band (GHz)
    <#
    FIELDS
        Auto -> 0	
            Specifies that the WiFi adapter is free to choose any band per internal logic.

        FiveGigahertz -> 2	
            Specifies that the WiFi adapter uses only the 5 GHz band.

        TwoPointFourGigahertz -> 1	
            Specifies that the WiFi adapter uses only the 2.4 GHz band.
    #>

    $configuration.Band = 0

    # Use above configuration for the new hotspot
    AwaitAction ($tetheringManager.ConfigureAccessPointAsync($configuration))


    # Start Hotspot
    Await ($tetheringManager.StartTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])

} catch {
# Errors...
# Silence.
}

# End
