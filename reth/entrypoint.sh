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
  $([ "${ARCHIVE_NODE}" = false ] && printf -- "--full") \
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
  --rpc.max-blocks-per-filter="${RPC_MAX_BLOCKS_PER_FILTER}" \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.jwtsecret "${JWT_PATH}" \
  --block-interval "${BLOCK_INTERVAL}" \
  $([ "${PRUNE_SENDERRECOVERY_FULL}" = true ] && printf -- "--prune.senderrecovery.full") \
  --prune.receipts.before "${PRUNE_RECEIPTS_BEFORE}" \
  --prune.accounthistory.distance "${PRUNE_ACCOUNTHISTORY_DISTANCE}" \
  --prune.storagehistory.distance "${PRUNE_STORAGEHISTORY_DISTANCE}" ${EXTRA_OPTS}
