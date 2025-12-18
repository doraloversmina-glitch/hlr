CREATE OR REPLACE PROCEDURE DANAD.P1_MAIN_SYS_INTERFACES_TE(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
) IS

    -- =============================================================================================
    --    Enhanced Version             : Test Edition with Performance Optimizations
    --    Modified by                  : Performance Refactoring Team
    --    Release                      : R1.1_TE
    --    Modification Date            : 18/12/2025
    --    Comments                     : Performance optimizations:
    --                                   - **ELIMINATED 14 UPDATE statements** (replaced with NVL in CREATE)
    --                                   - All objects use _TE suffix for test isolation
    --                                   - Objects created under DANAD schema
    --                                   - Enhanced activity tracing with timestamps
    --                                   - FAFIF tables remain SELECT-only
    --                                   - Same business logic, same output, faster execution
    --   -------------------------------------------------------------------------------------------
    --    Original Author              : FAF
    --    Original Release             : R1.0
    --    Original Date                : 31/10/2009
    --    Pre-requisite(s)             : SV DMP (CLEAN_SV_ALL_UPD)
    --                                   HLR DMP (HLR1 & HLR2)
    --                                   MINSAT DMP (FAFIF.PPS_ABONNE_JOUR_MIGDB)
    -- =============================================================================================

    -- Variables
    SQL_TXT              VARCHAR2(8000);
    RELEASE              VARCHAR2(20)    := 'R1.1_TE';
    ENT_TYPE_CODE        NUMBER;
    ENT_CODE             NUMBER;
    CLIENT_ID            VARCHAR2(10);
    SAS_TABLE            VARCHAR2(100);
    REJ_TABLE            VARCHAR2(100);
    HIST_TABLE           VARCHAR2(100);
    CURRENT_DATE         VARCHAR2(100);

    -- Activity tracing
    v_step               VARCHAR2(200);
    v_start_time         TIMESTAMP;
    v_end_time           TIMESTAMP;
    v_rows_affected      NUMBER;

    -- Exception declarations
    TABLE_CREATION_FAILED   EXCEPTION;
    INDEX_CREATION_FAILED   EXCEPTION;
    TABLE_UPDATE_FAILED     EXCEPTION;
    TABLE_INSERT_FAILED     EXCEPTION;
    FATAL_ERROR             EXCEPTION;
    TABLE_DROP_FAILED       EXCEPTION;
    EMPTY_ERROR             EXCEPTION;

    -- Activity logging procedure
    PROCEDURE log_activity(p_step VARCHAR2, p_start_time TIMESTAMP, p_end_time TIMESTAMP, p_rows NUMBER DEFAULT NULL) IS
        v_duration NUMBER;
    BEGIN
        v_duration := EXTRACT(SECOND FROM (p_end_time - p_start_time)) +
                      EXTRACT(MINUTE FROM (p_end_time - p_start_time)) * 60;
        DBMS_OUTPUT.PUT_LINE('[' || TO_CHAR(p_end_time, 'HH24:MI:SS') || '] ' || p_step ||
                           ' - Duration: ' || ROUND(v_duration, 2) || 's' ||
                           CASE WHEN p_rows IS NOT NULL THEN ' - Rows: ' || p_rows ELSE '' END);
    END log_activity;

