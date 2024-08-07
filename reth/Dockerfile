ARG UPSTREAM_VERSION

FROM ghcr.io/paradigmxyz/reth:${UPSTREAM_VERSION}

ARG NETWORK
ARG P2P_PORT
ARG STAKER_SCRIPTS_VERSION
ARG DATA_DIR

RUN apt-get update && apt-get --yes install --no-install-recommends curl && apt-get clean

ENV DATA_DIR=${DATA_DIR} \
    JWT_PATH=/jwtsecret.hex \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ADD ${STAKER_SCRIPTS_URL}/execution_tools.sh /etc/profile.d/

RUN chmod +rx /usr/local/bin/entrypoint.sh /etc/profile.d/execution_tools.sh

# Placed at the end to regenerate the least amount of layers
ENV NETWORK=${NETWORK} \
    P2P_PORT=${P2P_PORT}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
