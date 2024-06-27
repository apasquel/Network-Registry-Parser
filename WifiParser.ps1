#SYSTEMTIME Conversion Function
Function convert-date($x){
    try{
        $Count = 0
        $string = $null
        $val = $null
 
        while($Count -ine $x.count){
            $y = "{0:x}" -f $x[$Count]
            [System.Array]$val += $y
            $Count++
        }
 
        $Count = 0
        $VarStor = $null
 
        while($Count -ine $val.Count){
            if ($val[$Count].Length -eq '2'){
                [System.Array]$VarStor += $Val[$Count]
            }
            if ($val[$Count].Length -ne '2'){
                $Var = $val[$Count]
                [System.Array]$VarStor += "0$Var"
            }
            $Count++
        }
        $Count = 0
        while ($Count -ne $VarStor.Count){
            $string += $VarStor[$Count].ToString()
            $Count++
        }
 
        #swaping the values--->
 
        $swap1 = $string[2]+$string[3]+$string[0]+$string[1]
        $swap2 = $string[6]+$string[7]+$string[4]+$string[5]
        $swap3 = $string[10]+$string[11]+$string[8]+$string[9]
        $swap4 = $string[14]+$string[15]+$string[12]+$string[13]
        $swap5 = $string[18]+$string[19]+$string[16]+$string[17]
        $swap6 = $string[22]+$string[23]+$string[20]+$string[21]
        $swap7 = $string[26]+$string[27]+$string[24]+$string[25]
 
 
        #Finding the Year--->
 
        [int]$year = "0x$swap1"
 
        #Finding the month
 
        [int]$month = "0x$swap2"
 
        #Finding the Date--->
 
        [int]$Date = "0x$swap4"
 
        #finding the Time--->
 
        [int]$Hour = "0x$swap5"
        [int]$Minute = "0x$swap6"
        [int]$Seconds = "0x$swap7"
 
        $retval= $(get-date -Year $year -Month $month -Day $date -Hour $Hour -Minute $Minute -Second $Seconds -Format "yyyy-MM-ddTHH:mm:ss")
        return $retval
    }
 
    catch{
        return "Error"
    }    
}

function Show-Usage {
    Write-Host "To Export Results: .\WifiParser.ps1 -o <Output Path and Filename>"
    }

#Collecting both main registry keys
$Profiles = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\*"  | Select-Object Description, DateCreated, DateLastConnected, PSPath
$Signatures = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged\*" | Select-Object ProfileGuid, Source, DnsSuffix, DefaultGatewayMac
$mergedTable = @()

#Merge both keys and match based off of GUIDs
foreach ($row1 in $Profiles) {
    foreach ($row2 in $Signatures) {
        if ($row1.PSPath -split '\\' -contains  $row2.ProfileGuid) {
            $mergedRow = New-Object PSObject -Property @{
                Description = $row1.Description
                DateCreated = $row1.DateCreated
                DateLast = $row1.DateLastConnected
                GUID1 = $row2.ProfileGuid
                GUID2 = $row1.PSPath.ToString().split('\\') | Select-String "{"
                Source = $row2.Source
                DNSSuffix = $row2.DNSSuffix
                GatewayMac = $row2.DefaultGatewayMac | ForEach-Object { $_.ToString("x2") }
            }
            $mergedTable += $mergedRow
        }
    }
}

#Sub Arrays into their proper format
Foreach ($nic in $mergedTable){
    $nic.GatewayMac = $nic.GatewayMac -join ":"
    $nic.DateCreated = convert-date $($nic.DateCreated)
    $nic.DateLast = convert-date $($nic.DateLast)
    $mergedTable += $nic
}

#Command Line Arguments
$x = "-o"
if ($args -contains $x ) {
    $mergedTable | Export-Csv -Path $args[1] -NoTypeInformation
    }
else {
    Show-Usage
    $mergedTable | Format-Table
    }
