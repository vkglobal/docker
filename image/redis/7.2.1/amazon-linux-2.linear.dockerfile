# This is the base OCI image used for this Dockerfile execution.
# Source Docker image used for this build process.
FROM sloopstash/amazon-linux-2:v1.1.1


# Install system packages and dependencies required for Redis database server.
RUN set -x \
  && yum install -y tcl

# Run commands create and complile the container lifecycle
# Download and extract Redis from source archives.
WORKDIR /tmp
RUN set -x \
  && wget http://download.redis.io/releases/redis-7.2.1.tar.gz --quiet \
  && tar xvzf redis-7.2.1.tar.gz > /dev/null


# Compile and install Redis from its source code.
WORKDIR /tmp/redis-7.2.1
RUN set -x \
&& make \
&& make install


# Create required directories to customize and run Redis database server.
RUN set -x \
&& rm -rf /tmp/redis-* \
&& mkdir /opt/redis \
&& mkdir /opt/redis/data \
&& mkdir /opt/redis/log \
&& mkdir /opt/redis/conf \
&& mkdir /opt/redis/script \
&& mkdir /opt/redis/system \
&& touch /opt/redis/system/server.pid \
&& touch /opt/redis/system/supervisor.ini \
&& history -c