#!/bin/bash
# Oracle Instant Client Environment Setup

# Set Oracle Client library path
export LD_LIBRARY_PATH=/opt/oracle:$LD_LIBRARY_PATH
export ORACLE_HOME=/opt/oracle

# Start the secure dashboard
cd /home/user/hlr/dashboard
python3 app_secure.py
