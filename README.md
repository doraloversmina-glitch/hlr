# HLR Reconciliation System

## Overview
This is an Oracle PL/SQL based Home Location Register (HLR) Reconciliation System for telecommunications operators. The system handles data reconciliation between various telecom network elements and billing systems.

## Purpose
The HLR Reconciliation Interfaces package manages subscriber data synchronization across multiple systems, ensuring consistency for:
- Subscriber provisioning
- Service activation/deactivation
- Billing reconciliation
- Network service management

## Key Components

### Main Interfaces
- **P1_MAIN_SYS_INTERFACES**: Primary system interface handler
- **P1_CALL_COMPLETION_INTERFACES**: Call completion reconciliation
- **P1_HLR_RECON_MONTH_INTERFACES**: Monthly HLR reconciliation

### Service-Specific Interfaces

#### Prepaid & Postpaid Services
- **P2_POST_PREP_SERV_INTERFACES**: Postpaid/Prepaid service reconciliation
- **P2_POST_SUSP_SERV_INTERFACES**: Suspended service reconciliation
- **P3_PREP_INTERFACES**: Prepaid interfaces

#### Content Provider (CP) Interfaces
- **P4_CP_INTERFACES**: Standard CP reconciliation
- **P4_WLL_CP_INTERFACES**: Wireless Local Loop CP reconciliation
- **P_IA_CP_INTERFACES**: IA (Interactive Applications) CP reconciliation
- **P_MTROAMING_CP_INTERFACES**: MT Roaming CP reconciliation
- **P5_ALFA_CP_INTERFACES**: ALFA CP reconciliation

#### Advanced Services
- **P6_VOLTE_INTERFACES**: VoLTE (Voice over LTE) reconciliation
- **P7_DATACARD_INTERFACES**: Data card service reconciliation

### Provisioning Reconciliation Procedures
- **prov_recon_services**: Service provisioning reconciliation
- **prov_recon_services_cps**: CP service provisioning reconciliation
- **prov_recon_VPN_cps**: VPN service reconciliation
- **PROV_RECON_SMS_CPS**: SMS service reconciliation
- **PROV_RECON_SMS_ROAMING_CPS**: SMS roaming reconciliation
- **PROV_RECON_ROAMING_CPS**: Roaming service reconciliation
- **PROV_RECON_MT_ROAMING_CPS**: MT roaming reconciliation
- **PROV_RECON_VOLTE_CPS**: VoLTE CP reconciliation

### Parameter Management
- **PROV_RECON_SCHAR_PARAM**: Service Characteristics parameter reconciliation
- **PROV_RECON_BS3G_PARAM**: 3G Bearer Service parameter reconciliation
- **PROV_RECON_RSA_PARAM**: RSA parameter reconciliation
- **PROV_RECON_CSP_PARAM**: Customer Service Profile parameter reconciliation
- **PROV_RECON_TS11_PARAM**: TS11 parameter reconciliation
- **PROV_RECON_APN_MODIFY_PARAM**: APN modification parameter reconciliation

### Utility Procedures
- **EXPORT_TABLE_TO_CSV_FILE**: Export reconciliation data to CSV
- **EXPORT_TABLE_TO_ADM_TXT**: Export reconciliation data to admin text format
- **send_mail**: Email notification utility

## Technical Details

### Exception Handling
The package includes comprehensive exception handling for:
- Application errors
- Data conversion errors
- Backup failures
- Table operation failures
- Entity validation errors
- Transient and permanent errors

### Counters & Metrics
- Insert count (CNTINS)
- Update count (CNTUPD)
- Delete count (CNTDEL)
- Level-based counters (LEVEL3-6)

## Version Information
- **Release**: R1.2
- **Modified by**: FA
- **Date**: 07/07/2007

## Usage
All procedures follow a standard signature:
```sql
PROCEDURE_NAME(
  INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
  RESULT OUT VARCHAR2,
  P_ENT_TYPE IN NUMBER DEFAULT 4,
  P_ENT_CODE IN NUMBER DEFAULT 1
)
```

## License
[Add license information]

## Contributors
[Add contributor information]
