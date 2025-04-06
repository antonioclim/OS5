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

---

## 🛠️ Core Usage

### Building the kernel (from the container)
```bash
./bin/kernel.sh --arch arm64 --config pixel_5_defconfig --target dtboimage
```

### Key Bash snippet: Modular argument handling
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

---

## 🐳 Container-Based Environment

All builds are expected to occur in an isolated container:

```bash
./bin/container-run.sh bash
```

### Key Bash logic:
```bash
if [[ -n "$CI" ]]; then
  docker run --rm -v "$PWD":/src kernel-builder
else
  exec docker run -it -v "$PWD":/src kernel-builder bash
fi
```

---

## 🪄 Bash Highlights: Important Logic Explained

### Dynamic toolchain detection
```bash
TOOLCHAIN_DIR="$(find /opt/toolchains -type d -name 'gcc-*' | sort | tail -n1)"
```

### Build log management
```bash
exec &> >(tee -a "$LOG_FILE")
```

### Fail-fast error handling
```bash
set -euo pipefail
```

---

## 🔒 Concurrency & Synchronization in Bash

### 🔐 File Locking with `flock`
```bash
(
  flock -n 200 || exit 1
  do_critical_work
) 200>/tmp/build.lock
```

---

## 🧪 Background Tasks + Temp Files
```bash
tmpfile=$(mktemp)
some_long_command > "$tmpfile" &
pid=$!
wait "$pid"
rm -f "$tmpfile"
```

---

## 📊 Monitoring and Debugging
```bash
echo "CPU: $(uptime)"
echo "Memory: $(free -h)"
echo "Disk: $(df -h /)"
```

---

## 🧹 Logging & Temporary File Hygiene
```bash
find logs/ -type f -name '*.log' -mtime +7 -delete

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
```

---

## 🧠 Resource Allocation Analogy: The Banker's Algorithm
```bash
JOBS=$(nproc)
[[ $JOBS -ge 4 ]] || MAKEFLAGS=-j1
```

---

## 🧭 Deadlocks and Safe Execution
```bash
(
  flock -w 5 200 || exit 1
  critical_task
) 200>/tmp/build.lock
```

---

## 🧩 Scheduling Logic (Sleeping Barber Analogy)
```bash
./bin/build-logs.sh &
log_pid=$!
./bin/kernel.sh --target image
wait "$log_pid"
```

---

## 🧵 Init and Resource Management
```bash
LOCKDIR=/tmp/kernel-locks
mkdir -p "$LOCKDIR"
touch "$LOCKDIR/build.lock"
```

---

## 🧠 Readers-Writers in Bash
```bash
cat logs/*.log | grep ERROR

(
  flock -x 200
  echo "New log" >> logs/errors.log
) 200>logs/errors.log.lock
```

---

## 🧽 Cleanup
```bash
cleanup() {
  rm -f "$LOCK_FILE" "$TMP_FILE"
}
trap cleanup EXIT
```

---

## 🛠 Summary Table

| OS Concept            | Toolkit Equivalent                              |
|-----------------------|--------------------------------------------------|
| Concurrency           | Background builds, job control                   |
| Synchronization       | flock usage for mutual exclusion                 |
| Deadlock prevention   | Timeouts, ordered locking                        |
| Resource safety       | Banker's-style checks before job spawning        |
| Scheduling model      | Sleeping Barber-style interactive queuing        |
| File access control   | Readers-Writers: concurrent read, exclusive write|

---

## 📘 Learning Path

1. `kernel.sh` – argument parsing
2. `container-run.sh` – consistent env
3. `init.sh` / `cleanup.sh` – lifecycle logic
4. `logs/` – trace error flow
5. `presets/` – extend support
6. New scripts – use flock, mktemp, trap

---

## 🙌 Contributing

Follow Bash best practices:
- `set -euo pipefail`
- Use `flock` and `trap`
- Clean logs and temp files
- Comment complex Bash logic

---

## 🧠 Final Analogy

> This toolkit is a miniature OS:
> - Container = kernel
> - Scripts = user processes
> - Logs = /var/log
> - You = the scheduler and the banker

Build responsibly. Lock wisely. Enjoy scripting!