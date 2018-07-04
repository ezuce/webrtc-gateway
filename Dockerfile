FROM ubuntu:16.04
MAINTAINER martin harcar <martin.harcar@ezuce.com>

# Copy installation scripts in
COPY *.sh ./

# Prepare the system
RUN ./install_depends.sh

# Install libsrtp 2.0.0
RUN ./libsrtp.sh

# Compile & install Janus
RUN ./install_janus.sh

# Put configs in place
COPY conf/*.cfg /opt/janus/etc/janus/

# Put certs in place
COPY certs/* /opt/janus/share/janus/certs/

# Declare the ports we use
EXPOSE 8088 8089

EXPOSE 30000-31000/udp

# Define the default start-up command
CMD ./startup.sh
