FROM quay.io/ukhomeofficedigital/mysql-java:v0.1.2

# Customisations to allow for schema updates using liquidbase Java file
# =====================================================================

ENV TERM dumb

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
