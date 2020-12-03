function Create-Sites {
    param (
        $settingsFilePath="Config.json"
    )
    process{
        
        $settingsContent = Get-Content $settingsFilePath
        $settingsJson = $settingsContent | ConvertFrom-Json 

        $inputCSV = $settingsJson.Settings.sourceCSV

        $onPremUsername = $settingsJson.Settings.onPrem.userName
        $onPremPassword = $settingsJson.Settings.onPrem.password

       

        $siteUrls =Import-Csv $inputCSV
        
        $onPremPasswordSecure = ConvertTo-SecureString $onPremPassword -AsPlainText -Force
        $onPremCreds = New-Object System.Management.Automation.PSCredential ($onPremUsername, $onPremPasswordSecure)
        

        $tenantUrl = $settingsJson.Settings.online.adminUrl
        $tenantUsername = $settingsJson.Settings.online.userName
        $tenantPassword = $settingsJson.Settings.online.password
        $tenantpasswordSecure = ConvertTo-SecureString $tenantPassword  -AsPlainText -Force
        $onlineCreds = New-Object -TypeName pscredential -ArgumentList $tenantUsername, $tenantpasswordSecure

        $conSer =Connect-PnPOnline -url $tenantUrl -Credentials $onlineCreds

        $headers = @{}        
        $headers["Accept"] = "application/json;odata=verbose"

        foreach($row in $siteUrls)
        {
            $restResult=Invoke-RestMethod -Uri "$($row.Url)/_api/web/title" -Method Get -Headers $headers -Credential $onPremCreds

            #converting xml result to json
            $jsonTitleResult= $restResult | ConvertTo-Json
            $jsonObjectResut = $jsonTitleResult | ConvertFrom-Json
            $Url = $row.Url
            if($($row.Url).endsWith("/"))
            {
                $Url = $Url.substring(0,$url.LastIndexOf("/"))
            }
            $alias = $Url.substring($url.LastIndexOf("/")+1)

            $onlineSiteUrl =(Get-PnPSite).Url.replace("-admin","")+"/sites/"+$alias

          $tenantSite = Get-PnPTenantSite $onlineSiteUrl -ErrorAction:SilentlyContinue #check if the site already exists in tenant

          if($tenantSite -eq $null)
          { 
              $siteUrl=  Create-Site -title $jsonObjectResut.d.Title -urlAlias $alias
              if($siteUrl -ne $null)
              {
                 Write-Host "The site with url $siteUrl is successfully created" -ForegroundColor green
              }
              else
              {
                Write-Host "Error in creation of $Url" -ForegroundColor Red
              }
           }
           else
           {
              Write-Host "The site with url $url already exists" -ForegroundColor yellow
           }


        }

    }
    
}
function Create-Site
{
    param(
        $urlAlias,
        $title
    )
    process
    {
     $site =   New-PnPSite -Type TeamSite -Title $title -Alias $urlAlias 
     return $site
    }
    
} 