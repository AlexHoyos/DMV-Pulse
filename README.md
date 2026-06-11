# DMV-Pulse Data API Builder (DAB) Project

This project uses Microsoft's **Azure Data API Builder (DAB)** to expose database tables, views, and stored procedures as REST and MCP (Model Context Protocol) endpoints. It is paired with a SQL database project that contains the database schemas and monitoring procedures.

---

## 📋 Table of Contents
1. [Prerequisites](#-prerequisites)
2. [Environment Setup (`.env`)](#-environment-setup-env)
3. [Running the Data API Builder](#-running-the-data-api-builder)
4. [Database Setup (SQL Project)](#-database-setup-sql-project)
5. [API Endpoints](#-api-endpoints)

---

## 🛠️ Prerequisites

To run this project, you need:
- **.NET 8.0 SDK** or later (to install and run the DAB CLI locally)
- Alternatively, **Docker** (to run DAB inside a container)
- A running instance of **SQL Server** (local or Azure SQL Database)

---

## 🔑 Environment Setup (`.env`)

The DAB configuration file [dab-config.json] references environment variables for database connections, authentication, and telemetry.

To configure your environment:

1. Copy the provided [development.env] template to a new file named `.env`:
   ```bash
   cp development.env .env
   ```
   > [!IMPORTANT]
   > Do **not** commit your `.env` file to version control. It is already added to `.gitignore` to keep credentials secure.

2. Populate the `.env` file with your environment-specific configurations:

   ```env
   # Database connection string
   DAB_CONN_STRING="Server=tcp:127.0.0.1,1433;Initial Catalog=dmvpulse;User Id=sa;Password=YourSecurePassword123;Encrypt=True;TrustServerCertificate=True;"

   # Audience for Azure AD (Microsoft Entra ID) JWT Authentication
   AD_CLIENT_ID="your-azure-ad-client-id"

   # OpenTelemetry configurations (Optional, for monitoring)
   OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"
   OTEL_EXPORTER_OTLP_HEADERS="api-key=your-otel-key"
   OTEL_SERVICE_NAME="dmvpulse-data-api"
   ```

---

## 🚀 Running the Data API Builder

You can run the API engine locally using either the .NET DAB CLI or Docker.

### Option A: Using the .NET CLI (Recommended)

1. **Install the CLI globally:**
   ```bash
   dotnet tool install -g Microsoft.DataApiBuilder
   ```
   *(If already installed, you can update it using `dotnet tool update -g Microsoft.DataApiBuilder`)*

2. **Verify the installation:**
   ```bash
   dab --version
   ```

3. **Start the API engine:**
   Execute the following command in the root folder of this project:
   ```bash
   dab start --config dab-config.json
   ```
   > [!NOTE]
   > DAB will automatically look for a `.env` file in the same directory, load the variables, and start the engine on `http://localhost:5000` (or the port configured by the runtime).

---

### Option B: Using Docker

If you prefer containerized execution, run:

```bash
docker run -it -p 5000:5000 \
  -v "$(pwd)":/App/config \
  --env-file .env \
  mcr.microsoft.com/azure-databases/data-api-builder \
  --ConfigFileName /App/config/dab-config.json
```

---

## 🗄️ Database Setup (SQL Project)

The schemas, stored procedures, and tables are defined in the SQL Project located in the [DMVPulse-SqlProj/] directory.

To build and deploy the database:
1. Navigate to the SQL Project directory:
   ```bash
   cd DMVPulse-SqlProj
   ```
2. Follow the detailed steps in [DMVPulse-SqlProj/README.md] to:
   - Install `sqlpackage`.
   - Build the database schema: `dotnet build`.
   - Publish it using a publish profile: `sqlpackage /Action:Publish ...`.