BEGIN

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('P1_MAIN_SYS_INTERFACES_TE - Start');
    DBMS_OUTPUT.PUT_LINE('Release: ' || RELEASE);
    DBMS_OUTPUT.PUT_LINE('Timestamp: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('========================================');

    UTILS_INTERFACES.INTERFACE_NAME := 'P1_MAIN_SYS_INTERFACES_TE';

    -- ================================================================================================================
    -- STEP 1: Create SYS_MINSAT_TE from CS4 DMP
    -- ================================================================================================================
    v_step := 'Creating SYS_MINSAT_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.SYS_MINSAT_TE NOLOGGING AS
                SELECT DECODE(SUBSTR(SUBSTR(NUM_APPEL, 4), 1, 1),
                              7, SUBSTR(NUM_APPEL, 4),
                              3, ''0'' || (SUBSTR(NUM_APPEL, 4)),
                              1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN,
                       D.*
                FROM FAFIF.PPS_ABONNE_JOUR_MIGDB D';

    IF UTILS_INTERFACES.CREATE_TABLE('SYS_MINSAT_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- Create index
    v_step := 'Creating index IX_MINSAT_MSISDN_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('SYS_MINSAT_TE', 'DANAD', 'IX_MINSAT_MSISDN_TE', 'MSISDN') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 2: Create APN_DATA_HLR1_TE
    -- ================================================================================================================
    v_step := 'Creating APN_DATA_HLR1_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.APN_DATA_HLR1_TE NOLOGGING AS
                SELECT DECODE(SUBSTR(SUBSTR(D.MSISDN, 4), 1, 1),
                              7, SUBSTR(D.MSISDN, 4),
                              3, ''0'' || (SUBSTR(D.MSISDN, 4)),
                              1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_APN1,
                       D.IMSI AS IMSI_1, D.MSISDN AS MSISDN_1, D.APN_ID AS APN_ID_1,
                       D.PDP_ID AS PDP_ID_1, D.QOS AS QOS_1
                FROM FAFIF.APNID_HLR1 D
                WHERE SUBSTR(D.MSISDN, 0, 2) NOT IN ''01''
                  AND (SUBSTR(D.IMSI, 0, 6) NOT IN ''415018'' OR D.IMSI IS NULL)';

    IF UTILS_INTERFACES.CREATE_TABLE('APN_DATA_HLR1_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating index IX_MSISDN_APN1_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('APN_DATA_HLR1_TE', 'DANAD', 'IX_MSISDN_APN1_TE', 'MSISDN_APN1') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 3: Create APN_DATA_HLR2_TE
    -- ================================================================================================================
    v_step := 'Creating APN_DATA_HLR2_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.APN_DATA_HLR2_TE NOLOGGING AS
                SELECT DECODE(SUBSTR(SUBSTR(D.MSISDN, 4), 1, 1),
                              7, SUBSTR(D.MSISDN, 4),
                              3, ''0'' || (SUBSTR(D.MSISDN, 4)),
                              1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_APN2,
                       D.IMSI AS IMSI_2, D.MSISDN AS MSISDN_2, D.APN_ID AS APN_ID_2,
                       D.PDP_ID AS PDP_ID_2, D.QOS AS QOS_2
                FROM FAFIF.APNID_HLR2 D
                WHERE SUBSTR(D.MSISDN, 0, 2) NOT IN ''01''
                  AND (SUBSTR(D.IMSI, 0, 6) NOT IN ''415018'' OR D.IMSI IS NULL)';

    IF UTILS_INTERFACES.CREATE_TABLE('APN_DATA_HLR2_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating index IX_MSISDN_APN2_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('APN_DATA_HLR2_TE', 'DANAD', 'IX_MSISDN_APN2_TE', 'MSISDN_APN2') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 4: Create REP_SV_MSISDN_IN_MISP_TE
    -- ================================================================================================================
    v_step := 'Creating REP_SV_MSISDN_IN_MISP_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_SV_MSISDN_IN_MISP_TE NOLOGGING AS
                SELECT *
                FROM FAFIF.CLEAN_SV_ALL_UPD T
                WHERE T.PRODUCT_TYPE_NAME IN (''Mobile Broadband Prepaid'')
                  AND T.RATE_PLAN IN (31, 33, 30, 34, 32)';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_SV_MSISDN_IN_MISP_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 5: Create REP_SV_MSISDN_NOT_MISP_TE
    -- ================================================================================================================
    v_step := 'Creating REP_SV_MSISDN_NOT_MISP_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_SV_MSISDN_NOT_MISP_TE NOLOGGING AS
                SELECT *
                FROM FAFIF.CLEAN_SV_ALL_UPD T
                WHERE T.SERVICE_NAME NOT IN (SELECT SERVICE_NAME FROM DANAD.REP_SV_MSISDN_IN_MISP_TE)';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_SV_MSISDN_NOT_MISP_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 6: Create MERGE_SYS_SV_CS4_TE (SV merged with CS4)
    -- ================================================================================================================
    v_step := 'Creating MERGE_SYS_SV_CS4_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.MERGE_SYS_SV_CS4_TE NOLOGGING AS
                SELECT T.SERVICE_NAME AS MSISDN_SV,
                       ID, ACCOUNT_NAME, SERVICE_NAME, SERVICE_TYPE_NAME, PRODUCT_TYPE_NAME,
                       SERVICE_STATUS, ACCOUNT_TYPE, CUSTOMER_NODE_ID, SERVICE_START_DATE,
                       SERVICE_END_DATE, IMSI, FIRST_CALL, SHELF_LIFE_EXP, SERVICE_ID,
                       SERV_BP_INT, PRODUCT_INSTANCE_ID, PROD_START_DATE, PROD_END_DATE,
                       PRODUCT_ID, PROD_BP_INST, PROD_STATUS, PROD_REASON_CODE, PROD_REASON_NAME,
                       SERVICE_REASON_NAME, SERV_REASON_CODE, CUSTOMER_START_DATE, ACCOUNT_START_DATE,
                       LAST_RUN_DATE, T.DEALER_CODE_P, IMEI, ACCOUNT_ID, RATE_PLAN,
                       CUSTOMER_NODE_STATUS_CODE, TT.MSISDN AS MSISDN_CS4, JOUR, NUM_APPEL,
                       CUST_ID, CUST_CLASS, LANGUE, DATE_ACTIF, DATE_INACTIF, DATE_SUSP,
                       DATE_INIT, DATE_CREAT, ETAT_PPAS, ETAT, DUREE_VALIDITE, DATE_CHGT_ETAT,
                       AMOUNT, DATE_RETENTION
                FROM DANAD.REP_SV_MSISDN_NOT_MISP_TE T, DANAD.SYS_MINSAT_TE TT
                WHERE T.SERVICE_NAME(+) = TT.MSISDN
                UNION
                SELECT T.SERVICE_NAME AS MSISDN_SV,
                       ID, ACCOUNT_NAME, SERVICE_NAME, SERVICE_TYPE_NAME, PRODUCT_TYPE_NAME,
                       SERVICE_STATUS, ACCOUNT_TYPE, CUSTOMER_NODE_ID, SERVICE_START_DATE,
                       SERVICE_END_DATE, IMSI, FIRST_CALL, SHELF_LIFE_EXP, SERVICE_ID,
                       SERV_BP_INT, PRODUCT_INSTANCE_ID, PROD_START_DATE, PROD_END_DATE,
                       PRODUCT_ID, PROD_BP_INST, PROD_STATUS, PROD_REASON_CODE, PROD_REASON_NAME,
                       SERVICE_REASON_NAME, SERV_REASON_CODE, CUSTOMER_START_DATE, ACCOUNT_START_DATE,
                       LAST_RUN_DATE, T.DEALER_CODE_P, IMEI, ACCOUNT_ID, RATE_PLAN,
                       CUSTOMER_NODE_STATUS_CODE, TT.MSISDN AS MSISDN_CS4, JOUR, NUM_APPEL,
                       CUST_ID, CUST_CLASS, LANGUE, DATE_ACTIF, DATE_INACTIF, DATE_SUSP,
                       DATE_INIT, DATE_CREAT, ETAT_PPAS, ETAT, DUREE_VALIDITE, DATE_CHGT_ETAT,
                       AMOUNT, DATE_RETENTION
                FROM DANAD.REP_SV_MSISDN_NOT_MISP_TE T, DANAD.SYS_MINSAT_TE TT
                WHERE T.SERVICE_NAME = TT.MSISDN(+)';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_SYS_SV_CS4_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating indexes on MERGE_SYS_SV_CS4_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('MERGE_SYS_SV_CS4_TE', 'DANAD', 'IX_MSISDN_SYS_MERG_SV_TE', 'MSISDN_SV') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    IF UTILS_INTERFACES.CREATE_INDEX('MERGE_SYS_SV_CS4_TE', 'DANAD', 'IX_MSISDN_SYS_MERG_CS4_TE', 'MSISDN_CS4') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 7: Create CLEAN_ALL_SYS_MERGED_TE
    -- ================================================================================================================
    v_step := 'Creating CLEAN_ALL_SYS_MERGED_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.CLEAN_ALL_SYS_MERGED_TE NOLOGGING AS
                SELECT (CASE WHEN M.MSISDN_SV IS NULL THEN MSISDN_CS4
                             WHEN M.MSISDN_CS4 IS NULL THEN MSISDN_SV
                             ELSE MSISDN_SV END) AS MSISDN_SYS, M.*
                FROM DANAD.MERGE_SYS_SV_CS4_TE M
                WHERE (SUBSTR(M.IMSI, 0, 6) NOT IN ''415018''
                   AND SUBSTR(M.IMSI, 0, 6) NOT IN ''415018'')';

    IF UTILS_INTERFACES.CREATE_TABLE('CLEAN_ALL_SYS_MERGED_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating indexes on CLEAN_ALL_SYS_MERGED_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('CLEAN_ALL_SYS_MERGED_TE', 'DANAD', 'IX_MSISDN_SYSM_TE', 'MSISDN_SYS') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    IF UTILS_INTERFACES.CREATE_INDEX('CLEAN_ALL_SYS_MERGED_TE', 'DANAD', 'IX_PROD_SYSM_TE', 'PRODUCT_INSTANCE_ID') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    IF UTILS_INTERFACES.CREATE_INDEX('CLEAN_ALL_SYS_MERGED_TE', 'DANAD', 'IX_SERV_SYSM_TE', 'SERV_BP_INT') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    IF UTILS_INTERFACES.CREATE_INDEX('CLEAN_ALL_SYS_MERGED_TE', 'DANAD', 'IX_DEA_SYSM_TE', 'DEALER_CODE_P') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 8: Create MERGE_HLR1_HLR2_1_TE
    -- ================================================================================================================
    v_step := 'Creating MERGE_HLR1_HLR2_1_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.MERGE_HLR1_HLR2_1_TE NOLOGGING AS
                SELECT DECODE(SUBSTR(SUBSTR(T.NUM_APPEL, 4), 1, 1), 7, SUBSTR(T.NUM_APPEL, 4),
                              3, ''0'' || (SUBSTR(T.NUM_APPEL, 4)), 1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_HLR1,
                       T.IMSI AS IMSI_1, T.NUM_APPEL AS NUM_APPEL_1, T.CFU AS CFU_1, T.CFB AS CFB_1,
                       T.CFNRY AS CFNRY_1, T.CFNRC AS CFNRC_1, T.SPN AS SPN_1, T.CAW AS CAW_1,
                       T.HOLD AS HOLD_1, T.MPTY AS MPTY_1, T.AOC AS AOC_1, T.BAOC AS BAOC_1,
                       T.BOIC AS BOIC_1, T.BOIEX AS BOIEX_1, T.BAIC AS BAIC_1, T.BICRO AS BICRO_1,
                       T.CAT AS CAT_1, T.OBO AS OBO_1, T.OBI AS OBI_1, T.OBR AS OBR_1,
                       T.OBOPRI AS OBOPRI_1, T.OBOPRE AS OBOPRE_1, T.OBSSM AS OBSSM_1,
                       T.OSB1 AS OSB1_1, T.OSB2 AS OSB2_1, T.OSB3 AS OSB3_1, T.OSB4 AS OSB4_1,
                       T.OFA AS OFA_1, T.PWD AS PWD_1, T.ICI AS ICI_1, T.OIN AS OIN_1,
                       T.TIN AS TIN_1, T.CLIP AS CLIP_1, T.CLIR AS CLIR_1, T.COLP AS COLP_1,
                       T.COLR AS COLR_1, T.SOCB AS SOCB_1, T.SOCFU AS SOCFU_1, T.SOCFB AS SOCFB_1,
                       T.SOCFRY AS SOCFRY_1, T.SOCFRC AS SOCFRC_1, T.SOCLIP AS SOCLIP_1,
                       T.SOCLIR AS SOCLIR_1, T.SOCOLP AS SOCOLP_1, T.TS11 AS TS11_1, T.TS21 AS TS21_1,
                       T.TS22 AS TS22_1, T.TS62 AS TS62_1, T.TSD1 AS TSD1_1, T.BS21 AS BS21_1,
                       T.BS22 AS BS22_1, T.BS23 AS BS23_1, T.BS24 AS BS24_1, T.BS25 AS BS25_1,
                       T.BS26 AS BS26_1, T.BS31 AS BS31_1, T.BS32 AS BS32_1, T.BS33 AS BS33_1,
                       T.BS34 AS BS34_1, T.DBSG AS DBSG_1, T.TS61 AS TS61_1, T.CUG AS CUG_1,
                       T.REGSER AS REGSER_1, T.PICI AS PICI_1, T.DCF AS DCF_1, T.SODCF AS SODCF_1,
                       T.SOSDCF AS SOSDCF_1, T.CAPL AS CAPL_1, T.OICK AS OICK_1, T.TICK AS TICK_1,
                       T.NAM AS NAM_1, T.TSMO AS TSMO_1, T.REDUND AS REDUND_1, T.OCSI AS OCSI_1,
                       T.RSA AS RSA_1, T.RM AS RM_1, T.OBP AS OBP_1, T.OSMCSI AS OSMCSI_1,
                       T.STYPE AS STYPE_1, T.SCHAR AS SCHAR_1, T.REDMCH AS REDMCH_1,
                       T.GPRCSI AS GPRCSI_1, T.BS3G AS BS3G_1, T.DATE_INSERTION_HLR1,
                       DECODE(SUBSTR(SUBSTR(TT.NUM_APPEL, 4), 1, 1), 7, SUBSTR(TT.NUM_APPEL, 4),
                              3, ''0'' || (SUBSTR(TT.NUM_APPEL, 4)), 1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_HLR2,
                       TT.IMSI AS IMSI_2, TT.NUM_APPEL AS NUM_APPEL_2, TT.CFU AS CFU_2, TT.CFB AS CFB_2,
                       TT.CFNRY AS CFNRY_2, TT.CFNRC AS CFNRC_2, TT.SPN AS SPN_2, TT.CAW AS CAW_2,
                       TT.HOLD AS HOLD_2, TT.MPTY AS MPTY_2, TT.AOC AS AOC_2, TT.BAOC AS BAOC_2,
                       TT.BOIC AS BOIC_2, TT.BOIEX AS BOIEX_2, TT.BAIC AS BAIC_2, TT.BICRO AS BICRO_2,
                       TT.CAT AS CAT_2, TT.OBO AS OBO_2, TT.OBI AS OBI_2, TT.OBR AS OBR_2,
                       TT.OBOPRI AS OBOPRI_2, TT.OBOPRE AS OBOPRE_2, TT.OBSSM AS OBSSM_2,
                       TT.OSB1 AS OSB1_2, TT.OSB2 AS OSB2_2, TT.OSB3 AS OSB3_2, TT.OSB4 AS OSB4_2,
                       TT.OFA AS OFA_2, TT.PWD AS PWD_2, TT.ICI AS ICI_2, TT.OIN AS OIN_2,
                       TT.TIN AS TIN_2, TT.CLIP AS CLIP_2, TT.CLIR AS CLIR_2, TT.COLP AS COLP_2,
                       TT.COLR AS COLR_2, TT.SOCB AS SOCB_2, TT.SOCFU AS SOCFU_2, TT.SOCFB AS SOCFB_2,
                       TT.SOCFRY AS SOCFRY_2, TT.SOCFRC AS SOCFRC_2, TT.SOCLIP AS SOCLIP_2,
                       TT.SOCLIR AS SOCLIR_2, TT.SOCOLP AS SOCOLP_2, TT.TS11 AS TS11_2, TT.TS21 AS TS21_2,
                       TT.TS22 AS TS22_2, TT.TS62 AS TS62_2, TT.TSD1 AS TSD1_2, TT.BS21 AS BS21_2,
                       TT.BS22 AS BS22_2, TT.BS23 AS BS23_2, TT.BS24 AS BS24_2, TT.BS25 AS BS25_2,
                       TT.BS26 AS BS26_2, TT.BS31 AS BS31_2, TT.BS32 AS BS32_2, TT.BS33 AS BS33_2,
                       TT.BS34 AS BS34_2, TT.DBSG AS DBSG_2, TT.TS61 AS TS61_2, TT.CUG AS CUG_2,
                       TT.REGSER AS REGSER_2, TT.PICI AS PICI_2, TT.DCF AS DCF_2, TT.SODCF AS SODCF_2,
                       TT.SOSDCF AS SOSDCF_2, TT.CAPL AS CAPL_2, TT.OICK AS OICK_2, TT.TICK AS TICK_2,
                       TT.NAM AS NAM_2, TT.TSMO AS TSMO_2, TT.REDUND AS REDUND_2, TT.OCSI AS OCSI_2,
                       TT.RSA AS RSA_2, TT.RM AS RM_2, TT.OBP AS OBP_2, TT.OSMCSI AS OSMCSI_2,
                       TT.STYPE AS STYPE_2, TT.SCHAR AS SCHAR_2, TT.REDMCH AS REDMCH_2,
                       TT.GPRCSI AS GPRCSI_2, TT.BS3G AS BS3G_2, TT.DATE_INSERTION_HLR2
                FROM FAFIF.HLR1 T, FAFIF.HLR2 TT
                WHERE T.NUM_APPEL(+) = TT.NUM_APPEL';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_HLR1_HLR2_1_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 9: Create MERGE_HLR1_HLR2_2_TE
    -- ================================================================================================================
    v_step := 'Creating MERGE_HLR1_HLR2_2_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.MERGE_HLR1_HLR2_2_TE NOLOGGING AS
                SELECT DECODE(SUBSTR(SUBSTR(T.NUM_APPEL, 4), 1, 1), 7, SUBSTR(T.NUM_APPEL, 4),
                              3, ''0'' || (SUBSTR(T.NUM_APPEL, 4)), 1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_HLR1,
                       T.IMSI AS IMSI_1, T.NUM_APPEL AS NUM_APPEL_1, T.CFU AS CFU_1, T.CFB AS CFB_1,
                       T.CFNRY AS CFNRY_1, T.CFNRC AS CFNRC_1, T.SPN AS SPN_1, T.CAW AS CAW_1,
                       T.HOLD AS HOLD_1, T.MPTY AS MPTY_1, T.AOC AS AOC_1, T.BAOC AS BAOC_1,
                       T.BOIC AS BOIC_1, T.BOIEX AS BOIEX_1, T.BAIC AS BAIC_1, T.BICRO AS BICRO_1,
                       T.CAT AS CAT_1, T.OBO AS OBO_1, T.OBI AS OBI_1, T.OBR AS OBR_1,
                       T.OBOPRI AS OBOPRI_1, T.OBOPRE AS OBOPRE_1, T.OBSSM AS OBSSM_1,
                       T.OSB1 AS OSB1_1, T.OSB2 AS OSB2_1, T.OSB3 AS OSB3_1, T.OSB4 AS OSB4_1,
                       T.OFA AS OFA_1, T.PWD AS PWD_1, T.ICI AS ICI_1, T.OIN AS OIN_1,
                       T.TIN AS TIN_1, T.CLIP AS CLIP_1, T.CLIR AS CLIR_1, T.COLP AS COLP_1,
                       T.COLR AS COLR_1, T.SOCB AS SOCB_1, T.SOCFU AS SOCFU_1, T.SOCFB AS SOCFB_1,
                       T.SOCFRY AS SOCFRY_1, T.SOCFRC AS SOCFRC_1, T.SOCLIP AS SOCLIP_1,
                       T.SOCLIR AS SOCLIR_1, T.SOCOLP AS SOCOLP_1, T.TS11 AS TS11_1, T.TS21 AS TS21_1,
                       T.TS22 AS TS22_1, T.TS62 AS TS62_1, T.TSD1 AS TSD1_1, T.BS21 AS BS21_1,
                       T.BS22 AS BS22_1, T.BS23 AS BS23_1, T.BS24 AS BS24_1, T.BS25 AS BS25_1,
                       T.BS26 AS BS26_1, T.BS31 AS BS31_1, T.BS32 AS BS32_1, T.BS33 AS BS33_1,
                       T.BS34 AS BS34_1, T.DBSG AS DBSG_1, T.TS61 AS TS61_1, T.CUG AS CUG_1,
                       T.REGSER AS REGSER_1, T.PICI AS PICI_1, T.DCF AS DCF_1, T.SODCF AS SODCF_1,
                       T.SOSDCF AS SOSDCF_1, T.CAPL AS CAPL_1, T.OICK AS OICK_1, T.TICK AS TICK_1,
                       T.NAM AS NAM_1, T.TSMO AS TSMO_1, T.REDUND AS REDUND_1, T.OCSI AS OCSI_1,
                       T.RSA AS RSA_1, T.RM AS RM_1, T.OBP AS OBP_1, T.OSMCSI AS OSMCSI_1,
                       T.STYPE AS STYPE_1, T.SCHAR AS SCHAR_1, T.REDMCH AS REDMCH_1,
                       T.GPRCSI AS GPRCSI_1, T.BS3G AS BS3G_1, T.DATE_INSERTION_HLR1,
                       DECODE(SUBSTR(SUBSTR(TT.NUM_APPEL, 4), 1, 1), 7, SUBSTR(TT.NUM_APPEL, 4),
                              3, ''0'' || (SUBSTR(TT.NUM_APPEL, 4)), 1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_HLR2,
                       TT.IMSI AS IMSI_2, TT.NUM_APPEL AS NUM_APPEL_2, TT.CFU AS CFU_2, TT.CFB AS CFB_2,
                       TT.CFNRY AS CFNRY_2, TT.CFNRC AS CFNRC_2, TT.SPN AS SPN_2, TT.CAW AS CAW_2,
                       TT.HOLD AS HOLD_2, TT.MPTY AS MPTY_2, TT.AOC AS AOC_2, TT.BAOC AS BAOC_2,
                       TT.BOIC AS BOIC_2, TT.BOIEX AS BOIEX_2, TT.BAIC AS BAIC_2, TT.BICRO AS BICRO_2,
                       TT.CAT AS CAT_2, TT.OBO AS OBO_2, TT.OBI AS OBI_2, TT.OBR AS OBR_2,
                       TT.OBOPRI AS OBOPRI_2, TT.OBOPRE AS OBOPRE_2, TT.OBSSM AS OBSSM_2,
                       TT.OSB1 AS OSB1_2, TT.OSB2 AS OSB2_2, TT.OSB3 AS OSB3_2, TT.OSB4 AS OSB4_2,
                       TT.OFA AS OFA_2, TT.PWD AS PWD_2, TT.ICI AS ICI_2, TT.OIN AS OIN_2,
                       TT.TIN AS TIN_2, TT.CLIP AS CLIP_2, TT.CLIR AS CLIR_2, TT.COLP AS COLP_2,
                       TT.COLR AS COLR_2, TT.SOCB AS SOCB_2, TT.SOCFU AS SOCFU_2, TT.SOCFB AS SOCFB_2,
                       TT.SOCFRY AS SOCFRY_2, TT.SOCFRC AS SOCFRC_2, TT.SOCLIP AS SOCLIP_2,
                       TT.SOCLIR AS SOCLIR_2, TT.SOCOLP AS SOCOLP_2, TT.TS11 AS TS11_2, TT.TS21 AS TS21_2,
                       TT.TS22 AS TS22_2, TT.TS62 AS TS62_2, TT.TSD1 AS TSD1_2, TT.BS21 AS BS21_2,
                       TT.BS22 AS BS22_2, TT.BS23 AS BS23_2, TT.BS24 AS BS24_2, TT.BS25 AS BS25_2,
                       TT.BS26 AS BS26_2, TT.BS31 AS BS31_2, TT.BS32 AS BS32_2, TT.BS33 AS BS33_2,
                       TT.BS34 AS BS34_2, TT.DBSG AS DBSG_2, TT.TS61 AS TS61_2, TT.CUG AS CUG_2,
                       TT.REGSER AS REGSER_2, TT.PICI AS PICI_2, TT.DCF AS DCF_2, TT.SODCF AS SODCF_2,
                       TT.SOSDCF AS SOSDCF_2, TT.CAPL AS CAPL_2, TT.OICK AS OICK_2, TT.TICK AS TICK_2,
                       TT.NAM AS NAM_2, TT.TSMO AS TSMO_2, TT.REDUND AS REDUND_2, TT.OCSI AS OCSI_2,
                       TT.RSA AS RSA_2, TT.RM AS RM_2, TT.OBP AS OBP_2, TT.OSMCSI AS OSMCSI_2,
                       TT.STYPE AS STYPE_2, TT.SCHAR AS SCHAR_2, TT.REDMCH AS REDMCH_2,
                       TT.GPRCSI AS GPRCSI_2, TT.BS3G AS BS3G_2, TT.DATE_INSERTION_HLR2
                FROM FAFIF.HLR1 T, FAFIF.HLR2 TT
                WHERE T.NUM_APPEL = TT.NUM_APPEL(+)';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_HLR1_HLR2_2_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 10: Create MERGE_HLR1_HLR2_TE with NULL-to-0 conversion
    -- OPTIMIZATION: Replaces 14 separate UPDATE statements with NVL in CREATE TABLE
    -- ================================================================================================================
    v_step := 'Creating MERGE_HLR1_HLR2_TE (NVL optimization - replaces 14 UPDATEs)';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.MERGE_HLR1_HLR2_TE NOLOGGING AS
                SELECT MSISDN_HLR1, IMSI_1, NUM_APPEL_1, CFU_1, CFB_1, CFNRY_1, CFNRC_1, SPN_1,
                       CAW_1, HOLD_1, MPTY_1, AOC_1, BAOC_1, BOIC_1, BOIEX_1, BAIC_1, BICRO_1,
                       CAT_1, NVL(OBO_1, 0) AS OBO_1, NVL(OBI_1, 0) AS OBI_1, NVL(OBR_1, 0) AS OBR_1,
                       OBOPRI_1, OBOPRE_1, OBSSM_1, OSB1_1, OSB2_1, OSB3_1, OSB4_1, OFA_1, PWD_1,
                       ICI_1, OIN_1, TIN_1, CLIP_1, CLIR_1, COLP_1, COLR_1, SOCB_1, SOCFU_1,
                       SOCFB_1, SOCFRY_1, SOCFRC_1, SOCLIP_1, SOCLIR_1, SOCOLP_1, TS11_1, TS21_1,
                       TS22_1, TS62_1, TSD1_1, BS21_1, BS22_1, BS23_1, BS24_1, BS25_1, BS26_1,
                       BS31_1, BS32_1, BS33_1, BS34_1, DBSG_1, TS61_1, CUG_1, REGSER_1, PICI_1,
                       DCF_1, SODCF_1, SOSDCF_1, CAPL_1, NVL(OICK_1, 0) AS OICK_1,
                       NVL(TICK_1, 0) AS TICK_1, NAM_1, TSMO_1, REDUND_1, OCSI_1,
                       NVL(RSA_1, 0) AS RSA_1, RM_1, NVL(OBP_1, 0) AS OBP_1, OSMCSI_1,
                       STYPE_1, SCHAR_1, REDMCH_1, GPRCSI_1, BS3G_1, DATE_INSERTION_HLR1,
                       MSISDN_HLR2, IMSI_2, NUM_APPEL_2, CFU_2, CFB_2, CFNRY_2, CFNRC_2, SPN_2,
                       CAW_2, HOLD_2, MPTY_2, AOC_2, BAOC_2, BOIC_2, BOIEX_2, BAIC_2, BICRO_2,
                       CAT_2, NVL(OBO_2, 0) AS OBO_2, NVL(OBI_2, 0) AS OBI_2, NVL(OBR_2, 0) AS OBR_2,
                       OBOPRI_2, OBOPRE_2, OBSSM_2, OSB1_2, OSB2_2, OSB3_2, OSB4_2, OFA_2, PWD_2,
                       ICI_2, OIN_2, TIN_2, CLIP_2, CLIR_2, COLP_2, COLR_2, SOCB_2, SOCFU_2,
                       SOCFB_2, SOCFRY_2, SOCFRC_2, SOCLIP_2, SOCLIR_2, SOCOLP_2, TS11_2, TS21_2,
                       TS22_2, TS62_2, TSD1_2, BS21_2, BS22_2, BS23_2, BS24_2, BS25_2, BS26_2,
                       BS31_2, BS32_2, BS33_2, BS34_2, DBSG_2, TS61_2, CUG_2, REGSER_2, PICI_2,
                       DCF_2, SODCF_2, SOSDCF_2, CAPL_2, NVL(OICK_2, 0) AS OICK_2,
                       NVL(TICK_2, 0) AS TICK_2, NAM_2, TSMO_2, REDUND_2, OCSI_2,
                       NVL(RSA_2, 0) AS RSA_2, RM_2, NVL(OBP_2, 0) AS OBP_2, OSMCSI_2,
                       STYPE_2, SCHAR_2, REDMCH_2, GPRCSI_2, BS3G_2, DATE_INSERTION_HLR2
                FROM (SELECT * FROM DANAD.MERGE_HLR1_HLR2_1_TE
                      UNION
                      SELECT * FROM DANAD.MERGE_HLR1_HLR2_2_TE)';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_HLR1_HLR2_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    COMMIT;

    -- ================================================================================================================
    -- STEP 11: Create reporting tables
    -- ================================================================================================================
    v_step := 'Creating REP_HLRS_MIS_MSISDN_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_HLRS_MIS_MSISDN_TE NOLOGGING AS
                SELECT * FROM DANAD.MERGE_HLR1_HLR2_TE HH
                WHERE HH.MSISDN_HLR1 IS NULL OR HH.MSISDN_HLR2 IS NULL';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_HLRS_MIS_MSISDN_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating REP_HLRS_MIS_IMSI_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_HLRS_MIS_IMSI_TE NOLOGGING AS
                SELECT * FROM DANAD.MERGE_HLR1_HLR2_TE HH
                WHERE HH.MSISDN_HLR1 = HH.MSISDN_HLR2
                  AND HH.MSISDN_HLR1 IS NOT NULL
                  AND HH.IMSI_1 <> HH.IMSI_2';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_HLRS_MIS_IMSI_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 12: Create CLEAN_HLRS_MERGED_TE
    -- ================================================================================================================
    v_step := 'Creating CLEAN_HLRS_MERGED_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.CLEAN_HLRS_MERGED_TE NOLOGGING AS
                SELECT (CASE WHEN M.MSISDN_HLR1 IS NULL THEN M.MSISDN_HLR2
                             WHEN M.MSISDN_HLR2 IS NULL THEN MSISDN_HLR1
                             ELSE M.MSISDN_HLR2 END) AS MSISDN_HLRS, M.*
                FROM DANAD.MERGE_HLR1_HLR2_TE M
                WHERE (SUBSTR(M.IMSI_1, 0, 6) NOT IN ''415018''
                   AND SUBSTR(M.IMSI_2, 0, 6) NOT IN ''415018''
                   AND SUBSTR(M.MSISDN_HLR1, 0, 2) NOT IN ''01''
                   AND SUBSTR(M.MSISDN_HLR2, 0, 2) NOT IN ''01'')
                   OR M.IMSI_1 IS NULL
                   OR M.IMSI_2 IS NULL';

    IF UTILS_INTERFACES.CREATE_TABLE('CLEAN_HLRS_MERGED_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 13: Create MERGE_SYS_HLRS_TE
    -- ================================================================================================================
    v_step := 'Creating MERGE_SYS_HLRS_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.MERGE_SYS_HLRS_TE NOLOGGING AS
                SELECT T.*, SUBSTR(TT.IMSI_1, 0, 6) AS PRIM_FLAG, TT.*
                FROM DANAD.CLEAN_ALL_SYS_MERGED_TE T, DANAD.CLEAN_HLRS_MERGED_TE TT
                WHERE T.MSISDN_SYS(+) = TT.MSISDN_HLRS
                UNION
                SELECT T.*, SUBSTR(TT.IMSI_1, 0, 6) AS PRIM_FLAG, TT.*
                FROM DANAD.CLEAN_ALL_SYS_MERGED_TE T, DANAD.CLEAN_HLRS_MERGED_TE TT
                WHERE T.MSISDN_SYS = TT.MSISDN_HLRS(+)';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_SYS_HLRS_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 14: Create REP_CLEAN_ALL_MERGED_TE (Final merged table with SDP logic)
    -- ================================================================================================================
    v_step := 'Creating REP_CLEAN_ALL_MERGED_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_CLEAN_ALL_MERGED_TE NOLOGGING AS
                SELECT (CASE WHEN M.MSISDN_SYS IS NULL THEN M.MSISDN_HLRS
                             WHEN M.MSISDN_HLRS IS NULL THEN M.MSISDN_SYS
                             ELSE M.MSISDN_SYS END) AS MSISDN,
                       DECODE(PRIM_FLAG, ''415012'', 1, ''415019'', 1, 2) AS PRIMARY_HLR,
                       (CASE WHEN M.MSISDN_SYS IS NULL THEN
                           (CASE WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 71900000 AND 71999999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 71800000 AND 71899999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 3000000  AND 3999999)  THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 70000000 AND 70999999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 71000000 AND 71099999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 76100000 AND 76199999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 71600000 AND 71699999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 71700000 AND 71799999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 76300000 AND 76399999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 76400000 AND 76499999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 76500000 AND 76599999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_HLRS) BETWEEN 79100000 AND 79199999) THEN ''SDP02''
                                 ELSE ''SDP'' END)
                        WHEN M.MSISDN_HLRS IS NULL THEN
                           (CASE WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71900000 AND 71999999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71800000 AND 71899999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 3000000  AND 3999999)  THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 70000000 AND 70999999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71000000 AND 71099999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76100000 AND 76199999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71600000 AND 71699999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71700000 AND 71799999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76300000 AND 76399999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76400000 AND 76499999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76500000 AND 76599999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 79100000 AND 79199999) THEN ''SDP02''
                                 ELSE ''SDP'' END)
                        ELSE
                           (CASE WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71900000 AND 71999999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71800000 AND 71899999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 3000000  AND 3999999)  THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 70000000 AND 70999999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71000000 AND 71099999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76100000 AND 76199999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71600000 AND 71699999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 71700000 AND 71799999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76300000 AND 76399999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76400000 AND 76499999) THEN ''SDP02''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 76500000 AND 76599999) THEN ''SDP01''
                                 WHEN (TO_NUMBER(M.MSISDN_SYS) BETWEEN 79100000 AND 79199999) THEN ''SDP02''
                                 ELSE ''SDP'' END)
                        END) AS SDP,
                       M.*
                FROM DANAD.MERGE_SYS_HLRS_TE M';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_CLEAN_ALL_MERGED_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating indexes on REP_CLEAN_ALL_MERGED_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('REP_CLEAN_ALL_MERGED_TE', 'DANAD', 'IX_CLEAN_ALL_MSISDN_TE', 'MSISDN') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    IF UTILS_INTERFACES.CREATE_INDEX('REP_CLEAN_ALL_MERGED_TE', 'DANAD', 'IX_PRODUCT_INSTANCE_ID_TE', 'PRODUCT_INSTANCE_ID') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 15: Create SYS_APN1_TE and MERGE_SYS_APN1_TE
    -- ================================================================================================================
    v_step := 'Creating SYS_APN1_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.SYS_APN1_TE NOLOGGING AS
                SELECT T.*
                FROM DANAD.REP_CLEAN_ALL_MERGED_TE T
                WHERE EXISTS (SELECT 1 FROM DANAD.APN_DATA_HLR1_TE H WHERE T.MSISDN = H.MSISDN_APN1)';

    IF UTILS_INTERFACES.CREATE_TABLE('SYS_APN1_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating index on SYS_APN1_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('SYS_APN1_TE', 'DANAD', 'IX_SYSAPN1_MSISDN_TE', 'MSISDN') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating MERGE_SYS_APN1_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.MERGE_SYS_APN1_TE NOLOGGING AS
                SELECT T.*,
                       (SELECT V.APN_ID_1 FROM DANAD.APN_DATA_HLR1_TE V WHERE V.MSISDN_APN1 = T.MSISDN AND V.APN_ID_1 = 13) MBB_APN1,
                       (SELECT V.APN_ID_1 FROM DANAD.APN_DATA_HLR1_TE V WHERE V.MSISDN_APN1 = T.MSISDN AND V.APN_ID_1 = 12) BLACKBERRY_APN1,
                       (SELECT V.APN_ID_1 FROM DANAD.APN_DATA_HLR1_TE V WHERE V.MSISDN_APN1 = T.MSISDN AND V.APN_ID_1 = 10) GPRS_INTRA_APN1,
                       (SELECT V.APN_ID_1 FROM DANAD.APN_DATA_HLR1_TE V WHERE V.MSISDN_APN1 = T.MSISDN AND V.APN_ID_1 = 9) MMS_APN1,
                       (SELECT V.APN_ID_1 FROM DANAD.APN_DATA_HLR1_TE V WHERE V.MSISDN_APN1 = T.MSISDN AND V.APN_ID_1 = 8) WAP_APN1,
                       (SELECT V.APN_ID_1 FROM DANAD.APN_DATA_HLR1_TE V WHERE V.MSISDN_APN1 = T.MSISDN AND V.APN_ID_1 = 7) GPRS_APN1
                FROM DANAD.SYS_APN1_TE T';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_SYS_APN1_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating index on MERGE_SYS_APN1_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('MERGE_SYS_APN1_TE', 'DANAD', 'IX_MERSYSAPN1_MSISDN_TE', 'MSISDN') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 16: Create SYS_APN2_TE and MERGE_SYS_APN2_TE
    -- ================================================================================================================
    v_step := 'Creating SYS_APN2_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.SYS_APN2_TE NOLOGGING AS
                SELECT T.*
                FROM DANAD.REP_CLEAN_ALL_MERGED_TE T
                WHERE EXISTS (SELECT 1 FROM DANAD.APN_DATA_HLR2_TE H WHERE T.MSISDN = H.MSISDN_APN2)';

    IF UTILS_INTERFACES.CREATE_TABLE('SYS_APN2_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating index on SYS_APN2_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('SYS_APN2_TE', 'DANAD', 'IX_SYSAPN2_MSISDN_TE', 'MSISDN') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating MERGE_SYS_APN2_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.MERGE_SYS_APN2_TE NOLOGGING AS
                SELECT T.*,
                       (SELECT V.APN_ID_2 FROM DANAD.APN_DATA_HLR2_TE V WHERE V.MSISDN_APN2 = T.MSISDN AND V.APN_ID_2 = 13) MBB_APN2,
                       (SELECT V.APN_ID_2 FROM DANAD.APN_DATA_HLR2_TE V WHERE V.MSISDN_APN2 = T.MSISDN AND V.APN_ID_2 = 12) BLACKBERRY_APN2,
                       (SELECT V.APN_ID_2 FROM DANAD.APN_DATA_HLR2_TE V WHERE V.MSISDN_APN2 = T.MSISDN AND V.APN_ID_2 = 10) GPRS_INTRA_APN2,
                       (SELECT V.APN_ID_2 FROM DANAD.APN_DATA_HLR2_TE V WHERE V.MSISDN_APN2 = T.MSISDN AND V.APN_ID_2 = 9) MMS_APN2,
                       (SELECT V.APN_ID_2 FROM DANAD.APN_DATA_HLR2_TE V WHERE V.MSISDN_APN2 = T.MSISDN AND V.APN_ID_2 = 8) WAP_APN2,
                       (SELECT V.APN_ID_2 FROM DANAD.APN_DATA_HLR2_TE V WHERE V.MSISDN_APN2 = T.MSISDN AND V.APN_ID_2 = 7) GPRS_APN2
                FROM DANAD.SYS_APN2_TE T';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_SYS_APN2_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating index on MERGE_SYS_APN2_TE';
    v_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('MERGE_SYS_APN2_TE', 'DANAD', 'IX_MERSYSAPN2_MSISDN_TE', 'MSISDN') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 17: Create mismatch reports
    -- ================================================================================================================
    v_step := 'Creating REP_APN_MISMATCH_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_APN_MISMATCH_TE NOLOGGING AS
                SELECT T.ACCOUNT_NAME, T.SERVICE_TYPE_NAME, T.MSISDN, T.SERVICE_NAME,
                       T.BLACKBERRY_APN1, T.GPRS_INTRA_APN1, T.MMS_APN1, T.WAP_APN1, T.GPRS_APN1, T.MBB_APN1,
                       TT.MSISDN AS MSISDN2, TT.BLACKBERRY_APN2, TT.GPRS_INTRA_APN2, TT.MMS_APN2,
                       TT.WAP_APN2, TT.GPRS_APN2, TT.MBB_APN2
                FROM DANAD.MERGE_SYS_APN1_TE T, DANAD.MERGE_SYS_APN2_TE TT
                WHERE T.MSISDN = TT.MSISDN
                  AND (NVL(T.BLACKBERRY_APN1, 0) <> NVL(TT.BLACKBERRY_APN2, 0)
                   OR NVL(T.GPRS_INTRA_APN1, 0) <> NVL(TT.GPRS_INTRA_APN2, 0)
                   OR NVL(T.MMS_APN1, 0) <> NVL(TT.MMS_APN2, 0)
                   OR NVL(T.WAP_APN1, 0) <> NVL(TT.WAP_APN2, 0)
                   OR NVL(T.GPRS_APN1, 0) <> NVL(TT.GPRS_APN2, 0)
                   OR NVL(T.MBB_APN1, 0) <> NVL(TT.MBB_APN2, 0))';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_APN_MISMATCH_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating REP_CALL_FWD_MISMATCH_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_CALL_FWD_MISMATCH_TE NOLOGGING AS
                SELECT DECODE((SUBSTR(T.IMSI_1, 0, 6)), ''415012'', 1, 2) AS PRIMARY_HLR,
                       T.MSISDN_HLR1, T.IMSI_1, T.MSISDN_HLR2, T.IMSI_2,
                       T.CFU_1, T.CFU_2, T.CFB_1, T.CFB_2, T.CFNRY_1, T.CFNRY_2,
                       T.CFNRC_1, T.CFNRC_2
                FROM DANAD.MERGE_HLR1_HLR2_TE T
                WHERE NVL(T.CFU_1, 0) <> NVL(T.CFU_2, 0)
                   OR NVL(T.CFB_1, 0) <> NVL(T.CFB_2, 0)
                   OR NVL(T.CFNRY_1, 0) <> NVL(T.CFNRY_2, 0)
                   OR NVL(T.CFNRC_1, 0) <> NVL(T.CFNRC_2, 0)';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_CALL_FWD_MISMATCH_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating REP_CALL_BAR_MISMATCH_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_CALL_BAR_MISMATCH_TE NOLOGGING AS
                SELECT T.MSISDN_HLR1, T.IMSI_1, T.MSISDN_HLR2, T.IMSI_2,
                       T.BAOC_1, T.BAOC_2, T.BOIC_1, T.BOIC_2, T.BOIEX_1, T.BOIEX_2,
                       T.BAIC_1, T.BAIC_2, T.BICRO_1, T.BICRO_2, T.SOCB_1, T.SOCB_2
                FROM DANAD.MERGE_HLR1_HLR2_TE T
                WHERE NVL(T.BAOC_1, 0) <> NVL(T.BAOC_2, 0)
                   OR NVL(T.BOIC_1, 0) <> NVL(T.BOIC_2, 0)
                   OR NVL(T.BOIEX_1, 0) <> NVL(T.BOIEX_2, 0)
                   OR NVL(T.BAIC_1, 0) <> NVL(T.BAIC_2, 0)
                   OR NVL(T.BICRO_1, 0) <> NVL(T.BICRO_2, 0)
                   OR NVL(T.SOCB_1, 0) <> NVL(T.SOCB_2, 0)';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_CALL_BAR_MISMATCH_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 18: Create ADM export tables
    -- ================================================================================================================
    v_step := 'Creating REP_ADM_DMP_HLR1_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_ADM_DMP_HLR1_TE NOLOGGING AS
                SELECT T.MSISDN, T.IMSI,
                       DECODE(A.APN_ID_1, 3, ''Data Card'', 4, ''Data Card'', 7, ''GPRS'',
                              8, ''WAP'', 9, ''MMS'', 10, ''GPRS INTRA'', 12, ''Blackberry'',
                              13, ''Mobile BroadBand'', 5, ''Other'', 11, ''Other'', NULL) AS COMPANION_PRODUCT,
                       T.SERVICE_TYPE_NAME
                FROM DANAD.REP_CLEAN_ALL_MERGED_TE T, DANAD.APN_DATA_HLR1_TE A
                WHERE A.MSISDN_APN1 = T.MSISDN
                  AND T.PRIMARY_HLR = 1';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_ADM_DMP_HLR1_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating REP_ADM_DMP_HLR2_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_ADM_DMP_HLR2_TE NOLOGGING AS
                SELECT T.MSISDN, T.IMSI,
                       DECODE(A.APN_ID_2, 3, ''Data Card'', 4, ''Data Card'', 7, ''GPRS'',
                              8, ''WAP'', 9, ''MMS'', 10, ''GPRS INTRA'', 12, ''Blackberry'',
                              13, ''Mobile BroadBand'', 5, ''Other'', 11, ''Other'', NULL) AS COMPANION_PRODUCT,
                       T.SERVICE_TYPE_NAME
                FROM DANAD.REP_CLEAN_ALL_MERGED_TE T, DANAD.APN_DATA_HLR2_TE A
                WHERE A.MSISDN_APN2 = T.MSISDN
                  AND T.PRIMARY_HLR = 2';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_ADM_DMP_HLR2_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating UNION_APNS_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.UNION_APNS_TE NOLOGGING AS
                SELECT SS.* FROM DANAD.REP_ADM_DMP_HLR1_TE SS
                UNION
                SELECT VV.* FROM DANAD.REP_ADM_DMP_HLR2_TE VV';

    IF UTILS_INTERFACES.CREATE_TABLE('UNION_APNS_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating REP_APN_SYS_ALL_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.REP_APN_SYS_ALL_TE NOLOGGING AS
                SELECT AA.MSISDN, AA.IMSI, AA.COMPANION_PRODUCT, AA.SERVICE_TYPE_NAME
                FROM DANAD.UNION_APNS_TE AA
                UNION
                SELECT MM.MSISDN, MM.IMSI, NULL, MM.SERVICE_TYPE_NAME
                FROM DANAD.REP_CLEAN_ALL_MERGED_TE MM
                WHERE MM.SERVICE_STATUS <> ''Cancelled''';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_APN_SYS_ALL_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'Creating LIST_NULL_CP_GROUP_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'CREATE TABLE DANAD.LIST_NULL_CP_GROUP_TE NOLOGGING AS
                SELECT T.MSISDN, COUNT(T.MSISDN) AS COUNT_NUM
                FROM DANAD.REP_APN_SYS_ALL_TE T
                GROUP BY T.MSISDN
                HAVING COUNT(T.MSISDN) > 1';

    IF UTILS_INTERFACES.CREATE_TABLE('LIST_NULL_CP_GROUP_TE', 'DANAD', SQL_TXT) = 0 THEN
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 19: Remove duplicates from REP_APN_SYS_ALL_TE
    -- ================================================================================================================
    v_step := 'Removing duplicates from REP_APN_SYS_ALL_TE';
    v_start_time := SYSTIMESTAMP;

    SQL_TXT := 'DELETE FROM DANAD.REP_APN_SYS_ALL_TE T
                WHERE T.MSISDN IN (SELECT V.MSISDN FROM DANAD.LIST_NULL_CP_GROUP_TE V)
                  AND T.COMPANION_PRODUCT IS NULL';

    IF UTILS_INTERFACES.DELETE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_INSERT_FAILED;
    END IF;

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    -- ================================================================================================================
    -- STEP 20: Export to ADM and FTP transfer
    -- ================================================================================================================
    v_step := 'Exporting to ADM TXT file';
    v_start_time := SYSTIMESTAMP;

    FAFIF.RECONCILIATION_INTERFACES.EXPORT_TABLE_TO_ADM_TXT('DANAD', 'REP_APN_SYS_ALL_TE');

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    v_step := 'FTP file transfer';
    v_start_time := SYSTIMESTAMP;

    CURRENT_DATE := TO_CHAR(TO_DATE(TO_CHAR(SYSDATE, 'DDMMYYYY'), 'DDMMYYYY'), 'DDMMYYYY');
    DBAUSER.P_FTP('192.168.41.13', 'ftp_prov', '123Prov', 'OUTPUT_BOPS',
                  'reconciliation_' || CURRENT_DATE || '.csv',
                  'reconciliation_' || CURRENT_DATE || '.txt');

    v_end_time := SYSTIMESTAMP;
    log_activity(v_step, v_start_time, v_end_time, NULL);

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('P1_MAIN_SYS_INTERFACES_TE - Completed Successfully');
    DBMS_OUTPUT.PUT_LINE('========================================');

    RESULT := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('========================================');
        RESULT := 'FAILURE';
        RAISE;

END P1_MAIN_SYS_INTERFACES_TE;
/
