FROM docker.io/ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y build-essential curl
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN curl https://s3.us-west-2.amazonaws.com/downloads.dlang.org/releases/2021/dmd_2.098.0-0_amd64.deb -o dmd.deb && \
    dpkg -i dmd.deb
RUN apt-get install -y nodejs sbcl
RUN curl https://ziglang.org/builds/zig-linux-x86_64-0.9.0-dev.1561+5ebdc8c46.tar.xz -o zig.tar.xz && \
    mkdir /zig && \
    tar xf zig.tar.xz -C /zig --strip-components 1
ENV PATH="/zig/:${PATH}"
RUN apt-get install -y default-jdk-headless
RUN apt-get install -y unzip
RUN curl https://downloads.gradle-dn.com/distributions/gradle-6.4.1-bin.zip -o gradle.zip && \
    unzip -d /opt/gradle gradle.zip
ENV PATH="/opt/gradle/gradle-6.4.1/bin/:${PATH}"
RUN apt-get install -y golang
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get -y update && \
    apt-get install -y mono-devel
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl https://nim-lang.org/choosenim/init.sh -sSf -o /root/init.sh && \
    chmod +x /root/init.sh && \
    /root/init.sh -y && \
    rm /root/init.sh
ENV PATH $PATH:/root/.nimble/bin
RUN apt-get install -y lua5.3
RUN curl -sSL https://get.haskellstack.org/ | sh
WORKDIR /app
COPY . .
CMD ["sh", "benchmark.sh"]
