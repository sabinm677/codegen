# Setup Script

This repository contains Bash scripts to automate local project setup.

## Usage

Run locally:

```bash
bash ./setup.sh
```

Run the minimal setup:

```bash
bash ./setup_minimal.sh
```

Run via a symlink in your local bin:

```bash
ln -sf "$PWD/setup.sh" ~/.local/bin/setup_env
```

```bash
setup_env
```

Run directly from a remote URL (after you upload `setup.sh`):

```bash
curl -fsSL https://raw.githubusercontent.com/sabinm677/codegen/refs/heads/develop/setup.sh | bash
```

## What It Does

- Prompts for a Git repository URL.
- Creates the next available `sN` directory (e.g., `s1`, `s2`).
- Clones the repo into that directory.
- Downloads boilerplate and copies `.devcontainer` and `local`.
- Starts a tmux session and runs `./local/container/up`.
- Opens a new tmux window and runs `./local/container/connect`.

## Requirements

- `git`, `curl`, `tar`, `rsync`
- `tmux`
- `docker`

## Notes

- The boilerplate URL is fixed in the script.
- The tarball is downloaded to a temporary directory and cleaned up automatically.
