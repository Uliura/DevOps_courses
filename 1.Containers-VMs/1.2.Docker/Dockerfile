FROM ubuntu:20.04
WORKDIR /ruby
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
&& apt-get -y install curl g++ gcc autoconf automake bison libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev libssl-dev
RUN curl -O https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.2.tar.gz
RUN tar -C /ruby/ -xvf ruby-2.7.2.tar.gz --strip 1 \
&& ./configure && make && make install
