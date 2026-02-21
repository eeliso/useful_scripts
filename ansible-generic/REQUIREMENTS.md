# Requirements & Setup

## Control Node

- **ansible-core 2.16** installed via pipx:
  ```bash
  pipx install ansible-core==2.16.14
  pipx inject ansible-core pywinrm
  ansible-galaxy collection install ansible.windows chocolatey.chocolatey community.windows
  ```

## Linux Targets

- SSH access as root (or user with sudo)
- Python 3 — bootstrap with `ansible-playbook init.yml` if missing

## Windows Targets

WinRM must be enabled. Run in an **elevated PowerShell** on each Windows server:

```powershell
# Enable WinRM
winrm quickconfig -force

# Allow unencrypted connections (HTTP/port 5985)
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Enable basic auth
winrm set winrm/config/service/auth '@{Basic="true"}'

# Open firewall for WinRM
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985

# Verify
winrm enumerate winrm/config/listener
```

### HTTP Fallback

If a server has TLS/SSL issues, switch to HTTP in `inventory.yml`:

```yaml
windows:
  hosts:
    server.example.com:
      ansible_port: 5985
      ansible_winrm_scheme: http
```

### Verify Connectivity

```bash
ansible server.example.com -m win_ping --ask-pass
```
