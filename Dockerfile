FROM mcr.microsoft.com/playwright:v1.46.0-noble

# Update everything
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y xvfb dbus-x11 \
    git openjdk-11-jdk unzip \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer \
    novnc python3-websockify python3-numpy nginx && \
    apt clean
RUN rm -rf /var/lib/apt/lists/*

# Get Maven
ARG MAVEN_VERSION="3.9.9"
RUN wget -O /tmp/maven.zip \
    https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip && \
    unzip /tmp/maven.zip -d /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven

# VNC Setup
RUN touch /home/ubuntu/.Xauthority
COPY docker-assets/xstartup /home/ubuntu/.vnc/xstartup
RUN chmod +x /home/ubuntu/.vnc/xstartup
RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html
COPY docker-assets/nginx.conf /etc/nginx/nginx.conf

# Copy script, fix permissions
COPY docker-assets/entry.sh /home/ubuntu/entry.sh
RUN chmod +x /home/ubuntu/entry.sh
RUN chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
RUN ssh-keygen -t rsa -N "" -f /home/ubuntu/.ssh/id_rsa
EXPOSE 6081
RUN mkdir -p /home/ubuntu/tests
VOLUME /home/ubuntu/tests

ENTRYPOINT [ "/bin/bash", "/home/ubuntu/entry.sh" ]
