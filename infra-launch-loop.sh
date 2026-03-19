#!/usr/bin/env bash

# Use shell best practices: -u (exit on unset vars), -o pipefail (catch pipe errors)
# We omit -e because we expect the 'make' command to fail when out of capacity.
set -uo pipefail

# Configuration
readonly MIN_WAIT_SECONDS=60
readonly MAX_WAIT_SECONDS=240
readonly LOG_PREFIX="[infra-loop]"

# Ensure we are in the project root
cd "$(dirname "$0")"

echo "${LOG_PREFIX} Starting OCI ARM Capacity Hunter for OpenClaw..."

while true; do
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "--------------------------------------------------------"
  echo "${LOG_PREFIX} Attempting launch at ${timestamp}..."

  # Execute make infra-apply and capture ALL output (stdout and stderr)
  # We use a temporary file to safely inspect the output without losing it.
  TMP_OUTPUT=$(mktemp)
  make infra-apply > "$TMP_OUTPUT" 2>&1
  EXIT_STATUS=$?

  if [[ $EXIT_STATUS -eq 0 ]]; then
    echo "${LOG_PREFIX} SUCCESS: Instance provisioned successfully."
    grep "instance_public_ip" "$TMP_OUTPUT"
    rm -f "$TMP_OUTPUT"
    break
  fi

  # Check specifically for the 'Out of host capacity' string from OCI
  if grep -q "Out of host capacity" "$TMP_OUTPUT"; then
    # Calculate a randomized backoff to avoid bot detection/throttling
    WAIT_TIME=$(( (RANDOM % (MAX_WAIT_SECONDS - MIN_WAIT_SECONDS)) + MIN_WAIT_SECONDS ))
    echo "${LOG_PREFIX} ERROR: Out of capacity. Retrying in ${WAIT_TIME} seconds..."
    rm -f "$TMP_OUTPUT"
    sleep "$WAIT_TIME"
  else
    echo "${LOG_PREFIX} TERMINAL ERROR: A non-capacity related failure occurred. Output below:"
    cat "$TMP_OUTPUT"
    rm -f "$TMP_OUTPUT"
    exit 1
  fi
done
