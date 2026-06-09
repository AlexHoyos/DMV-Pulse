# DMV-Pulse SQL Project

## Build

To build the project, run the following command:

```bash
dotnet build
```

This will generate a dacpac "bin/Debug/DMVPulse-SqlProj.dacpac"

## Publish

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
