#
# This Docker image encapsulates Maltrieve, a tool to retrieve malware
# directly from the source for security researchers.
# which was created by Kyle Maxwell (krmaxwell) and is
# available at https://github.com/krmaxwell/maltrieve.
#
# The file below is based on ideas from Spenser Reinhardt's Dockerfile
# (https://registry.hub.docker.com/u/sreinhardt/honeynet/dockerfile)
# and on instructions outlined by M. Fields (@shakey_1).
#
# To run this image after installing Docker, use a command like this:
#
# sudo docker run --rm -it technoskald/maltrieve

FROM ubuntu:16.04
MAINTAINER Michael Boman <michael@michaelboman.org>

USER root
RUN apt-get update && \
  apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
    gcc \
    git \
    libpython2.7-stdlib \
    libmagic1 \
    python2.7 \
    python2.7-dev \
    python-pip \
    python-setuptools

RUN rm -rf /var/lib/apt/lists/* && \
  pip install --upgrade pip && \
  groupadd -r maltrieve && \
  useradd -r -g maltrieve -d /home/maltrieve -s /sbin/nologin -c "Maltrieve User" maltrieve

RUN mkdir /archive && \
  chown maltrieve:maltrieve /archive

WORKDIR /home
RUN mkdir /home/maltrieve
COPY requirements.txt maltrieve/
RUN pip install -r /home/maltrieve/requirements.txt

COPY . /home/maltrieve
RUN cd maltrieve && \
  chown -R maltrieve:maltrieve /home/maltrieve

USER maltrieve
ENV HOME /home/maltrieve
ENV USER maltrieve
WORKDIR /archive
ENTRYPOINT ["/home/maltrieve/maltrieve.py"]
CMD ["-d", "/archive/samples", "-l", "/archive/maltrieve.log", "--config", "/home/maltrieve/maltrieve.cfg"]
