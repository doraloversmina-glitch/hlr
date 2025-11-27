# P1_MAIN_SYS_INTERFACES - BUSINESS LOGIC EXPLANATION

## 🎯 **WHAT IS THIS PROCEDURE?**

**P1_MAIN_SYS_INTERFACES** is an **HLR (Home Location Register) Reconciliation** procedure for a telecom operator. It reconciles data between multiple critical systems to identify discrepancies in subscriber information.

---

## 🏗️ **HIGH-LEVEL PURPOSE**

**Goal:** Ensure data consistency across 4 core telecom systems:
1. **HLR1** - Primary Home Location Register (subscriber network data)
2. **HLR2** - Secondary/Backup Home Location Register
3. **SV (Subscriber Vision)** - Billing/Customer Management System
4. **CS4/MINSAT** - Provisioning System

**Why needed?**
In telecom networks, subscriber data gets replicated across multiple systems. This procedure finds where they don't match (e.g., subscriber exists in HLR but not in billing, wrong IMSI, missing services).

---

## 📊 **THE 4 SOURCE SYSTEMS**

### **System 1: HLR1 & HLR2** (Network Layer)
- **What:** Home Location Registers store subscriber network profiles
- **Data includes:**
  - MSISDN (phone number)
  - IMSI (subscriber identity on SIM card)
  - Telecom services (call forwarding, roaming, data APNs)
  - 100+ network parameters (CFU, CFB, CLIP, CLIR, etc.)

### **System 2: SV (Subscriber Vision)** (Billing Layer)
- **What:** Customer Relationship Management / Billing system
- **Data includes:**
  - Service status (Active, Suspended, Cancelled)
  - Product instances (what services customer subscribes to)
  - Customer account information
  - Service start/end dates

### **System 3: CS4/MINSAT** (Provisioning Layer)
- **What:** Prepaid platform provisioning system (PPS_ABONNE_JOUR_MIGDB)
- **Data includes:**
  - Subscriber state (active, suspended)
  - Balance information
  - Validity dates
  - Customer class

### **System 4: Companion Products (APNs)**
- **What:** Data Access Point Names for internet/data services
- **APN Types:**
  - WLL (Wireless Local Loop)
  - Mobile Broadband (MBB)
  - Blackberry APN
  - GPRS, WAP, MMS
  - VoLTE (Voice over LTE)
  - Data cards

---

## 🔄 **WHAT THE PROCEDURE DOES - STEP BY STEP**

### **PHASE 1: DATA EXTRACTION & NORMALIZATION** (Steps 1-7)

#### **Step 1: Extract CS4/MINSAT Data**
```
Creates: SYS_MINSAT_TE
Source: FAFIF.PPS_ABONNE_JOUR_MIGDB
```
- Extracts prepaid subscriber data
- **Normalizes MSISDN** (phone numbers) to standard format
  - Removes country code (first 3 digits)
  - Adds leading zero if needed
  - Example: "96171234567" → "71234567" or "071234567"

#### **Step 2-4: Extract HLR1 Data**
```
Creates: HLR1_APN_DATA_TE, HLR1_PARAM_TE, MERGE_HLR1_APN_TE
Source: FAFIF.HLR1
```
- **HLR1_APN_DATA_TE**: Groups APNs by subscriber
  - One subscriber can have multiple APNs (data services)
  - Uses MAX(DECODE) to pivot APN_IDs into columns
  - Result: One row per MSISDN with 14 APN indicator columns

- **HLR1_PARAM_TE**: All subscriber parameters
  - 100+ service flags per subscriber
  - Call forwarding settings
  - Roaming permissions
  - 3G/4G/VoLTE capabilities

- **MERGE_HLR1_APN_TE**: Combines APNs + Parameters
  - Full outer join to catch all subscribers
  - Even if subscriber missing in one table

#### **Step 5-7: Extract HLR2 Data**
```
Creates: HLR2_APN_DATA_TE, HLR2_PARAM_TE, MERGE_HLR2_APN_TE
Source: FAFIF.HLR2
```
- Same process as HLR1
- HLR2 is the backup/secondary HLR node

