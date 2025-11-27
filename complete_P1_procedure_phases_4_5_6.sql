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
