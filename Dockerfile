FROM debian:12-slim

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
    qemu-system-x86 \
    qemu-utils \
    net-tools \
    iproute2 \
    openssl \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "startxfce4" > /etc/skel/.xsession && \
    echo "startxfce4" > /root/.xsession && \
    sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini

RUN useradd -m -s /bin/bash admin && \
    echo "admin:admin123" | chpasswd && \
    adduser admin sudo

RUN qemu-img create -f qcow2 /home/admin/vm.qcow2 10G

RUN echo '#!/bin/bash\n\
service xrdp start\n\
sleep 3\n\
su - admin -c "qemu-system-x86_64 -m 2048 -smp 2 -hda /home/admin/vm.qcow2 -vga std -display none -vnc :1 &"\n\
tail -f /dev/null' > /start.sh && chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
