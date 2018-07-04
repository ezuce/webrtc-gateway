cd ~
git clone https://github.com/meetecho/janus-gateway.git
cd janus-gateway
sh autogen.sh
./configure --prefix=/opt/janus --disable-rabbitmq --disable-mqtt --disable-websockets --disable-data-channels --disable-plugin-lua
make
make install
make configs
