  Param (
      [parameter(
      Mandatory = $true,
      HelpMessage = 'Enter a filepath'
      )][String]$filepath
  )

  #Great Check line 
  # Get-ADUser -SearchBase "OU=HarrisR,DC=esage,DC=us" -Filter * | ft
  # Get-ADOrganizationalUnit -Filter 'Name -like "*"' | ft 

    #Domain to use
    $domain = (get-AdDomain).distinguishedName;
    
    $xml =[xml](get-content $filepath)

    #Check if we need to create OU(s)
     $ouList = $xml.root.user.ou | Sort-Object | Get-Unique;
     foreach($ou in $ouList){
         try{
         $ouExisted = Get-ADOrganizationalUnit -Identity "Ou=$ou, $domain";
         write-host("The organization ($ou) exists on the computer"); 
         }
         catch{
         New-ADOrganizationalUnit -Name $ou -Path "$domain";
         write-host("Creating $ou organizational Unit");
         }
     } 

    #Get Necessary Groups to Create
    $groups = $xml.root.user.memberOf.group | Sort-Object | Get-Unique;
       foreach($group in $groups){
       $group = $group.Replace(" ","");
         try{
         $groupExisted = Get-ADGroup -Identity "CN=$group, OU=$ouList, $domain";
         write-host("The Group ($group) exists on the Domain in the Organizational Unit ($ouList)"); 
         }
         catch{
         New-ADGroup $group -GroupScope Global -Path "OU=$ouList, $domain";
         write-host("Creating $group organizational Unit");
         }
     } 
  
   #Make Necessary Users to Create
    $Users =$xml.root.user
    foreach($user in $Users){
        #checks to see if we must make user
            try{
            Get-AdUser -FIlter "Name -eq $($user.account)" -SearchBase "OU=$ouList,$domain";
            }
            catch {
            #property of an object in the expanision string it needs alittle help
            write-host "creating user $($user.account)"
            New-ADUser -Name $($user.account) -GivenName "$($user.firstname)" -Surname "$($user.lastname)"  -Path "OU=$ouList,$domain" -AccountPassword (ConvertTo-SecureString -AsPlainText $user.password -force) -Enabled $true;
            }

            #checks to see if we need to add use to group
             foreach($group in $user.memberof.group){
                try{
                     $groupMembers = Get-ADGroupMember -Identity "CN=$group, OU=$ouList, $domain" | Select -ExcludeProperty SamAccountName
                     If ( $groupMembers -contains $user.account){
                     Write-Host "$user.account is a member of $group";
                     }                }
                catch{
                   #Add user to groups they belong to
                    write-host "adding user $($user.account) to group $group";
                    Add-ADGroupMember -Identity "CN=$group, OU=$ouList, $domain" -Members $user.account;
                }
            }
    }