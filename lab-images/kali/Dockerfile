ARG BASE_IMAGE=ghcr.io/m1k1o/neko/xfce:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="HackLab Kali"
LABEL org.opencontainers.image.description="HackLab branded security training desktop with common Kali-style tools."

USER root

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        dnsutils \
        file \
        gobuster \
        hydra \
        iproute2 \
        iputils-ping \
        john \
        netcat-openbsd \
        nmap \
        python3 \
        python3-pip \
        sqlmap \
        tcpdump \
        traceroute \
        vim \
        whois \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY workspace-branding/hacklab-logo.svg /var/www/img/logo.800bec71.svg
COPY workspace-branding/apply-hacklab-branding.sh /tmp/apply-hacklab-branding.sh
COPY client/public/hacklab-icon-16x16.png /var/www/favicon-16x16.png
COPY client/public/hacklab-icon-32x32.png /var/www/favicon-32x32.png
COPY client/public/hacklab-icon-32x32.png /var/www/apple-touch-icon.png

RUN sh /tmp/apply-hacklab-branding.sh && rm /tmp/apply-hacklab-branding.sh
