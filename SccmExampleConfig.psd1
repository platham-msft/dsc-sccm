#paulath@microsoft.com 07/02/2017 - Sample ConfigurationData file for use with SCCMPR v0.5

# When using DSC Push the "NodeName" must match the hostname of the server you are applying the configuration to
# Anything defined under NodeName "*" is applied to all nodes

# Possible Roles are: 
# "SiteServer", "Database", "ManagementPoint", "DistributionPoint", "EnrollmentPoint", "ApplicationCatalogWebServicePoint"
# "EnrollmentProxyPoint",  "FallbackStatusPoint", "CertificateRegistrationPoint", "ApplicationCatalogWebsitePoint", "EndpointProtectionPoint"

# "SoftwareUpdatePoint" - for using WSUS with WID (Windows Internal Database) or "SoftwareUpdatePointSQL" for using WSUS with SQL

@{

    AllNodes = @(

        @{
            NodeName        = "*"
            DotNetSrc       = "\\winfile01\s2016\winsxs"
        },

        @{
            NodeName         = "sccm01"
            Role             = "SiteServer", "Database", "ManagementPoint", "DistributionPoint", "EndpointProtectionPoint"
        },

        @{
            NodeName         = "sccmwsus01"
            Role             = "SoftwareUpdatePoint"
        }
    )
    
}