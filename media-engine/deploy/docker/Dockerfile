# ============================================================================
# T-Odd Media Engine — single Dockerfile, two services
#
# Build:
#   docker build -f deploy/docker/Dockerfile -t traceodd/todd-studio \
#     --build-arg SERVICE=todd-signaling .
#   docker build -f deploy/docker/Dockerfile -t traceodd/todd-broadcaster \
#     --build-arg SERVICE=todd-sfu .
#
# The builder runs Ubuntu 24.04 because it ships GStreamer 1.24, which the
# `gst` feature links against. The runtime image only carries the runtime
# plugins, keeping the final image lean.
# ============================================================================

ARG SERVICE=todd-signaling
ARG FEATURES=gst

# ---- build stage -----------------------------------------------------------
FROM ubuntu:24.04 AS builder
ARG SERVICE
ARG FEATURES

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl pkg-config \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    && rm -rf /var/lib/apt/lists/*
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile minimal --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /src
COPY Cargo.toml ./
COPY crates ./crates
# web/ is embedded by todd-signaling at compile time (dev test page)
COPY web ./web
RUN cargo build --release -p ${SERVICE} --features ${FEATURES}

# ---- runtime stage ----------------------------------------------------------
FROM ubuntu:24.04 AS runtime
ARG SERVICE

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
    gstreamer1.0-tools libgstreamer1.0-0 \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/target/release/${SERVICE} /usr/local/bin/todd
RUN useradd -r -u 10001 todd
USER todd
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/todd"]
