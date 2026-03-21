FROM mcr.microsoft.com/mssql/server:2025-latest

ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=SqlServerDemo2025!
ENV MSSQL_PID=Developer

USER root

RUN apt-get update && \
    apt-get install -y mssql-tools18 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY TSQLV6.sql /tmp/TSQLV6.sql

# Convert UTF-16LE to UTF-8 so sqlcmd can process it reliably
RUN iconv -f UTF-16LE -t UTF-8 /tmp/TSQLV6.sql -o /tmp/TSQLV6_utf8.sql

# Ensure mssql user owns its data directories and can access setup files
RUN chown -R mssql:mssql /var/opt/mssql && \
    chown mssql:mssql /tmp/TSQLV6.sql /tmp/TSQLV6_utf8.sql

USER mssql

# Start SQL Server, wait for it to be ready, run the setup script, then stop
# The final entrypoint will start SQL Server normally
RUN (/opt/mssql/bin/sqlservr &) && \
    for i in $(seq 1 30); do \
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" > /dev/null 2>&1 && break; \
        sleep 1; \
    done && \
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i /tmp/TSQLV6_utf8.sql && \
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "ALTER DATABASE TSQLV6 SET COMPATIBILITY_LEVEL = 170" && \
    pkill sqlservr && \
    sleep 5 && \
    rm -f /tmp/TSQLV6.sql /tmp/TSQLV6_utf8.sql

EXPOSE 1433

CMD ["/opt/mssql/bin/sqlservr"]
