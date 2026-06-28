##################### BEGIN STAGE #####################
# Source Docker image used for this stage build process.
# In this stage, we are installing the essential system packages
# required for Redis database server.
FROM sloopstash/amazon-linux-2:v1.1.1 AS install_system_packages

# Install system packages and dependencies required for Redis database server.
RUN yum install -y tcl
##################### END STAGE #####################

##################### BEGIN STAGE #####################
# This stage depends on `install_system_packages` stage to download,
# extract, build, and compile Redis database server from
# its source code.
FROM install_system_packages AS install_redis

# Download and extract Redis from source archives.
WORKDIR /tmp
RUN set -x \
  && wget http://download.redis.io/releases/redis-7.2.1.tar.gz --quiet \
  && tar xvzf redis-7.2.1.tar.gz > /dev/null

# Compile and install Redis from its source code.
WORKDIR /tmp/redis-7.2.1
RUN set -x \
  && make distclean \
  && make \
  && make install
##################### END STAGE #####################

##################### BEGIN STAGE #####################
# This stage used to create required directories for Redis
# database server.
FROM sloopstash/amazon-linux-2:v1.1.1 AS create_redis_directories

# Create required directories to customize and run Redis database server.
RUN set -x \
  && mkdir /opt/redis \
  && mkdir /opt/redis/data \
  && mkdir /opt/redis/log \
  && mkdir /opt/redis/conf \
  && mkdir /opt/redis/script \
  && mkdir /opt/redis/system \
  && touch /opt/redis/system/server.pid \
  && touch /opt/redis/system/supervisor.ini
##################### END STAGE #####################

###################### BEGIN STAGE #####################
# In this stage we are going to copy the required Redis binary
# executable programs and directories to the resultant Redis OCI
# image. 
FROM sloopstash/amazon-linux-2:v1.1.1 AS resultant_redis_oci_image

# Copy Redis binary executable programs.
COPY --from=install_redis /usr/local/bin/redis-server /usr/local/bin/redis-server

# Copy Redis directories.
COPY --from=create_redis_directories /opt/redis /opt/redis
##################### END STAGE #####################

 