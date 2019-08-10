####################################################################
# Powershell code for checking the length of the specified folder  #
# Created by Anirudra Choudhury Created on : 15-04-2018            #
# Modified on : 05-06-2019                                         #
# Modification : Logging Feature Added File List and               #
#                Folder List Exported in csv                       #
####################################################################

#Set Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

$LogFile = "$($env:TEMP)\Path Length Check-$([system.Datetime]::Now.Tostring("yyyyMMdd HHmmSS")).log"

<#
.SYNOPSIS
    Function for Logging
.DESCRIPTION
    This Function will append into created Logfile.
    Each Log will contain Time stamp and Log massage
.PARAMETER logstring
    The Massage Should be passed for Logging given here
.EXAMPLE
    Logging "Processing Started"
    The Above command will log in file lite : "yyyy-MM-dd HH:mm:SS - Processing Started" 
.NOTES
    The Genaratec Log File Will be Saved in Temporary Folder
#>

Function LogWrite{

   Param ([string]$LogType,
        [string]$LogString)

    $TimeStamp = [system.Datetime]::Now.Tostring("yyyy-MM-dd HH:mm:SS")
    $massage = $TimeStamp + "-" + $LogType + "-" + $LogString

   Add-content $Logfile -value $massage

    if($LogType -eq "Success"){
        Write-Host -ForegroundColor Green "$LogString Processed Sucessfully"
    }
    Elseif($LogType -eq "Error"){
        Write-Host -ForegroundColor Red "$LogString Having Long Path Error"
    }
    Elseif($LogType -eq "Info"){
        Write-Host -ForegroundColor cyan $LogString
    }
    Else{
        Write-Host -ForegroundColor Yellow $LogString
    }
}

#Creating Folder Browser Dialogue
Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

#Get The directory to be uploaded and upload location from user
[void]$FolderBrowser.ShowDialog()
$WorkingDirectory = $FolderBrowser.SelectedPath

LogWrite -LogType "Info" -LogString "$WorkingDirectory selected as working directory"


#Ask For Upload Location in Autodesk Vault
$VaultLocation = Read-Host -Prompt "Upload Location For Vault"

#Starting The Process
$StartTime = [system.Datetime]::Now

#Temp Location Where Files Being Copied By Autoloader
$TempLocationPrefix = "C:\Temp\Vault_Autoloader\$\Designs\"

#Upload location Temp folder charecter length
LogWrite -LogType "Info" -LogString "$TempLocationPrefix$VaultLocation Folder is the Temp Folder Where Files will be copied"
$UploadPathSize = $($TempLocationPrefix+$VaultLocation).Length


#Declearing Custom object for Long Path Folders and Long Path Files
$LongPathFolders=@()
$LongPathFiles = @()

#Getting All Folders in The Selected Path
$Folders = Get-ChildItem -Path $WorkingDirectory -Directory -Recurse

#Looping Through All Folders
ForEach ($Folder in $Folders){

    LogWrite -LogType "Info" -LogString "Processing folder : $($Folder.FullName)"
    LogWrite -LogType "Info" -LogString "The path Length for : $($Folder.FullName) is $($Folder.FullName.Length)"

    #Checking if the Folder Path Length is Greater Than 243 or not
    # If Greater than 248 then adding object into Long Path Folders
    # Else Loop Through Files
    # Check EachFile Length is greater than 255 or not
    # If all files in a folder got error then the folder added to the list of long path folders
    # Else The files Added to the Long Path List
    If($Folder.FullName.Length -gt (243-$UploadPathSize)){
        LogWrite -LogType "Error" -LogString "Folder-$($Folder.FullName)"

        $LongPathFolders+=[pscustomobject]@{
            'Folder Name' = $Folder.Name
            'Folder Path' = $Folder.FullName
            'Folder Path Length' = $Folder.FullName.Length
            'After Copy Length' = $($Folder.FullName.Length+$UploadPathSize)
        } 
    }
    else{
        LogWrite -LogType "Info" -LogString "Checking files in the folder: $($Folder.FullName)"
        $lencheck=0
        $tempFiles = @()
        $Files = Get-ChildItem -Path $Folder.FullName -File
        ForEach ($File in $Files){
           
            If($File.FullName.Length -gt (255-$UploadPathSize)){
                $lencheck += 1
                $tempFiles+=@{
                'FileName'  = $File.Name
                'FilePath'  = $Folder.FullName
                'FileSize'  = $File.FullName.Length
                'ACFileSize'= $($File.FullName.Length+$UploadPathSize)
                }
                LogWrite -LogType "Error" -LogString "File-$($File.FullName)"
            }
            else{
                LogWrite -LogType "Success" -LogString "File-$($File.FullName)"
            }
        }

        LogWrite -LogType "Info" -LogString "All files in folder $($Folder.FullName) Successfully Processed"
        
        if(($Files.length -eq $lencheck) -and -not($lencheck -eq 0)){
            
            $LongPathFolders+=[pscustomobject]@{
                'Folder Name' = $Folder.Name
                'Folder Path' = $Folder.FullName
                'Folder Path Length' = $Folder.FullName.Length
                'After Copy Length' = $($Folder.FullName.Length+$UploadPathSize)
            }

            LogWrite -LogType "Error" -LogString "Folder-$($Folder.FullName)" 
        }
        else{
            ForEach($temp in $tempFiles){
                $LongPathFiles+=[pscustomobject]@{
                    'File Name'=$temp.FileName
                    'File Path'=$temp.FilePath
                    'File Name Length' = $temp.FileSize
                    'After Copy Length' = $temp.ACFileSize
                }
            }
            LogWrite -LogType "Info" -LogString "Total $($tempFiles.length) files in the folder : $FolderPath Having Long Path Problem" 
        }
    }
}

#Checking If Long Path Report Folders Existance
if (-Not $(Test-Path -Path "C:\users\$($env:username)\LongPathReport\")){
    mkdir -Path "C:\users\$($env:username)\LongPathReport"
}
#Exporting Reports as Csv
$LongPathFolders | Export-Csv -Path "C:\users\$($env:username)\LongPathReport\$($WorkingDirectory.Replace(":\","_").Replace("\","_"))LongpathFolders.csv" -NoTypeInformation
$LongPathFiles | Export-Csv -Path "C:\users\$($env:username)\LongPathReport\$($WorkingDirectory.Replace(":\","_").Replace("\","_"))LongpathFiles.csv" -NoTypeInformation
LogWrite -LogType "Info" -LogString "Long Path Report Exported"

$EndTime = [system.Datetime]::Now
$Duration = $EndTime - $StartTime
LogWrite -LogType "Info" -LogString "Total Time Took $($Duration.TotalSeconds) Seconds"