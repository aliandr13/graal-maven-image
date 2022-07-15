FROM amazonlinux:2

RUN set -ex \
    && yum install -y gcc glibc-devel zlib-devel tar gzip unzip

ENV JAVA_HOME="/opt/graalvm" \
    GRAALVM_HOME="/opt/graalvm" \
    GRAALVM_VERSION=21.3.2 \
    GRAALVM_DOWNLOAD_SHA256="1332e2716601abea1e05b7b0b1c643740aedc9a6f82f375f5d2afa7e6323c130" \
    MAVEN_HOME="/opt/maven" \
    MAVEN_VERSION=3.8.6 \
    MAVEN_DOWNLOAD_SHA512="f790857f3b1f90ae8d16281f902c689e4f136ebe584aba45e4b1fa66c80cba826d3e0e52fdd04ed44b4c66f6d3fe3584a057c26dfcac544a60b301e6d0f91c26"

ARG MAVEN_CONFIG_HOME="/root/.m2"

RUN set -ex \
    # Install GraalVM - https://github.com/graalvm/graalvm-ce-builds/releases
    && mkdir -p $JAVA_HOME \
    && curl -LSso /var/tmp/graalvm-ce-java11-linux-amd64-$GRAALVM_VERSION.tar.gz https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAALVM_VERSION/graalvm-ce-java11-linux-amd64-$GRAALVM_VERSION.tar.gz \
    && echo "$GRAALVM_DOWNLOAD_SHA256 /var/tmp/graalvm-ce-java11-linux-amd64-$GRAALVM_VERSION.tar.gz" | sha256sum -c - \
    && tar xzvf /var/tmp/graalvm-ce-java11-linux-amd64-$GRAALVM_VERSION.tar.gz -C $JAVA_HOME --strip-components=1 \
    && rm /var/tmp/graalvm-ce-java11-linux-amd64-$GRAALVM_VERSION.tar.gz \
    && for tool_path in $JAVA_HOME/bin/*; do \
          tool=`basename $tool_path`; \
          update-alternatives --install /usr/bin/$tool $tool $tool_path 10000; \
          update-alternatives --set $tool $tool_path; \
        done \
    # Install GraalVM Native image
    && $GRAALVM_HOME/bin/gu install native-image

RUN set -ex \
    # Install Maven - https://downloads.apache.org/maven/maven-3/
    && mkdir -p $MAVEN_HOME \
    && curl -LSso /var/tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz https://apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    && echo "$MAVEN_DOWNLOAD_SHA512 /var/tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz" | sha512sum -c - \
    && tar xzvf /var/tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_HOME --strip-components=1 \
    && rm /var/tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    && update-alternatives --install /usr/bin/mvn mvn /opt/maven/bin/mvn 10000 \
    && mkdir -p $MAVEN_CONFIG_HOME

#RUN set -ex \
#    # Install AWS CLI V2
#    && curl -LSso /var/tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
#    && unzip -q /var/tmp/awscliv2.zip -d /var/tmp \
#    && ./var/tmp/aws/install -b /usr/bin \
#    && rm /var/tmp/awscliv2.zip