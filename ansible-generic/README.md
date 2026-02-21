# Ansible Configuration Management

Centralized, repeatable management of a mixed Linux/Windows server environment. One inventory, one set of playbooks — packages get installed, security patches get applied, configs get pushed.

## Philosophy

- **Security-first patching** — Only security updates are applied, never full upgrades. Application packages stay pinned to their current versions unless explicitly changed.
- **Idempotent everything** — Every playbook is safe to re-run. Services that are already configured get skipped, packages already installed don't get touched.
- **No secrets in code** — All passwords are prompted at runtime. Nothing sensitive is committed to the repository.
- **Dry-run by default** — Always preview changes with `--check --diff` before applying.

## Playbooks

| Playbook | Purpose | Reboots? |
|---|---|---|
| `site.yml` | Run everything (packages → config → patching) | ⚠️ Yes |
| `packages.yml` | Install packages and FireEye/Trellix agent | No |
| `config.yml` | Distribute configuration files | No |
| `patch.yml` | Security-only OS patching with auto-reboot | ⚠️ Yes |
| `init.yml` | Bootstrap Python on new Linux hosts (once) | No |

## Usage

```bash
# Preview changes first (always recommended)
ansible-playbook site.yml --check --diff

# Full run
ansible-playbook site.yml

# Individual playbooks
ansible-playbook packages.yml
ansible-playbook config.yml
ansible-playbook patch.yml

# Target specific hosts
ansible-playbook site.yml --limit "linux"
ansible-playbook site.yml --limit "siem.ldil.vle.fi"
```

## Adding a Server

Add an entry under `linux` or `windows` in `inventory.yml`:

```yaml
linux:
  hosts:
    newserver.corp.com:
      packages:
        - fireeye-agent
        - filebeat
      config_files: []
      patch: true
```

## Per-Host Controls

| Variable | Type | Default | Description |
|---|---|---|---|
| `packages` | list | `[]` | Packages to install via repo or local archive |
| `config_files` | list | `[]` | Files from `files/` directory to push |
| `patch` | bool | `true` | Enable/disable security patching |

## Project Structure

```
├── inventory.yml              # All servers and their settings
├── site.yml                   # Master playbook
├── packages.yml / config.yml / patch.yml / init.yml
├── group_vars/
│   ├── linux.yml              # Linux connection & patching defaults
│   └── windows.yml            # Windows connection & patching defaults
├── files/                     # Config files & agent installers
└── roles/
    ├── packages/              # Package & agent installation
    ├── config_files/          # Config file distribution
    └── patching/              # Security-only OS patching
```

## Setup

See [REQUIREMENTS.md](REQUIREMENTS.md) for control node setup, target prerequisites, and WinRM configuration.