---

### **PHASE 2: SV & CS4 INTEGRATION** (Steps 8-11)

#### **Step 8-9: Filter Mobile Broadband**
```
Creates: REP_SV_MSISDN_IN_MISP_TE, REP_SV_MSISDN_NOT_MISP_TE
Source: FAFIF.CLEAN_SV_ALL_UPD
```
- Separates Mobile Broadband Prepaid subscribers
- MISP = Mobile Internet Service Provider
- Rate plans 31,33,30,34,32,35,36,37,38,59

#### **Step 10-11: Merge SV with CS4**
```
Creates: MERGE_SYS_SV_CS4_TE → CLEAN_ALL_SYS_MERGED_TE
```
- **Full outer join** SV ⟷ CS4
- Finds:
  - Subscribers in SV but not CS4
  - Subscribers in CS4 but not SV
  - Matching subscribers
- Creates unified MSISDN_SYS field

**Indexes created for performance:**
- MSISDN_SV (for SV lookups)
- MSISDN_CS4 (for CS4 lookups)
- PRODUCT_INSTANCE_ID (for product lookups)
- SERV_BP_INT (for service lookups)

---

### **PHASE 3: HLR RECONCILIATION** (Steps 12-17)

#### **Step 12-14: Merge HLR1 ⟷ HLR2**
```
Creates: MERGE_HLR1_HLR2_1_TE, MERGE_HLR1_HLR2_2_TE → MERGE_HLR1_HLR2_TE
```
- **Two-way merge:**
  1. HLR1 LEFT JOIN HLR2 (catches HLR1-only subscribers)
  2. HLR1 RIGHT JOIN HLR2 (catches HLR2-only subscribers)
  3. UNION combines both

- **Result columns:**
  - All HLR1 fields (suffix _1)
  - All HLR2 fields (suffix _2)
  - Side-by-side comparison

#### **Step 15-20: NULL Handling**
```
Updates: 20 UPDATE statements
```
- **Problem:** Oracle can't compare NULL = NULL
- **Solution:** Convert NULL → 0 for numeric fields
- **Fields updated:**
  - Barring parameters: OBO, OBI, OBR, OICK, TICK
  - Roaming: RSA, OBP
  - Prepaid roaming: OCSIST, TCSIST

**Why important?**
So we can later detect REAL differences:
- `OBO_1 = 0 AND OBO_2 = 1` → Mismatch!
- `OBO_1 = NULL AND OBO_2 = NULL` → Would fail comparison

#### **Step 21-22: Identify HLR Mismatches**
```
Creates: REP_HLRS_MIS_MSISDN_TE, REP_HLRS_MIS_IMSI_TE
```
- **REP_HLRS_MIS_MSISDN_TE**: MSISDN exists in HLR1 XOR HLR2
- **REP_HLRS_MIS_IMSI_TE**: Same MSISDN but different IMSI
  - ⚠️ Critical issue! Subscriber has different SIM cards in 2 HLRs

#### **Step 23: Clean HLR Data**
```
Creates: CLEAN_HLRS_MERGED_TE
```
- Filters out test subscribers (commented out: IMSI prefix 415018)
- Determines primary MSISDN (prefer HLR2 if both exist)
- Identifies primary HLR (based on IMSI prefix):
  - 415012 or 415019 → HLR1 is primary
  - Other → HLR2 is primary

---

### **PHASE 4: FINAL MERGE & SDP ASSIGNMENT** (Steps 24-25)

#### **Step 24: Merge SYS ⟷ HLRs**
```
Creates: MERGE_SYS_HLRS_TE
```
- Merges CLEAN_ALL_SYS_MERGED_TE (SV+CS4) with CLEAN_HLRS_MERGED_TE (HLRs)
- Full outer join catches all scenarios:
  - Subscriber in billing but not HLR
  - Subscriber in HLR but not billing
  - Subscriber in all systems

