# Dockerfile
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Add 32-bit architecture and update repositories
RUN dpkg --add-architecture i386 && apt-get update

# Install required packages: Wine, Xvfb, x11vnc, Fluxbox, wget, and openssl (for password generation)
RUN apt-get install -y \
    wine wine32 xvfb x11vnc fluxbox wget openssl sudo

# Download and install MetaTrader 5 (update the URL and silent flags as needed)
RUN wget -O /tmp/mt5setup.exe "https://download-link-for-mt5/setup.exe" && \
    xvfb-run wine /tmp/mt5setup.exe /S && \
    rm /tmp/mt5setup.exe

# Setup VNC password using the environment variable VNC_PASSWORD (default provided for build)
ENV VNC_PASSWORD=changeme
RUN mkdir -p /root/.vnc && \
    echo ${VNC_PASSWORD} | x11vnc -storepasswd - /root/.vnc/passwd

# Expose the VNC port (inside container, always 5900)
EXPOSE 5900

# Start Fluxbox, then start x11vnc, and finally run MetaTrader 5 using Xvfb
CMD ["bash", "-c", "fluxbox & x11vnc -forever -usepw -create & xvfb-run wine 'C:/Program Files/MetaTrader 5/terminal64.exe'"]