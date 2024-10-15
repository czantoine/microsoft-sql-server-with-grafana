FROM mcr.microsoft.com/mssql/server:2019-latest

WORKDIR /tmp

USER root

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=YourStrong@Passw0rd
ENV MSSQL_PID=Developer

COPY ./quickstart/db/create_db.sql .
COPY ./quickstart/db/insert_data.sql .
COPY ./quickstart/db/init-db.sh .

RUN chmod +x ./init-db.sh

ENTRYPOINT ["./init-db.sh"]
