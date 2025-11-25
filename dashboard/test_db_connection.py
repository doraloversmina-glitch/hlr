#!/usr/bin/env python3
"""
Oracle Database Connection Test Script
Tests connection to Oracle database for HLR Dashboard
"""

import sys
import cx_Oracle
from config import ORACLE_CONFIG

def test_connection():
    """Test Oracle database connection"""

    print("=" * 60)
    print("🔍 Oracle Database Connection Test")
    print("=" * 60)

    # Display configuration (hide password)
    print("\n📋 Connection Configuration:")
    print(f"   Host: {ORACLE_CONFIG['host']}")
    print(f"   Port: {ORACLE_CONFIG['port']}")
    print(f"   Service: {ORACLE_CONFIG['service_name']}")
    print(f"   Username: {ORACLE_CONFIG['username']}")
    print(f"   Password: {'*' * len(ORACLE_CONFIG['password'])}")

    print("\n🔌 Attempting connection...")

    try:
        # Create DSN
        dsn = cx_Oracle.makedsn(
            ORACLE_CONFIG['host'],
            ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service_name']
        )

        print(f"   DSN: {dsn}")

        # Connect
        connection = cx_Oracle.connect(
            ORACLE_CONFIG['username'],
            ORACLE_CONFIG['password'],
            dsn
        )

        print("\n✅ Connection successful!")

        # Test queries
        cursor = connection.cursor()

        # 1. Test basic query
        print("\n📊 Running test queries...")
        cursor.execute("SELECT SYSDATE FROM DUAL")
        result = cursor.fetchone()
        print(f"   Database time: {result[0]}")

        # 2. Check if reconciliation tables exist
        print("\n📁 Checking for reconciliation tables...")

        tables_to_check = [
            'RECONCILIATION_EXECUTION_LOG',
            'RECONCILIATION_ERRORS'
        ]

        for table in tables_to_check:
            cursor.execute(f"""
                SELECT COUNT(*)
                FROM user_tables
                WHERE table_name = '{table}'
            """)
            exists = cursor.fetchone()[0]

            if exists:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"   ✅ {table}: {count} records")
            else:
                print(f"   ❌ {table}: NOT FOUND (needs to be created)")

        # 3. Check HLR tables
        print("\n📁 Checking for HLR source tables...")

        hlr_tables = ['HLR1', 'HLR2', 'CLEAN_SV_ALL_UPD', 'PPS_ABONNE_JOUR_MIGDB']

        for table in hlr_tables:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table} WHERE ROWNUM <= 1")
                exists = True
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"   ✅ {table}: {count} records")
            except cx_Oracle.DatabaseError:
                print(f"   ❌ {table}: NOT FOUND")

        cursor.close()
        connection.close()

        print("\n" + "=" * 60)
        print("✅ Database connection test completed successfully!")
        print("=" * 60)
        print("\n💡 Next steps:")
        print("   1. If reconciliation tables are missing, run the SQL")
        print("      scripts from DATABASE_SETUP.md")
        print("   2. Update config.py: USE_REAL_DATABASE = True")
        print("   3. Restart the dashboard: python3 app_secure.py")
        print("=" * 60)

        return True

    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print("\n❌ Connection failed!")
        print(f"\n🔴 Error Details:")
        print(f"   Error Code: {error.code}")
        print(f"   Error Message: {error.message}")

        print("\n💡 Common solutions:")

        if error.code == 12170 or error.code == 12541:
            print("   ❌ TNS: Connection timeout")
            print("   → Check if host and port are correct")
            print("   → Verify Oracle listener is running")
            print("   → Check firewall settings")

        elif error.code == 12514:
            print("   ❌ TNS: Listener does not know of service")
            print("   → Check service_name in config.py")
            print("   → Try using SID instead of service_name")

        elif error.code == 1017:
            print("   ❌ Invalid username/password")
            print("   → Verify credentials in config.py")
            print("   → Check if account is locked")

        elif error.code == 12545:
            print("   ❌ Host unreachable")
            print("   → Check if host address is correct")
            print("   → Verify network connectivity")

        print("\n📖 Full troubleshooting guide: DATABASE_SETUP.md")
        print("=" * 60)

        return False

    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        print(f"   Type: {type(e).__name__}")
        return False

if __name__ == '__main__':
    success = test_connection()
    sys.exit(0 if success else 1)
