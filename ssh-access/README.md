# SSH Key Setup Script

This script automates the process of generating an SSH key pair and copying the public key to a remote server for passwordless SSH login.

## Usage

1. **Make the script executable**:

   ```bash
   chmod +x setup_ssh_key.sh
   ```

2. **Run the script and follow the prompts**:

    ```bash
   ./setup_ssh.sh
   ```

## What the script does
1. Generates an SSH key if one doesn't exist.
2. Copies the public key to the authorized_keys file of the specified user on the remote server.
3. Ensures correct permissions on the remote server for SSH to work properly.
