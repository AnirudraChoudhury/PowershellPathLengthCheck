# PowershellPathLengthCheck
This Script first check the file lengths and list out all error files and folders and Export the Report
## User Manual
1. Run The Powershell code
2. It will Ask to select the Folder for Doing Study
3. Then it will Ask for upload directory
    * You have to provide the path after the design folder
    * For Example:
        * Example 1:
            * Suppose your Upload Directory is **$/Design/Drawings**
            * Then you have to Enter **Drawings** in the Command Line
        * Example 2:
            * Suppose your Upload Directory is **$/Design/Drawings/2018/01**
            * Then you have to Enter **Drawings/2018/01** in the Command Line
4. Then the Script will create 2 Reports and 1 Log File
    * Long Path Folders Report Location: **C:\\Users**\\*<UserName>***\\LongPathReport\\**
    * Long Path Files Report Location: **C:\\Users**\\*<UserName>***\\LongPathReport\\**
    * Log File Location: **C:\\Users**\\*<UserName>***\\AppData\\Local\\Temp\\**