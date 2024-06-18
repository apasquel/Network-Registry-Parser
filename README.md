# Network-Registry-Parser
Parses and compares the NetworkList Registry Key and its subkeys (Signature &amp; Profiles). Retrieves the following data from a Windows Host: 

- Description (or Network Name)
- DateCreated
- DateLastConnected
- PSPath (the Registry Path of the Key- useful for GUID identification)
- ProfileGuid (Same as above just not within the full path)
- Source
- DnsSuffix
- DefaultGatewayMac (BSSID) 

Huge thanks to those that helped!

# Usage
In an elevated powershell command prompt: `.\WifiParser.ps1`
