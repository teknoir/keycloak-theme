# Build the Teknoir custom Keycloak theme image.
# The theme files are copied into /opt/keycloak/themes/ so that Keycloak
# picks them up automatically on startup without any additional configuration.
ARG KEYCLOAK_VERSION=26.5.3
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

COPY themes/teknoir-theme /opt/keycloak/themes/teknoir-theme
