#!/bin/sh

# shellcheck disable=SC1091
. /etc/profile

JWT_SECRET=$(get_jwt_secret_by_network "${NETWORK}")
echo "${JWT_SECRET}" >"${JWT_PATH}"

post_jwt_to_dappmanager "${JWT_PATH}"

echo "[INFO - entrypoint] Running Reth client for network: ${NETWORK}"

# shellcheck disable=SC2086
exec reth \
  node \
  --full \
  --chain "${NETWORK}" \
  --metrics 0.0.0.0:6060 \
  --datadir "${DATA_DIR}" \
  --addr 0.0.0.0 \
  --port "${P2P_PORT}" \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 8545 \
  --http.corsdomain "*" \
  --ws \
  --ws.addr 0.0.0.0 \
  --ws.port 8546 \
  --ws.origins "*" \
  --engine.legacy \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.jwtsecret "${JWT_PATH}" ${EXTRA_OPTS}
