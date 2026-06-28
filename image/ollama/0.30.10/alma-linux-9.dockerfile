##################### BEGIN STAGE #####################
# Source Docker image to use required for Ollama-0.30.10
FROM sloopstash/alma-linux-9:v1.1.1 as install_system_packages

# Install system_packages and dependencies
RUN yum install -y tcl
##################### END STAGE #####################

##################### BEGIN STAGE #####################
# This stage depends on `install_system_packages` stage to download,
# extract, build, and compile Ollama model from
# its source code.

FROM install_system_packages AS install_ollama

# Download and extract Ollama from source archives.

RUN yum install -y zstd

WORKDIR /tmp
RUN set -x \
  && wget https://github.com/ollama/ollama/releases/download/v0.30.10/ollama-linux-amd64.tar.zst --quiet \
  && tar --use-compress-program=unzstd -xvf ollama-linux-amd64.tar.zst > /dev/null \
  && mkdir /usr/local/lib/ollama \
  && cp -r lib/ollama/* /usr/local/lib/ollama/ \
  && mv bin/ollama /usr/local/bin/ \
  && rm -rf ollama* lib bin
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_MODELS=/opt/ollama/model 


##################### END STAGE #####################

##################### BEGIN STAGE #####################
# Create Ollama required directories to customize 
RUN set -x \
  && mkdir /opt/ollama \
  && mkdir /opt/ollama/model \
  && mkdir /opt/ollama/data \
  && mkdir /opt/ollama/log \
  && mkdir /opt/ollama/conf \
  && mkdir /opt/ollama/script \
  && mkdir /opt/ollama/system \
  && touch /opt/ollama/system/server.pid \
  && touch /opt/ollama/system/supervisor.ini \
  && ln -s /opt/ollama/system/supervisor.ini /etc/supervisord.d/ollama.ini \
  && history -c

# Set default work directory.
WORKDIR /opt/ollama
##################### END STAGE #####################

