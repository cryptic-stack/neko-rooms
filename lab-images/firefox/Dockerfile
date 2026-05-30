ARG BASE_IMAGE=ghcr.io/m1k1o/neko/firefox:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="HackLab Firefox"
LABEL org.opencontainers.image.description="HackLab branded Firefox browser lab image."

COPY workspace-branding/hacklab-logo.svg /var/www/img/logo.800bec71.svg
COPY workspace-branding/apply-hacklab-branding.sh /tmp/apply-hacklab-branding.sh
COPY client/public/hacklab-icon-16x16.png /var/www/favicon-16x16.png
COPY client/public/hacklab-icon-32x32.png /var/www/favicon-32x32.png
COPY client/public/hacklab-icon-32x32.png /var/www/apple-touch-icon.png

RUN sh /tmp/apply-hacklab-branding.sh && rm /tmp/apply-hacklab-branding.sh
