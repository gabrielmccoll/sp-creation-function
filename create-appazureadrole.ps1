# Basic information
$description = "Can create service principals, also needs global reader"
$displayName = "SP-Principal-Creation-RLG"
$templateId = (New-Guid).Guid

# Set of actions to grant
$allowedResourceAction =
@(
    "microsoft.directory/applications.myOrganization/allProperties/read",
    "microsoft.directory/applications.myOrganization/allProperties/update",
    "microsoft.directory/applications.myOrganization/basic/update",
    "microsoft.directory/applications.myOrganization/credentials/update",
    "microsoft.directory/applications.myOrganization/owners/read",
    "microsoft.directory/applications.myOrganization/owners/update",
    "microsoft.directory/applications.myOrganization/permissions/update",
    "microsoft.directory/applications.myOrganization/standard/read",
    "microsoft.directory/applications/allProperties/read",
    "microsoft.directory/applications/allProperties/update",
    "microsoft.directory/applications/create",
    "microsoft.directory/applications/credentials/update",
    "microsoft.directory/applications/owners/read",
    "microsoft.directory/applications/owners/update",
    "microsoft.directory/servicePrincipals/allProperties/read",
    "microsoft.directory/servicePrincipals/allProperties/update",
    "microsoft.directory/servicePrincipals/appRoleAssignedTo/read",
    "microsoft.directory/servicePrincipals/appRoleAssignedTo/update",
    "microsoft.directory/servicePrincipals/authentication/update",
    "microsoft.directory/servicePrincipals/create",
    "microsoft.directory/servicePrincipals/credentials/update",
    "microsoft.directory/servicePrincipals/owners/read",
    "microsoft.directory/servicePrincipals/owners/update",
    "microsoft.directory/servicePrincipals/standard/read",
    "microsoft.directory/servicePrincipals/synchronizationCredentials/manage"
)
$rolePermissions = @{'allowedResourceActions'= $allowedResourceAction}

# Create new custom admin role
$customAdmin = New-AzureADMSRoleDefinition -RolePermissions $rolePermissions -DisplayName $displayName -Description $description -TemplateId $templateId -IsEnabled $true