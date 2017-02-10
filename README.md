# dsc-sccm
Powershell DSC Configurations for SCCM

SCCMPR.ps1 - This Powershell DSC Configuration allows you to specify the roles intended for each server and it will produce a MOF for each containing the pre-requisite windows features.

Usage: sccmpr.ps1 -ConfigDataFile sccmexampleconfig.psd1

SccmExampleConfig.PSD1 - Example configuration data for a primary site server "sccm01" and a software update point "sccmwsus01" with WID database.
