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
