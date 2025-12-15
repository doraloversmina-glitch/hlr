-- =============================================================================================
-- Package: P1_CONFIG_HELPER_PKG_TE
-- Purpose: Helper package to access configuration tables and generate dynamic SQL
-- =============================================================================================

CREATE OR REPLACE PACKAGE P1_CONFIG_HELPER_PKG_TE AS

    -- Get active APN IDs
    FUNCTION GET_ACTIVE_APN_IDS RETURN VARCHAR2;

    -- Generate APN column definitions for CREATE TABLE
    FUNCTION GENERATE_APN_COLUMNS(p_hlr_suffix VARCHAR2) RETURN VARCHAR2;

    -- Generate SDP routing CASE statement
    FUNCTION GENERATE_SDP_CASE(p_msisdn_column VARCHAR2) RETURN VARCHAR2;

    -- Generate HLR primary flag DECODE statement
    FUNCTION GENERATE_HLR_DECODE(p_imsi_column VARCHAR2) RETURN VARCHAR2;

    -- Generate MISP filter condition
    FUNCTION GENERATE_MISP_FILTER RETURN VARCHAR2;

    -- Get companion product CASE statement
    FUNCTION GENERATE_COMPANION_CASE(p_hlr_suffix VARCHAR2) RETURN VARCHAR2;

    -- Get system configuration value
    FUNCTION GET_SYS_CONFIG(p_config_key VARCHAR2) RETURN VARCHAR2;

    -- Check if activity trace is enabled
    FUNCTION IS_TRACE_ENABLED RETURN BOOLEAN;

END P1_CONFIG_HELPER_PKG_TE;
/

