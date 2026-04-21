# NewSpace Development Template

## Overview
This template provides a standardised development environment for Python projects using Dev Containers, Docker, and Docker Compose. The environment is pre-configured and ready to use immediately, regardless of the host operating system.

## Installation

### Prerequisites

- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/) with Docker Compose V2
- [Visual Studio Code](https://code.visualstudio.com/) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
- NVIDIA GPU + drivers *(optional — see GPU-specific settings below)*

### 1. Clone the repository

```bash
git clone git@github.com:your-username/your-repo.git
cd your-repo
git submodule update --init --recursive
```

### 2. Open in Dev Container

Open the folder in VS Code and select **"Reopen in Container"** when prompted, or run:

```
Dev Containers: Rebuild and Reopen in Container
```

The container will build automatically and install all system dependencies.

### 3. Install Python dependencies

Inside the container terminal:

```bash
pip install -r .devcontainer/requirements.txt
```

The virtual environment is located at `/app/venv` and is activated automatically.

---

## Dev Container

The Dev Container provides a fully configured development environment for VS Code. It includes:

- Python runtime
- Pre-configured extensions for Python development
- Consistent environment variables
- Pinned dependencies

### Getting Started with Dev Containers

1. Install [Visual Studio Code](https://code.visualstudio.com/)
2. Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
3. Open this directory in VS Code
4. When prompted, select "Reopen in Container"
5. The environment will be set up automatically

## Docker & Docker Compose

### Docker Configuration

The development environment is based on the official NVIDIA CUDA image. The `Dockerfile` contains:

```dockerfile
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

# Further configuration...
```

### Docker Compose

Docker Compose orchestrates the container and GPU resources:

```yaml
services:
  app:
    build: .
    volumes:
      - .:/app
    # Further configuration...
```

## Python Development

### Project Structure

```
NewSpace/
├── .claude/                        # Claude Code team defaults (settings, commands)
├── .devcontainer/                  # Dev Container configuration
│   └── requirements.txt            # Dev-time Python dependencies
├── .github/                        # GitHub Copilot instructions and prompt files
├── .vscode/                        # Shared VS Code settings
├── src/                            # Source code
├── data/                           # Sample datasets
├── docs/                           # Documentation / cheat sheets
├── CLAUDE.md                       # Context file for Claude Code
├── ReadMe.md                       # This file
└── newspace.code-workspace         # VS Code multi-root workspace
```

### Creating a New Python Program

1. Create a new file under `src/` with a `.py` extension
2. Import required modules:
   ```python
   import pandas as pd
   import numpy as np
   ```
3. Write your functions and classes
4. Add an entry point:
   ```python
   if __name__ == "__main__":
       main()
   ```

### Managing Dependencies

1. Add new dependencies to `.devcontainer/requirements.txt`
2. Run inside the container terminal:
   ```bash
   pip install -r .devcontainer/requirements.txt
   ```

---

## AI Assistants (Claude Code + GitHub Copilot)

This template ships with both assistants pre-wired so every new team member can
pick their preferred workflow.

### Claude Code
- Installed automatically via the Dev Container feature
  `ghcr.io/anthropics/devcontainer-features/claude-code:1`.
- The `claude` CLI is available inside the container after the first rebuild.
- Team defaults live in `.claude/settings.json` (model: `claude-sonnet-4-6`,
  conservative tool-permission defaults).
- Personal overrides go in `.claude/settings.local.json` (git-ignored).
- Project context for the assistant is maintained in `CLAUDE.md` at repo root –
  please keep it up to date when you change structure or conventions.
- **Package docs skill**: `.claude/skills/package-docs/` auto-loads reference
  material from `docs/package_a/` and `docs/package_b/` whenever someone asks
  Claude about those packages (API, examples, integration). Drop `api.md`,
  `examples/*.md`, or a `changelog.md` into either folder — the skill picks
  them up without any extra wiring.
- Launch: open a terminal in the container and run `claude`, or use the
  VS Code extension `anthropic.claude-code`.

### GitHub Copilot
- Extensions `github.copilot` and `github.copilot-chat` are pre-installed.
- Default settings (`.vscode/settings.json`) enable completions for Python,
  YAML, Dockerfile, and Markdown. Plaintext is disabled to reduce noise.
- Sign in once with a GitHub account that has a Copilot licence.

Both tools can run in parallel — pick whatever fits the task.

### How the AI setup works

| Tool                   | Config file                       | What it does                                                         |
| ---------------------- | --------------------------------- | -------------------------------------------------------------------- |
| GitHub Copilot         | `.github/copilot-instructions.md` | Pre-prompt loaded automatically in every chat session                |
| GitHub Copilot         | `.vscode/settings.json`           | Injects `CodingRules.md` and package references into code generation |
| Claude Code            | `CLAUDE.md`                       | Full project context including coding standards                      |
| Custom GPT / Claude.ai | `docs/help/CustomGPT/`            | Standalone system prompts for external chatbots                      |

### Single source of truth

All AI tools point to the same rules file:
```
docs/CodingRules.md
```
Update this file once and every assistant automatically follows the new rules.

### Package Reference Docs

Drop package-specific API notes, gotchas, and usage examples into the reference folders:
```
docs/package_a/   ← package A references (e.g. Eigen, OpenCV)
docs/package_b/   ← package B references
```
Both Copilot and Claude Code can load these on demand (see commands below).

### Reusable Skills / Commands

**GitHub Copilot** — invoke via the `/` prompt picker in Copilot Chat:

| Skill             | File                                       | What it does                                                            |
| ----------------- | ------------------------------------------ | ----------------------------------------------------------------------- |
| `/fix-spelling`   | `.github/prompts/fix-spelling.prompt.md`   | Fixes spelling/grammar in docs without touching code or technical terms |
| `/read-package-a` | `.github/prompts/read-package-a.prompt.md` | Loads all docs from `docs/package_a/` into the session context          |
| `/read-package-b` | `.github/prompts/read-package-b.prompt.md` | Loads all docs from `docs/package_b/` into the session context          |

**Claude Code** — invoke via the `/` command picker in Claude Code chat:

| Command           | File                                 | What it does                                                            |
| ----------------- | ------------------------------------ | ----------------------------------------------------------------------- |
| `/spell-check`    | `.claude/commands/spell-check.md`    | Fixes spelling/grammar in docs without touching code or technical terms |
| `/read-package-a` | `.claude/commands/read-package-a.md` | Loads all docs from `docs/package_a/` into the session context          |
| `/read-package-b` | `.claude/commands/read-package-b.md` | Loads all docs from `docs/package_b/` into the session context          |

### Adding a new package reference

1. Create a new folder `docs/package_c/` and add your reference Markdown files.
2. **Copilot:** Copy `.github/prompts/read-package-a.prompt.md` → `read-package-c.prompt.md` and update the path inside. Add it to `github.copilot.chat.codeGeneration.instructions` in `.vscode/settings.json` and register it in `.github/copilot-instructions.md`.
3. **Claude Code:** Copy `.claude/commands/read-package-a.md` → `read-package-c.md` and update the path inside.

---

## Best Practices

1. **Version control:** Use Git — work on feature branches, never commit directly to `main`.
2. **Tests:** Write unit tests for your code in `src/<module>/tests/` or a top-level `tests/` folder.
3. **Documentation:** Document your code with docstrings (Google style for Python, Doxygen for C++).
4. **Environment variables:** Manage sensitive data via `.env` files (already git-ignored).
5. **Secrets:** Never commit credentials or API keys.

## Running Python Programs

Inside the Dev Container terminal:

```bash
# Run directly
python src/your_program.py

# With arguments
python src/your_program.py --arg1 value1

# As a module
python -m src.your_module
```

## Troubleshooting

- **Container does not start:** Check that Docker is running and you have sufficient permissions.
- **Module not found:** Verify `requirements.txt` and run `pip install -r .devcontainer/requirements.txt`.
- **Path issues:** Check for correct relative imports in Python.

---

## Dev Container Step-by-Step Setup

- **Open WSL**
  Start your WSL terminal (e.g. Ubuntu) from the command line.

- **Connect to GitHub**
  Make sure you have access to your GitHub account. Configure Git:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your@email.com"
  ```

- **Create an SSH key**
  If you don't have one yet:
  ```bash
  ssh-keygen -t ed25519 -C "your@email.com"
  ```
  Add the public key (`~/.ssh/id_ed25519.pub`) to your GitHub account under
  **Settings → SSH and GPG Keys**.

- **Clone the repository**
  ```bash
  git clone git@github.com:your-username/your-repo.git
  ```

- **Install Visual Studio Code**
  Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)

- **Open VS Code from WSL**
  ```bash
  code .
  ```

- **Install required extensions**
  - Dev Containers
  - Remote – SSH *(if the container runs on a remote SSH server)*
  - Remote – WSL *(if the container runs locally on Linux)*

- **Workspace path in docker-compose.yml**
  Since template version 2, `docker-compose.yml` uses `${localWorkspaceFolder}` automatically — no manual path adjustment needed. To start the container outside VS Code, override via environment variable:
  ```bash
  localWorkspaceFolder=/your/project/path docker compose up
  ```

- **GPU-specific settings (optional)**
  If you don't have an NVIDIA GPU, comment out the GPU sections in `docker-compose.yml` and `.devcontainer/devcontainer.json` (marked with `# NVIDIA` comments in those files).

- **Rebuild the container**
  Open the VS Code command palette (`F1` or `Ctrl+Shift+P`) and select:
  ```
  Dev Containers: Rebuild and Reopen in Container
  ```
