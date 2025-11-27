-- =============================================================================================
-- THIS FILE CONTAINS THE REMAINING PHASES (3-6) TO BE INSERTED BEFORE "PROCEDURE END LOGGING"
-- INSERT THIS AFTER LINE 1010 (MILESTONE: SV AND CS4 MERGE COMPLETE) in P1_MAIN_SYS_INTERFACES_ENHANCED_WITH_LOGGING.sql
-- =============================================================================================

    -- =============================================================================================
    -- PHASE 3: HLR RECONCILIATION
    -- =============================================================================================

    -- =============================================================================================
    -- STEP 13: CREATE MERGE_HLR1_HLR2_1_TE (LEFT OUTER JOIN)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_MERGE_HLR1_HLR2_1_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Merging HLR1 and HLR2 (LEFT JOIN)',
        p_act_body2 => 'Capturing HLR1-only and matching subscribers',
        p_act_status => 'IN_PROGRESS'
    );

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

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_HLR1_HLR2_1_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.MERGE_HLR1_HLR2_1_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'HLR merge part 1 completed',
        p_act_body2 => 'Rows: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 14: CREATE MERGE_HLR1_HLR2_2_TE (RIGHT OUTER JOIN)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_MERGE_HLR1_HLR2_2_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Merging HLR1 and HLR2 (RIGHT JOIN)',
        p_act_body2 => 'Capturing HLR2-only subscribers',
        p_act_status => 'IN_PROGRESS'
    );

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

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_HLR1_HLR2_2_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.MERGE_HLR1_HLR2_2_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'HLR merge part 2 completed',
        p_act_body2 => 'Rows: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 15: UNION MERGE_HLR1_HLR2_1_TE AND MERGE_HLR1_HLR2_2_TE
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_MERGE_HLR1_HLR2_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Combining HLR merge parts with UNION',
        p_act_body2 => 'Final HLR1/HLR2 reconciliation table',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'CREATE TABLE MERGE_HLR1_HLR2_TE NOLOGGING AS
                select * from MERGE_HLR1_HLR2_1_TE
                union
                SELECT * FROM MERGE_HLR1_HLR2_2_TE';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_HLR1_HLR2_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.MERGE_HLR1_HLR2_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'Complete HLR merge table created',
        p_act_body2 => 'Total merged HLR records: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 16-35: UPDATE NULL VALUES TO 0 (20 UPDATE statements)
    -- =============================================================================================
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'MILESTONE',
        p_act_body => 'NULL_TO_ZERO_UPDATES_START',
        p_act_body1 => 'Updating NULL operational flags to 0',
        p_act_body2 => '20 UPDATE statements for proper comparison logic',
        p_act_status => 'IN_PROGRESS'
    );

    -- UPDATE 1: OBO_1
    v_step_name := 'UPDATE_OBO_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OBO_1 = 0
                  WHERE HH.OBO_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 2: OBI_1
    v_step_name := 'UPDATE_OBI_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                SET HH.OBI_1 = 0
                WHERE HH.OBI_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 3: TICK_1
    v_step_name := 'UPDATE_TICK_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                SET HH.TICK_1 = 0
                WHERE HH.TICK_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 4: OBR_1
    v_step_name := 'UPDATE_OBR_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
              SET HH.OBR_1 = 0
              WHERE HH.OBR_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 5: OICK_1
    v_step_name := 'UPDATE_OICK_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OICK_1 = 0
                  WHERE HH.OICK_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 6: RSA_1
    v_step_name := 'UPDATE_RSA_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.RSA_1 = 0
                  WHERE HH.RSA_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 7: OBO_2
    v_step_name := 'UPDATE_OBO_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OBO_2 = 0
                  WHERE HH.OBO_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 8: OBI_2
    v_step_name := 'UPDATE_OBI_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                SET HH.OBI_2 = 0
                WHERE HH.OBI_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 9: TICK_2
    v_step_name := 'UPDATE_TICK_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                SET HH.TICK_2 = 0
                WHERE HH.TICK_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 10: OBR_2
    v_step_name := 'UPDATE_OBR_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
              SET HH.OBR_2 = 0
              WHERE HH.OBR_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 11: OICK_2
    v_step_name := 'UPDATE_OICK_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OICK_2 = 0
                  WHERE HH.OICK_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 12: RSA_2
    v_step_name := 'UPDATE_RSA_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.RSA_2 = 0
                  WHERE HH.RSA_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 13: OBP_1
    v_step_name := 'UPDATE_OBP_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OBP_1 = 0
                  WHERE HH.OBP_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 14: OBP_2
    v_step_name := 'UPDATE_OBP_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OBP_2 = 0
                  WHERE HH.OBP_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 15-16: RSA_1 and RSA_2 (duplicate for Roaming - as per original)
    v_step_name := 'UPDATE_RSA_1_ROAMING';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.RSA_1 = 0
                  WHERE HH.RSA_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    v_step_name := 'UPDATE_RSA_2_ROAMING';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.RSA_2 = 0
                  WHERE HH.RSA_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 17: OCSIST_1 (Prepaid Roaming)
    v_step_name := 'UPDATE_OCSIST_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OCSIST_1 = 0
                  WHERE HH.OCSIST_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 18: OCSIST_2
    v_step_name := 'UPDATE_OCSIST_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.OCSIST_2 = 0
                  WHERE HH.OCSIST_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 19: TCSIST_1 (Prepaid Roaming)
    v_step_name := 'UPDATE_TCSIST_1_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.TCSIST_1 = 0
                  WHERE HH.TCSIST_1 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- UPDATE 20: TCSIST_2
    v_step_name := 'UPDATE_TCSIST_2_TO_ZERO';
    v_step_start_time := SYSTIMESTAMP;

    SQL_TXT := 'UPDATE MERGE_HLR1_HLR2_TE HH
                  SET HH.TCSIST_2 = 0
                  WHERE HH.TCSIST_2 IS NULL';

    IF UTILS_INTERFACES.UPDATE_TABLE(SQL_TXT) = 0 THEN
        RAISE TABLE_UPDATE_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'UPDATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- Commit all updates
    COMMIT;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'MILESTONE',
        p_act_body => 'NULL_TO_ZERO_UPDATES_COMPLETE',
        p_act_body1 => 'All 20 NULL to zero updates completed successfully',
        p_act_body2 => 'Ready for mismatch report generation',
        p_act_status => 'SUCCESS'
    );
