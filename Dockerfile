FROM ubuntu:latest

RUN apt update && \
    apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y dbus-x11 \
                   fcitx-mozc \
                   git \
                   kubuntu-desktop \
                   language-pack-ja \
                   python3 \
                   python3-numpy \
                   x11vnc \
                   xvfb

RUN apt install -y curl \
                   ffmpeg \
                   fontconfig \
                   kde-config-fcitx \
                   language-pack-kde-ja \
                   sudo \
                   unzip \
                   vim

RUN adduser user && \
    echo "user:user" | chpasswd && \
    usermod -aG sudo user

USER user

RUN mkdir /tmp/exec && \
    cd /tmp/exec/ && \
    curl -O http://moji.or.jp/wp-content/ipafont/IPAfont/IPAfont00303.zip && \
    unzip IPAfont00303.zip -d /tmp/exec && \
    rm -rf /tmp/exec/IPAfont00303.zip && \
    git clone https://github.com/novnc/noVNC && \
    cd /tmp/exec/noVNC/utils/ && \
    git clone https://github.com/novnc/websockify

COPY fcitx.tar /home/user/.config/fcitx.tar

RUN mkdir /home/user/.fonts && \
    mv /tmp/exec/IPAfont00303/ /home/user/.fonts/IPAfont00303/ && \
    fc-cache -fv && \
    mkdir -p /home/user/.local/share/konsole && \
    echo \
    '[General]\n \
     Command=/bin/bash\n \
     Directory=/home/user\n \
     Name=user\n \
     Parent=FALLBACK/' \
    > /home/user/.local/share/konsole/user.profile && \
    mkdir -p /home/user/.config && \
    echo \
    '[Desktop Entry]\n \
     DefaultProfile=user.profile\n' \
    > /home/user/.config/konsolerc && \
    cd /home/user/.config/ && \
    tar xf /home/user/.config/fcitx.tar && \
    rm -rf /home/user/.config/fcitx.tar

RUN echo \
    '#!/bin/bash\n \
     fcitx &\n \
     /tmp/exec/noVNC/utils/novnc_proxy &\n \
     Xvfb :1 -screen 0 1920x920x24 &\n \
     startplasma-x11 &\n \
     x11vnc -display :1' \
    > /tmp/exec/cmd.sh && \
    chmod u+x /tmp/exec/cmd.sh

CMD /tmp/exec/cmd.sh

ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP.UTF-8 \
    TZ=Asia/Tokyo \
    DISPLAY=:1 \
    DISPLAY_WIDTH=1920 \
    DISPLAY_HEIGHT=1080 \
    GTK_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx \
    QT_IM_MODULE=fcitx

EXPOSE 6080
