#!/bin/bash

# Fail the script if any command returns a non-zero status
set -e

# Prompt for the necessary details
echo "Enter the remote username (eg: eo):"
read REMOTE_USER

echo "Enter the remote host (eg: localserver01 or IP address):"
read REMOTE_HOST

echo "Enter the path to your SSH key (Leave blank to generate new one):"
read SSH_KEY_PATH

# Default SSH key path in case none is provided
if [[ -z "$SSH_KEY_PATH" ]]; then
    SSH_KEY_PATH="$HOME/.ssh/id_rsa"
fi

# Generate an SSH key if it doesn't already exist
if [[ ! -f "$SSH_KEY_PATH" ]]; then
    echo "SSH key not found, generating new one..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -C "$USER@$(hostname)" -N ""
else
    echo "SSH key exists at $SSH_KEY_PATH, using that."
fi

# Ensure new SSH agent is started and adds the private key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

# Copy the public key to the remote host using the SSH user supplied
echo "Copying SSH key to ${REMOTE_USER}@${REMOTE_HOST}..."
ssh-copy-id -i "${SSH_KEY_PATH}.pub" "${REMOTE_USER}@${REMOTE_HOST}"

# Verify if the key was successfully added
echo "Verifying on remote host..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && cat ~/.ssh/authorized_keys"

echo "SSH key successfully added. Test your SSH connection using: ssh ${REMOTE_USER}@${REMOTE_HOST}"

# Optional: Open a non-password-protected SSH session as a test
read -p "Would you like to connect to ${REMOTE_USER}@${REMOTE_HOST} now? (y/n): " CONNECT

if [[ "$CONNECT" == "y" || "$CONNECT" == "Y" ]]; then
    ssh "${REMOTE_USER}@${REMOTE_HOST}"
else
    echo "You can connect later using: ssh ${REMOTE_USER}@${REMOTE_HOST}"
fi
