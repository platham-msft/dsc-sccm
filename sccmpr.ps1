#paulath@microsoft.com 07/02/2017 SCCMPR v0.5 - DSC Config to enforce Windows Feature pre-requisites for SCCM Server Roles

#IMPORTANT - Dot NET Framework 3.5 needs internet connectivity to download the source files unless you configure "Source" to point to a
#            side by side store (or have configured one via GPO.) See https://technet.microsoft.com/en-us/library/jj127275(v=ws.11).aspx
#            Configure the source in your configurationdata psd1 file and uncomment the "Source" parameter under Dot NET 3.5 on line 56

param(
    
        [Parameter(Mandatory=$True,Position=0,HelpMessage="Path to the .psd1 configuration data file e.g. c:\temp\sccmconfig.psd1")]
        [ValidateNotNullOrEmpty()]
        [string] $ConfigDataFile
               
      )

configuration SCCMPR
{
    
Import-DscResource -ModuleName PSDesiredStateConfiguration

# Dot NET Framework 4.5 required on all site systems
    node $AllNodes.NodeName
    {

        WindowsFeature DotNET45 
        {
           Ensure = "Present"
           Name   = "NET-Framework-45-Core"
        }

    }

# Dot NET Framework 3.5 required on Site Server, Endpoint Protection Point, Software Update Point, Enrollment Point, Application Catalog Web Service Point,
# Application Catalog Website Point, Enrollment Proxy Point
 
    node $AllNodes.Where{`
        $_.Role -contains "SiteServer"`
    -or $_.Role -contains "EndpointProtectionPoint"`
    -or $_.Role -contains "SoftwareUpdatePoint"`
    -or $_.Role -contains "SoftwareUpdatePointSQL"`
    -or $_.Role -contains "EnrollmentPoint"`
    -or $_.Role -contains "ApplicationCatalogWebServicePoint"`
    -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
    -or $_.Role -contains "EnrollmentProxyPoint"`
    }.Nodename

    {

        #Dot NET Framework 3.5 needs internet connectivity to download the source files unless you configure "Source" to point to a
        #side by side store (or have configured one via GPO). See https://technet.microsoft.com/en-us/library/jj127275(v=ws.11).aspx
        
        WindowsFeature DotNET35 
                                
        {
           Ensure = "Present"
           Name   = "NET-Framework-Core"
           #Source = $Node.DotNetSrc
        }

    }

# Remote Diffferential Compression required by Site Server and Distribution Point

    node $AllNodes.Where{$_.Role -contains "SiteServer" -or $_.Role -contains "DistributionPoint"}.Nodename
    {
        
        WindowsFeature RemoteDifferentialCompression
        {
           Ensure = "Present"
           Name   = "RDC"
        }
      

     }

# WSUS Console - Required on site servers even when WSUS is installed on a remote server (not required if you've no software update points)

    node $AllNodes.Where{$_.Role -contains "SiteServer"}.Nodename
    {
             
        WindowsFeature WsusConsole #WSUS Console required on site server if there is a Software Update Point in the site
        {                  
           Ensure = "Present"
           Name   = "UpdateServices-RSAT"
        }
    }

# Remote registry service present and running required for site database server

    node $AllNodes.Where{$_.Role -contains "Database"}.Nodename
    {
        Service RemoteRegistry #Required on the site database server
        {
            Ensure = 'Present'
            State = 'Running'
            Name = 'RemoteRegistry'
        }

    }

# BITS required only on Management Point

    node $AllNodes.Where{$_.Role -contains "ManagementPoint"}.Nodename
    {

        WindowsFeature BITS #Required for Management Point role only
        {
           Ensure = "Present"
           Name   = "BITS"
        }
    }

# Default Web Server (IIS) install required on Management Point, Distribution Point, Software Update Point, Enrollment Point, Application Catalog Web Service Point,
# Application Catalog Website Point, Enrollment Proxy Point, Fallback Status Point, Certificate Registration Point

    node $AllNodes.Where{`
        $_.Role -contains "ManagementPoint" `
    -or $_.Role -contains "DistributionPoint" `
    -or $_.Role -contains "SoftwareUpdatePoint"`
    -or $_.Role -contains "SoftwareUpdatePointSQL"`
    -or $_.Role -contains "EnrollmentPoint"`
    -or $_.Role -contains "ApplicationCatalogWebServicePoint"`
    -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
    -or $_.Role -contains "EnrollmentProxyPoint"`
    -or $_.Role -contains "FallbackStatusPoint"`
    -or $_.Role -contains "CertificateRegistrationPoint"`
    }.Nodename

    {
        WindowsFeature WebServer #Default Web Server (IIS) Install
        {                  
           Ensure = "Present"
           Name   = "Web-Server"
        }
       
    }

# ISAPI extensions required by Distribution Point and Management Point

    node $AllNodes.Where{$_.Role -contains "ManagementPoint" -or $_.Role -contains "DistributionPoint"}.Nodename
    {
        
        WindowsFeature IsapiExtensions
        {
           Ensure = "Present"
           Name   = "Web-ISAPI-Ext"
           DependsOn = '[WindowsFeature]WebServer'
        }

     }

# IIS6 WMI Compatibility required by Distribution Point, Management Point and Certificate Registration Point

    node $AllNodes.Where{$_.Role -contains "ManagementPoint" -or $_.Role -contains "DistributionPoint" -or $_.Role -contains "CertificateRegistrationPoint"}.Nodename
    {
        
        WindowsFeature IIS6WMICompatibility #Required for Distribution Point, Management Point and Certificate Registration Point
        {                  
           Ensure = "Present"
           Name   = "Web-WMI"
           DependsOn = '[WindowsFeature]WebServer'
        }
    }

# Windows Authentication required by Distribution Point, Management Point, Enrollment Proxy Point, Application Catalog Website Point

    node $AllNodes.Where{$_.Role -contains "ManagementPoint" -or $_.Role -contains "DistributionPoint" -or $_.Role -contains "EnrollmentProxyPoint" -or $_.Role -contains "ApplicationCatalogWebsitePoint"}.Nodename
    {
        
        WindowsFeature WindowsAuth #Required for Distribution Point, Management Point, Enrollment Proxy Point, Application Catalog Website Point
        {                  
           Ensure = "Present"
           Name   = "Web-Windows-Auth"
           DependsOn = '[WindowsFeature]WebServer'
        }

    }


# IIS6 Metabase Compatibility required for Distribution Point, Management Point, Enrollment Proxy Point, Fallback Status Point, Enrollment Point, Certificate Registration Point,
# Application Catalog Website Point, Application Catalog Web Service Point.
 
    node $AllNodes.Where{`
        $_.Role -contains "DistributionPoint"`
    -or $_.Role -contains "ManagementPoint"`
    -or $_.Role -contains "EnrollmentProxyPoint"`
    -or $_.Role -contains "FallbackStatusPoint"`
    -or $_.Role -contains "EnrollmentPoint"`
    -or $_.Role -contains "CertificateRegistration Point"`
    -or $_.Role -contains "ApplicationCatalogWebServicePoint"`
    -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
    }.Nodename

    {

        WindowsFeature IIS6MetabaseCompatibility #Required for Distribution Point, Management Point, Enrollment Proxy Point, Fallback Status Point, Enrollment Point, Certificate Registration Point,
        {                                        #Application Catalog Website Point, Application Catalog Web Service Point.
           Ensure = "Present"
           Name   = "Web-Metabase"
           DependsOn = '[WindowsFeature]WebServer'
        }

    }

# Dot Net 4.5 HTTP Activation Required for Application Catalog Web Service Point, Certificate Registration Point, Enrollment Point

    node $AllNodes.Where{$_.Role -contains "ApplicationCatalogWebServicePoint" -or $_.Role -contains "CertificateRegistrationPoint" -or $_.Role -contains "EnrollmentPoint"}.Nodename
    {
        WindowsFeature DotNET45HTTPActivation #Required for Application Catalog Web Service Point, Certificate Registration Point, Enrollment Point
        {
           Ensure = "Present"
           Name   = "NET-WCF-HTTP-Activation45"
           DependsOn = '[WindowsFeature]WebServer'
        }

    }

# Dot Net Extensibility 3.5 required for Enrollment Proxy Point, Enrollment Point, Application Catalog Website Point, Application Catalog Web Service Point.
    
    node $AllNodes.Where{`
            $_.Role -contains "ApplicationCatalogWebServicePoint"`
        -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
        -or $_.Role -contains "EnrollmentPoint"`
        -or $_.Role -contains "EnrollmentProxyPoint"`
        }.Nodename

    {
        WindowsFeature DotNetExtensibility35     #Required for Enrollment Proxy Point, Enrollment Point
        {                                        #Application Catalog Website Point, Application Catalog Web Service Point.
           Ensure = "Present"
           Name   = "Web-Net-Ext"
           DependsOn = '[WindowsFeature]WebServer'
        }

    }

# Dot Net Extensibility 4.5 required for Enrollment Proxy Point, Enrollment Point, Application Catalog Website Point, Application Catalog Web Service Point.
    
    node $AllNodes.Where{`
            $_.Role -contains "ApplicationCatalogWebServicePoint"`
        -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
        -or $_.Role -contains "EnrollmentPoint"`
        -or $_.Role -contains "EnrollmentProxyPoint"`
        }.Nodename

    {
        WindowsFeature DotNetExtensibility45     #Required for Enrollment Proxy Point, Enrollment Point
        {                                        #Application Catalog Website Point, Application Catalog Web Service Point.
           Ensure = "Present"
           Name   = "Web-Net-Ext45"
           DependsOn = '[WindowsFeature]WebServer'
        }

    }

# ASP .NET 3.5 required for Enrollment Proxy Point, Enrollment Point, Application Catalog Website Point, Application Catalog Web Service Point, Certificate Registration Point.
    
    node $AllNodes.Where{`
            $_.Role -contains "ApplicationCatalogWebServicePoint"`
        -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
        -or $_.Role -contains "EnrollmentPoint"`
        -or $_.Role -contains "EnrollmentProxyPoint"`
        -or $_.Role -contains "CertificateRegistrationPoint"`
        }.Nodename

    {
        WindowsFeature AspNet35                  #Required for Enrollment Proxy Point, Enrollment Point, Certificate Registration Point,
        {                                        #Application Catalog Website Point, Application Catalog Web Service Point.
           Ensure = "Present"
           Name   = "Web-Asp-Net"
           DependsOn = '[WindowsFeature]WebServer'
        }

    }

# ASP .NET 4.5 required for Enrollment Proxy Point, Enrollment Point, Application Catalog Website Point, Application Catalog Web Service Point, Certificate Registration Point.
    
    node $AllNodes.Where{`
            $_.Role -contains "ApplicationCatalogWebServicePoint"`
        -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
        -or $_.Role -contains "EnrollmentPoint"`
        -or $_.Role -contains "EnrollmentProxyPoint"`
        -or $_.Role -contains "CertificateRegistrationPoint"`
        }.Nodename

    {
        WindowsFeature AspNet45                  #Required for Enrollment Proxy Point, Enrollment Point, Certificate Registration Point,
        {                                        #Application Catalog Website Point, Application Catalog Web Service Point.
           Ensure = "Present"
           Name   = "Web-Asp-Net45"
           DependsOn = '[WindowsFeature]WebServer'
        }

    }

# Dot Net Framework 4.5 ASP required for Application Catalog Website Point, Application Catalog Web Service Point, Enrollment Point.
    
    node $AllNodes.Where{`
            $_.Role -contains "ApplicationCatalogWebServicePoint"`
        -or $_.Role -contains "ApplicationCatalogWebsitePoint"`
        -or $_.Role -contains "EnrollmentPoint"`
        }.Nodename

    {
        WindowsFeature DotNET45ASP #Required for Application Catalog Website Point, Application Catalog Web Service Point, Enrollment Point.
        {
           Ensure = "Present"
           Name   = "NET-Framework-45-ASPNET"
        } 

    }

# Standard WSUS installation for Software Update Point using WID (Windows Internal Database)

    node $AllNodes.Where{$_.Role -contains "SoftwareUpdatePoint"}.Nodename
    {
             
        WindowsFeature Wsus #WSUS default installation with WID (Windows Internal Database)
        {                  
           Ensure = "Present"
           Name   = "UpdateServices"
        }
    }

# WSUS components for a Software Update Point that uses SQL instead of WID

    node $AllNodes.Where{$_.Role -contains "SoftwareUpdatePointSQL"}.Nodename
    {
             
        WindowsFeature WsusServices #WSUS
        {                  
           Ensure = "Present"
           Name   = "UpdateServices-Services"

        }

        WindowsFeature WsusSQL #WSUS SQL DB Connectivity
        {                  
           Ensure = "Present"
           Name   = "UpdateServices-DB"

        }
    }

}

sccmpr -ConfigurationData $ConfigDataFile