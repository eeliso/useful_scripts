# Configuration Management & OS Patching

Ansible-based configuration management for mixed Linux/Windows server environments. Handles package installation, OS patching with automatic reboots, and configuration file distribution.

## Prerequisites

- **Ansible 2.14+** with the following collections:
  ```bash
  ansible-galaxy collection install ansible.windows chocolatey.chocolatey
  ```
- **Linux targets**: SSH access with sudo privileges
- **Windows targets**: WinRM enabled over HTTPS (port 5986)

## Quick Start

1. **Edit the inventory** —  Set packages, config files, and patching preferences per host.

2. **Credentials** — The playbook will prompt you for passwords at runtime. No passwords are stored in files. You can configure usernames in `group_vars/linux.yml` and `group_vars/windows.yml`.

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

## Authentication

When you run the playbook, you will be prompted for passwords interactively:

```
Enter SSH password for Linux hosts:
Enter sudo password for Linux hosts (press Enter if same as SSH):
Enter WinRM password for Windows hosts:
```

If you limit the run to one group, only the relevant prompts appear. Alternatively, you can use CLI flags instead of the built-in prompts:

```bash
# Single password for all hosts
ansible-playbook site.yml --ask-pass

# SSH + sudo password
ansible-playbook site.yml --ask-pass --ask-become-pass
```

## Common Commands

```bash
# Run against all hosts (prompts for passwords)
ansible-playbook site.yml

# Run against Linux or Windows only
ansible-playbook site.yml --limit "linux"
ansible-playbook site.yml --limit "windows"

# Run against a single host
ansible-playbook site.yml --limit "web01.corp.com"

# Run only specific roles
ansible-playbook site.yml --tags packages
ansible-playbook site.yml --tags patching
ansible-playbook site.yml --tags config_files

# Combine: patch only Linux
ansible-playbook site.yml --limit "linux" --tags patching

# Dry run (no changes made)
ansible-playbook site.yml --check --diff
```

## File Structure

```
├── ansible.cfg              # Ansible settings
├── inventory.yml            # Server definitions
├── site.yml                 # Master playbook
├── group_vars/
│   ├── linux.yml            # Linux connection & defaults
│   └── windows.yml          # Windows connection & defaults
├── files/                   # Config files to distribute
└── roles/
    ├── packages/tasks/main.yml     # Package installation
    ├── patching/tasks/main.yml     # OS patching + reboot
    └── config_files/tasks/main.yml # Config file distribution
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
| `fireeye_package` | *(must set)* | Path to FireEye `.tgz` installer on the Ansible control node |

## Security Packages

The inventory is pre-configured with these security-focused packages:

| Package | Linux | Windows | Install Method | Purpose |
|---|---|---|---|---|
| `fireeye-agent` | ✅ | ✅ | Local `.tgz` | FireEye/Trellix EDR agent |
| `filebeat` | ✅ | ✅ | Repo/Chocolatey | Log shipping to Elastic |

> **Note:** `fireeye-agent` is installed from a local `.tgz` archive. Set the `fireeye_package` variable in `group_vars/linux.yml` and `group_vars/windows.yml` to the path on your Ansible control node.
