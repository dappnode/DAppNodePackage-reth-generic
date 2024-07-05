ARG UPSTREAM_VERSION

FROM ghcr.io/paradigmxyz/reth:${UPSTREAM_VERSION}

ARG NETWORK
ARG P2P_PORT
ARG STAKER_SCRIPTS_VERSION

COPY /security /security
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apt-get update && apt-get install --no-install-recommends -y curl && apt-get clean

ENV DATA_DIR=/data/reth \
    NETWORK=${NETWORK} \
    P2P_PORT=${P2P_PORT} \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/execution_tools.sh /etc/profile.d/

RUN chmod +rx /usr/local/bin/entrypoint.sh /etc/profile.d/execution_tools.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