CREATE OR REPLACE PACKAGE BODY P1_CONFIG_HELPER_PKG_TE AS

    -- =============================================================================================
    -- Function: GET_ACTIVE_APN_IDS
    -- Purpose: Get comma-separated list of active APN IDs
    -- =============================================================================================
    FUNCTION GET_ACTIVE_APN_IDS RETURN VARCHAR2 IS
        v_apn_list VARCHAR2(4000);
    BEGIN
        SELECT LISTAGG('''' || APN_ID || '''', ',') WITHIN GROUP (ORDER BY PRIORITY_ORDER)
        INTO v_apn_list
        FROM P1_APN_CONFIG_TE
        WHERE ACTIVE_FLAG = 'Y';

        RETURN v_apn_list;
    END GET_ACTIVE_APN_IDS;

    -- =============================================================================================
    -- Function: GENERATE_APN_COLUMNS
    -- Purpose: Generate dynamic APN column definitions
    -- =============================================================================================
    FUNCTION GENERATE_APN_COLUMNS(p_hlr_suffix VARCHAR2) RETURN VARCHAR2 IS
        v_sql VARCHAR2(8000) := '';
    BEGIN
        FOR rec IN (SELECT APN_ID, APN_NAME, PRIORITY_ORDER
                    FROM P1_APN_CONFIG_TE
                    WHERE ACTIVE_FLAG = 'Y'
                    ORDER BY PRIORITY_ORDER) LOOP

            v_sql := v_sql || '                       max( decode( APN_ID, ''' || rec.APN_ID || ''', APN_ID, null ) ) AS ' ||
                     rec.APN_NAME || p_hlr_suffix || ',' || CHR(10);
        END LOOP;

        -- Remove trailing comma and newline
        IF LENGTH(v_sql) > 0 THEN
            v_sql := RTRIM(v_sql, ',' || CHR(10));
        END IF;

        RETURN v_sql;
    END GENERATE_APN_COLUMNS;

    -- =============================================================================================
    -- Function: GENERATE_SDP_CASE
    -- Purpose: Generate dynamic SDP routing CASE statement
    -- =============================================================================================
    FUNCTION GENERATE_SDP_CASE(p_msisdn_column VARCHAR2) RETURN VARCHAR2 IS
        v_sql VARCHAR2(8000);
    BEGIN
        v_sql := '(case ';

        FOR rec IN (SELECT MSISDN_RANGE_START, MSISDN_RANGE_END, SDP_NAME
                    FROM P1_SDP_ROUTING_CONFIG_TE
                    WHERE ACTIVE_FLAG = 'Y'
                    ORDER BY PRIORITY_ORDER) LOOP

            v_sql := v_sql || CHR(10) ||
                     '                                  when (to_number(' || p_msisdn_column || ') between ' ||
                     rec.MSISDN_RANGE_START || ' and ' || rec.MSISDN_RANGE_END || ') then ''' ||
                     rec.SDP_NAME || '''';
        END LOOP;

        -- Add default case
        v_sql := v_sql || CHR(10) || '                                  else ''' || GET_SYS_CONFIG('DEFAULT_SDP') || '''';
        v_sql := v_sql || CHR(10) || '                             end)';

        RETURN v_sql;
    END GENERATE_SDP_CASE;

    -- =============================================================================================
    -- Function: GENERATE_HLR_DECODE
    -- Purpose: Generate HLR primary flag DECODE statement
    -- =============================================================================================
    FUNCTION GENERATE_HLR_DECODE(p_imsi_column VARCHAR2) RETURN VARCHAR2 IS
        v_sql VARCHAR2(4000);
        v_first BOOLEAN := TRUE;
    BEGIN
        v_sql := 'decode(' || p_imsi_column || ',';

        FOR rec IN (SELECT IMSI_PREFIX, HLR_NUMBER
                    FROM P1_HLR_CONFIG_TE
                    WHERE ACTIVE_FLAG = 'Y'
                    AND HLR_NUMBER > 0
                    ORDER BY IMSI_PREFIX) LOOP

            v_sql := v_sql || '''' || rec.IMSI_PREFIX || ''',' || rec.HLR_NUMBER || ',';
        END LOOP;

        -- Add default HLR
        v_sql := v_sql || GET_SYS_CONFIG('DEFAULT_HLR') || ')';

        RETURN v_sql;
    END GENERATE_HLR_DECODE;

    -- =============================================================================================
    -- Function: GENERATE_MISP_FILTER
    -- Purpose: Generate MISP filter condition for WHERE clause
    -- =============================================================================================
    FUNCTION GENERATE_MISP_FILTER RETURN VARCHAR2 IS
        v_sql VARCHAR2(4000);
        v_product_types VARCHAR2(2000);
        v_rate_plans VARCHAR2(2000);
    BEGIN
        -- Get distinct product types
        SELECT LISTAGG('''' || DISTINCT PRODUCT_TYPE_NAME || '''', ',') WITHIN GROUP (ORDER BY PRODUCT_TYPE_NAME)
        INTO v_product_types
        FROM (SELECT DISTINCT PRODUCT_TYPE_NAME FROM P1_PRODUCT_CONFIG_TE WHERE ACTIVE_FLAG = 'Y' AND CATEGORY = 'MISP');

        -- Get rate plans
        SELECT LISTAGG(RATE_PLAN, ',') WITHIN GROUP (ORDER BY RATE_PLAN)
        INTO v_rate_plans
        FROM P1_PRODUCT_CONFIG_TE
        WHERE ACTIVE_FLAG = 'Y'
        AND CATEGORY = 'MISP';

        v_sql := 'T.PRODUCT_TYPE_NAME IN (' || v_product_types || ')' || CHR(10) ||
                 '                  AND T.RATE_PLAN IN (' || v_rate_plans || ')';

        RETURN v_sql;
    END GENERATE_MISP_FILTER;

    -- =============================================================================================
    -- Function: GENERATE_COMPANION_CASE
    -- Purpose: Generate companion product CASE statement
    -- =============================================================================================
    FUNCTION GENERATE_COMPANION_CASE(p_hlr_suffix VARCHAR2) RETURN VARCHAR2 IS
        v_sql VARCHAR2(8000);
    BEGIN
        v_sql := '(case';

        FOR rec IN (SELECT APN_NAME, COMPANION_PRODUCT
                    FROM P1_APN_CONFIG_TE
                    WHERE ACTIVE_FLAG = 'Y'
                    ORDER BY PRIORITY_ORDER) LOOP

            v_sql := v_sql || CHR(10) ||
                     '                        when t.' || rec.APN_NAME || p_hlr_suffix ||
                     ' is not null then ''' || rec.COMPANION_PRODUCT || '''';
        END LOOP;

        v_sql := v_sql || CHR(10) || '                                                    else ''OTHER''' || CHR(10) ||
                 '                         end)';

        RETURN v_sql;
    END GENERATE_COMPANION_CASE;

    -- =============================================================================================
    -- Function: GET_SYS_CONFIG
    -- Purpose: Get system configuration value by key
    -- =============================================================================================
    FUNCTION GET_SYS_CONFIG(p_config_key VARCHAR2) RETURN VARCHAR2 IS
        v_value VARCHAR2(500);
    BEGIN
        SELECT CONFIG_VALUE
        INTO v_value
        FROM P1_SYSTEM_CONFIG_TE
        WHERE CONFIG_KEY = p_config_key
        AND ACTIVE_FLAG = 'Y';

        RETURN v_value;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GET_SYS_CONFIG;

    -- =============================================================================================
    -- Function: IS_TRACE_ENABLED
    -- Purpose: Check if activity tracing is enabled
    -- =============================================================================================
    FUNCTION IS_TRACE_ENABLED RETURN BOOLEAN IS
        v_enabled VARCHAR2(1);
    BEGIN
        v_enabled := GET_SYS_CONFIG('ENABLE_ACTIVITY_TRACE');
        RETURN (v_enabled = 'Y');
    EXCEPTION
        WHEN OTHERS THEN
            RETURN TRUE; -- Default to enabled
    END IS_TRACE_ENABLED;

END P1_CONFIG_HELPER_PKG_TE;
/