-- =============================================================================================
-- THIS FILE CONTAINS PHASES 4-6 (Final Merge, APN Reports, Export)
-- APPEND THIS AFTER THE NULL-TO-ZERO UPDATES FROM complete_P1_procedure_remaining_phases.sql
-- =============================================================================================

    -- =============================================================================================
    -- STEP 36: CREATE REP_HLRS_MIS_MSISDN_TE (MSISDN Mismatch Report)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_REP_HLRS_MIS_MSISDN_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Creating MSISDN mismatch report',
        p_act_body2 => 'Subscribers in HLR1 XOR HLR2',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'CREATE TABLE REP_HLRS_MIS_MSISDN_TE NOLOGGING AS
              SELECT * FROM MERGE_HLR1_HLR2_TE HH
              WHERE HH.MSISDN_HLR1 IS NULL OR HH.MSISDN_HLR2 IS NULL';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_HLRS_MIS_MSISDN_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.REP_HLRS_MIS_MSISDN_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'MSISDN mismatch report created',
        p_act_body2 => 'Mismatched MSISDNs: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 37: CREATE REP_HLRS_MIS_IMSI_TE (IMSI Mismatch Report - CRITICAL)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_REP_HLRS_MIS_IMSI_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Creating IMSI mismatch report',
        p_act_body2 => 'CRITICAL: Same MSISDN with different IMSI',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'CREATE TABLE REP_HLRS_MIS_IMSI_TE NOLOGGING AS
              SELECT * FROM MERGE_HLR1_HLR2_TE HH
              WHERE HH.MSISDN_HLR1 = HH.MSISDN_HLR2
              AND HH.MSISDN_HLR1 IS NOT NULL
              AND HH.IMSI_1<>HH.IMSI_2';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_HLRS_MIS_IMSI_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.REP_HLRS_MIS_IMSI_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'IMSI mismatch report created',
        p_act_body2 => 'CRITICAL IMSI conflicts: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 38: CREATE CLEAN_HLRS_MERGED_TE (Clean HLR Merge)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_CLEAN_HLRS_MERGED_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Creating clean merged HLR table',
        p_act_body2 => 'Determining primary MSISDN and HLR',
        p_act_status => 'IN_PROGRESS'
    );

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

    IF UTILS_INTERFACES.CREATE_TABLE('CLEAN_HLRS_MERGED_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.CLEAN_HLRS_MERGED_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'Clean HLR merged table created',
        p_act_body2 => 'Total HLR records: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- Create index
    v_step_name := 'CREATE_INDEX_IX_MSISDN_HLR';
    v_step_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('CLEAN_HLRS_MERGED_TE', 'DANAD', 'IX_MSISDN_HLR', 'MSISDN_HLRS') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'INDEX_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- =============================================================================================
    -- PHASE 4: FINAL MERGE & SDP ASSIGNMENT
    -- =============================================================================================
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'MILESTONE',
        p_act_body => 'PHASE_4_START',
        p_act_body1 => 'Starting final merge of all systems',
        p_act_body2 => 'Merging SV, CS4, HLR1, and HLR2',
        p_act_status => 'IN_PROGRESS'
    );

    -- =============================================================================================
    -- STEP 39: MERGE SYS_HLRS (Merge all systems)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_MERGE_SYS_HLRS_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Merging all systems: SV, CS4, HLR1, HLR2',
        p_act_body2 => 'Full outer join for complete view',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'CREATE TABLE MERGE_SYS_HLRS_TE AS
                  SELECT t.*, SUBSTR(tt.IMSI_1,0,6) as prim_flag,TT.*
                  FROM CLEAN_ALL_SYS_MERGED_TE t, CLEAN_HLRS_MERGED_TE TT
                  WHERE T.MSISDN_SYS(+)=TT.MSISDN_HLRS
                  UNION
                  SELECT t.*, SUBSTR(tt.IMSI_1,0,6) as prim_flag ,TT.*
                  FROM CLEAN_ALL_SYS_MERGED_TE t, CLEAN_HLRS_MERGED_TE TT
                  WHERE t.MSISDN_SYS =TT.MSISDN_HLRS(+)';

    IF UTILS_INTERFACES.CREATE_TABLE('MERGE_SYS_HLRS_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.MERGE_SYS_HLRS_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'All systems merged successfully',
        p_act_body2 => 'Total records across all systems: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 40: CREATE REP_CLEAN_ALL_MERGED_TE with SDP Assignment
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_REP_CLEAN_ALL_MERGED_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Creating final reconciliation table',
        p_act_body2 => 'Assigning SDP by MSISDN range + primary HLR',
        p_act_status => 'IN_PROGRESS'
    );

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

    IF UTILS_INTERFACES.CREATE_TABLE('REP_CLEAN_ALL_MERGED_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.REP_CLEAN_ALL_MERGED_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'Final reconciliation table with SDP created',
        p_act_body2 => 'Master reconciliation records: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- Create indexes
    v_step_name := 'CREATE_INDEXES_ON_REP_CLEAN_ALL_MERGED_TE';
    v_step_start_time := SYSTIMESTAMP;

    IF UTILS_INTERFACES.CREATE_INDEX('REP_CLEAN_ALL_MERGED_TE', 'DANAD', 'IX_clean_all_msisdn', 'msisdn') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    IF UTILS_INTERFACES.CREATE_INDEX('REP_CLEAN_ALL_MERGED_TE', 'DANAD', 'IX_PRODUCT_INSTANCE_ID', 'PRODUCT_INSTANCE_ID') = 0 THEN
        RAISE INDEX_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'INDEX_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'Created 2 indexes on final reconciliation table',
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time
    );

    -- =============================================================================================
    -- PHASE 5: APN COMPANION PRODUCT REPORTING
    -- =============================================================================================
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'MILESTONE',
        p_act_body => 'PHASE_5_START',
        p_act_body1 => 'Starting APN companion product reports',
        p_act_body2 => 'Mapping APNs to product names',
        p_act_status => 'IN_PROGRESS'
    );

    -- =============================================================================================
    -- STEP 41: CREATE REP_ADM_DMP_HLR1_TE (HLR1 APN Report)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_REP_ADM_DMP_HLR1_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Creating HLR1 companion product report',
        p_act_body2 => 'Mapping APN_ID to product names',
        p_act_status => 'IN_PROGRESS'
    );

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

    IF UTILS_INTERFACES.CREATE_TABLE('REP_ADM_DMP_HLR1_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.REP_ADM_DMP_HLR1_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'HLR1 companion product report created',
        p_act_body2 => 'HLR1 primary records: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 42: CREATE REP_ADM_DMP_HLR2_TE (HLR2 APN Report)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_REP_ADM_DMP_HLR2_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Creating HLR2 companion product report',
        p_act_status => 'IN_PROGRESS'
    );

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

    IF UTILS_INTERFACES.CREATE_TABLE('REP_ADM_DMP_HLR2_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.REP_ADM_DMP_HLR2_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'HLR2 companion product report created',
        p_act_body2 => 'HLR2 primary records: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 43: CREATE UNION_APNS_TE (Combine HLR1 and HLR2 APNs)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_UNION_APNS_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Combining HLR1 and HLR2 APN reports',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'CREATE TABLE UNION_APNS_TE NOLOGGING AS
                      SELECT ss.* FROM REP_ADM_DMP_HLR1_TE ss
                      UNION
                      SELECT vv.* FROM REP_ADM_DMP_HLR2_TE vv';

    IF UTILS_INTERFACES.CREATE_TABLE('UNION_APNS_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.UNION_APNS_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'Combined APN table created',
        p_act_body2 => 'Total APN records: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 44: CREATE REP_APN_SYS_ALL_TE (Merge APNs with SV)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_REP_APN_SYS_ALL_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Merging APNs with SV service data',
        p_act_body2 => 'Excluding cancelled services',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'CREATE TABLE REP_APN_SYS_ALL_TE NOLOGGING AS
                SELECT AA.MSISDN, AA.IMSI, AA.COMPANION_PRODUCT, AA.SERVICE_TYPE_NAME FROM UNION_APNS_TE AA
                UNION
                SELECT MM.MSISDN, MM.IMSI, NULL, MM.SERVICE_TYPE_NAME FROM REP_CLEAN_ALL_MERGED_TE MM
                WHERE mm.service_status <> ''Cancelled''';

    IF UTILS_INTERFACES.CREATE_TABLE('REP_APN_SYS_ALL_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.REP_APN_SYS_ALL_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'APN-SV merged report created',
        p_act_body2 => 'Records before dedup: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- PHASE 6: DUPLICATE ELIMINATION AND EXPORT
    -- =============================================================================================
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'MILESTONE',
        p_act_body => 'PHASE_6_START',
        p_act_body1 => 'Starting duplicate elimination',
        p_act_body2 => 'Preparing final export',
        p_act_status => 'IN_PROGRESS'
    );

    -- =============================================================================================
    -- STEP 45: CREATE LIST_NULL_CP_GROUP_TE (Find duplicates)
    -- =============================================================================================
    v_step_name := 'CREATE_TABLE_LIST_NULL_CP_GROUP_TE';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Identifying duplicate MSISDN records',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'CREATE TABLE list_null_cp_group_TE NOLOGGING AS
                  SELECT t.msisdn, COUNT (t.msisdn) AS count_NUM FROM rep_apn_sys_all_TE t
                  GROUP BY t.msisdn
                  HAVING COUNT (t.msisdn) >1';

    IF UTILS_INTERFACES.CREATE_TABLE('list_null_cp_group_TE', 'DANAD', SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'TABLE_CREATE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_CREATION_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    SELECT COUNT(*) INTO v_affected_rows FROM DANAD.list_null_cp_group_TE;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'TABLE_CREATE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'Duplicate MSISDN list created',
        p_act_body2 => 'MSISDNs with duplicates: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 46: DELETE Duplicates (Keep records WITH companion_product)
    -- =============================================================================================
    v_step_name := 'DELETE_DUPLICATE_NULL_COMPANION_PRODUCTS';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'DELETE_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Removing duplicates with NULL companion_product',
        p_act_body2 => 'Keeping records WITH companion_product',
        p_act_status => 'IN_PROGRESS'
    );

    SQL_TXT := 'DELETE FROM REP_APN_SYS_ALL_TE T
                    WHERE T.MSISDN IN (SELECT V.MSISDN FROM LIST_NULL_CP_GROUP_TE V)
                    AND T.COMPANION_PRODUCT IS NULL';

    IF UTILS_INTERFACES.DELETE_TABLE (SQL_TXT) = 0 THEN
        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'DELETE_FAILED',
            p_act_body => v_step_name,
            p_act_status => 'FAILED',
            p_act_exec_time => v_execution_time,
            p_ora_error => SQLERRM
        );
        RAISE TABLE_INSERT_FAILED;
    END IF;

    v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
    v_affected_rows := SQL%ROWCOUNT;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'DELETE_SUCCESS',
        p_act_body => v_step_name,
        p_act_body1 => 'Duplicate records removed successfully',
        p_act_body2 => 'Records deleted: ' || v_affected_rows,
        p_act_status => 'SUCCESS',
        p_act_exec_time => v_execution_time,
        p_affected_rows => v_affected_rows
    );

    -- =============================================================================================
    -- STEP 47: EXPORT FINAL REPORT
    -- =============================================================================================
    v_step_name := 'EXPORT_FINAL_RECONCILIATION_REPORT';
    v_step_start_time := SYSTIMESTAMP;

    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'EXPORT_START',
        p_act_body => v_step_name,
        p_act_body1 => 'Exporting REP_APN_SYS_ALL_TE to CSV',
        p_act_body2 => 'Format: reconciliation_DDMMYYYY.csv',
        p_act_status => 'IN_PROGRESS'
    );

    BEGIN
        fafif.reconciliation_interfaces.EXPORT_TABLE_TO_ADM_TXT ('FAFIF','REP_APN_SYS_ALL_TE');

        CURRENT_DATE := TO_CHAR(TO_DATE(TO_CHAR(SYSDATE, 'DDMMYYYY'),'DDMMYYYY') ,'DDMMYYYY');

        v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));

        LOG_ACTIVITY_TRACE(
            p_interface_id => INTEGRATION_LOG_ID,
            p_interface_name => 'P1_MAIN_SYS_INTERFACES',
            p_act_type => 'EXPORT_SUCCESS',
            p_act_body => v_step_name,
            p_act_body1 => 'Export completed successfully',
            p_act_body2 => 'File: reconciliation_' || CURRENT_DATE || '.csv',
            p_act_status => 'SUCCESS',
            p_act_exec_time => v_execution_time
        );
    EXCEPTION
        WHEN OTHERS THEN
            v_execution_time := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_step_start_time));
            LOG_ACTIVITY_TRACE(
                p_interface_id => INTEGRATION_LOG_ID,
                p_interface_name => 'P1_MAIN_SYS_INTERFACES',
                p_act_type => 'EXPORT_FAILED',
                p_act_body => v_step_name,
                p_act_body1 => 'Export failed but continuing',
                p_act_status => 'WARNING',
                p_act_exec_time => v_execution_time,
                p_ora_error => SQLERRM
            );
    END;

    -- =============================================================================================
    -- FINAL MILESTONE: ALL PHASES COMPLETE
    -- =============================================================================================
    LOG_ACTIVITY_TRACE(
        p_interface_id => INTEGRATION_LOG_ID,
        p_interface_name => 'P1_MAIN_SYS_INTERFACES',
        p_act_type => 'MILESTONE',
        p_act_body => 'ALL_PHASES_COMPLETE',
        p_act_body1 => 'All 6 phases completed successfully',
        p_act_body2 => 'Full reconciliation pipeline executed',
        p_act_status => 'SUCCESS'
    );
