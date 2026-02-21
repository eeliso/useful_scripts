# Configuration Management & OS Patching

Ansible-based configuration management for mixed Linux/Windows server environments. Handles package installation, OS patching with automatic reboots, and configuration file distribution.

## Prerequisites

- **ansible-core 2.16** installed via pipx:
  ```bash
  pipx install ansible-core==2.16.14
  pipx inject ansible-core pywinrm
  ansible-galaxy collection install ansible.windows chocolatey.chocolatey community.windows
  ```
- **Linux targets**: SSH access as root
- **Windows targets**: WinRM enabled over HTTPS (port 5986)

## Quick Start

1. **Edit the inventory** — Set packages, config files, and patching preferences per host.

2. **Credentials** — All playbooks prompt for passwords at runtime. No passwords are stored in files. Configure usernames in `group_vars/linux.yml` and `group_vars/windows.yml`.

3. **Place config files** — Drop any configuration files into the `files/` directory.

4. **Bootstrap Python** on Linux targets (first-time only):
   ```bash
   ansible-playbook init.yml
   ```

5. **Dry run** to see what would change:
   ```bash
   ansible-playbook site.yml --check --diff
   ```

6. **Apply** to all hosts:
   ```bash
   ansible-playbook site.yml
   ```

## Playbooks

| Playbook | Purpose | Reboots? |
|---|---|---|
| `site.yml` | Run everything (packages → config → patching) | ⚠️ Yes |
| `packages.yml` | Install/manage packages and FireEye agent | No |
| `config.yml` | Distribute configuration files | No |
| `patch.yml` | OS patching with optional auto-reboot | ⚠️ Yes |
| `init.yml` | Bootstrap Python on new Linux hosts (run once) | No |

## Common Commands

```bash
# --- Full run (packages + config + patching) ---
ansible-playbook site.yml

# --- Packages only (safe, no reboots) ---
ansible-playbook packages.yml                          # all hosts
ansible-playbook packages.yml --limit "linux"          # linux only
ansible-playbook packages.yml --limit "siem.ldil.vle.fi"  # single host

# --- Config files only ---
ansible-playbook config.yml
ansible-playbook config.yml --limit "windows"

# --- OS patching (may reboot!) ---
ansible-playbook patch.yml                             # all hosts
ansible-playbook patch.yml --limit "linux"             # linux only
ansible-playbook patch.yml --check --diff              # dry-run first!

# --- Dry run (no changes made) ---
ansible-playbook site.yml --check --diff
```

## Authentication

All playbooks prompt for passwords interactively:

```
Enter SSH password for Linux hosts:
Enter WinRM password for Windows hosts:
```

If you limit the run to one group, only the relevant prompt appears.

## File Structure

```
├── ansible.cfg              # Ansible settings
├── inventory.yml            # Server definitions
├── site.yml                 # Master playbook (imports all below)
├── packages.yml             # Package installation playbook
├── patch.yml                # OS patching playbook
├── config.yml               # Config file distribution playbook
├── init.yml                 # Python bootstrap (run once)
├── group_vars/
│   ├── linux.yml            # Linux connection & defaults
│   └── windows.yml          # Windows connection & defaults
├── files/                   # Config files & installers
└── roles/
    ├── packages/tasks/main.yml     # Package installation logic
    ├── patching/tasks/main.yml     # OS patching + reboot logic
    └── config_files/tasks/main.yml # Config file distribution logic
```

## Adding a Server

Add a new entry under the appropriate group in `inventory.yml`:

```yaml
linux:
  hosts:
    newserver.corp.com:
      packages:
        - fail2ban
        - elastic-agent
        - filebeat
      config_files:
        - sshd_config
      patch: true
```

## Per-Host Controls

| Variable | Type | Default | Description |
|---|---|---|---|
| `packages` | list | `[]` | Packages to install |
| `config_files` | list | `[]` | Files from `files/` to push |
| `patch` | bool | `true` | Enable/disable OS patching |

## Group-Level Controls

Set in `group_vars/linux.yml` or `group_vars/windows.yml`:

| Variable | Default | Description |
|---|---|---|
| `patching_auto_reboot` | `true` | Reboot after patching if required |
| `patching_reboot_timeout` | `600`/`1200` | Seconds to wait for reboot |
| `config_dest_dir` | `/etc/` or `C:\ProgramData\configs\` | Where config files are placed |
| `fireeye_package` | *(must set)* | Path to FireEye installer on the Ansible control node |

## Security Packages

| Package | Linux | Windows | Install Method | Purpose |
|---|---|---|---|---|
| `fireeye-agent` | ✅ | ✅ | Local `.tgz`/`.zip` | FireEye/Trellix EDR agent |
| `filebeat` | ✅ | ✅ | Repo/Chocolatey | Log shipping to Elastic |

> **Note:** `fireeye-agent` is installed from a local archive. Set the `fireeye_package` variable in `group_vars/linux.yml` and `group_vars/windows.yml` to the path on your Ansible control node.
