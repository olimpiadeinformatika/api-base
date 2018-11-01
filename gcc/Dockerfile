FROM buildpack-deps:jessie

RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

ENV GCC_VERSIONS \
       8.2.0
RUN set -xe && \
    for GCC_VERSION in $GCC_VERSIONS; do \
      curl -fSsL "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz" -o /tmp/gcc-$GCC_VERSION.tar.gz; \
    done; \
    for GCC_VERSION in $GCC_VERSIONS; do \
      mkdir /tmp/gcc-$GCC_VERSION && \
      tar -xf /tmp/gcc-$GCC_VERSION.tar.gz -C /tmp/gcc-$GCC_VERSION --strip-components=1 && \
      rm /tmp/gcc-$GCC_VERSION.tar.gz && \
      cd /tmp/gcc-$GCC_VERSION && \
      ./contrib/download_prerequisites && \
      { rm *.tar.* || true; } && \
      tmpdir="$(mktemp -d)" && \
      cd "$tmpdir" && \
      /tmp/gcc-$GCC_VERSION/configure \
        --disable-multilib \
        --enable-languages=c,c++ \
        --prefix=/usr/local/gcc-$GCC_VERSION && \
      make -j"$(nproc)" && \
      make install-strip && \
      rm -rf "$tmpdir" /tmp/gcc-$GCC_VERSION; \
    done

ENV RUBY_VERSIONS \
      2.3.3
RUN set -xe && \
    for RUBY_VERSION in $RUBY_VERSIONS; do \
      curl -fSsL "https://cache.ruby-lang.org/pub/ruby/ruby-$RUBY_VERSION.tar.gz" -o /tmp/ruby-$RUBY_VERSION.tar.gz; \
    done; \
    for RUBY_VERSION in $RUBY_VERSIONS; do \
      mkdir /tmp/ruby-$RUBY_VERSION && \
      tar -xf /tmp/ruby-$RUBY_VERSION.tar.gz -C /tmp/ruby-$RUBY_VERSION --strip-components=1 && \
      rm /tmp/ruby-$RUBY_VERSION.tar.gz && \
      cd /tmp/ruby-$RUBY_VERSION && \
      ./configure \
        --disable-install-doc \
        --prefix=/usr/local/ruby-$RUBY_VERSION && \
      make -j"$(nproc)" && make install && \
      rm -rf /tmp/ruby-$RUBY_VERSION; \
    done

RUN set -xe && \
    apt-get update && apt-get install -y libcap-dev && \
    git clone https://github.com/ioi/isolate.git /tmp/isolate && \
    cd /tmp/isolate && \
    git checkout v1.7 && \
    echo "num_boxes = 2147483647" >> default.cf && \
    make install && \
    rm -rf /tmp/isolate
ENV BOX_ROOT /var/local/lib/isolate

LABEL maintainer="Herman Zvonimir Došilović, hermanz.dosilovic@gmail.com" \
      version="gcc"
