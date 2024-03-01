FROM lukemathwalker/cargo-chef:latest-rust-1.75-bookworm as builder
#FROM --platform=linux/amd64 ubuntu as builder

ARG TEI_VERSION='.1.1.0'
#ENV PATH "/root/.cargo/bin:$PATH"

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        curl \
        gcc \
        libssl-dev \
        libomp-dev \
        pkg-config

RUN curl -o - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        | gpg --dearmor \
        | tee /usr/share/keyrings/oneapi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
        | tee /etc/apt/sources.list.d/oneAPI.list \
    && apt-get update \
    && apt-get install -y intel-oneapi-mkl-devel

# RUN curl -sSf https://sh.rustup.rs | sh  -s -- -y

RUN curl -sLo /tmp/tei.tgz https://github.com/huggingface/text-embeddings-inference/archive/refs/tags/v${TEI_VERSION}.tar.gz \
    && tar xf /tmp/tei.tgz -C /tmp \
    && cd /tmp/text-embeddings-inference-v${TEI_VERSION} \
    && sed -i 's/^debug.*/debug = 0/g' Cargo.toml \
    && cargo install --path router -F candle -F mkl \
    && cd -

# TODO: Delme
RUN uname -a && cat /proc/cpuinfo

FROM ubuntu

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libomp-dev \
    ca-cacert \
    && rm -rf /var/lib/apt/lists/*

# TODO: Remove unnneded once decide which options will be used for build container
#COPY --from=builder /root/.cargo/bin/text-embeddings-router /usr/local/bin/text-embeddings-router
COPY --from=builder /usr/local/cargo/bin/text-embeddings-router /usr/local/bin/text-embeddings-router

#TODO: Remove it for in production
RUN /usr/local/bin/text-embeddings-router  --help
