FROM grafana/grafana:latest

USER root

ENV GF_AUTH_ANONYMOUS_ENABLED=true

RUN mkdir -p /var/lib/grafana/dashboards

RUN curl -o /var/lib/grafana/dashboards/dashboard.json https://grafana.com/api/dashboards/21378/revisions/4/download

COPY ./dashboards.yml /etc/grafana/provisioning/dashboards/default.yml
COPY ./datasource.yml /etc/grafana/provisioning/datasources/default.yml