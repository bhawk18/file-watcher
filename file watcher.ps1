$folder = "\\Server1\d$\Scan-Q00230"

$Temp =$folder
foreach ($elements in $Temp )
{
$LogFileName = $elements
}
write-host $LogFileName
$logFile = "\\Server2\tools$\ScanTOFolder\FileLog_$LogFileName.csv" 
$filter = '*.*'              
$destination = "C:\Scripts"

$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{
 IncludeSubdirectories = $true      
 NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite,Attributes,CreationTime,size'
 EnableRaisingEvents = $True
 }

$onCreated = Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
 $path = $Event.SourceEventArgs.FullPath
 $name = $Event.SourceEventArgs.Name
 $changeType = $Event.SourceEventArgs.ChangeType
 $timeStamp = $Event.TimeGenerated
GetSize $path $changeType $name
}
 
$onChanged = Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
 $path = $Event.SourceEventArgs.FullPath
 $name = $Event.SourceEventArgs.Name
 $changeType = $Event.SourceEventArgs.ChangeType
 $timeStamp = $Event.TimeGenerated 
 GetSize $path $changeType $name
 }
 

$onDeleted= Register-ObjectEvent $fsw Deleted -SourceIdentifier FileDeleted -Action {
 $path = $Event.SourceEventArgs.FullPath
 $name = $Event.SourceEventArgs.Name
 $Size = $Event.SourceEventArgs.Size
 Write-host $Size
 $changeType = $Event.SourceEventArgs.ChangeType
 $timeStamp = $Event.TimeGenerated 
 GetSize $path $changeType $name
}


Function GetSize { 
param ($FileName,$changeTypeP,$nameP)

$Date = Get-Date
$DateNow = $Date.ToShortDateString()
$TimeNow = $Date.ToShortTimeString()

if ($changeTypeP -ne "Deleted")
{
$objFSO = New-Object -com Scripting.FileSystemObject
$SizeFolder = (($objFSO.GetFile("$FileName").Size))
$Result = "{0:N2}" -f $SizeFolder + " KB"

Write-Host "$DateNow;$TimeNow;$FileName;$nameP;$Result;$changeTypeP"
Add-Content $logFile "$DateNow;$TimeNow;$FileName;$nameP;$Result;$changeTypeP"
}
else
{
Write-Host "$DateNow;$TimeNow;$FileName;$nameP;$Result;$changeTypeP"
Add-Content $logFile "$DateNow;$TimeNow;$FileName;$nameP;$Result;$changeTypeP"

}



}