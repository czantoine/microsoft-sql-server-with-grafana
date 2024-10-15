FROM mcr.microsoft.com/mssql/server:2019-latest

WORKDIR /tmp

USER root

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=YourStrong@Passw0rd
ENV MSSQL_PID=Developer

COPY db/create_db.sql .
COPY db/insert_data.sql .
COPY db/init-db.sh .

RUN chmod +x ./init-db.sh

ENTRYPOINT ["./init-db.sh"]
