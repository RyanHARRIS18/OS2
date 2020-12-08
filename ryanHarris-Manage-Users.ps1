  Param (
      [parameter(
      Mandatory = $true,
      HelpMessage = 'Enter a filepath'
      )][String]$filepath
  )
    #Domain to use
    $domain = (get-AdDomain).distinguishedName;
    #XML to Use
    $xml =[xml](get-content $filepath)
    #User Nodes
    $Users =$xml.root.user
  
    foreach($user in $Users){
       #Check if we need to create OU(s)
         try{
         New-ADOrganizationalUnit -Name $($user.ou) -Path "$domain";
         write-host("Creating $($user.ou) organizational Unit");
         }
         catch{
         $ouExisted = Get-ADOrganizationalUnit -Identity "OU=$($user.ou), $domain";
         write-host("The organization $($user.ou) exists on the computer"); 
         }
     
    #Get Necessary Groups to Create
    $groups = $user.memberOf.group | Sort-Object | Get-Unique;
       foreach($group in $groups){
         try{
         New-ADGroup $group -GroupScope Global -Path "OU=$($user.ou), $domain";
         write-host("Creating $group organizational Unit");
          }
         catch{
         $groupExisted = Get-ADGroup -Identity "$group";
         write-host("The Group ($group) exists on the Domain in the Organizational Unit $($user.ou)"); 
         }
     } 

        #checks to see if we must make user
            try{
            New-ADUser -Name $($user.account) -GivenName "$($user.firstname)" -Surname "$($user.lastname)"  -Path "OU=$($user.ou),$domain" -AccountPassword (ConvertTo-SecureString -AsPlainText $user.password -force) -Enabled $true;
            write-host "creating user $($user.account)";          
           }
            catch {
            #property of an object in the expanision string it needs alittle help
            $userFound = Get-ADUser -Filter * -SearchBase "OU=$($user.ou), $domain"| Select-Object $($user.account)
            write-host "User $($user.account) found in $($user.ou)"
            }

            #checks to see if we need to add use to group
             foreach($group in $user.memberof.group){
                try{
                    #Add user to groups they belong to
                    Add-ADGroupMember -Identity "CN=$group, OU=$($user.ou), $domain" -Members $($user.account);
                    write-host "adding user $($user.account) to group ($group) in ou $($user.ou)";                  
                   }
                catch{
                  $groupMembers = Get-ADGroupMember -Identity "$group" | Select-Object $($user.account)
                  Write-Host "$($user.account) is a member of $group";
                }
            }
    }