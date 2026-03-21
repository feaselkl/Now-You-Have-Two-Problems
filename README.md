# Now You Have Two Problems
## An Introduction to Regular Expressions in SQL Server 2025

This is the repository for my talk entitled [Now You Have Two Problems:  An Introduction to Regular Expressions in SQL Server 2025](https://csmore.info/on/regex).

## Setting Up SQL Server

The easiest way to get started is with the included Dockerfile, which installs SQL Server 2025 Developer Edition and pre-creates the TSQLV6 database.

### Build and Run

From the repository root:

```bash
docker build -t sql-regex-demos Scripts/Setup/
docker run -d --name sql-regex-demos -p 1433:1433 sql-regex-demos
```

This starts SQL Server on **localhost:1433** with the TSQLV6 database ready to go.

### Connection Details

| Setting  | Value                  |
|----------|------------------------|
| Server   | `localhost`            |
| Port     | `1433`                 |
| User     | `sa`                   |
| Password | `SqlServerDemo2025!`   |
| Database | `TSQLV6`               |

These defaults work directly with the VS Code mssql extension or any other SQL client.

### Stopping and Removing the Container

```bash
docker stop sql-regex-demos
docker rm sql-regex-demos
```

### Without Docker

If you prefer to install SQL Server directly, you will need SQL Server 2025 and the [TSQLV6](https://itziktsql.com/r-downloads) database. Run `Scripts/Setup/TSQLV6.sql` against your instance to create the database.

## Running the Code

All scripts are in the `Scripts` folder and can be run from SQL Server Management Studio, VS Code with the mssql extension, or whatever your SQL Server query runner of choice.
