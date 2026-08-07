// MoonBit IEC 104 - Protocol Constants and Enumerations

///|
pub const START_BYTE : Byte = b'\x68'

///|
pub const MIN_APDU_LEN : Int = 6

///|
pub const MAX_APDU_LEN : Int = 255

// Type Identifiers (ASDU Types)

///|
pub const TYPE_M_SP_NA_1 : Byte = b'\x01' // Single-point information without time tag

///|
pub const TYPE_M_SP_TA_1 : Byte = b'\x02' // Single-point information with CP24 time tag

///|
pub const TYPE_M_DP_NA_1 : Byte = b'\x03' // Double-point information without time tag

///|
pub const TYPE_M_DP_TA_1 : Byte = b'\x04' // Double-point information with CP24 time tag

///|
pub const TYPE_M_ST_NA_1 : Byte = b'\x05' // Step position information without time tag

///|
pub const TYPE_M_ST_TA_1 : Byte = b'\x06' // Step position information with CP24 time tag

///|
pub const TYPE_M_BO_NA_1 : Byte = b'\x07' // Bitstring of 32 bit without time tag

///|
pub const TYPE_M_ME_NA_1 : Byte = b'\x09' // Measured value, normalized value without time tag

///|
pub const TYPE_M_ME_TA_1 : Byte = b'\x0A' // Measured value, normalized value with CP24 time tag

///|
pub const TYPE_M_ME_NB_1 : Byte = b'\x0B' // Measured value, scaled value without time tag

///|
pub const TYPE_M_ME_TB_1 : Byte = b'\x0C' // Measured value, scaled value with CP24 time tag

///|
pub const TYPE_M_ME_NC_1 : Byte = b'\x0D' // Measured value, short floating point without time tag

///|
pub const TYPE_M_ME_TC_1 : Byte = b'\x0E' // Measured value, short floating point with CP24 time tag

///|
pub const TYPE_M_IT_NA_1 : Byte = b'\x0F' // Integrated totals (energy counter) without time tag

///|
pub const TYPE_M_IT_TA_1 : Byte = b'\x10' // Integrated totals with CP24 time tag

///|
pub const TYPE_M_SP_TB_1 : Byte = b'\x1E' // Single-point information with CP56Time2a time tag

///|
pub const TYPE_M_DP_TB_1 : Byte = b'\x1F' // Double-point information with CP56Time2a time tag

///|
pub const TYPE_M_ST_TB_1 : Byte = b'\x20' // Step position information with CP56Time2a time tag

///|
pub const TYPE_M_ME_TD_1 : Byte = b'\x22' // Measured value, normalized with CP56Time2a time tag

///|
pub const TYPE_M_ME_TE_1 : Byte = b'\x23' // Measured value, scaled with CP56Time2a time tag

///|
pub const TYPE_M_ME_TF_1 : Byte = b'\x24' // Measured value, short float with CP56Time2a time tag

///|
pub const TYPE_M_IT_TB_1 : Byte = b'\x25' // Integrated totals with CP56Time2a time tag

///|
pub const TYPE_C_SC_NA_1 : Byte = b'\x2D' // Single command

///|
pub const TYPE_C_DC_NA_1 : Byte = b'\x2E' // Double command

///|
pub const TYPE_C_RC_NA_1 : Byte = b'\x2F' // Regulating step command

///|
pub const TYPE_C_SE_NA_1 : Byte = b'\x30' // Set-point command, normalized value

///|
pub const TYPE_C_SE_NB_1 : Byte = b'\x31' // Set-point command, scaled value

///|
pub const TYPE_C_SE_NC_1 : Byte = b'\x32' // Set-point command, short floating point

///|
pub const TYPE_C_IC_NA_1 : Byte = b'\x64' // Interrogation command (General Interrogation GI)

///|
pub const TYPE_C_CI_NA_1 : Byte = b'\x65' // Counter interrogation command

///|
pub const TYPE_C_RD_NA_1 : Byte = b'\x66' // Read command

///|
pub const TYPE_C_CS_NA_1 : Byte = b'\x67' // Clock synchronization command

///|
pub const TYPE_C_TS_NA_1 : Byte = b'\x68' // Test command

///|
pub const TYPE_C_RP_NA_1 : Byte = b'\x69' // Reset process command

// Cause of Transmission (COT)

///|
pub const COT_PERIODIC : Int = 1 // Periodic, cyclic

///|
pub const COT_BACKGROUND : Int = 2 // Background scan

///|
pub const COT_SPONTANEOUS : Int = 3 // Spontaneous (event driven)

///|
pub const COT_INITIALIZED : Int = 4 // Initialized

///|
pub const COT_REQUEST : Int = 5 // Request or requested

///|
pub const COT_ACTIVATION : Int = 6 // Activation (command sent by Master)

///|
pub const COT_ACTIVATION_CON : Int = 7 // Activation confirmation (Slave ack)

///|
pub const COT_DEACTIVATION : Int = 8 // Deactivation

///|
pub const COT_DEACTIVATION_CON : Int = 9 // Deactivation confirmation

///|
pub const COT_ACTIVATION_TERMINATED : Int = 10 // Activation termination

///|
pub const COT_RETURN_INFO_REMOTE : Int = 11 // Return information caused by remote command

///|
pub const COT_RETURN_INFO_LOCAL : Int = 12 // Return information caused by local command

///|
pub const COT_INTERROGATED_STATION : Int = 20 // Interrogated by station GI

///|
pub const COT_INTERROGATED_GROUP_1 : Int = 21 // Interrogated by group 1 GI

///|
pub const COT_UNKNOWN_TYPE_ID : Int = 44 // Unknown type identification

///|
pub const COT_UNKNOWN_COT : Int = 45 // Unknown cause of transmission

///|
pub const COT_UNKNOWN_CASDU : Int = 46 // Unknown common address of ASDU

///|
pub const COT_UNKNOWN_IOA : Int = 47 // Unknown information object address

// Qualifier of Interrogation (QOI)

///|
pub const QOI_STATION_GI : Byte = b'\x14' // Global station general interrogation (20)

// Qualifier of Counter Interrogation (QCC)

///|
pub const QCC_GENERAL_RESET : Byte = b'\x05'
