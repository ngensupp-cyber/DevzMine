FROM --platform=linux/amd64 debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    xrdp \
    dbus-x11 \
    sudo \
    curl \
    wget \
    ca-certificates \
    firefox-esr \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "startxfce4" > /etc/skel/.xsession && \
    echo "startxfce4" > /root/.xsession

RUN useradd -m -s /bin/bash user && \
    echo "user:1234" | chpasswd && \
    adduser user sudo

EXPOSE 3389

CMD ["/usr/sbin/xrdp", "--nodaemon"]
