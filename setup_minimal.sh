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

if [[ -e "${PROJECT_NAME}" ]]; then
  echo "Directory ${PROJECT_NAME} already exists." >&2
  exit 1
fi

git clone "${REPO_URL}" "${PROJECT_NAME}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required but not installed." >&2
  exit 1
fi

echo "Starting tmux session: ${PROJECT_NAME}"

tmux new-session -d -s "${PROJECT_NAME}" -c "${PROJECT_NAME}"
tmux new-window -t "${PROJECT_NAME}" -c "${PROJECT_NAME}"

if [[ -t 1 ]]; then
  tmux attach -t "${PROJECT_NAME}"
else
  echo "tmux session '${PROJECT_NAME}' is running. Attach with: tmux attach -t ${PROJECT_NAME}"
fi
