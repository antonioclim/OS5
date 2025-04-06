

---

## ✅ Revised README (Part 1)

```markdown
# Kernel Build Automation Toolkit

This toolkit automates building and packaging Linux kernels across different architectures and configurations. It streamlines building clean, reproducible kernels and offers tooling for:
- Kernel compilation for multiple targets
- Repackaging kernels for custom images
- Environment setup with containerized consistency
- Advanced configuration presets and overrides

---

## 📁 Directory Structure Overview

```
project/
│
├── bin/                  # Main executable and helper scripts
├── etc/                  # Default configs, environment setup, presets
├── overlays/            # Kernel source overlays and patches
├── repo/                # Kernel source (git-based or static tarball)
├── tmp/                 # Workspace for build artifacts
└── out/                 # Final output: packages, logs, builds
```

---

## 🚀 Quick Start

### 1. Clone and Configure
```bash
git clone https://github.com/example/kernel-toolkit.git
cd kernel-toolkit
```

### 2. Setup environment
Make sure you're running on a compatible system. For consistency, the toolkit supports Docker-based builds.

#### Run inside container
```bash
./bin/container-run.sh bash
```
> This wraps your shell inside a clean container environment (Ubuntu-based) with preinstalled dependencies. It guarantees build reproducibility regardless of host OS.

---

## 🛠️ Core Usage

### Building the kernel (from the container)
```bash
./bin/kernel.sh --arch arm64 --config pixel_5_defconfig --target dtboimage
```

### Key Bash snippet: Modular argument handling
Inside `bin/kernel.sh`:
```bash
for arg in "$@"; do
  case "$arg" in
    --arch=*) ARCH="${arg#*=}" ;;
    --config=*) KCONFIG="${arg#*=}" ;;
    --target=*) TARGETS+=("${arg#*=}") ;;
    ...
  esac
done
```
> This dynamic flag parsing enables easily extensible options (`--foo=bar`) without hardcoding the sequence, keeping `kernel.sh` versatile.

### Commonly used targets:
- `image` — Build kernel image
- `dtboimage` — Build device tree blobs
- `modules` — Compile and install external modules
- `clean` — Clean build tree

---

## ⚙️ Config and Preset System

Configuration is layered:
1. **Global defaults** in `etc/config-defaults.sh`
2. **Per-device presets** in `etc/presets/*.sh`
3. **User overrides** passed via command line or env

### Example: Preset file structure

```bash
# etc/presets/pixel_5.sh
ARCH=arm64
KERNEL_DEFCONFIG=pixel_5_defconfig
TARGETS=(image dtboimage)
```

### Apply a preset manually
```bash
source etc/presets/pixel_5.sh
./bin/kernel.sh
```

> 🧠 **Why this matters:** Separating config logic from build logic reduces duplication and makes it easier to scale to more devices or tweak builds independently.

---

## 🐳 Container-Based Environment

All builds are expected to occur in an isolated container:

```bash
./bin/container-run.sh bash
```

Key Bash logic:
```bash
if [[ -n "$CI" ]]; then
  docker run --rm -v "$PWD":/src kernel-builder
else
  exec docker run -it -v "$PWD":/src kernel-builder bash
fi
```

> This block conditionally adjusts behavior depending on whether you're running in CI vs interactively, using `exec` for PID 1 replacement in local sessions.

---

## 🪄 Bash Highlights: Important Logic Explained

### Dynamic toolchain detection
```bash
TOOLCHAIN_DIR="$(find /opt/toolchains -type d -name 'gcc-*' | sort | tail -n1)"
```
> Ensures that the most recent available toolchain is selected without hardcoding paths.

### Build log management
```bash
exec &> >(tee -a "$LOG_FILE")
```
> Redirects all output to both stdout and a persistent log file. Crucial for debugging CI or headless builds.

### Fail-fast error handling
```bash
set -euo pipefail
```
> Ensures scripts immediately exit on:
- Any failed command (`-e`)
- Use of undefined variables (`-u`)
- Failures in piped commands (`-o pipefail`)

---

## 🧼 Cleaning and Reset

Clean up all build artifacts:
```bash
./bin/kernel.sh --target clean
```

To reset everything including temp/cache:
```bash
rm -rf tmp/ out/
```

> Use this when switching kernel versions or debugging persistent build issues.

---

[next]
```
