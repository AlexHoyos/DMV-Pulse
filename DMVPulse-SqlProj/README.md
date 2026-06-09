# DMV-Pulse SQL Project

## Build

To build the project, run the following command:

```bash
dotnet build
```

This will generate a dacpac "bin/Debug/DMVPulse-SqlProj.dacpac"

## Publish

To publish the project, the SqlPackage CLI or the SQL Database Projects extension for VS Code is required. The following command will publish the project to a local SQL Server instance using the default dmv profile:

```bash
sqlpackage /Action:Publish /SourceFile:bin/Debug/DMVPulse_SqlProj.dacpac /Profile:"dmvpulse-publish.xml" /p:ConnectionString=ConnectionString /p:TargetDatabaseName=MyDatabase
```

### Install SqlPackage CLI

The usage of the sqlpackage command requires to install the package :)

Try it out
```bash
dotnet tool install -g microsoft.sqlpackage
```
