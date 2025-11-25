CREATE OR REPLACE PACKAGE RECONCILIATION_INTERFACES AUTHID CURRENT_USER IS

  -- =============================================================================================
  -- Package: RECONCILIATION_INTERFACES
  -- Purpose: HLR (Home Location Register) Reconciliation System for Telecommunications
  -- =============================================================================================
  -- Modified by                 : FA
  -- Release                     : R1.2
  -- Date                        : 07/07/2007
  -- =============================================================================================

  -- =============================================================================================
  -- GLOBAL VARIABLES - Counters and Metrics
  -- =============================================================================================
  CUROCC                       NUMBER;
  ERRLOGID                     NUMBER;
  ERROR_MSG                    NUMBER;
  CNTINS                       NUMBER := 0;
  CNTUPD                       NUMBER := 0;
  CNTDEL                       NUMBER := 0;
  LEVEL6_COUNT                 NUMBER := 0;
  LEVEL5_COUNT                 NUMBER := 0;
  LEVEL4_COUNT                 NUMBER := 0;
  LEVEL3_COUNT                 NUMBER := 0;

  -- =============================================================================================
  -- GLOBAL VARIABLES - Logging and Error Handling
  -- =============================================================================================
  LOGOBJTYPE                   VARCHAR2(30);
  LOGOBJNAME                   VARCHAR2(30);
  G_EXCEPTION_MESSAGE          VARCHAR2(512);
  TABLE_NAME                   VARCHAR2(150);
  CURSTEP                      VARCHAR2(50);
  INTERNAL_ID                  VARCHAR2(10);
  UPDRECORDS                   VARCHAR2(1000);
  DELRECORDS                   VARCHAR2(1000);

  -- =============================================================================================
  -- EXCEPTION DEFINITIONS
  -- =============================================================================================
  APPLICATION_ERROR            EXCEPTION;
  EMPTY_ERROR                  EXCEPTION;
  CONVERT_ERROR                EXCEPTION;
  CONVERT_ERROR_1              EXCEPTION;
  CONVERT_ERROR_2              EXCEPTION;
  BACKUP_ERROR                 EXCEPTION;
  NO_FILE_ERROR                EXCEPTION;
  CONCAT_ERROR                 EXCEPTION;
  FATAL_ERROR                  EXCEPTION;
  TABLE_CREATION_FAILED        EXCEPTION;
  TABLE_UPDATE_FAILED          EXCEPTION;
  TABLE_INSERT_FAILED          EXCEPTION;
  NO_DATA_FOR_CURRENT_ENTITY   EXCEPTION;
  NO_FRST_LEVEL                EXCEPTION;
  ERR_FRST_LEVEL               EXCEPTION;
  FAILURE_ERROR                EXCEPTION;
  LISTS_UPDATE_FAILURE         EXCEPTION;
  NO_PARMATER_VALUE            EXCEPTION;
  INDEX_CREATION_FAILED        EXCEPTION;
  TABLE_DROP_FAILED            EXCEPTION;
  TABLE_TRUNC_ERROR            EXCEPTION;
  FATAL_EXCEPTION              EXCEPTION;
  ENTITIES_NOT_EXIST           EXCEPTION;
  INVALID_OPERATION            EXCEPTION;
  TRANSIENT_ERROR              EXCEPTION;
  PERMANENT_ERROR              EXCEPTION;

  -- =============================================================================================
  -- MAIN SYSTEM INTERFACES
  -- =============================================================================================

  -- Main system interface handler
  PROCEDURE P1_MAIN_SYS_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Main system interface handler (old version)
  PROCEDURE P1_MAIN_SYS_INTERFACES_OLD(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Call completion interface handler
  PROCEDURE P1_CALL_COMPLETION_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Monthly HLR reconciliation interface
  PROCEDURE P1_HLR_RECON_MONTH_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- =============================================================================================
  -- PREPAID/POSTPAID SERVICE INTERFACES
  -- =============================================================================================

  -- Postpaid/Prepaid service interface (old version)
  PROCEDURE P2_POST_PREP_SERV_INTER_old(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Postpaid/Prepaid service interface
  PROCEDURE P2_POST_PREP_SERV_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Postpaid suspended service interface
  PROCEDURE P2_POST_SUSP_SERV_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Prepaid interface
  PROCEDURE P3_PREP_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- =============================================================================================
  -- CONTENT PROVIDER (CP) INTERFACES
  -- =============================================================================================

  -- Content Provider interface (old version)
  PROCEDURE P4_CP_INTERFACES_OLD(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Content Provider interface
  PROCEDURE P4_CP_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Wireless Local Loop CP interface
  PROCEDURE P4_WLL_CP_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Interactive Applications CP interface
  PROCEDURE P_IA_CP_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- MT Roaming CP interface
  PROCEDURE P_MTROAMING_CP_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- ALFA CP interface
  PROCEDURE P5_ALFA_CP_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- =============================================================================================
  -- ADVANCED SERVICE INTERFACES
  -- =============================================================================================

  -- VoLTE (Voice over LTE) interface
  PROCEDURE P6_VOLTE_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- Data card interface
  PROCEDURE P7_DATACARD_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
  );

  -- =============================================================================================
  -- PROVISIONING RECONCILIATION PROCEDURES
  -- =============================================================================================

  -- Reconcile services for Content Providers
  PROCEDURE prov_recon_services_cps(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    OPTION_TO_ACT IN VARCHAR2,
    CP_PRODUCT IN VARCHAR2,
    HLR IN VARCHAR2
  );

  -- Reconcile standard services
  PROCEDURE prov_recon_services(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    OPTION_TO_ACT IN VARCHAR2,
    PRODUCT IN VARCHAR2,
    HLR IN VARCHAR2
  );

  -- Reconcile VPN for Content Providers
  PROCEDURE prov_recon_VPN_cps(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    OPTION_TO_ACT IN VARCHAR2,
    CP_PRODUCT IN VARCHAR2,
    HLR IN VARCHAR2
  );

  -- Reconcile SMS for Content Providers
  PROCEDURE PROV_RECON_SMS_CPS(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    OPTION_TO_ACT IN VARCHAR2,
    CP_PRODUCT IN VARCHAR2,
    HLR IN VARCHAR2,
    SMSMode IN VARCHAR2
  );

  -- Reconcile SMS roaming for Content Providers
  PROCEDURE PROV_RECON_SMS_ROAMING_CPS(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    OPTION_TO_ACT IN VARCHAR2,
    CP_PRODUCT IN VARCHAR2,
    HLR IN VARCHAR2
  );

  -- Reconcile roaming for Content Providers
  PROCEDURE PROV_RECON_ROAMING_CPS(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    OPTION_TO_ACT IN VARCHAR2,
    CP_PRODUCT IN VARCHAR2,
    HLR IN VARCHAR2
  );

  -- Reconcile MT roaming for Content Providers
  PROCEDURE PROV_RECON_MT_ROAMING_CPS(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    OPTION_TO_ACT IN VARCHAR2,
    HLR IN VARCHAR2
  );

  -- Reconcile VoLTE for Content Providers
  PROCEDURE PROV_RECON_VOLTE_CPS(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    SERVICE_TYPE IN VARCHAR2,
    SCP_OPTION IN VARCHAR2,
    CP_PRODUCT IN VARCHAR2
  );

  -- =============================================================================================
  -- PARAMETER RECONCILIATION PROCEDURES
  -- =============================================================================================

  -- Reconcile Service Characteristics parameter
  PROCEDURE PROV_RECON_SCHAR_PARAM(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    SCHAR_VALUE IN VARCHAR2
  );

  -- Reconcile 3G Bearer Service parameter
  PROCEDURE PROV_RECON_BS3G_PARAM(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    SCHAR_VALUE IN VARCHAR2
  );

  -- Reconcile RSA parameter
  PROCEDURE PROV_RECON_RSA_PARAM(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    RSA_VALUE IN VARCHAR2
  );

  -- Reconcile Customer Service Profile parameter
  PROCEDURE PROV_RECON_CSP_PARAM(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    CSP_VALUE IN VARCHAR2,
    OCSIST_VALUE IN VARCHAR2
  );

  -- Reconcile TS11 parameter
  PROCEDURE PROV_RECON_TS11_PARAM(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    TS11_VALUE IN VARCHAR2
  );

  -- Reconcile APN modification parameter
  PROCEDURE PROV_RECON_APN_MODIFY_PARAM(
    Schema_owner IN VARCHAR2,
    recon_table_name IN VARCHAR2,
    Action IN VARCHAR2,
    HLR IN VARCHAR2
  );

  -- =============================================================================================
  -- UTILITY PROCEDURES
  -- =============================================================================================

  -- Export reconciliation table to CSV file
  PROCEDURE EXPORT_TABLE_TO_CSV_FILE(
    Schema_owner IN VARCHAR2,
    TABLE_NAME IN VARCHAR2
  );

  -- Export reconciliation table to admin text format
  PROCEDURE EXPORT_TABLE_TO_ADM_TXT(
    Schema_owner IN VARCHAR2,
    TABLE_NAME IN VARCHAR2
  );

  -- Send email notification
  PROCEDURE send_mail(
    pSender VARCHAR2,
    pRecipient VARCHAR2,
    pSubject VARCHAR2,
    pMessage VARCHAR2
  );

END RECONCILIATION_INTERFACES;
/
