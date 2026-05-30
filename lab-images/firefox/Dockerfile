ARG BASE_IMAGE=ghcr.io/m1k1o/neko/firefox:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="HackLab Firefox"
LABEL org.opencontainers.image.description="HackLab branded Firefox browser lab image."

ENV USER=student \
    HOME=/home/student \
    XDG_RUNTIME_DIR=/tmp/runtime-hacklab \
    NEKO_PLUGINS_DIR=/etc/hacklab/plugins/ \
    HACKLAB_SHELL_USER=student \
    HACKLAB_SHELL_HOST=hacklab

COPY workspace-branding/apply-hacklab-branding.sh /tmp/apply-hacklab-branding.sh
COPY client/public/hacklab-icon-16x16.png /var/www/favicon-16x16.png
COPY client/public/hacklab-icon-32x32.png /var/www/favicon-32x32.png
COPY workspace-branding/hacklab-icon-70x70.png /var/www/mstile-70x70.png
COPY workspace-branding/hacklab-icon-144x144.png /var/www/mstile-144x144.png
COPY workspace-branding/hacklab-icon-150x150.png /var/www/mstile-150x150.png
COPY workspace-branding/hacklab-icon-192x192.png /var/www/android-chrome-192x192.png
COPY workspace-branding/hacklab-icon-192x192.png /var/www/apple-touch-icon.png
COPY workspace-branding/hacklab-icon-310x310.png /var/www/mstile-310x150.png
COPY workspace-branding/hacklab-icon-310x310.png /var/www/mstile-310x310.png
COPY workspace-branding/hacklab-icon-512x512.png /var/www/android-chrome-512x512.png
COPY workspace-branding/hacklab-logo.svg /var/www/safari-pinned-tab.svg

RUN sh /tmp/apply-hacklab-branding.sh && rm /tmp/apply-hacklab-branding.sh

CMD ["/usr/bin/supervisord", "-c", "/etc/hacklab/supervisord.conf"]
