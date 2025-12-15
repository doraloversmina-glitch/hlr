-- =============================================================================================
-- P1_MAIN_SYS_INTERFACES_TE - Complete Installation Script
-- Purpose: Install all components in correct order
-- Date: 2025-12-15
-- =============================================================================================

WHENEVER SQLERROR EXIT SQL.SQLCODE
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON

PROMPT =============================================================================================
PROMPT P1_MAIN_SYS_INTERFACES_TE Installation Starting...
PROMPT =============================================================================================

PROMPT
PROMPT Step 1: Creating Configuration Tables...
PROMPT =============================================================================================
@@P1_CONFIG_TABLES_TE.sql

PROMPT
PROMPT Step 2: Creating Helper Package...
PROMPT =============================================================================================
@@P1_CONFIG_HELPER_PKG_TE.sql

PROMPT
PROMPT Step 3: Verifying Installation...
PROMPT =============================================================================================

-- Verify configuration tables
DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Verifying configuration tables...');

    SELECT COUNT(*) INTO v_count FROM P1_APN_CONFIG_TE WHERE ACTIVE_FLAG = 'Y';
    DBMS_OUTPUT.PUT_LINE('  - P1_APN_CONFIG_TE: ' || v_count || ' active APNs');

    SELECT COUNT(*) INTO v_count FROM P1_SDP_ROUTING_CONFIG_TE WHERE ACTIVE_FLAG = 'Y';
    DBMS_OUTPUT.PUT_LINE('  - P1_SDP_ROUTING_CONFIG_TE: ' || v_count || ' active routes');

    SELECT COUNT(*) INTO v_count FROM P1_HLR_CONFIG_TE WHERE ACTIVE_FLAG = 'Y';
    DBMS_OUTPUT.PUT_LINE('  - P1_HLR_CONFIG_TE: ' || v_count || ' active HLR configs');

    SELECT COUNT(*) INTO v_count FROM P1_PRODUCT_CONFIG_TE WHERE ACTIVE_FLAG = 'Y';
    DBMS_OUTPUT.PUT_LINE('  - P1_PRODUCT_CONFIG_TE: ' || v_count || ' active products');

    SELECT COUNT(*) INTO v_count FROM P1_SYSTEM_CONFIG_TE WHERE ACTIVE_FLAG = 'Y';
    DBMS_OUTPUT.PUT_LINE('  - P1_SYSTEM_CONFIG_TE: ' || v_count || ' active configs');

    DBMS_OUTPUT.PUT_LINE('Configuration tables verified successfully!');
END;
/

-- Verify helper package
DECLARE
    v_status VARCHAR2(10);
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Verifying helper package...');

    SELECT STATUS INTO v_status
    FROM USER_OBJECTS
    WHERE OBJECT_NAME = 'P1_CONFIG_HELPER_PKG_TE'
    AND OBJECT_TYPE = 'PACKAGE BODY';

    IF v_status = 'VALID' THEN
        DBMS_OUTPUT.PUT_LINE('  - P1_CONFIG_HELPER_PKG_TE: VALID');
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Package body is INVALID');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Helper package verified successfully!');
END;
/

PROMPT
PROMPT Step 4: Testing Helper Functions...
PROMPT =============================================================================================

DECLARE
    v_apn_list VARCHAR2(4000);
    v_sdp_case VARCHAR2(8000);
    v_hlr_decode VARCHAR2(4000);
    v_misp_filter VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing helper functions...');

    -- Test GET_ACTIVE_APN_IDS
    v_apn_list := P1_CONFIG_HELPER_PKG_TE.GET_ACTIVE_APN_IDS();
    DBMS_OUTPUT.PUT_LINE('  - GET_ACTIVE_APN_IDS: ' || SUBSTR(v_apn_list, 1, 50) || '...');

    -- Test GENERATE_SDP_CASE
    v_sdp_case := P1_CONFIG_HELPER_PKG_TE.GENERATE_SDP_CASE('MSISDN');
    DBMS_OUTPUT.PUT_LINE('  - GENERATE_SDP_CASE: Generated successfully (' || LENGTH(v_sdp_case) || ' chars)');

    -- Test GENERATE_HLR_DECODE
    v_hlr_decode := P1_CONFIG_HELPER_PKG_TE.GENERATE_HLR_DECODE('IMSI');
    DBMS_OUTPUT.PUT_LINE('  - GENERATE_HLR_DECODE: ' || v_hlr_decode);

    -- Test GENERATE_MISP_FILTER
    v_misp_filter := P1_CONFIG_HELPER_PKG_TE.GENERATE_MISP_FILTER();
    DBMS_OUTPUT.PUT_LINE('  - GENERATE_MISP_FILTER: Generated successfully');

    -- Test GET_SYS_CONFIG
    DBMS_OUTPUT.PUT_LINE('  - GET_SYS_CONFIG(DEFAULT_SDP): ' ||
                        P1_CONFIG_HELPER_PKG_TE.GET_SYS_CONFIG('DEFAULT_SDP'));

    -- Test IS_TRACE_ENABLED
    IF P1_CONFIG_HELPER_PKG_TE.IS_TRACE_ENABLED() THEN
        DBMS_OUTPUT.PUT_LINE('  - IS_TRACE_ENABLED: TRUE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  - IS_TRACE_ENABLED: FALSE');
    END IF;

    DBMS_OUTPUT.PUT_LINE('All helper functions tested successfully!');
END;
/

PROMPT
PROMPT Step 5: Displaying Active Configurations...
PROMPT =============================================================================================

SELECT
    CONFIG_TYPE,
    COUNT(*) as TOTAL_CONFIGS
FROM V_P1_ACTIVE_CONFIG_TE
GROUP BY CONFIG_TYPE
ORDER BY CONFIG_TYPE;

PROMPT
PROMPT Step 6: Installation Summary
PROMPT =============================================================================================

SELECT
    OBJECT_TYPE,
    COUNT(*) as COUNT,
    SUM(CASE WHEN STATUS = 'VALID' THEN 1 ELSE 0 END) as VALID,
    SUM(CASE WHEN STATUS = 'INVALID' THEN 1 ELSE 0 END) as INVALID
FROM USER_OBJECTS
WHERE OBJECT_NAME LIKE 'P1%TE%'
OR OBJECT_NAME LIKE 'V_P1%TE%'
GROUP BY OBJECT_TYPE
ORDER BY OBJECT_TYPE;

PROMPT
PROMPT =============================================================================================
PROMPT Installation Complete!
PROMPT =============================================================================================
PROMPT
PROMPT Next Steps:
PROMPT 1. Review the configuration tables and adjust as needed
PROMPT 2. Ensure source tables exist: HLR1, HLR2, CLEAN_SV_ALL_UPD, PPS_ABONNE_JOUR_MIGDB
PROMPT 3. Deploy the main procedure P1_MAIN_SYS_INTERFACES_TE
PROMPT 4. Test with a sample execution
PROMPT
PROMPT For documentation, see: P1_ENHANCEMENT_README_TE.md
PROMPT =============================================================================================

SPOOL OFF
EXIT
