# DMV-Pulse SQL Project

## Build

To build the project, run the following command:

```bash
dotnet build
```

This will generate a dacpac "bin/Debug/DMVPulse-SqlProj.dacpac"

## Publish

Create a publish profile:

A publish profile is an XML file that contains the settings required to publish your database project. To create a publish profile, follow these steps:

1. Open your project in Visual Studio or your preferred text editor.
2. Create a new XML file in the project directory and name it `dmvpulse-publish.xml`.
3. Add the following content to the file, replacing `<ConnectionString>` and `<DatabaseName>` with your actual connection string and database name:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
        <TargetConnectionString>Data Source=<ConnectionString>;Initial Catalog=<DatabaseName>;Integrated Security=True;</TargetConnectionString>
        <DeployDatabaseName><DatabaseName></DeployDatabaseName>
        <BlockOnPossibleDataLoss>True</BlockOnPossibleDataLoss>
    </PropertyGroup>
</Project>
```

4. Save the file in the project directory.

This profile can now be used with the `sqlpackage` command to publish your project.


To publish the project, the SqlPackage CLI or the SQL Database Projects extension for VS Code is required. The following command will publish the project to a local SQL Server instance using the default dmv profile, first replace the variables with the current connection string and database name, then execute this command:

```bash
sqlpackage /Action:Publish /SourceFile:"bin/Debug/DMVPulse-SqlProj.dacpac" /Profile:"dmvpulse-publish.xml"
```
### Install SqlPackage CLI

The usage of the sqlpackage command requires to install the package :)

Try it out
```bash
dotnet tool install -g microsoft.sqlpackage
```
