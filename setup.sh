#!/usr/bin/env bash
set -euo pipefail

if [[ -t 0 ]]; then
  read -r -p "Enter git repository URL: " REPO_URL
else
  read -r -p "Enter git repository URL: " REPO_URL < /dev/tty
fi
if [[ -z "${REPO_URL}" ]]; then
  echo "Repository URL is required." >&2
  exit 1
fi

# Find next project folder name (s1, s2, s3, ...)
max_num=0
shopt -s nullglob
for d in s*/; do
  d=${d%/}
  if [[ "$d" =~ ^s([0-9]+)$ ]]; then
    num=${BASH_REMATCH[1]}
    if (( num > max_num )); then
      max_num=$num
    fi
  fi
done
shopt -u nullglob

next_num=$((max_num + 1))
PROJECT_NAME="s${next_num}"

echo "Creating project directory: ${PROJECT_NAME}"

# Clone repository
if [[ -e "${PROJECT_NAME}" ]]; then
  echo "Directory ${PROJECT_NAME} already exists." >&2
  exit 1
fi

git clone "${REPO_URL}" "${PROJECT_NAME}"

# Download setup code and copy required folders
TMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

TARBALL_URL="https://github.com/sabinm677/claude-code-boilerplate/archive/refs/tags/v0.1.0.tar.gz"

echo "Downloading setup code..."
if ! curl -fsSL "${TARBALL_URL}" -o "${TMP_DIR}/setup.tar.gz"; then
  echo "Failed to download ${TARBALL_URL}" >&2
  exit 1
fi

tar -xzf "${TMP_DIR}/setup.tar.gz" -C "${TMP_DIR}"

SRC_ROOT=$(find "${TMP_DIR}" -maxdepth 1 -type d -name "claude-code-boilerplate-*" | head -n 1)
if [[ -z "${SRC_ROOT}" ]]; then
  echo "Failed to locate setup code contents." >&2
  exit 1
fi

for folder in .devcontainer local; do
  if [[ -d "${SRC_ROOT}/${folder}" ]]; then
    rsync -a "${SRC_ROOT}/${folder}" "${PROJECT_NAME}/"
  else
    echo "Warning: ${folder} not found in setup code." >&2
  fi
done

# Start tmux session and run container scripts
if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required but not installed." >&2
  exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but not installed." >&2
  exit 1
fi

if [[ ! -x "${PROJECT_NAME}/local/container/up" ]]; then
  echo "${PROJECT_NAME}/local/container/up not found or not executable." >&2
  exit 1
fi

if [[ ! -x "${PROJECT_NAME}/local/container/connect" ]]; then
  echo "${PROJECT_NAME}/local/container/connect not found or not executable." >&2
  exit 1
fi

echo "Starting tmux session: ${PROJECT_NAME}"

tmux new-session -d -s "${PROJECT_NAME}" -c "${PROJECT_NAME}" "./local/container/up"

PROJECT_PATH="$(pwd)/${PROJECT_NAME}"
echo "Waiting for dev container to be running..."
ready=0
for _ in {1..120}; do
  if docker ps --filter "label=devcontainer.local_folder=${PROJECT_PATH}" --format '{{.ID}}' | grep -q '.'; then
    ready=1
    break
  fi
  sleep 2
done

if [[ "${ready}" -ne 1 ]]; then
  echo "Warning: dev container not detected after waiting. Opening connect anyway." >&2
fi

tmux new-window -t "${PROJECT_NAME}" -c "${PROJECT_NAME}" "./local/container/connect"
if [[ -t 1 ]]; then
  tmux attach -t "${PROJECT_NAME}"
else
  echo "tmux session '${PROJECT_NAME}' is running. Attach with: tmux attach -t ${PROJECT_NAME}"
fi
