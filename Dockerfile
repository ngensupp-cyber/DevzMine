FROM --platform=linux/amd64 debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# تحديث وتثبيت الحزم الأساسية فقط
RUN apt update && apt install -y --no-install-recommends \
    xfce4 \
    tigervnc-standalone-server \
    novnc \
    websockify \
    xterm \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    firefox-esr \
    curl \
    wget \
    ca-certificates \
    openssl \
    sudo \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# إنشاء Xauthority
RUN touch /root/.Xauthority

# فتح البورتات
EXPOSE 5901
EXPOSE 6080

# تشغيل VNC + noVNC
CMD bash -c "\
mkdir -p ~/.vnc && \
echo '123456' | vncpasswd -f > ~/.vnc/passwd && \
chmod 600 ~/.vnc/passwd && \
vncserver -localhost no -geometry 1280x720 && \
openssl req -new -subj '/C=US' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
websockify --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 \
"
