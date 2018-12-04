FROM buildpack-deps:jessie

RUN apt-get update && apt-get upgrade -y

ENV GCC_VERSIONS 4.8.5
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



ENV PYTHON_VERSIONS \
      3.6.0 \
      2.7.9
RUN set -xe && \
    for PYTHON_VERSION in $PYTHON_VERSIONS; do \
      curl -fSsL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -o /tmp/python-$PYTHON_VERSION.tar.xz; \
    done; \
    for PYTHON_VERSION in $PYTHON_VERSIONS; do \
      mkdir /tmp/python-$PYTHON_VERSION && \
      tar -xf /tmp/python-$PYTHON_VERSION.tar.xz -C /tmp/python-$PYTHON_VERSION --strip-components=1 && \
      rm /tmp/python-$PYTHON_VERSION.tar.xz && \
      cd /tmp/python-$PYTHON_VERSION && \
      ./configure \
        --prefix=/usr/local/python-$PYTHON_VERSION && \
      make -j"$(nproc)" && make install && \
      rm -rf /tmp/python-$PYTHON_VERSION; \
    done



# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
RUN set -xe && \
    JAVA_8_DEBIAN_VERSION=8u131-b11-1~bpo8+1 && \
    JAVA_7_DEBIAN_VERSION=7u151-2.6.11-1~deb8u1 && \
    CA_CERTIFICATES_JAVA_VERSION=20161107~bpo8+1 && \
    echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get update && apt-get install -y \
      openjdk-8-jdk="$JAVA_8_DEBIAN_VERSION" \
      openjdk-7-jdk="$JAVA_7_DEBIAN_VERSION" \
      ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac
RUN set -xe && \
    curl -fSsL "https://github.com/AdoptOpenJDK/openjdk9-openj9-releases/releases/download/jdk-9%2B181/OpenJDK9-OPENJ9_x64_Linux_jdk-9.181.tar.gz" -o /tmp/openjdk9-openj9.tar.gz && \
    mkdir /usr/local/openjdk9-openj9 && \
    tar -xf /tmp/openjdk9-openj9.tar.gz -C /usr/local/openjdk9-openj9 --strip-components=2 && \
    rm /tmp/openjdk9-openj9.tar.gz



RUN set -xe && \
    curl -fSsL "ftp://ftp.freepascal.org/fpc/dist/3.0.0/x86_64-linux/fpc-3.0.0.x86_64-linux.tar" -o /tmp/fpc-3.0.0.tar && \
    mkdir /tmp/fpc-3.0.0 && \
    tar -xf /tmp/fpc-3.0.0.tar -C /tmp/fpc-3.0.0 --strip-components=1 && \
    rm /tmp/fpc-3.0.0.tar && \
    cd /tmp/fpc-3.0.0 && \
    echo "/usr/local/fpc-3.0.0" | sh install.sh && \
    rm -rf /tmp/fpc-3.0.0



RUN set -xe && \
    apt-get update && apt-get install -y locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8


 
RUN set -xe && \
    apt-get update && apt-get install -y libcap-dev && \
    git clone https://github.com/ioi/isolate.git /tmp/isolate && \
    cd /tmp/isolate && \
    echo "num_boxes = 2147483647" >> default.cf && \
    make install && \
    rm -rf /tmp/isolate
ENV BOX_ROOT /var/local/lib/isolate



LABEL maintainer="Mamat Rahmat, coderbodoh@gmail.com" \
      version="0.2.1"