#### **Step 25: Assign SDP (Service Delivery Platform)**
```
Creates: REP_CLEAN_ALL_MERGED_TE
```
- **SDP assignment by MSISDN range:**

| MSISDN Range | SDP Node |
|--------------|----------|
| 71900000-71999999 | SDP05 |
| 71800000-71899999 | SDP06 |
| 3000000-3999999 | SDP03 |
| 70000000-70999999 | SDP04 |
| 71000000-71099999 | SDP04 |
| 76100000-76199999 | SDP05 |
| 71600000-71699999 | SDP04 |
| 71700000-71799999 | SDP05 |
| 76300000-76399999 | SDP05 |
| 76400000-76499999 | SDP06 |
| 76500000-76599999 | SDP05 |
| 79100000-79199999 | SDP06 |
| 79300000-79324999 | SDP06 |
| 1000000-1999999 | SDP06 |
| 81000000-81999999 | SDP05 |

**Why important?**
Different SDP nodes handle different MSISDN ranges. Reconciliation reports need to be routed to correct SDP team.

---

### **PHASE 5: APN COMPANION PRODUCT REPORTING** (Steps 26-31)

#### **Step 26-27: Extract Companion Products per HLR**
```
Creates: REP_ADM_DMP_HLR1_TE, REP_ADM_DMP_HLR2_TE
```
- Identifies active data companion products
- Maps APN_ID to product name:
  - 20 → Mobile Internet WLL
  - 15 → Alfa APN
  - 13 → Mobile Broadband
  - 12 → Blackberry
  - 10 → GPRS INTRA
  - 9 → MMS
  - 8 → WAP
  - 7 → GPRS
  - 3,4,6 → Data Card
  - 94,95 → VoLTE

#### **Step 28-29: Union & Merge APNs**
```
Creates: UNION_APNS_TE → REP_APN_SYS_ALL_TE
```
- Combines HLR1 + HLR2 APN data
- Merges with SV service type
- Includes non-cancelled services only

#### **Step 30-31: Remove Duplicate APNs**
```
Creates: LIST_NULL_CP_GROUP_TE
Deletes: Duplicates from REP_APN_SYS_ALL_TE
```
- Finds MSISDNs with multiple APN records
- Keeps record WITH companion_product
- Deletes record with NULL companion_product

---

### **PHASE 6: EXPORT** (Step 32)

#### **Step 32: Export Final Report**
```
Calls: EXPORT_TABLE_TO_ADM_TXT
Output: reconciliation_DDMMYYYY.csv
```
- Exports REP_APN_SYS_ALL_TE to CSV
- Contains: MSISDN, IMSI, Companion Product, Service Type
- Used by operations team for reconciliation actions

---

## 🎯 **WHAT PROBLEMS DOES THIS SOLVE?**

### **Problem 1: Ghost Subscribers**
**Scenario:** Subscriber in HLR but not in billing
**Impact:** Network resources allocated but no revenue
**Solution:** Report identifies them → Operations can deactivate

### **Problem 2: Billing Without Service**
**Scenario:** Active billing but no HLR profile
**Impact:** Customer charged but can't make calls
**Solution:** Report identifies them → Reprovisioning needed

### **Problem 3: IMSI Mismatch**
**Scenario:** Same MSISDN has different IMSI in HLR1 vs HLR2
**Impact:** Call routing failures, roaming issues
**Solution:** REP_HLRS_MIS_IMSI_TE report → Manual correction

### **Problem 4: Missing Data Services**
**Scenario:** Customer subscribed to Mobile Broadband in billing, but no APN in HLR
**Impact:** Customer can't access internet despite paying
**Solution:** Report shows missing APNs → Operations adds them

### **Problem 5: SDP Routing**
**Scenario:** Subscriber data on wrong SDP node
**Impact:** Performance degradation, incorrect routing
**Solution:** SDP assignment in report → Migration planning

---

## 📋 **OUTPUT REPORTS GENERATED**

