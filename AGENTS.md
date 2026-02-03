# Repository Guidelines

## Project Structure & Module Organization
- `setup.sh` is the primary entry point for local environment setup. It creates a numbered project folder (`s1`, `s2`, …), clones a repository, and provisions devcontainer files.
- No other source modules or test directories exist in this repository at this time.

## Build, Test, and Development Commands
- `bash ./setup.sh` — runs the interactive setup flow (prompts for a Git repo URL, prepares folders, and starts tmux sessions).
- `bash ./setup_minimal.sh` — runs a minimal flow (clone + tmux session with a new window).
- `ln -sf "$PWD/setup.sh" ~/.local/bin/setup_env` — creates a local symlink for easier invocation.
- `setup_env` — runs the script via the symlink (ensure `~/.local/bin` is on `PATH`).
- There are no build or test commands defined for this repository.

## Coding Style & Naming Conventions
- Shell scripts should use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Prefer `SCREAMING_SNAKE_CASE` for constants and `lower_snake_case` for local variables.
- Project directories created by the script must follow the `s<NUMBER>` pattern (e.g., `s5`).

## Testing Guidelines
- No automated tests are configured. If you add tests, document the framework and add a run command here.

## Commit & Pull Request Guidelines
- This repository does not currently expose a commit message convention. Use concise, imperative messages (e.g., "Add devcontainer download step").
- Pull requests should include a short summary of behavior changes and any new requirements.

## Security & Configuration Notes
- The script downloads a fixed tarball URL and runs container scripts; review external inputs before execution.
- Keep credentials out of the script; rely on environment configuration or external tools when needed.
