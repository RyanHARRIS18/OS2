    <#
.SYNOPSIS
    Automation of creating Oraganizational Units, groups, and Users for a domain
    froma xml file.
.DESCRIPTION
    .
.PARAMETER Path
    The path to the .
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of 
    LiteralPath is used exactly as it is typed. No characters are interpreted 
    as wildcards. If the path includes escape characters, enclose it in single
    quotation marks. Single quotation marks tell Windows PowerShell not to 
    interpret any characters as escape sequences.
.EXAMPLE
    C:\PS> 
    <Description of example>
.NOTES
    Author: Ryan Harris
    Date:   November 2020   
#>
    
    param(
        [Parameter(Mandatory=$true)]$filepath
    )

    $x =[xml](get-content C:\filepath)
    $x.root

    $Users =$x.root.user
    foreach($user in $Users){
    #property of an object in the expanision string it needs alittle help
    write-host "creating user $($user.account)"

    foreach($group in $user.memberof.group){
    write-host "adding user $($user.account) to group $group"
    }

    }

    #distinguished names
    Looks like a filepath
    (get-aduser cjlindstrom)

    #get domain name
    Get-ADDomain

   #If we wanted the new var to contain the newly created bojecty you acan use the _PassThru Param

    $new = New-ADUser "Anita" -passthru;
