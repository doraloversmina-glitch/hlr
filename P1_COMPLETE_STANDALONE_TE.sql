-- =============================================================================================
-- P1_MAIN_SYS_INTERFACES_TE - COMPLETE STANDALONE VERSION
-- All-in-one file: Copy and paste this entire file to deploy
-- =============================================================================================

-- =============================================================================================
-- STEP 1: Create Activity Trace Table
-- =============================================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE P1_ACTIVITY_TRACE_TE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE P1_ACTIVITY_TRACE_TE (
    TRACE_ID            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SESSION_ID          VARCHAR2(100),
    INTEGRATION_LOG_ID  VARCHAR2(50),
    STEP_NUMBER         NUMBER,
    STEP_NAME           VARCHAR2(200),
    STEP_STATUS         VARCHAR2(20),
    START_TIME          TIMESTAMP,
    END_TIME            TIMESTAMP,
    DURATION_SECONDS    NUMBER,
    ROWS_AFFECTED       NUMBER,
    ERROR_MESSAGE       VARCHAR2(4000),
    CREATED_DATE        DATE DEFAULT SYSDATE
);

-- =============================================================================================
-- STEP 2: Create Main Procedure P1_MAIN_SYS_INTERFACES_TE
-- =============================================================================================
CREATE OR REPLACE PROCEDURE P1_MAIN_SYS_INTERFACES_TE(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
) IS

    -- =============================================================================================
    --    Modified by                 : Enhanced Version with Activity Tracing
    --    Release                     : R1.2_TE
    --    Modification Date           : 15/12/2025
    --    Author                      : Enhanced by Claude
    --    Comments                    : Added _TE suffix, activity tracing, enhanced logic
    -- =============================================================================================

    -- Variables
    SQL_TXT              VARCHAR2(32000);
    RELEASE              VARCHAR2(20)    := 'R1.2_TE';
    ENT_TYPE_CODE        NUMBER;
    ENT_CODE             NUMBER;
    CLIENT_ID            VARCHAR2(10);
    SAS_TABLE            VARCHAR2(100);
    REJ_TABLE            VARCHAR2(100);
    HIST_TABLE           VARCHAR2(100);
    CURRENT_DATE         VARCHAR2(100);

    -- Activity Tracing Variables
    v_step_number        NUMBER := 0;
    v_step_name          VARCHAR2(200);
    v_step_start_time    TIMESTAMP;
    v_step_end_time      TIMESTAMP;
    v_rows_affected      NUMBER := 0;
    v_error_message      VARCHAR2(4000);
    v_procedure_start    TIMESTAMP;
    v_procedure_end      TIMESTAMP;
    v_session_id         VARCHAR2(100);

    -- Performance tracking
    v_total_tables       NUMBER := 0;
    v_total_indexes      NUMBER := 0;
    v_total_updates      NUMBER := 0;

    -- =============================================================================================
    -- Procedure: LOG_ACTIVITY_TE
    -- Purpose: Log activity trace information
    -- =============================================================================================
    PROCEDURE LOG_ACTIVITY_TE(
        p_step_number   IN NUMBER,
        p_step_name     IN VARCHAR2,
        p_status        IN VARCHAR2,
        p_start_time    IN TIMESTAMP,
        p_end_time      IN TIMESTAMP,
        p_rows_affected IN NUMBER DEFAULT 0,
        p_error_msg     IN VARCHAR2 DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_duration_seconds NUMBER;
    BEGIN
        v_duration_seconds := EXTRACT(SECOND FROM (p_end_time - p_start_time)) +
                             EXTRACT(MINUTE FROM (p_end_time - p_start_time)) * 60 +
                             EXTRACT(HOUR FROM (p_end_time - p_start_time)) * 3600;

        INSERT INTO P1_ACTIVITY_TRACE_TE (
            SESSION_ID,
            INTEGRATION_LOG_ID,
            STEP_NUMBER,
            STEP_NAME,
            STEP_STATUS,
            START_TIME,
            END_TIME,
            DURATION_SECONDS,
            ROWS_AFFECTED,
            ERROR_MESSAGE,
            CREATED_DATE
        ) VALUES (
            v_session_id,
            INTEGRATION_LOG_ID,
            p_step_number,
            p_step_name,
            p_status,
            p_start_time,
            p_end_time,
            v_duration_seconds,
            p_rows_affected,
            p_error_msg,
            SYSDATE
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END LOG_ACTIVITY_TE;

    -- =============================================================================================
    -- Procedure: CREATE_TABLE_WITH_TRACE_TE
    -- Purpose: Create table and log the activity
    -- =============================================================================================
    PROCEDURE CREATE_TABLE_WITH_TRACE_TE(
        p_table_name    IN VARCHAR2,
        p_schema_name   IN VARCHAR2,
        p_sql_text      IN VARCHAR2
    ) IS
    BEGIN
        v_step_number := v_step_number + 1;
        v_step_name := 'CREATE TABLE ' || p_table_name;
        v_step_start_time := SYSTIMESTAMP;

        IF UTILS_INTERFACES.CREATE_TABLE(p_table_name, p_schema_name, p_sql_text) = 0 THEN
            v_step_end_time := SYSTIMESTAMP;
            LOG_ACTIVITY_TE(v_step_number, v_step_name, 'FAILED', v_step_start_time, v_step_end_time, 0, 'Table creation failed');
            RAISE TABLE_CREATION_FAILED;
        END IF;

        -- Get row count
        BEGIN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_schema_name || '.' || p_table_name INTO v_rows_affected;
        EXCEPTION
            WHEN OTHERS THEN
                v_rows_affected := 0;
        END;

        v_step_end_time := SYSTIMESTAMP;
        v_total_tables := v_total_tables + 1;
        LOG_ACTIVITY_TE(v_step_number, v_step_name, 'SUCCESS', v_step_start_time, v_step_end_time, v_rows_affected);
    END CREATE_TABLE_WITH_TRACE_TE;

    -- =============================================================================================
    -- Procedure: CREATE_INDEX_WITH_TRACE_TE
    -- Purpose: Create index and log the activity
    -- =============================================================================================
    PROCEDURE CREATE_INDEX_WITH_TRACE_TE(
        p_table_name    IN VARCHAR2,
        p_schema_name   IN VARCHAR2,
        p_index_name    IN VARCHAR2,
        p_column_name   IN VARCHAR2
    ) IS
    BEGIN
        v_step_number := v_step_number + 1;
        v_step_name := 'CREATE INDEX ' || p_index_name || ' ON ' || p_table_name;
        v_step_start_time := SYSTIMESTAMP;

        IF UTILS_INTERFACES.CREATE_INDEX(p_table_name, p_schema_name, p_index_name, p_column_name) = 0 THEN
            v_step_end_time := SYSTIMESTAMP;
            LOG_ACTIVITY_TE(v_step_number, v_step_name, 'FAILED', v_step_start_time, v_step_end_time, 0, 'Index creation failed');
            RAISE INDEX_CREATION_FAILED;
        END IF;

        v_step_end_time := SYSTIMESTAMP;
        v_total_indexes := v_total_indexes + 1;
        LOG_ACTIVITY_TE(v_step_number, v_step_name, 'SUCCESS', v_step_start_time, v_step_end_time, 0);
    END CREATE_INDEX_WITH_TRACE_TE;

    -- =============================================================================================
    -- Procedure: UPDATE_TABLE_WITH_TRACE_TE
    -- Purpose: Update table and log the activity
    -- =============================================================================================
    PROCEDURE UPDATE_TABLE_WITH_TRACE_TE(
        p_sql_text      IN VARCHAR2,
        p_description   IN VARCHAR2
    ) IS
    BEGIN
        v_step_number := v_step_number + 1;
        v_step_name := 'UPDATE: ' || p_description;
        v_step_start_time := SYSTIMESTAMP;

        IF UTILS_INTERFACES.UPDATE_TABLE(p_sql_text) = 0 THEN
            v_step_end_time := SYSTIMESTAMP;
            LOG_ACTIVITY_TE(v_step_number, v_step_name, 'FAILED', v_step_start_time, v_step_end_time, 0, 'Update failed');
            RAISE TABLE_UPDATE_FAILED;
        END IF;

        v_rows_affected := SQL%ROWCOUNT;
        v_step_end_time := SYSTIMESTAMP;
        v_total_updates := v_total_updates + 1;
        LOG_ACTIVITY_TE(v_step_number, v_step_name, 'SUCCESS', v_step_start_time, v_step_end_time, v_rows_affected);
    END UPDATE_TABLE_WITH_TRACE_TE;

BEGIN
    -- Initialize session
    v_procedure_start := SYSTIMESTAMP;
    v_session_id := USERENV('SESSIONID');

    UTILS_INTERFACES.INTERFACE_NAME := 'P1_MAIN_SYS_INTERFACES_TE';

    -- Log procedure start
    v_step_number := v_step_number + 1;
    LOG_ACTIVITY_TE(v_step_number, 'PROCEDURE START', 'RUNNING', v_procedure_start, SYSTIMESTAMP, 0,
                    'Started with INTEGRATION_LOG_ID: ' || INTEGRATION_LOG_ID);

    -- ================================================================================================================
    -- SECTION 1: Create SYS_MINSAT_TE (CS5 DMP)
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE SYS_MINSAT_TE NOLOGGING AS
                    SELECT DECODE(SUBSTR(SUBSTR(NUM_APPEL, 4), 1, 1),8,SUBSTR(NUM_APPEL, 4),7,SUBSTR(NUM_APPEL, 4),3,''0'' || (SUBSTR(NUM_APPEL, 4)),1, ''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN,
                           D.*
                      FROM FAFIF.PPS_ABONNE_JOUR_MIGDB D ';

    CREATE_TABLE_WITH_TRACE_TE('SYS_MINSAT_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('SYS_MINSAT_TE', 'FAFIF', 'IX_MINSAT_MSISDN_TE', 'MSISDN');

    -- ================================================================================================================
    -- SECTION 2: Create HLR1 APN Data Tables
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE HLR1_APN_DATA_TE AS
                 select NUM_APPEL AS NUM_APPEL_APN1,
                       DECODE(SUBSTR(SUBSTR(NUM_APPEL, 4), 1, 1),8,SUBSTR(NUM_APPEL, 4),7,SUBSTR(NUM_APPEL, 4),3,''0'' || (SUBSTR(NUM_APPEL, 4)),1,''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_APN1,
                       max( decode( APN_ID, ''20'', APN_ID, null ) ) AS WLL_APN1,
                       max( decode( APN_ID, ''15'', APN_ID, null ) ) AS ALFA_APN1,
                       max( decode( APN_ID, ''13'', APN_ID, null ) ) AS MBB_APN1,
                       max( decode( APN_ID, ''12'', APN_ID, null ) ) AS BLACKBERRY_APN1,
                       max( decode( APN_ID, ''10'', APN_ID, null ) ) AS GPRS_INTRA_APN1,
                       max( decode( APN_ID, ''9'', APN_ID, null ) )  AS MMS_APN1,
                       max( decode( APN_ID, ''8'', APN_ID, null ) ) AS WAP_APN1,
                       max( decode( APN_ID, ''7'', APN_ID, null ) ) AS GPRS_APN1,
                       max( decode( APN_ID, ''3'', APN_ID, null ) ) AS DATACARD1_APN1,
                       max( decode( APN_ID, ''4'', APN_ID, null ) ) AS DATACARD2_APN1,
                       max( decode( APN_ID, ''6'', APN_ID, null ) ) AS DATACARD3_APN1,
                       max( decode( APN_ID, ''94'', APN_ID, null ) ) AS VOLTE01_APN1,
                       max( decode( APN_ID, ''95'', APN_ID, null ) ) AS VOLTE02_APN1
                       FROM
                       (
                       SELECT *
                       FROM HLR1
                       )
                       GROUP BY NUM_APPEL';

    CREATE_TABLE_WITH_TRACE_TE('HLR1_APN_DATA_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('HLR1_APN_DATA_TE', 'FAFIF', 'IX_MSISDN_APN1_TE', 'MSISDN_APN1');

    -- ================================================================================================================
    -- SECTION 3: Create HLR1 Parameter Table
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE HLR1_PARAM_TE AS
                 SELECT DISTINCT(T.NUM_APPEL),
                 DECODE(SUBSTR(SUBSTR(T.NUM_APPEL, 4), 1, 1),8,SUBSTR(T.NUM_APPEL, 4),7,SUBSTR(T.NUM_APPEL, 4),3,''0'' || (SUBSTR(T.NUM_APPEL, 4)),1,''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN,
                 T.IMSI, T.CFU, T.CFB, T.CFNRY,T.CFNRC,T.SPN,T.CAW,T.HOLD,T.MPTY,T.AOC,T.BAOC,T.BOIC,T.BOIEX,T.BAIC,T.BICRO,
                 T.CAT,T.OBO,T.OBI,T.OBR,T.OBOPRI,T.OBOPRE,T.OBSSM,T.OSB1,T.OSB2,T.OSB3,T.OSB4,T.OFA,T.PWD,T.ICI,T.OIN,T.TIN,
                 T.CLIP,T.CLIR,T.COLP,T.COLR,T.SOCB,T.SOCFU,T.SOCFB,T.SOCFRY,T.SOCFRC,T.SOCLIP,T.SOCLIR,T.SOCOLP,T.TS11,T.TS21,
                 T.TS22,T.TS62,T.TSD1,T.BS21,T.BS22,T.BS23,T.BS24,T.BS25,T.BS26,T.BS31,T.BS32,T.BS33,T.BS34,T.DBSG,T.TS61,T.CUG,
                 T.REGSER,T.PICI,T.DCF,T.SODCF,T.SOSDCF,T.CAPL,T.OICK,T.TICK,T.NAM,T.TSMO,T.REDUND,T.OCSI,T.RSA,T.RM,T.OBP,T.OSMCSI,
                 T.STYPE,T.SCHAR,T.REDMCH,T.GPRCSI,T.BS3G,T.CAMEL,T.RBT,T.EMLPP,T.NEMLPP,T.DEMLPP,
                 T.GPRSCSINF,T.MCSINF,T.OCSINF,T.OSMCSINF,T.TCSINF,T.TSMCSINF,T.VTCSINF,T.TIFCSINF,T.DCSIST,T.GPRSCSIST,
                 T.MCSIST,T.OCSIST,T.OSMCSIST,T.TCSIST,T.TSMCSIST,T.VTCSIST,T.ICS,T.CWNF,T.CHNF,T.CLIPNF,T.CLIRNF,T.ECTNF,T.ARD,
                 T.DATE_INSERTION_HLR1
                 FROM HLR1 T';

    CREATE_TABLE_WITH_TRACE_TE('HLR1_PARAM_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('HLR1_PARAM_TE', 'FAFIF', 'IX_HLR1_msisdn_TE', 'msisdn');

    -- ================================================================================================================
    -- SECTION 4: Merge HLR1 APN and Parameters
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE MERGE_HLR1_APN_TE NOLOGGING AS
                SELECT  TT.*,T.*
                FROM HLR1_APN_DATA_TE T, HLR1_PARAM_TE TT
                WHERE T.MSISDN_APN1 (+)= TT.MSISDN
                UNION
                SELECT  TT.*,T.*
                FROM HLR1_APN_DATA_TE T, HLR1_PARAM_TE TT
                WHERE T.MSISDN_APN1 = TT.MSISDN(+) ';

    CREATE_TABLE_WITH_TRACE_TE('MERGE_HLR1_APN_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 5: Create HLR2 APN Data Tables
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE HLR2_APN_DATA_TE AS
                 select NUM_APPEL AS NUM_APPEL_APN2,
                       DECODE(SUBSTR(SUBSTR(NUM_APPEL, 4), 1, 1),8,SUBSTR(NUM_APPEL, 4),7,SUBSTR(NUM_APPEL, 4),3,''0'' || (SUBSTR(NUM_APPEL, 4)),1,''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN_APN2,
                       max( decode( APN_ID, ''20'', APN_ID, null ) ) AS WLL_APN2,
                       max( decode( APN_ID, ''15'', APN_ID, null ) ) AS ALFA_APN2,
                       max( decode( APN_ID, ''13'', APN_ID, null ) ) AS MBB_APN2,
                       max( decode( APN_ID, ''12'', APN_ID, null ) ) AS BLACKBERRY_APN2,
                       max( decode( APN_ID, ''10'', APN_ID, null ) ) AS GPRS_INTRA_APN2,
                       max( decode( APN_ID, ''9'', APN_ID, null ) )  AS MMS_APN2,
                       max( decode( APN_ID, ''8'', APN_ID, null ) ) AS WAP_APN2,
                       max( decode( APN_ID, ''7'', APN_ID, null ) ) AS GPRS_APN2,
                       max( decode( APN_ID, ''3'', APN_ID, null ) ) AS DATACARD1_APN2,
                       max( decode( APN_ID, ''4'', APN_ID, null ) ) AS DATACARD2_APN2,
                       max( decode( APN_ID, ''6'', APN_ID, null ) ) AS DATACARD3_APN2,
                       max( decode( APN_ID, ''94'', APN_ID, null ) ) AS VOLTE01_APN2,
                       max( decode( APN_ID, ''95'', APN_ID, null ) ) AS VOLTE02_APN2
                       FROM
                       (
                       SELECT *
                       FROM HLR2
                       )
                       GROUP BY NUM_APPEL';

    CREATE_TABLE_WITH_TRACE_TE('HLR2_APN_DATA_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('HLR2_APN_DATA_TE', 'FAFIF', 'IX_MSISDN_APN2_TE', 'MSISDN_APN2');

    -- ================================================================================================================
    -- SECTION 6: Create HLR2 Parameter Table
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE HLR2_PARAM_TE AS
                 SELECT DISTINCT(T.NUM_APPEL),
                 DECODE(SUBSTR(SUBSTR(T.NUM_APPEL, 4), 1, 1),8,SUBSTR(T.NUM_APPEL, 4),7,SUBSTR(T.NUM_APPEL, 4),3,''0'' || (SUBSTR(T.NUM_APPEL, 4)),1,''0'' || (SUBSTR(NUM_APPEL, 4))) AS MSISDN,
                 T.IMSI, T.CFU, T.CFB, T.CFNRY,T.CFNRC,T.SPN,T.CAW,T.HOLD,T.MPTY,T.AOC,T.BAOC,T.BOIC,T.BOIEX,T.BAIC,T.BICRO,
                 T.CAT,T.OBO,T.OBI,T.OBR,T.OBOPRI,T.OBOPRE,T.OBSSM,T.OSB1,T.OSB2,T.OSB3,T.OSB4,T.OFA,T.PWD,T.ICI,T.OIN,T.TIN,
                 T.CLIP,T.CLIR,T.COLP,T.COLR,T.SOCB,T.SOCFU,T.SOCFB,T.SOCFRY,T.SOCFRC,T.SOCLIP,T.SOCLIR,T.SOCOLP,T.TS11,T.TS21,
                 T.TS22,T.TS62,T.TSD1,T.BS21,T.BS22,T.BS23,T.BS24,T.BS25,T.BS26,T.BS31,T.BS32,T.BS33,T.BS34,T.DBSG,T.TS61,T.CUG,
                 T.REGSER,T.PICI,T.DCF,T.SODCF,T.SOSDCF,T.CAPL,T.OICK,T.TICK,T.NAM,T.TSMO,T.REDUND,T.OCSI,T.RSA,T.RM,T.OBP,T.OSMCSI,
                 T.STYPE,T.SCHAR,T.REDMCH,T.GPRCSI,T.BS3G,T.CAMEL,T.RBT,T.EMLPP,T.NEMLPP,T.DEMLPP,
                 T.GPRSCSINF,T.MCSINF,T.OCSINF,T.OSMCSINF,T.TCSINF,T.TSMCSINF,T.VTCSINF,T.TIFCSINF,T.DCSIST,T.GPRSCSIST,
                 T.MCSIST,T.OCSIST,T.OSMCSIST,T.TCSIST,T.TSMCSIST,T.VTCSIST,T.ICS,T.CWNF,T.CHNF,T.CLIPNF,T.CLIRNF,T.ECTNF,T.ARD,
                 T.DATE_INSERTION_HLR2
                 FROM HLR2 T';

    CREATE_TABLE_WITH_TRACE_TE('HLR2_PARAM_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('HLR2_PARAM_TE', 'FAFIF', 'IX_HLR2_msisdn_TE', 'msisdn');

    -- ================================================================================================================
    -- SECTION 7: Merge HLR2 APN and Parameters
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE MERGE_HLR2_APN_TE NOLOGGING AS
                SELECT  TT.*,T.*
                FROM HLR2_APN_DATA_TE T, HLR2_PARAM_TE TT
                WHERE T.MSISDN_APN2 (+)= TT.MSISDN
                UNION
                SELECT  TT.*,T.*
                FROM HLR2_APN_DATA_TE T, HLR2_PARAM_TE TT
                WHERE T.MSISDN_APN2 = TT.MSISDN(+) ';

    CREATE_TABLE_WITH_TRACE_TE('MERGE_HLR2_APN_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 8: Create SV Reports for MISP
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE REP_SV_MSISDN_IN_MISP_TE NOLOGGING AS
                  SELECT *
                  FROM CLEAN_SV_ALL_UPD t
                  WHERE
                  T.PRODUCT_TYPE_NAME IN (''Mobile Broadband Prepaid'')
                  AND T.RATE_PLAN IN (31,33,30,34,32,35,36,37,38,59)
                ';

    CREATE_TABLE_WITH_TRACE_TE('REP_SV_MSISDN_IN_MISP_TE', 'FAFIF', SQL_TXT);

    SQL_TXT := ' CREATE TABLE REP_SV_MSISDN_NOT_MISP_TE NOLOGGING AS
                  SELECT *
                  FROM CLEAN_SV_ALL_UPD t
                  WHERE
                  T.SERVICE_NAME NOT IN ( SELECT SERVICE_NAME FROM REP_SV_MSISDN_IN_MISP_TE)';

    CREATE_TABLE_WITH_TRACE_TE('REP_SV_MSISDN_NOT_MISP_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 9: Merge SYS, SV and CS4
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE MERGE_SYS_SV_CS4_TE NOLOGGING AS
          SELECT
          T.service_name  AS MSISDN_SV,
          id, account_name, service_name, service_type_name, product_type_name, service_status, account_type, customer_node_id,
          service_start_date, service_end_date, imsi, first_call, shelf_life_exp, service_id, serv_bp_int, product_instance_id,
          prod_start_date, prod_end_date, product_id, prod_bp_inst, prod_status, prod_reason_code, prod_reason_name, service_reason_name,
          serv_reason_code, customer_start_date, account_start_date,last_run_date ,T.DEALER_CODE_P,IMEI,ACCOUNT_ID,RATE_PLAN,CUSTOMER_NODE_STATUS_CODE,LOGIN_OPTION,
          TT.MSISDN AS MSISDN_CS4, jour, num_appel, cust_id, cust_class, langue, date_actif,
          date_inactif,date_susp, date_init, date_creat, etat_ppas, etat, duree_validite, date_chgt_etat, amount, DATE_RETENTION
          FROM CLEAN_SV_ALL_UPD t, SYS_MINSAT_TE TT
          WHERE  T.SERVICE_NAME (+)= TT.MSISDN
          UNION
          SELECT
          T.service_name  AS MSISDN_SV,
          id, account_name, service_name, service_type_name, product_type_name, service_status, account_type, customer_node_id,
          service_start_date, service_end_date, imsi, first_call, shelf_life_exp, service_id, serv_bp_int, product_instance_id,
          prod_start_date, prod_end_date, product_id, prod_bp_inst, prod_status, prod_reason_code, prod_reason_name, service_reason_name,
          serv_reason_code, customer_start_date, account_start_date,last_run_date ,T.DEALER_CODE_P,IMEI,ACCOUNT_ID,RATE_PLAN,CUSTOMER_NODE_STATUS_CODE,LOGIN_OPTION,
          TT.MSISDN AS MSISDN_CS4, jour, num_appel, cust_id, cust_class, langue, date_actif,
          date_inactif,date_susp, date_init, date_creat, etat_ppas, etat, duree_validite, date_chgt_etat, amount, date_retention
          FROM CLEAN_SV_ALL_UPD t, SYS_MINSAT_TE TT
          WHERE  T.SERVICE_NAME = TT.MSISDN(+)';

    CREATE_TABLE_WITH_TRACE_TE('MERGE_SYS_SV_CS4_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('MERGE_SYS_SV_CS4_TE', 'FAFIF', 'IX_MSISDN_SYS_MERG_SV_TE', 'msisdn_sv');
    CREATE_INDEX_WITH_TRACE_TE('MERGE_SYS_SV_CS4_TE', 'FAFIF', 'IX_MSISDN_SYS_MERG_CS4_TE', 'msisdn_cs4');

    -- ================================================================================================================
    -- SECTION 10: Clean All SYS Merged
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE CLEAN_ALL_SYS_MERGED_TE NOLOGGING AS
              SELECT  (CASE WHEN M.msisdn_sv  IS NULL THEN msisdn_cs4
                           WHEN M.msisdn_cs4  IS NULL THEN msisdn_sv
                           ELSE msisdn_sv END)  AS MSISDN_SYS, m.*
              FROM MERGE_SYS_SV_CS4_TE M
               ';

    CREATE_TABLE_WITH_TRACE_TE('CLEAN_ALL_SYS_MERGED_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('CLEAN_ALL_SYS_MERGED_TE', 'FAFIF', 'IX_MSISDN_SYSM_TE', 'MSISDN_SYS');
    CREATE_INDEX_WITH_TRACE_TE('CLEAN_ALL_SYS_MERGED_TE', 'FAFIF', 'IX_PROD_SYSM_TE', 'PRODUCT_INSTANCE_ID');
    CREATE_INDEX_WITH_TRACE_TE('CLEAN_ALL_SYS_MERGED_TE', 'FAFIF', 'IX_SERV_SYSM_TE', 'SERV_BP_INT');

    -- ================================================================================================================
    -- SECTION 11: Merge HLR1 and HLR2 - Part 1
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE MERGE_HLR1_HLR2_1_TE NOLOGGING AS
          SELECT
              DECODE(SUBSTR(SUBSTR(t.NUM_APPEL,4 ),1,1),8,SUBSTR(t.NUM_APPEL, 4),7, SUBSTR(t.NUM_APPEL,4),3,''0''||(SUBSTR(t.NUM_APPEL,4 )),1,''0'' || (SUBSTR(T.NUM_APPEL, 4))) AS MSISDN_HLR1,
               t.IMSI as IMSI_1,t.NUM_APPEL as NUM_APPEL_1, t.CFU as CFU_1, t.CFB as CFB_1, t.CFNRY as CFNRY_1,
              t.CFNRC as CFNRC_1, t.SPN as SPN_1, t.CAW as CAW_1, t.HOLD as HOLD_1, t.MPTY as
              MPTY_1, t.AOC as AOC_1, t.BAOC as BAOC_1, t.BOIC as BOIC_1, t.BOIEX as BOIEX_1,
              t.BAIC as BAIC_1, t.BICRO as BICRO_1, t.CAT as CAT_1, t.OBO as OBO_1, t.OBI as
              OBI_1, t.OBR as OBR_1, t.OBOPRI as OBOPRI_1, t.OBOPRE as OBOPRE_1, t.OBSSM as
              OBSSM_1, t.OSB1 as OSB1_1, t.OSB2 as OSB2_1, t.OSB3 as OSB3_1, t.OSB4 as OSB4_1,
              t.OFA as OFA_1, t.PWD as PWD_1, t.ICI as ICI_1, t.OIN as OIN_1, t.TIN as TIN_1,
              t.CLIP as CLIP_1, t.CLIR as CLIR_1, t.COLP as COLP_1, t.COLR as COLR_1, t.SOCB
              as SOCB_1, t.SOCFU as SOCFU_1, t.SOCFB as SOCFB_1, t.SOCFRY as SOCFRY_1,
              t.SOCFRC as SOCFRC_1, t.SOCLIP as SOCLIP_1, t.SOCLIR as SOCLIR_1, t.SOCOLP as
              SOCOLP_1, t.TS11 as TS11_1, t.TS21 as TS21_1, t.TS22 as TS22_1, t.TS62 as
              TS62_1, t.TSD1 as TSD1_1, t.BS21 as BS21_1, t.BS22 as BS22_1, t.BS23 as BS23_1,
              t.BS24 as BS24_1, t.BS25 as BS25_1, t.BS26 as BS26_1, t.BS31 as BS31_1, t.BS32
              as BS32_1, t.BS33 as BS33_1, t.BS34 as BS34_1, t.DBSG as DBSG_1, t.TS61 as
              TS61_1, t.CUG as CUG_1, t.REGSER as REGSER_1, t.PICI as PICI_1, t.DCF as DCF_1,
              t.SODCF as SODCF_1, t.SOSDCF as SOSDCF_1, t.CAPL as CAPL_1, t.OICK as OICK_1,
              t.TICK as TICK_1, t.NAM as NAM_1, t.TSMO as TSMO_1, t.REDUND as REDUND_1, t.OCSI
              as OCSI_1, t.RSA as RSA_1, t.rm as rm_1,t.obp as obp_1, t.osmcsi as osmcsi_1,
              t.STYPE as STYPE_1, t.SCHAR as SCHAR_1, t.REDMCH as REDMCH_1, t.GPRCSI as GPRCSI_1,t.BS3G as BS3G_1,
              T.CAMEL as CAMEL_1,T.RBT as RBT_1,T.EMLPP as EMLPP_1,T.NEMLPP as NEMLPP_1 ,T.DEMLPP as DEMLPP_1,
              T.GPRSCSINF as GPRSCSINF_1,T.MCSINF as MCSINF_1,T.OCSINF as OCSINF_1,T.OSMCSINF as OSMCSINF_1,T.TCSINF as TCSINF_1,
              T.TSMCSINF as TSMCSINF_1,T.VTCSINF as VTCSINF_1,T.TIFCSINF as TIFCSINF_1,T.DCSIST as DCSIST_1,T.GPRSCSIST as GPRSCSIST_1,
              T.MCSIST as MCSIST_1,T.OCSIST as OCSIST_1,T.OSMCSIST as OSMCSIST_1,T.TCSIST as TCSIST_1,T.TSMCSIST AS TSMCSIST_1,
              T.VTCSIST AS VTCSIST_1,T.ICS AS ICS_1,T.CWNF AS CWNF_1,T.CHNF AS CHNF_1,T.CLIPNF AS CLIPNF_1,T.CLIRNF as CLIRNF_1,T.ECTNF AS ECTNF_1,T.ARD AS ARD_1,
              T.WLL_APN1,T.mbb_apn1, T.ALFA_APN1 , T.blackberry_apn1, T.gprs_intra_apn1, T.mms_apn1, T.wap_apn1,T.gprs_apn1, T.datacard1_apn1,
              T.datacard2_apn1, T.datacard3_apn1,T.VOLTE01_APN1,T.VOLTE02_APN1,T.Date_Insertion_Hlr1,
              DECODE(SUBSTR(SUBSTR(TT.NUM_APPEL,4 ),1,1),8,SUBSTR(TT.NUM_APPEL, 4),7, SUBSTR(TT.NUM_APPEL,4 ),3,''0''||(SUBSTR(TT.NUM_APPEL,4 )),1,''0'' || (SUBSTR(TT.NUM_APPEL, 4))) AS MSISDN_HLR2,
              tt.IMSI as IMSI_2, tt.NUM_APPEL as NUM_APPEL_2, tt.CFU as CFU_2, tt.CFB as CFB_2, tt.CFNRY as CFNRY_2,
               tt.CFNRC as CFNRC_2, tt.SPN as SPN_2, tt.CAW as CAW_2, tt.HOLD as
              HOLD_2, tt.MPTY as MPTY_2, tt.AOC as AOC_2, tt.BAOC as BAOC_2, tt.BOIC as
              BOIC_2, tt.BOIEX as BOIEX_2, tt.BAIC as BAIC_2, tt.BICRO as BICRO_2, tt.CAT as
              CAT_2, tt.OBO as OBO_2, tt.OBI as OBI_2, tt.OBR as OBR_2, tt.OBOPRI as OBOPRI_2,
              tt.OBOPRE as OBOPRE_2, tt.OBSSM as OBSSM_2, tt.OSB1 as OSB1_2, tt.OSB2 as
              OSB2_2, tt.OSB3 as OSB3_2, tt.OSB4 as OSB4_2, tt.OFA as OFA_2, tt.PWD as PWD_2,
              tt.ICI as ICI_2, tt.OIN as OIN_2, tt.TIN as TIN_2, tt.CLIP as CLIP_2, tt.CLIR as
              CLIR_2, tt.COLP as COLP_2, tt.COLR as COLR_2, tt.SOCB as SOCB_2, tt.SOCFU as
              SOCFU_2, tt.SOCFB as SOCFB_2, tt.SOCFRY as SOCFRY_2, tt.SOCFRC as SOCFRC_2,
              tt.SOCLIP as SOCLIP_2, tt.SOCLIR as SOCLIR_2, tt.SOCOLP as SOCOLP_2, tt.TS11 as
              TS11_2, tt.TS21 as TS21_2, tt.TS22 as TS22_2, tt.TS62 as TS62_2, tt.TSD1 as
              TSD1_2, tt.BS21 as BS21_2, tt.BS22 as BS22_2, tt.BS23 as BS23_2, tt.BS24 as
              BS24_2, tt.BS25 as BS25_2, tt.BS26 as BS26_2, tt.BS31 as BS31_2, tt.BS32 as
              BS32_2, tt.BS33 as BS33_2, tt.BS34 as BS34_2, tt.DBSG as DBSG_2, tt.TS61 as
              TS61_2, tt.CUG as CUG_2, tt.REGSER as REGSER_2, tt.PICI as PICI_2, tt.DCF as
              DCF_2, tt.SODCF as SODCF_2, tt.SOSDCF as SOSDCF_2, tt.CAPL as CAPL_2, tt.OICK as
              OICK_2, tt.TICK as TICK_2, tt.NAM as NAM_2, tt.TSMO as TSMO_2, tt.REDUND as
              REDUND_2, tt.OCSI as OCSI_2, tt.RSA as RSA_2,tt.rm as rm_2,tt.obp as obp_2,
              tt.osmcsi as osmcsi_2,tt.STYPE as STYPE_2, tt.SCHAR as SCHAR_2, tt.REDMCH as REDMCH_2, tt.GPRCSI as GPRCSI_2,tt.BS3G as BS3G_2,
              tt.CAMEL as CAMEL_2,tt.RBT as RBT_2,tt.EMLPP as EMLPP_2,tt.NEMLPP as NEMLPP_2 ,tt.DEMLPP as DEMLPP_2,
              TT.GPRSCSINF as GPRSCSINF_2,TT.MCSINF as MCSINF_2,TT.OCSINF as OCSINF_2,TT.OSMCSINF as OSMCSINF_2,TT.TCSINF as TCSINF_2,
              TT.TSMCSINF as TSMCSINF_2,TT.VTCSINF as VTCSINF_2,TT.TIFCSINF as TIFCSINF_2,TT.DCSIST as DCSIST_2,TT.GPRSCSIST as GPRSCSIST_2,
              TT.MCSIST as MCSIST_2,TT.OCSIST as OCSIST_2,TT.OSMCSIST as OSMCSIST_2,TT.TCSIST as TCSIST_2,TT.TSMCSIST AS TSMCSIST_2,
              TT.VTCSIST AS VTCSIST_2,TT.ICS AS ICS_2,TT.CWNF AS CWNF_2,TT.CHNF AS CHNF_2,TT.CLIPNF AS CLIPNF_2,TT.CLIRNF as CLIRNF_2,TT.ECTNF AS ECTNF_2,TT.ARD AS ARD_2,
              TT.WLL_APN2,tt.mbb_apn2, tt.ALFA_APN2 , tt.blackberry_apn2, tt.gprs_intra_apn2, tt.mms_apn2, tt.wap_apn2,tt.gprs_apn2, tt.datacard1_apn2,
              tt.datacard2_apn2, tt.datacard3_apn2,tt.VOLTE01_APN2,tt.VOLTE02_APN2,
              TT.DATE_INSERTION_HLR2 FROM MERGE_HLR1_APN_TE t, MERGE_HLR2_APN_TE TT WHERE  T.NUM_APPEL (+)= TT.NUM_APPEL ';

    CREATE_TABLE_WITH_TRACE_TE('MERGE_HLR1_HLR2_1_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 12: Merge HLR1 and HLR2 - Part 2
    -- ================================================================================================================
    SQL_TXT := ' CREATE TABLE MERGE_HLR1_HLR2_2_TE NOLOGGING AS
          SELECT DECODE(SUBSTR(SUBSTR(t.NUM_APPEL,4 ),1,1),8,SUBSTR(t.NUM_APPEL, 4),7, SUBSTR(t.NUM_APPEL,4),3,''0''||(SUBSTR(t.NUM_APPEL,4 )),1,''0'' || (SUBSTR(T.NUM_APPEL, 4))) AS MSISDN_HLR1,
             t.IMSI as IMSI_1, t.NUM_APPEL as NUM_APPEL_1, t.CFU as CFU_1, t.CFB as CFB_1, t.CFNRY as CFNRY_1,
            t.CFNRC as CFNRC_1, t.SPN as SPN_1, t.CAW as CAW_1, t.HOLD as HOLD_1, t.MPTY as
            MPTY_1, t.AOC as AOC_1, t.BAOC as BAOC_1, t.BOIC as BOIC_1, t.BOIEX as BOIEX_1,
            t.BAIC as BAIC_1, t.BICRO as BICRO_1, t.CAT as CAT_1, t.OBO as OBO_1, t.OBI as
            OBI_1, t.OBR as OBR_1, t.OBOPRI as OBOPRI_1, t.OBOPRE as OBOPRE_1, t.OBSSM as
            OBSSM_1, t.OSB1 as OSB1_1, t.OSB2 as OSB2_1, t.OSB3 as OSB3_1, t.OSB4 as OSB4_1,
            t.OFA as OFA_1, t.PWD as PWD_1, t.ICI as ICI_1, t.OIN as OIN_1, t.TIN as TIN_1,
            t.CLIP as CLIP_1, t.CLIR as CLIR_1, t.COLP as COLP_1, t.COLR as COLR_1, t.SOCB
            as SOCB_1, t.SOCFU as SOCFU_1, t.SOCFB as SOCFB_1, t.SOCFRY as SOCFRY_1,
            t.SOCFRC as SOCFRC_1, t.SOCLIP as SOCLIP_1, t.SOCLIR as SOCLIR_1, t.SOCOLP as
            SOCOLP_1, t.TS11 as TS11_1, t.TS21 as TS21_1, t.TS22 as TS22_1, t.TS62 as
            TS62_1, t.TSD1 as TSD1_1, t.BS21 as BS21_1, t.BS22 as BS22_1, t.BS23 as BS23_1,
            t.BS24 as BS24_1, t.BS25 as BS25_1, t.BS26 as BS26_1, t.BS31 as BS31_1, t.BS32
            as BS32_1, t.BS33 as BS33_1, t.BS34 as BS34_1, t.DBSG as DBSG_1, t.TS61 as
            TS61_1, t.CUG as CUG_1, t.REGSER as REGSER_1, t.PICI as PICI_1, t.DCF as DCF_1,
            t.SODCF as SODCF_1, t.SOSDCF as SOSDCF_1, t.CAPL as CAPL_1, t.OICK as OICK_1,
            t.TICK as TICK_1, t.NAM as NAM_1, t.TSMO as TSMO_1, t.REDUND as REDUND_1, t.OCSI
            as OCSI_1, t.RSA as RSA_1, t.rm as rm_1,t.obp as obp_1, t.osmcsi as osmcsi_1,
            t.STYPE as STYPE_1, t.SCHAR as SCHAR_1, t.REDMCH as REDMCH_1, t.GPRCSI as GPRCSI_1,t.BS3G AS BS3G_1,
            T.CAMEL as CAMEL_1,T.RBT as RBT_1,T.EMLPP as EMLPP_1,T.NEMLPP as NEMLPP_1 ,T.DEMLPP as DEMLPP_1,
            T.GPRSCSINF as GPRSCSINF_1,T.MCSINF as MCSINF_1,T.OCSINF as OCSINF_1,T.OSMCSINF as OSMCSINF_1,T.TCSINF as TCSINF_1,
            T.TSMCSINF as TSMCSINF_1,T.VTCSINF as VTCSINF_1,T.TIFCSINF as TIFCSINF_1,T.DCSIST as DCSIST_1,T.GPRSCSIST as GPRSCSIST_1,
            T.MCSIST as MCSIST_1,T.OCSIST as OCSIST_1,T.OSMCSIST as OSMCSIST_1,T.TCSIST as TCSIST_1,T.TSMCSIST AS TSMCSIST_1,
            T.VTCSIST AS VTCSIST_1,T.ICS AS ICS_1,T.CWNF AS CWNF_1,T.CHNF AS CHNF_1,T.CLIPNF AS CLIPNF_1,T.CLIRNF as CLIRNF_1,T.ECTNF AS ECTNF_1,T.ARD AS ARD_1,
            T.WLL_APN1, T.mbb_apn1, t.ALFA_APN1 , T.blackberry_apn1, T.gprs_intra_apn1, T.mms_apn1, T.wap_apn1,T.gprs_apn1, T.datacard1_apn1,
            T.datacard2_apn1, T.datacard3_apn1,T.VOLTE01_APN1,T.VOLTE02_APN1,
            T.DATE_INSERTION_HLR1,
            DECODE(SUBSTR(SUBSTR(TT.NUM_APPEL,4 ),1,1),8,SUBSTR(TT.NUM_APPEL, 4),7, SUBSTR(TT.NUM_APPEL,4),3,''0''||(SUBSTR(TT.NUM_APPEL,4 )),1,''0'' || (SUBSTR(TT.NUM_APPEL, 4))) AS MSISDN_HLR2,
            tt.IMSI as IMSI_2, tt.NUM_APPEL as NUM_APPEL_2, tt.CFU as CFU_2, tt.CFB as CFB_2, tt.CFNRY as CFNRY_2,
            tt.CFNRC as CFNRC_2, tt.SPN as SPN_2, tt.CAW as CAW_2, tt.HOLD as
            HOLD_2, tt.MPTY as MPTY_2, tt.AOC as AOC_2, tt.BAOC as BAOC_2, tt.BOIC as
            BOIC_2, tt.BOIEX as BOIEX_2, tt.BAIC as BAIC_2, tt.BICRO as BICRO_2, tt.CAT as
            CAT_2, tt.OBO as OBO_2, tt.OBI as OBI_2, tt.OBR as OBR_2, tt.OBOPRI as OBOPRI_2,
            tt.OBOPRE as OBOPRE_2, tt.OBSSM as OBSSM_2, tt.OSB1 as OSB1_2, tt.OSB2 as
            OSB2_2, tt.OSB3 as OSB3_2, tt.OSB4 as OSB4_2, tt.OFA as OFA_2, tt.PWD as PWD_2,
            tt.ICI as ICI_2, tt.OIN as OIN_2, tt.TIN as TIN_2, tt.CLIP as CLIP_2, tt.CLIR as
            CLIR_2, tt.COLP as COLP_2, tt.COLR as COLR_2, tt.SOCB as SOCB_2, tt.SOCFU as
            SOCFU_2, tt.SOCFB as SOCFB_2, tt.SOCFRY as SOCFRY_2, tt.SOCFRC as SOCFRC_2,
            tt.SOCLIP as SOCLIP_2, tt.SOCLIR as SOCLIR_2, tt.SOCOLP as SOCOLP_2, tt.TS11 as
            TS11_2, tt.TS21 as TS21_2, tt.TS22 as TS22_2, tt.TS62 as TS62_2, tt.TSD1 as
            TSD1_2, tt.BS21 as BS21_2, tt.BS22 as BS22_2, tt.BS23 as BS23_2, tt.BS24 as
            BS24_2, tt.BS25 as BS25_2, tt.BS26 as BS26_2, tt.BS31 as BS31_2, tt.BS32 as
            BS32_2, tt.BS33 as BS33_2, tt.BS34 as BS34_2, tt.DBSG as DBSG_2, tt.TS61 as
            TS61_2, tt.CUG as CUG_2, tt.REGSER as REGSER_2, tt.PICI as PICI_2, tt.DCF as
            DCF_2, tt.SODCF as SODCF_2, tt.SOSDCF as SOSDCF_2, tt.CAPL as CAPL_2, tt.OICK as
            OICK_2, tt.TICK as TICK_2, tt.NAM as NAM_2, tt.TSMO as TSMO_2, tt.REDUND as
            REDUND_2, tt.OCSI as OCSI_2, tt.RSA as RSA_2,tt.rm as rm_2,tt.obp as obp_2,
            tt.osmcsi as osmcsi_2,
            tt.STYPE as STYPE_2, tt.SCHAR as SCHAR_2, tt.REDMCH as REDMCH_2, tt.GPRCSI as GPRCSI_2,tt.BS3G AS BS3G_2,
            tt.CAMEL as CAMEL_2,tt.RBT as RBT_2,tt.EMLPP as EMLPP_2,tt.NEMLPP as NEMLPP_2 ,tt.DEMLPP as DEMLPP_2,
            TT.GPRSCSINF as GPRSCSINF_2,TT.MCSINF as MCSINF_2,TT.OCSINF as OCSINF_2,TT.OSMCSINF as OSMCSINF_2,TT.TCSINF as TCSINF_2,
            TT.TSMCSINF as TSMCSINF_2,TT.VTCSINF as VTCSINF_2,TT.TIFCSINF as TIFCSINF_2,TT.DCSIST as DCSIST_2,TT.GPRSCSIST as GPRSCSIST_2,
            TT.MCSIST as MCSIST_2,TT.OCSIST as OCSIST_2,TT.OSMCSIST as OSMCSIST_2,TT.TCSIST as TCSIST_2,TT.TSMCSIST AS TSMCSIST_2,
            TT.VTCSIST AS VTCSIST_2,TT.ICS AS ICS_2,TT.CWNF AS CWNF_2,TT.CHNF AS CHNF_2,TT.CLIPNF AS CLIPNF_2,TT.CLIRNF as CLIRNF_2,TT.ECTNF AS ECTNF_2,TT.ARD AS ARD_2,
            TT.WLL_APN2,tt.mbb_apn2,tt.ALFA_APN2 , tt.blackberry_apn2, tt.gprs_intra_apn2, tt.mms_apn2, tt.wap_apn2,tt.gprs_apn2, tt.datacard1_apn2,
            tt.datacard2_apn2, tt.datacard3_apn2,tt.VOLTE01_APN2,tt.VOLTE02_APN2,
            TT.DATE_INSERTION_HLR2 FROM MERGE_HLR1_APN_TE t, MERGE_HLR2_APN_TE TT WHERE T.NUM_APPEL = TT.NUM_APPEL(+)';

    CREATE_TABLE_WITH_TRACE_TE('MERGE_HLR1_HLR2_2_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 13: Union HLR1 and HLR2 Merges
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE MERGE_HLR1_HLR2_TE NOLOGGING AS
                select * from MERGE_HLR1_HLR2_1_TE
                union
                SELECT * FROM MERGE_HLR1_HLR2_2_TE';

    CREATE_TABLE_WITH_TRACE_TE('MERGE_HLR1_HLR2_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 14: Update NULL values to 0
    -- ================================================================================================================
    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBO_1 = 0 WHERE HH.OBO_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBO_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBI_1 = 0 WHERE HH.OBI_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBI_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.TICK_1 = 0 WHERE HH.TICK_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set TICK_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBR_1 = 0 WHERE HH.OBR_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBR_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OICK_1 = 0 WHERE HH.OICK_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OICK_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.RSA_1 = 0 WHERE HH.RSA_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set RSA_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBO_2 = 0 WHERE HH.OBO_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBO_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBI_2 = 0 WHERE HH.OBI_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBI_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.TICK_2 = 0 WHERE HH.TICK_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set TICK_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBR_2 = 0 WHERE HH.OBR_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBR_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OICK_2 = 0 WHERE HH.OICK_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OICK_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.RSA_2 = 0 WHERE HH.RSA_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set RSA_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBP_1 = 0 WHERE HH.OBP_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBP_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OBP_2 = 0 WHERE HH.OBP_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OBP_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OCSIST_1 = 0 WHERE HH.OCSIST_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OCSIST_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.OCSIST_2 = 0 WHERE HH.OCSIST_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set OCSIST_2 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.TCSIST_1 = 0 WHERE HH.TCSIST_1 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set TCSIST_1 NULL to 0');

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH SET HH.TCSIST_2 = 0 WHERE HH.TCSIST_2 IS NULL';
    UPDATE_TABLE_WITH_TRACE_TE(SQL_TXT, 'Set TCSIST_2 NULL to 0');

    COMMIT;

    -- ================================================================================================================
    -- SECTION 15: Create HLR Discrepancy Reports
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE REP_HLRS_MIS_MSISDN_TE NOLOGGING AS
              SELECT * FROM MERGE_HLR1_HLR2_TE HH
              WHERE HH.MSISDN_HLR1 IS NULL OR HH.MSISDN_HLR2 IS NULL';

    CREATE_TABLE_WITH_TRACE_TE('REP_HLRS_MIS_MSISDN_TE', 'FAFIF', SQL_TXT);

    SQL_TXT := 'CREATE TABLE REP_HLRS_MIS_IMSI_TE NOLOGGING AS
              SELECT * FROM MERGE_HLR1_HLR2_TE HH
              WHERE HH.MSISDN_HLR1 = HH.MSISDN_HLR2
              AND HH.MSISDN_HLR1 IS NOT NULL
              AND HH.IMSI_1<>HH.IMSI_2';

    CREATE_TABLE_WITH_TRACE_TE('REP_HLRS_MIS_IMSI_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 16: Create Clean HLR Merged Table
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE CLEAN_HLRS_MERGED_TE NOLOGGING AS
                  SELECT  (CASE WHEN M.MSISDN_HLR1 IS NULL THEN M.MSISDN_HLR2
                               WHEN M.MSISDN_HLR2  IS NULL THEN MSISDN_HLR1
                               ELSE M.MSISDN_HLR2
                               END)  AS MSISDN_HLRS, m.*
                  FROM MERGE_HLR1_HLR2_TE M
                  WHERE 1=1
                  OR M.IMSI_1 IS NULL
                  OR M.IMSI_2 IS NULL
                  ';

    CREATE_TABLE_WITH_TRACE_TE('CLEAN_HLRS_MERGED_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('CLEAN_HLRS_MERGED_TE', 'FAFIF', 'IX_MSISDN_HLR_TE', 'MSISDN_HLRS');

    -- ================================================================================================================
    -- SECTION 17: Merge SYS and HLRs
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE MERGE_SYS_HLRS_TE AS
                  SELECT t.*, SUBSTR(tt.IMSI_1,0,6) as prim_flag,TT.*
                  FROM CLEAN_ALL_SYS_MERGED_TE t, CLEAN_HLRS_MERGED_TE TT
                  WHERE T.MSISDN_SYS(+)=TT.MSISDN_HLRS
                  UNION
                  SELECT t.*, SUBSTR(tt.IMSI_1,0,6) as prim_flag ,TT.*
                  FROM CLEAN_ALL_SYS_MERGED_TE t, CLEAN_HLRS_MERGED_TE TT
                  WHERE t.MSISDN_SYS =TT.MSISDN_HLRS(+)';

    CREATE_TABLE_WITH_TRACE_TE('MERGE_SYS_HLRS_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 18: Create Final Clean All Merged Report
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE REP_CLEAN_ALL_MERGED_TE NOLOGGING AS
                  SELECT  (CASE WHEN M.MSISDN_SYS IS NULL THEN M.MSISDN_HLRS
                               WHEN M.MSISDN_HLRS  IS NULL THEN M.MSISDN_SYS
                               ELSE M.MSISDN_SYS END)  AS MSISDN ,
                          decode(prim_flag,''415012'', 1,''415019'',1,2) as primary_hlr,
                          (CASE WHEN M.MSISDN_SYS IS NULL THEN
                             (case when (to_number(M.MSISDN_HLRS) between 71900000 and 71999999) then ''SDP05''
                                   when (to_number(M.MSISDN_HLRS) between 71800000 and 71899999) then ''SDP06''
                                   when (to_number(M.MSISDN_HLRS) between 3000000  and 3999999)  then ''SDP03''
                                   when (to_number(M.MSISDN_HLRS) between 70000000 and 70999999) then ''SDP04''
                                   when (to_number(M.MSISDN_HLRS) between 71000000 and 71099999) then ''SDP04''
                                   when (to_number(M.MSISDN_HLRS) between 76100000 and 76199999) then ''SDP05''
                                   when (to_number(M.MSISDN_HLRS) between 71600000 and 71699999) then ''SDP04''
                                   when (to_number(M.MSISDN_HLRS) between 71700000 and 71799999) then ''SDP05''
                                   when (to_number(M.MSISDN_HLRS) between 76300000 and 76399999) then ''SDP05''
                                   when (to_number(M.MSISDN_HLRS) between 76400000 and 76499999) then ''SDP06''
                                   when (to_number(M.MSISDN_HLRS) between 76500000 and 76599999) then ''SDP05''
                                   when (to_number(M.MSISDN_HLRS) between 79100000 and 79199999) then ''SDP06''
                                   when (to_number(M.MSISDN_HLRS) between 79300000 and 79324999) then ''SDP06''
                                   when (to_number(M.MSISDN_HLRS) between 1000000 and 1999999) then ''SDP06''
                                   when (to_number(M.MSISDN_HLRS) between 81000000 and 81999999) then ''SDP05''
                                   else ''SDP''
                               end)
                            WHEN M.MSISDN_HLRS  IS NULL THEN
                            (case when (to_number(M.MSISDN_SYS) between 71900000 and 71999999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 71800000 and 71899999) then ''SDP04''
                                  when (to_number(M.MSISDN_SYS) between 3000000  and 3999999)  then ''SDP03''
                                  when (to_number(M.MSISDN_SYS) between 70000000 and 70999999) then ''SDP04''
                                  when (to_number(M.MSISDN_SYS) between 71000000 and 71099999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 76100000 and 76199999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 71600000 and 71699999) then ''SDP04''
                                  when (to_number(M.MSISDN_SYS) between 71700000 and 71799999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 76300000 and 76399999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 76400000 and 76499999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 76500000 and 76599999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 79100000 and 79199999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 79300000 and 79324999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 1000000 and 1999999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 81000000 and 81999999) then ''SDP05''
                                  else ''SDP''
                             end)
                            ELSE
                            (case when (to_number(M.MSISDN_SYS) between 71900000 and 71999999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 71800000 and 71899999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 3000000  and 3999999)  then ''SDP03''
                                  when (to_number(M.MSISDN_SYS) between 70000000 and 70999999) then ''SDP04''
                                  when (to_number(M.MSISDN_SYS) between 71000000 and 71099999) then ''SDP04''
                                  when (to_number(M.MSISDN_SYS) between 76100000 and 76199999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 71600000 and 71699999) then ''SDP04''
                                  when (to_number(M.MSISDN_SYS) between 71700000 and 71799999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 76300000 and 76399999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 76400000 and 76499999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 76500000 and 76599999) then ''SDP05''
                                  when (to_number(M.MSISDN_SYS) between 79100000 and 79199999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 79300000 and 79324999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 1000000 and 1999999) then ''SDP06''
                                  when (to_number(M.MSISDN_SYS) between 81000000 and 81999999) then ''SDP05''
                                  else ''SDP''
                             end)
                         END) AS  SDP,
                            m.*
                  FROM MERGE_SYS_HLRS_TE M';

    CREATE_TABLE_WITH_TRACE_TE('REP_CLEAN_ALL_MERGED_TE', 'FAFIF', SQL_TXT);
    CREATE_INDEX_WITH_TRACE_TE('REP_CLEAN_ALL_MERGED_TE', 'FAFIF', 'IX_clean_all_msisdn_TE', 'msisdn');
    CREATE_INDEX_WITH_TRACE_TE('REP_CLEAN_ALL_MERGED_TE', 'FAFIF', 'IX_PRODUCT_INSTANCE_ID_TE', 'PRODUCT_INSTANCE_ID');

    -- ================================================================================================================
    -- SECTION 19: Create ADM DMP Reports for HLR1
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE REP_ADM_DMP_HLR1_TE NOLOGGING AS
                      select t.msisdn, t.imsi,
                      (case
                        when t.wll_apn1 is not null then ''Mobile Internet WLL''
                          when t.mbb_apn1 is not null then ''Mobile BroadBand''
                            when t.alfa_apn1 is not null then ''Alfa APN''
                              when t.blackberry_apn1 is not null then ''Blackberry''
                                when t.gprs_intra_apn1 is not null then ''GPRS INTRA''
                                  when t.mms_apn1 is not null then ''MMS''
                                    when t.wap_apn1 is not null then ''WAP''
                                      when t.gprs_apn1 is not null then ''GPRS''
                                        when t.datacard1_apn1 is not null then ''Data Card''
                                          when t.datacard2_apn1 is not null then ''Data Card''
                                            when t.datacard3_apn1 is not null then ''Data Card''
                                              when t.volte01_apn1 is not null then ''Volte''
                                                  when t.volte02_apn1 is not null then ''Volte''
                                                    else ''OTHER''
                         end) AS Companion_Product,
                       t.service_type_name
                      from REP_CLEAN_ALL_MERGED_TE t
                      WHERE 1=1
                      AND t.primary_hlr = 1';

    CREATE_TABLE_WITH_TRACE_TE('REP_ADM_DMP_HLR1_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 20: Create ADM DMP Reports for HLR2
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE REP_ADM_DMP_HLR2_TE NOLOGGING AS
                    select t.msisdn, t.imsi,
                       (case
                        when t.wll_apn2 is not null then ''Mobile Internet WLL''
                          when t.mbb_apn2 is not null then ''Mobile BroadBand''
                            when t.alfa_apn2 is not null then ''Alfa APN''
                              when t.blackberry_apn2 is not null then ''Blackberry''
                                when t.gprs_intra_apn2 is not null then ''GPRS INTRA''
                                  when t.mms_apn2 is not null then ''MMS''
                                    when t.wap_apn2 is not null then ''WAP''
                                      when t.gprs_apn2 is not null then ''GPRS''
                                        when t.datacard1_apn2 is not null then ''Data Card''
                                          when t.datacard2_apn2 is not null then ''Data Card''
                                            when t.datacard3_apn2 is not null then ''Data Card''
                                              when t.volte01_apn2 is not null then ''Volte''
                                                  when t.volte02_apn2 is not null then ''Volte''
                                                    else ''OTHER''
                         end) AS Companion_Product,
                         t.service_type_name
                    from REP_CLEAN_ALL_MERGED_TE t
                    WHERE 1=1
                    AND t.primary_hlr = 2';

    CREATE_TABLE_WITH_TRACE_TE('REP_ADM_DMP_HLR2_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 21: Union APNs
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE UNION_APNS_TE NOLOGGING AS
                      SELECT ss.* FROM REP_ADM_DMP_HLR1_TE ss
                      UNION
                      SELECT vv.* FROM REP_ADM_DMP_HLR2_TE vv';

    CREATE_TABLE_WITH_TRACE_TE('UNION_APNS_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 22: Merge APN with SYS
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE REP_APN_SYS_ALL_TE NOLOGGING AS
                SELECT AA.MSISDN, AA.IMSI, AA.COMPANION_PRODUCT, AA.SERVICE_TYPE_NAME FROM UNION_APNS_TE AA
                UNION
                SELECT MM.MSISDN, MM.IMSI, NULL, MM.SERVICE_TYPE_NAME FROM REP_CLEAN_ALL_MERGED_TE MM
                WHERE mm.service_status <> ''Cancelled''';

    CREATE_TABLE_WITH_TRACE_TE('REP_APN_SYS_ALL_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 23: List Duplicates
    -- ================================================================================================================
    SQL_TXT := 'CREATE TABLE list_null_cp_group_TE NOLOGGING AS
                  SELECT t.msisdn, COUNT (t.msisdn) AS count_NUM FROM rep_apn_sys_all_TE t
                  GROUP BY t.msisdn
                  HAVING COUNT (t.msisdn) >1';

    CREATE_TABLE_WITH_TRACE_TE('list_null_cp_group_TE', 'FAFIF', SQL_TXT);

    -- ================================================================================================================
    -- SECTION 24: Remove Duplicates
    -- ================================================================================================================
    v_step_number := v_step_number + 1;
    v_step_name := 'DELETE: Remove duplicates from REP_APN_SYS_ALL_TE';
    v_step_start_time := SYSTIMESTAMP;

    EXECUTE IMMEDIATE 'DELETE FROM REP_APN_SYS_ALL_TE T
                    WHERE T.MSISDN IN (SELECT V.MSISDN FROM LIST_NULL_CP_GROUP_TE V)
                    AND T.COMPANION_PRODUCT IS NULL';

    v_rows_affected := SQL%ROWCOUNT;
    v_step_end_time := SYSTIMESTAMP;
    LOG_ACTIVITY_TE(v_step_number, v_step_name, 'SUCCESS', v_step_start_time, v_step_end_time, v_rows_affected);

    -- ================================================================================================================
    -- SECTION 25: Export Table
    -- ================================================================================================================
    v_step_number := v_step_number + 1;
    v_step_name := 'EXPORT: Export REP_APN_SYS_ALL_TE to ADM';
    v_step_start_time := SYSTIMESTAMP;

    BEGIN
        fafif.reconciliation_interfaces.EXPORT_TABLE_TO_ADM_TXT('FAFIF', 'REP_APN_SYS_ALL_TE');
        v_step_end_time := SYSTIMESTAMP;
        LOG_ACTIVITY_TE(v_step_number, v_step_name, 'SUCCESS', v_step_start_time, v_step_end_time, 0);
    EXCEPTION
        WHEN OTHERS THEN
            v_step_end_time := SYSTIMESTAMP;
            LOG_ACTIVITY_TE(v_step_number, v_step_name, 'WARNING', v_step_start_time, v_step_end_time, 0, 'Export failed: ' || SQLERRM);
    END;

    CURRENT_DATE := TO_CHAR(TO_DATE(TO_CHAR(SYSDATE, 'DDMMYYYY'), 'DDMMYYYY'), 'DDMMYYYY');

    -- ================================================================================================================
    -- SECTION 26: Procedure Completion
    -- ================================================================================================================
    v_procedure_end := SYSTIMESTAMP;

    v_step_number := v_step_number + 1;
    LOG_ACTIVITY_TE(v_step_number, 'PROCEDURE COMPLETED', 'SUCCESS', v_procedure_start, v_procedure_end, 0,
                    'Total Tables Created: ' || v_total_tables ||
                    ', Total Indexes Created: ' || v_total_indexes ||
                    ', Total Updates: ' || v_total_updates);

    RESULT := 'SUCCESS';
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SQLERRM;
        v_step_end_time := SYSTIMESTAMP;

        LOG_ACTIVITY_TE(v_step_number, 'PROCEDURE FAILED', 'ERROR', v_procedure_start, v_step_end_time, 0, v_error_message);

        RESULT := 'FAILED: ' || v_error_message;
        ROLLBACK;
        RAISE;

END P1_MAIN_SYS_INTERFACES_TE;
/

-- =============================================================================================
-- STEP 3: View Activity Trace Query
-- =============================================================================================

-- Query to view execution trace
PROMPT
PROMPT To view execution trace, run:
PROMPT
PROMPT SELECT STEP_NUMBER, STEP_NAME, STEP_STATUS, DURATION_SECONDS, ROWS_AFFECTED
PROMPT FROM P1_ACTIVITY_TRACE_TE
PROMPT WHERE SESSION_ID = USERENV('SESSIONID')
PROMPT ORDER BY STEP_NUMBER;
PROMPT
PROMPT =============================================================================================
PROMPT Installation Complete!
PROMPT =============================================================================================
