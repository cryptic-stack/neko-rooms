ARG BASE_IMAGE=dockurr/windows:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="HackLab Windows"
LABEL org.opencontainers.image.description="HackLab Windows VM lab image based on dockurr/windows."
LABEL org.opencontainers.image.url="https://github.com/dockur/windows"
LABEL m1k1o.neko_rooms.frontend_port="8006"
LABEL m1k1o.neko_rooms.stats="false"
LABEL m1k1o.neko_rooms.bind_mounts="/dev/kvm:/dev/kvm,/dev/net/tun:/dev/net/tun"

ENV VERSION=10 \
    RAM_SIZE=4G \
    CPU_CORES=2 \
    DISK_SIZE=30G
