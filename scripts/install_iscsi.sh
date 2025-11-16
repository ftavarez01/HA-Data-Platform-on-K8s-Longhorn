#!/bin/bash
############################################
# Note: Run this script on all worker nodes# 
############################################
# This script automates the installation of iSCSI prerequisites 
# on Debian/Ubuntu worker nodes for the Longhorn storage platform.

# --- Permission Check ---
if [ "$EUID" -ne 0 ]
  then echo "ERROR: Please run this script with sudo."
  exit 1
fi

echo "--- Starting open-iscsi installation on the host ---"

# 1. Update the package index
apt update -y
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to update apt packages."
    exit 1
fi

# 2. Install the open-iscsi package
apt install open-iscsi -y
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install open-iscsi."
    exit 1
fi

# 3. Ensure the iscsid service is running and enabled
systemctl enable iscsid
systemctl start iscsid
STATUS=$(systemctl is-active iscsid)

if [ "$STATUS" = "active" ]; then
    echo "--- SUCCESS: open-iscsi installed and the iscsid service is running. ---"
else
    echo "WARNING: The iscsid service is not active. Current status: $STATUS"
fi