| Report Table | Purpose | Key Findings |
|--------------|---------|---------------|
| **REP_HLRS_MIS_MSISDN_TE** | MSISDN exists in only HLR1 or HLR2 | Sync issues |
| **REP_HLRS_MIS_IMSI_TE** | IMSI mismatch between HLRs | Critical SIM conflicts |
| **CLEAN_HLRS_MERGED_TE** | Full HLR1+HLR2 reconciliation | Complete HLR view |
| **REP_CLEAN_ALL_MERGED_TE** | Master reconciliation (all systems) | Full system view |
| **REP_APN_SYS_ALL_TE** | Companion products per subscriber | Data service audit |

**Final Export:** `reconciliation_DDMMYYYY.csv`

---

## 🔢 **DATA VOLUMES (Typical)**

- **SYS_MINSAT_TE**: ~2-5 million prepaid subscribers
- **HLR1_PARAM_TE**: ~8-12 million subscribers
- **HLR2_PARAM_TE**: ~8-12 million subscribers
- **MERGE_SYS_SV_CS4_TE**: ~10-15 million records
- **REP_CLEAN_ALL_MERGED_TE**: ~15-20 million records
- **Final export**: ~10-15 million active subscribers

**Processing time:** 30-90 minutes depending on hardware

---

## ⏱️ **WHEN DOES THIS RUN?**

**Typical schedule:**
- **Daily:** After midnight dumps complete
- **Prerequisites:**
  1. HLR1 dump loaded (FAFIF.HLR1)
  2. HLR2 dump loaded (FAFIF.HLR2)
  3. SV extract loaded (FAFIF.CLEAN_SV_ALL_UPD)
  4. CS4 dump loaded (FAFIF.PPS_ABONNE_JOUR_MIGDB)

---

## 🛠️ **KEY TECHNICAL DECISIONS**

### **1. Full Outer Joins (UNION Pattern)**
```sql
SELECT ... FROM T1, T2 WHERE T1.id (+)= T2.id
UNION
SELECT ... FROM T1, T2 WHERE T1.id = T2.id (+)
```
**Why?** Captures ALL records from both sides (no data loss)

### **2. NOLOGGING on Temp Tables**
```sql
CREATE TABLE ... NOLOGGING AS
```
**Why?** Faster creation, we don't need redo logs for temp data

### **3. MAX(DECODE) for APN Pivoting**
```sql
max( decode( APN_ID, '20', APN_ID, null ) ) AS WLL_APN1
```
**Why?** Converts multiple APN rows into single row with columns

### **4. MSISDN Normalization**
```sql
DECODE(SUBSTR(SUBSTR(NUM_APPEL, 4), 1, 1),
       8, SUBSTR(NUM_APPEL, 4),
       7, SUBSTR(NUM_APPEL, 4),
       3, '0' || SUBSTR(NUM_APPEL, 4),
       1, '0' || SUBSTR(NUM_APPEL, 4))
```
**Why?** Handles inconsistent MSISDN formats across systems

### **5. NULL → 0 Updates**
**Why?** Enable proper comparison logic (NULL ≠ NULL in SQL)

---

## 🎓 **BUSINESS VALUE**

1. **Revenue Protection:** Identifies ghost subscribers draining network
2. **Customer Satisfaction:** Finds service provisioning issues
3. **Network Efficiency:** Identifies orphaned HLR profiles
4. **Audit Compliance:** Proves data consistency across systems
5. **Operations Efficiency:** Automated daily reconciliation (vs manual)

**Estimated value:** Prevents millions in revenue leakage per year

---

## 🚀 **SUMMARY**

**In one sentence:**
This procedure reconciles 4 telecom systems (HLR1, HLR2, Billing, Provisioning) to identify mismatches in subscriber data, companion products (APNs), and service parameters, then exports a daily report for operational action.

**Think of it as:**
A massive "data diff tool" that compares 10+ million subscriber records across 4 databases to find what doesn't match.
