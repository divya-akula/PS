This powershell scripts helps to create a bunch of team sites in SharePoint online , it can come handy when you are migrating/recreating the sites in SharePoint online.

Synopsis:
  It reads a list of URLs from a csv file and creates a team site with the same title as on premises, if it does not already exists. The configuration is defined in a json file.
  
 Technical Listings:
   1. pnp Powershell commands
   2. Rest API
   3. Standard PS Script 
   
   Settings:
     The configuration is defined in a json config file and looks as below.Ensure that you update with proper values
     
     ```json
     {
      "settings":{
      "online":{
         "adminUrl":"https://<tenant>-admin.sharepoint.com/",
         "userName":"divya@<tenant>.onmicrosoft.com",
         "password":"<pwd>"
      },
      "onPrem":{
         "userName":"<uname>",
         "password":"pwd"
      },
      "sourceCSV":"<physicalpath>\\sites.csv"
     }
    }
 
  Script:
  
 ```powershell script
 . .\CreateSites.ps1
    Create-Sites
 ```
  
  
