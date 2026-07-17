#!/bin/sh

# shellcheck disable=SC1091
. /etc/profile

JWT_SECRET=$(get_jwt_secret_by_network "${NETWORK}")
echo "${JWT_SECRET}" >"${JWT_PATH}"

post_jwt_to_dappmanager "${JWT_PATH}"

DOWNLOAD_SNAPSHOT="${DOWNLOAD_SNAPSHOT:-true}"
ARCHIVE_NODE="${ARCHIVE_NODE:-false}"
STORAGE_MODE="${STORAGE_MODE:-full}"

case "${DOWNLOAD_SNAPSHOT}" in
true | false) ;;
*)
  echo "[ERROR - entrypoint] DOWNLOAD_SNAPSHOT must be 'true' or 'false'"
  exit 1
  ;;
esac

if [ "${ARCHIVE_NODE}" = true ]; then
  echo "[INFO - entrypoint] ARCHIVE_NODE=true detected; using STORAGE_MODE=archive"
  STORAGE_MODE="archive"
fi

case "${STORAGE_MODE}" in
full)
  STORAGE_MODE_FLAG="--full"
  SNAPSHOT_MODE_FLAG="--full"
  ;;
minimal)
  STORAGE_MODE_FLAG="--minimal"
  SNAPSHOT_MODE_FLAG="--minimal"
  ;;
archive)
  STORAGE_MODE_FLAG=""
  SNAPSHOT_MODE_FLAG="--archive"
  ;;
custom)
  STORAGE_MODE_FLAG="--block-interval 5 --prune.senderrecovery.full --prune.receipts.before 0 --prune.accounthistory.distance 10064 --prune.storagehistory.distance 10064"
  SNAPSHOT_MODE_FLAG=""
  ;;
*)
  echo "[ERROR - entrypoint] STORAGE_MODE must be 'full', 'minimal', 'archive', or 'custom'"
  exit 1
  ;;
esac

is_data_dir_initialized() {
  for path in \
    "${DATA_DIR}/${NETWORK}/db" \
    "${DATA_DIR}/${NETWORK}/reth.toml" \
    "${DATA_DIR}/${NETWORK}/static_files" \
    "${DATA_DIR}/${NETWORK}/rocksdb" \
    "${DATA_DIR}/db" \
    "${DATA_DIR}/reth.toml" \
    "${DATA_DIR}/static_files" \
    "${DATA_DIR}/rocksdb"; do
    if [ -e "${path}" ]; then
      return 0
    fi
  done

  return 1
}

echo "[INFO - entrypoint] Running Reth client for network: ${NETWORK}"

if [ "${STORAGE_MODE}" = custom ]; then
  echo "[INFO - entrypoint] STORAGE_MODE=custom selected; skipping snapshot download"
elif [ "${DOWNLOAD_SNAPSHOT}" = true ]; then
  if is_data_dir_initialized; then
    echo "[INFO - entrypoint] Reth data directory already initialized; skipping snapshot download"
  else
    echo "[INFO - entrypoint] Downloading ${NETWORK} ${SNAPSHOT_MODE_FLAG#--} snapshot before starting Reth"
    # shellcheck disable=SC2086
    reth \
      download \
      -y \
      ${SNAPSHOT_MODE_FLAG} \
      --chain "${NETWORK}" \
      --datadir "${DATA_DIR}"
  fi
fi

# shellcheck disable=SC2086
exec reth \
  node \
  ${STORAGE_MODE_FLAG} \
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
  --rpc.max-blocks-per-filter="${RPC_MAX_BLOCKS_PER_FILTER}" \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.jwtsecret "${JWT_PATH}" ${EXTRA_OPTS}
