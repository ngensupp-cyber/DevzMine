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
    qemu-kvm \
    qemu-utils \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virtinst \
    ovmf \
    net-tools \
    iproute2 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# XRDP Fix
RUN echo "startxfce4" > /etc/skel/.xsession && \
    echo "startxfce4" > /root/.xsession && \
    sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini

# User
RUN useradd -m -s /bin/bash admin && \
    echo "admin:UltraStrong123" | chpasswd && \
    adduser admin sudo && \
    adduser admin libvirt

# Create disk
RUN qemu-img create -f qcow2 /home/admin/vm.qcow2 20G

# Start Script
RUN echo '#!/bin/bash\n\
service dbus start\n\
service xrdp start\n\
sleep 3\n\
qemu-system-x86_64 \\\n\
-enable-kvm \\\n\
-cpu host \\\n\
-smp 4 \\\n\
-m 4096 \\\n\
-drive file=/home/admin/vm.qcow2,format=qcow2 \\\n\
-net nic -net user \\\n\
-vga virtio \\\n\
-display none \\\n\
-vnc :1 &\n\
tail -f /dev/null' > /start.sh && chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
