FROM docker:29-dind

LABEL org.opencontainers.image.title="HackLab DFIR-IRIS"
LABEL org.opencontainers.image.description="HackLab DFIR-IRIS incident response platform lab image."
LABEL org.opencontainers.image.url="https://github.com/dfir-iris/iris-web"
LABEL m1k1o.neko_rooms.frontend_port="443"
LABEL m1k1o.neko_rooms.stats="false"

ENV IRIS_VERSION=v2.4.27

RUN apk add --no-cache bash curl docker-cli-compose nginx openssl

WORKDIR /opt/hacklab/dfir-iris

COPY lab-images/dfir-iris/docker-compose.yml /opt/hacklab/dfir-iris/docker-compose.yml
COPY lab-images/dfir-iris/entrypoint.sh /usr/local/bin/hacklab-dfir-iris

RUN chmod +x /usr/local/bin/hacklab-dfir-iris

EXPOSE 443

HEALTHCHECK --interval=15s --timeout=5s --start-period=5m --retries=20 \
    CMD curl -fsS http://127.0.0.1:443/ >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/hacklab-dfir-iris"]
