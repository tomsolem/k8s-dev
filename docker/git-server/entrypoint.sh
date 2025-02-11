#!/bin/sh

# Copy the SSH key to the shared volume
echo "Copying SSH host key to shared volume..."
cp /home/git/tmp/ssh/git-server_id /mnt/shared/git-server_id
cp /home/git/tmp/ssh/git-server_id.pub /mnt/shared/git-server_id.pub

# Ensure the authorized_keys file exists
echo "Checking for authorized_keys file..."
cat /home/git/tmp/ssh/git-server_id.pub > /home/git/.ssh/authorized_keys
# Start ssh
exec /usr/sbin/sshd -h /home/git/tmp/ssh/git-server_id -D -e "$@"

