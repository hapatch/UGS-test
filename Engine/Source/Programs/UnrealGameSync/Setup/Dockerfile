FROM ubuntu:24.04

# Bump to match the p4d version your production servers run
ARG P4_RELEASE=r24.2

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl dos2unix \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/p4d https://ftp.perforce.com/perforce/${P4_RELEASE}/bin.linux26x86_64/p4d \
 && curl -fsSL -o /usr/local/bin/p4  https://ftp.perforce.com/perforce/${P4_RELEASE}/bin.linux26x86_64/p4 \
 && chmod +x /usr/local/bin/p4d /usr/local/bin/p4

ENV P4ROOT=/p4/root

# Seed the depot at build time, so every `docker run` starts from the same known state.
COPY setup.sh /setup.sh
RUN dos2unix /setup.sh && chmod +x /setup.sh && /setup.sh

COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 1666
ENTRYPOINT ["/entrypoint.sh"]