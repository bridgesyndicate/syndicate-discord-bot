FROM public.ecr.aws/ubuntu/ubuntu:20.04
WORKDIR /root

ARG RBENV_SRC_DIR="/usr/local/rbenv"

ENV PATH="/root/.rbenv/shims:$RBENV_SRC_DIR/bin:$RBENV_SRC_DIR/shims:$PATH" \
    RUBY_BUILD_SRC_DIR="$RBENV_SRC_DIR/plugins/ruby-build"

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
	    build-essential \
	    ca-certificates \
	    curl \
	    libpq-dev \
	    libsqlite3-dev \
	    openssl \
	    zlib1g-dev \
            git

RUN set -ex \
    && git clone https://github.com/rbenv/rbenv.git $RBENV_SRC_DIR \
    && mkdir -p $RBENV_SRC_DIR/plugins \
    && git clone https://github.com/rbenv/ruby-build.git $RUBY_BUILD_SRC_DIR \
    && sh $RUBY_BUILD_SRC_DIR/install.sh

ENV RUBY_27_VERSION="2.7.6"

RUN    rbenv install $RUBY_27_VERSION && rm -rf /tmp/* \
    && rbenv global $RUBY_27_VERSION && ruby -v
