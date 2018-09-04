FROM ubuntu:16.04
MAINTAINER martin harcar <martin.harcar@ezuce.com>

RUN apt-get update && apt-get install -y \
        build-essential \
        autoconf \
        automake \
        cmake

### Utils ###
RUN apt-get update && apt-get install -y \
        vim \
        curl \
        psmisc \
        nano \
        git \
        wget \
        unzip \
        python

### Janus ###
RUN apt-get update && apt-get install -y \
        libmicrohttpd-dev \
        libjansson-dev \
        #libsofia-sip-ua-dev \
        libglib2.0-dev \
        libevent-dev \
        libtool \
        gengetopt \
        libssl-dev \
        openssl \
        libcurl4-openssl-dev \
        libopus-dev \
        libogg-dev
	#golang
RUN cd /root && wget https://nice.freedesktop.org/releases/libnice-0.1.13.tar.gz && \
        tar xvf libnice-0.1.13.tar.gz && \
        cd libnice-0.1.13 && \
        ./configure --prefix=/usr && \
        make && \
        make install

RUN cd /root && wget https://github.com/cisco/libsrtp/archive/v2.0.0.tar.gz -O libsrtp-2.0.0.tar.gz && \
        tar xfv libsrtp-2.0.0.tar.gz && \
        cd /root/libsrtp-2.0.0 && \
        ./configure --prefix=/usr --enable-openssl && \
        make shared_library && \
        make install
# Put certs in place
COPY patches/* /root/
RUN cd /root && wget http://conf.meetecho.com/sofiasip/sofia-sip-1.12.11.tar.gz && \
        tar xfv sofia-sip-1.12.11.tar.gz && \
        cd sofia-sip-1.12.11 && \
        #wget http://conf.meetecho.com/sofiasip/0001-fix-undefined-behaviour.patch && \
        #wget http://conf.meetecho.com/sofiasip/sofiasip-semicolon-authfix.diff && \
        patch -p1 -u < /root/0001-fix-undefined-behaviour.patch && \
        patch -p1 -u < /root/sofiasip-semicolon-authfix.diff && \
        ./configure --prefix=/usr && \
        make && make install
RUN cd /root && git clone https://github.com/meetecho/janus-gateway.git
RUN cd /root/janus-gateway && \
	git pull && \
	#git checkout 198e4c9c1aca4a2356c50c07ff43967db4f20120 && \
        ./autogen.sh && \
        ./configure \
                --prefix=/opt/janus \
                --disable-docs \
                --disable-plugin-videoroom \
                --disable-plugin-streaming \
                --disable-plugin-audiobridge \
                --disable-plugin-textroom \
                --disable-plugin-recordplay \
                --disable-plugin-videocall \
                --disable-plugin-voicemail \
		--disable-plugin-lua \
		#--disable-plugin-echotest \
		--disable-plugin-nosip \
                --disable-rabbitmq \
                --disable-mqtt \
                --disable-unix-sockets \
                --disable-data-channels && \
                #--enable-boringssl && \
        make && \
        make install && \
        make configs
RUN sed -i "s/admin_http = no/admin_http = yes/g" /opt/janus/etc/janus/janus.transport.http.cfg
RUN sed -i "s/https = no/https = yes/g" /opt/janus/etc/janus/janus.transport.http.cfg
RUN sed -i "s/;secure_port = 8089/secure_port = 8089/g" /opt/janus/etc/janus/janus.transport.http.cfg
#RUN sed -i "s/wss = no/wss = yes/g" /opt/janus/etc/janus/janus.transport.websockets.cfg
#RUN sed -i "s/;wss_port = 8989/wss_port = 8989/g" /opt/janus/etc/janus/janus.transport.websockets.cfg
#RUN sed -i "s/enabled = no/enabled = yes/g" /opt/janus/etc/janus/janus.eventhandler.sampleevh.cfg
#RUN sed -i "s\^backend.*path$\backend = http://janus.click2vox.io:7777\g" /opt/janus/etc/janus/janus.eventhandler.sampleevh.cfg
#RUN sed -i s/grouping = yes/grouping = no/g /opt/janus/etc/janus/janus.eventhandler.sampleevh.cfg
#RUN sed -i "s/behind_nat = no/behind_nat = yes/g" /opt/janus/etc/janus/janus.plugin.sip.cfg
RUN sed -i "s/rtp_port_range = 20000-40000/rtp_port_range = 30000-31000/g" /opt/janus/etc/janus/janus.plugin.sip.cfg
RUN sed -i "s/;rtp_port_range = 20000-40000/rtp_port_range = 30000-31000/g" /opt/janus/etc/janus/janus.cfg
#RUN sed -i "s/;nat_1_1_mapping = 1.2.3.4/nat_1_1_mapping = 172.17.0.2/g" /opt/janus/etc/janus/janus.cfg
#RUN sed -i "s/;full_trickle = true/full_trickle = false/g" /opt/janus/etc/janus/janus.cfg

# Put certs in place
COPY certs/* /opt/janus/share/janus/certs/

# Declare the ports we use
EXPOSE 8088 8089

EXPOSE 30000-31000/udp

### Cleaning ###
RUN apt-get clean && apt-get autoclean && apt-get autoremove

ENTRYPOINT ["/opt/janus/bin/janus"]
