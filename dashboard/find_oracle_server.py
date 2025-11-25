#!/usr/bin/env python3
"""
Oracle Database Discovery Script
Attempts to find the Oracle database server on your network
"""

import socket
import subprocess
import os

print("=" * 60)
print("🔍 Searching for Oracle Database Server...")
print("=" * 60)

# Check 1: Environment variables
print("\n📋 Checking environment variables...")
oracle_vars = ['ORACLE_HOME', 'ORACLE_SID', 'TNS_ADMIN', 'TWO_TASK']
found_vars = False
for var in oracle_vars:
    value = os.environ.get(var)
    if value:
        print(f"   ✅ {var} = {value}")
        found_vars = True

if not found_vars:
    print("   ❌ No Oracle environment variables found")

# Check 2: Local Oracle listener
print("\n🎧 Checking for local Oracle listener (port 1521)...")
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(2)
    result = sock.connect_ex(('localhost', 1521))
    sock.close()

    if result == 0:
        print("   ✅ Oracle listener found on localhost:1521")
        print("   💡 Try using: host='localhost' or host='127.0.0.1'")
    else:
        print("   ❌ No Oracle listener on localhost:1521")
except:
    print("   ❌ Cannot check localhost:1521")

# Check 3: Common local IPs
print("\n🌐 Checking common IP addresses on port 1521...")
common_ips = [
    '127.0.0.1',
    '192.168.1.1',
    '192.168.0.1',
    '10.0.0.1',
]

for ip in common_ips:
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((ip, 1521))
        sock.close()

        if result == 0:
            print(f"   ✅ Found Oracle listener at {ip}:1521")
            print(f"   💡 Try using: host='{ip}'")
    except:
        pass

# Check 4: Network interfaces
print("\n🔌 Your network interfaces:")
try:
    hostname = socket.gethostname()
    print(f"   Hostname: {hostname}")

    ip_address = socket.gethostbyname(hostname)
    print(f"   IP Address: {ip_address}")

    # Try this IP
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((ip_address, 1521))
        sock.close()

        if result == 0:
            print(f"   ✅ Found Oracle listener at {ip_address}:1521")
            print(f"   💡 Try using: host='{ip_address}'")
    except:
        pass
except:
    print("   ❌ Cannot determine network info")

# Check 5: Oracle processes
print("\n⚙️  Checking for Oracle processes...")
try:
    result = subprocess.run(['ps', 'aux'], capture_output=True, text=True, timeout=5)
    oracle_processes = [line for line in result.stdout.split('\n') if 'oracle' in line.lower() or 'tns' in line.lower()]

    if oracle_processes:
        print(f"   ✅ Found {len(oracle_processes)} Oracle-related processes")
        for proc in oracle_processes[:3]:  # Show first 3
            print(f"      {proc[:80]}...")
    else:
        print("   ❌ No Oracle processes found")
except:
    print("   ❌ Cannot check processes")

# Check 6: TNS files
print("\n📁 Looking for Oracle TNS configuration files...")
common_tns_locations = [
    '/etc/tnsnames.ora',
    '/opt/oracle/network/admin/tnsnames.ora',
    os.path.expanduser('~/.tnsnames.ora'),
    '$ORACLE_HOME/network/admin/tnsnames.ora',
]

for location in common_tns_locations:
    expanded = os.path.expandvars(location)
    if os.path.exists(expanded):
        print(f"   ✅ Found: {expanded}")
        try:
            with open(expanded, 'r') as f:
                content = f.read()
                if 'RECON_GEOX' in content:
                    print("   🎯 Found RECON_GEOX in this file!")
                    # Extract host info
                    for line in content.split('\n'):
                        if 'HOST' in line.upper():
                            print(f"      {line.strip()}")
        except:
            pass

print("\n" + "=" * 60)
print("📊 Summary & Recommendations")
print("=" * 60)

print("\n💡 What to try:")
print("\n1️⃣  If you found 'localhost' or '127.0.0.1' above:")
print("   → Use: host='localhost'")

print("\n2️⃣  If you found another IP address above:")
print("   → Use: host='<that_ip_address>'")

print("\n3️⃣  If nothing was found:")
print("   → The database might be on a remote server")
print("   → You'll need to ask someone who knows where it is")

print("\n4️⃣  Common scenarios:")
print("   • Database on same machine → host='localhost'")
print("   • Database on local network → host='192.168.x.x'")
print("   • Database on remote server → host='server.company.com'")

print("\n" + "=" * 60)
