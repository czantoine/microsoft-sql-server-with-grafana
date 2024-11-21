FROM grafana/grafana:latest

USER root

ENV GF_AUTH_ANONYMOUS_ENABLED=true

RUN mkdir -p /var/lib/grafana/dashboards

RUN curl -o /var/lib/grafana/dashboards/dashboard.json https://grafana.com/api/dashboards/21378/revisions/6/download

RUN sed -i 's/"uid": *"\${DS_MSSQL}"/"uid": ""/g' /var/lib/grafana/dashboards/dashboard.json

COPY ./quickstart/grafana/dashboards.yml /etc/grafana/provisioning/dashboards/default.yml
COPY ./quickstart/grafana/datasource.yml /etc/grafana/provisioning/datasources/default.yml
