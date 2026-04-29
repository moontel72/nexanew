//! Hierarchical Code Generator
//!
//! This module provides functionality for generating codes in a hierarchical structure:
//! Bundle -> Carton -> Packet -> Unit
//!
//! This allows generating complete packaging hierarchies in a single operation.

use crate::models::{
    BundleCode, CartonCode, PacketCode, UnitCode, HierarchicalCodes, HierarchySummary,
    CodeGenerationResponse, NexaTraceError,
};
use crate::generators::{bundle, carton, packet, unit};
use uuid::Uuid;

/// Generate hierarchical codes
pub fn generate_hierarchical(
    bundle_prefix: String,
    carton_prefix: String,
    packet_prefix: String,
    unit_prefix: String,
    bundle_count: u32,
    cartons_per_bundle: u32,
    packets_per_carton: u32,
    units_per_packet: u32,
    factory_id: String,
) -> Result<HierarchicalCodes, NexaTraceError> {
    // Validate inputs
    validate_hierarchical_inputs(
        &bundle_prefix,
        &carton_prefix,
        &packet_prefix,
        &unit_prefix,
        bundle_count,
        cartons_per_bundle,
        packets_per_carton,
        units_per_packet,
        &factory_id,
    )?;

    let mut bundles = Vec::with_capacity(bundle_count as usize);
    let mut all_cartons = Vec::new();
    let mut all_packets = Vec::new();
    let mut all_units = Vec::new();

    // Generate bundles
    for bundle_index in 0..bundle_count {
        let bundle_sequence = bundle_index + 1;
        let bundle_code = bundle::generate_single_code(
            bundle_prefix.clone(),
            bundle_sequence,
            factory_id.clone(),
        )?;

        // Generate cartons for this bundle
        let mut carton_codes = Vec::with_capacity(cartons_per_bundle as usize);
        let mut bundle_cartons = Vec::with_capacity(cartons_per_bundle as usize);

        for carton_index in 0..cartons_per_bundle {
            let carton_sequence = carton_index + 1;
            let carton_code = carton::generate_single_code(
                carton_prefix.clone(),
                carton_sequence,
                bundle_code.clone(),
                factory_id.clone(),
            )?;

            carton_codes.push(carton_code.clone());

            // Generate packets for this carton
            let mut packet_codes = Vec::with_capacity(packets_per_carton as usize);
            let mut carton_packets = Vec::with_capacity(packets_per_carton as usize);

            for packet_index in 0..packets_per_carton {
                let packet_sequence = packet_index + 1;
                let packet_code = packet::generate_single_code(
                    packet_prefix.clone(),
                    packet_sequence,
                    carton_code.clone(),
                    factory_id.clone(),
                )?;

                packet_codes.push(packet_code.clone());

                // Generate units for this packet
                let mut unit_codes = Vec::with_capacity(units_per_packet as usize);
                let mut packet_units = Vec::with_capacity(units_per_packet as usize);

                for unit_index in 0..units_per_packet {
                    let unit_sequence = unit_index + 1;
                    let unit_code = unit::generate_single_code(
                        unit_prefix.clone(),
                        unit_sequence,
                        packet_code.clone(),
                        factory_id.clone(),
                    )?;

                    unit_codes.push(unit_code.clone());

                    // Generate authentication code for unit
                    let auth_code = crate::algorithms::authentication::generate_secure_code(16)
                        .map_err(|e| NexaTraceError::GenerationError(e.to_string()))?;

                    let serial_number = generate_serial_number(&unit_code, unit_sequence);

                    let unit = UnitCode {
                        code: unit_code,
                        sequence: unit_sequence,
                        packet_code: packet_code.clone(),
                        authentication_code: auth_code,
                        serial_number,
                    };

                    packet_units.push(unit);
                }

                all_units.extend(packet_units.clone());

                let packet = PacketCode {
                    code: packet_code,
                    sequence: packet_sequence,
                    carton_code: carton_code.clone(),
                    unit_codes,
                    total_units: units_per_packet,
                };

                carton_packets.push(packet);
            }

            all_packets.extend(carton_packets.clone());

            let carton = CartonCode {
                code: carton_code,
                sequence: carton_sequence,
                bundle_code: bundle_code.clone(),
                packet_codes,
                total_packets: packets_per_carton,
                total_units: packets_per_carton * units_per_packet,
            };

            bundle_cartons.push(carton);
        }

        all_cartons.extend(bundle_cartons.clone());

        let bundle = BundleCode {
            code: bundle_code,
            sequence: bundle_sequence,
            carton_codes,
            total_cartons: cartons_per_bundle,
            total_packets: cartons_per_bundle * packets_per_carton,
            total_units: cartons_per_bundle * packets_per_carton * units_per_packet,
        };

        bundles.push(bundle);
    }

    // Calculate totals
    let total_bundles = bundle_count;
    let total_cartons = bundle_count * cartons_per_bundle;
    let total_packets = total_cartons * packets_per_carton;
    let total_units = total_packets * units_per_packet;

    let hierarchy_summary = HierarchySummary {
        bundle_count,
        cartons_per_bundle,
        packets_per_carton,
        units_per_packet,
        total_bundles,
        total_cartons,
        total_packets,
        total_units,
    };

    let hierarchical_codes = HierarchicalCodes {
        bundles,
        cartons: all_cartons,
        packets: all_packets,
        units: all_units,
        total_codes: total_units, // Total unit codes generated
        hierarchy_summary,
    };

    Ok(hierarchical_codes)
}

/// Generate hierarchical codes with international standards
pub fn generate_hierarchical_with_international(
    bundle_prefix: String,
    carton_prefix: String,
    packet_prefix: String,
    unit_prefix: String,
    bundle_count: u32,
    cartons_per_bundle: u32,
    packets_per_carton: u32,
    units_per_packet: u32,
    factory_id: String,
    company_prefix: String,
) -> Result<CodeGenerationResponse, NexaTraceError> {
    // Generate hierarchical codes
    let hierarchical_codes = generate_hierarchical(
        bundle_prefix.clone(),
        carton_prefix.clone(),
        packet_prefix.clone(),
        unit_prefix.clone(),
        bundle_count,
        cartons_per_bundle,
        packets_per_carton,
        units_per_packet,
        factory_id.clone(),
    )?;

    // Extract all codes
    let mut all_codes = Vec::new();
    let mut all_qr_codes = Vec::new();
    let mut all_barcodes = Vec::new();
    let mut all_international_codes = Vec::new();

    // Process bundles
    for bundle in &hierarchical_codes.bundles {
        all_codes.push(bundle.code.clone());

        // Generate GS1 code for bundle
        let gs1_code = crate::international::gs1::generate_gs1_code(
            company_prefix.clone(),
            "BUNDLE".to_string(),
            format!("{:08}", bundle.sequence),
        )?;
        all_international_codes.push(gs1_code.clone());

        // Generate QR code
        let qr_data = crate::international::qr::generate_qr_data(
            bundle.code.clone(),
            Some(gs1_code.clone()),
        )?;
        all_qr_codes.push(qr_data);

        // Generate barcode
        let barcode_data = crate::international::barcode::generate_barcode_data(
            bundle.code.clone(),
            "CODE128".to_string(),
        )?;
        all_barcodes.push(barcode_data);
    }

    // Process cartons
    for carton in &hierarchical_codes.cartons {
        all_codes.push(carton.code.clone());

        // Generate GS1 code for carton
        let gs1_code = crate::international::gs1::generate_gs1_code(
            company_prefix.clone(),
            "CARTON".to_string(),
            format!("{:08}", carton.sequence),
        )?;
        all_international_codes.push(gs1_code.clone());

        // Generate QR code
        let qr_data = crate::international::qr::generate_qr_data(
            carton.code.clone(),
            Some(gs1_code.clone()),
        )?;
        all_qr_codes.push(qr_data);

        // Generate barcode
        let barcode_data = crate::international::barcode::generate_barcode_data(
            carton.code.clone(),
            "CODE128".to_string(),
        )?;
        all_barcodes.push(barcode_data);
    }

    // Process packets
    for packet in &hierarchical_codes.packets {
        all_codes.push(packet.code.clone());

        // Generate GS1 code for packet
        let gs1_code = crate::international::gs1::generate_gs1_code(
            company_prefix.clone(),
            "PACKET".to_string(),
            format!("{:08}", packet.sequence),
        )?;
        all_international_codes.push(gs1_code.clone());

        // Generate QR code
        let qr_data = crate::international::qr::generate_qr_data(
            packet.code.clone(),
            Some(gs1_code.clone()),
        )?;
        all_qr_codes.push(qr_data);

        // Generate barcode
        let barcode_data = crate::international::barcode::generate_barcode_data(
            packet.code.clone(),
            "CODE128".to_string(),
        )?;
        all_barcodes.push(barcode_data);
    }

    // Process units
    for unit in &hierarchical_codes.units {
        all_codes.push(unit.code.clone());

        // Generate GS1 code for unit
        let gs1_code = crate::international::gs1::generate_gs1_code(
            company_prefix.clone(),
            "UNIT".to_string(),
            format!("{:010}", unit.sequence),
        )?;
        all_international_codes.push(gs1_code.clone());

        // Generate QR code with authentication
        let qr_data = crate::international::qr::generate_qr_data(
            unit.code.clone(),
            Some(format!("{}|{}", gs1_code, unit.authentication_code)),
        )?;
        all_qr_codes.push(qr_data);

        // Generate barcode
        let barcode_data = crate::international::barcode::generate_barcode_data(
            unit.code.clone(),
            "CODE128".to_string(),
        )?;
        all_barcodes.push(barcode_data);
    }

    let response = CodeGenerationResponse {
        success: true,
        batch_id: Uuid::new_v4().to_string(),
        codes_generated: hierarchical_codes.total_codes,
        generated_codes: all_codes,
        qr_codes: Some(all_qr_codes),
        barcodes: Some(all_barcodes),
        international_codes: Some(all_international_codes),
        error: None,
    };

    Ok(response)
}

/// Validate hierarchical configuration
pub fn validate_hierarchical_config(
    bundle_prefix: &str,
    carton_prefix: &str,
    packet_prefix: &str,
    unit_prefix: &str,
    bundle_count: u32,
    cartons_per_bundle: u32,
    packets_per_carton: u32,
    units_per_packet: u32,
    factory_id: &str,
) -> Result<(), NexaTraceError> {
    validate_hierarchical_inputs(
        bundle_prefix,
        carton_prefix,
        packet_prefix,
        unit_prefix,
        bundle_count,
        cartons_per_bundle,
        packets_per_carton,
        units_per_packet,
        factory_id,
    )
}

/// Calculate hierarchy totals
pub fn calculate_hierarchy_totals(
    bundle_count: u32,
    cartons_per_bundle: u32,
    packets_per_carton: u32,
    units_per_packet: u32,
) -> HierarchySummary {
    let total_bundles = bundle_count;
    let total_cartons = bundle_count * cartons_per_bundle;
    let total_packets = total_cartons * packets_per_carton;
    let total_units = total_packets * units_per_packet;

    HierarchySummary {
        bundle_count,
        cartons_per_bundle,
        packets_per_carton,
        units_per_packet,
        total_bundles,
        total_cartons,
        total_packets,
        total_units,
    }
}

/// Validate hierarchical inputs
fn validate_hierarchical_inputs(
    bundle_prefix: &str,
    carton_prefix: &str,
    packet_prefix: &str,
    unit_prefix: &str,
    bundle_count: u32,
    cartons_per_bundle: u32,
    packets_per_carton: u32,
    units_per_packet: u32,
    factory_id: &str,
) -> Result<(), NexaTraceError> {
    // Validate prefixes
    if !is_valid_bundle_prefix(bundle_prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid bundle prefix: {}. Must be 1-3 uppercase letters", bundle_prefix)
        ));
    }

    if !is_valid_carton_prefix(carton_prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid carton prefix: {}. Must be 2-3 uppercase letters", carton_prefix)
        ));
    }

    if !is_valid_packet_prefix(packet_prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid packet prefix: {}. Must be 3 uppercase letters", packet_prefix)
        ));
    }

    if !is_valid_unit_prefix(unit_prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid unit prefix: {}. Must be 4 uppercase letters", unit_prefix)
        ));
    }

    // Validate counts
    if bundle_count == 0 {
        return Err(NexaTraceError::ValidationError(
            "Bundle count cannot be zero".to_string()
        ));
    }

    if bundle_count > 100 {
        return Err(NexaTraceError::ValidationError(
            "Cannot generate more than 100 bundles at once".to_string()
        ));
    }

    if cartons_per_bundle == 0 {
        return Err(NexaTraceError::ValidationError(
            "Cartons per bundle cannot be zero".to_string()
        ));
    }

    if cartons_per_bundle > 100 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 100 cartons per bundle".to_string()
        ));
    }

    if packets_per_carton == 0 {
        return Err(NexaTraceError::ValidationError(
            "Packets per carton cannot be zero".to_string()
        ));
    }

    if packets_per_carton > 50 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 50 packets per carton".to_string()
        ));
    }

    if units_per_packet == 0 {
        return Err(NexaTraceError::ValidationError(
            "Units per packet cannot be zero".to_string()
        ));
    }

    if units_per_packet > 100 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 100 units per packet".to_string()
        ));
    }

    // Validate factory ID
    if factory_id.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Factory ID cannot be empty".to_string()
        ));
    }

    // Calculate total units and check limits
    let total_units = bundle_count * cartons_per_bundle * packets_per_carton * units_per_packet;
    if total_units > 1_000_000 {
        return Err(NexaTraceError::ValidationError(
            "Cannot generate more than 1,000,000 units in a single hierarchy".to_string()
        ));
    }

    Ok(())
}

/// Check if bundle prefix is valid
fn is_valid_bundle_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    (1..=3).contains(&len) && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Check if carton prefix is valid
fn is_valid_carton_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    (2..=3).contains(&len) && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Check if packet prefix is valid
fn is_valid_packet_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    len == 3 && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Check if unit prefix is valid
fn is_valid_unit_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    len == 4 && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Generate serial number for unit
fn generate_serial_number(unit_code: &str, sequence: u32) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", unit_code, sequence);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 12 characters of hex representation
    hex::encode(result)[0..12].to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_hierarchical() {
        let result = generate_hierarchical(
            "A".to_string(),
            "YY".to_string(),
            "YBZ".to_string(),
            "TSFG".to_string(),
            2,  // 2 bundles
            3,  // 3 cartons per bundle
            2,  // 2 packets per carton
            4,  // 4 units per packet
            "factory_123".to_string(),
        ).unwrap();

        assert_eq!(result.bundles.len(), 2);
        assert_eq!(result.cartons.len(), 6);  // 2 bundles * 3 cartons
        assert_eq!(result.packets.len(), 12); // 6 cartons * 2 packets
        assert_eq!(result.units.len(), 48);   // 12 packets * 4 units

        // Verify hierarchy structure
        assert_eq!(result.hierarchy_summary.bundle_count, 2);
        assert_eq!(result.hierarchy_summary.cartons_per_bundle, 3);
        assert_eq!(result.hierarchy_summary.packets_per_carton, 2);
        assert_eq!(result.hierarchy_summary.units_per_packet, 4);
        assert_eq!(result.hierarchy_summary.total_bundles, 2);
        assert_eq!(result.hierarchy_summary.total_cartons, 6);
        assert_eq!(result.hierarchy_summary.total_packets, 12);
        assert_eq!(result.hierarchy_summary.total_units, 48);

        // Verify bundle codes
        assert!(result.bundles[0].code.starts_with("A-01-"));
        assert!(result.bundles[1].code.starts_with("A-02-"));

        // Verify carton codes reference correct bundle
        for carton in &result.cartons {
            assert!(carton.code.starts_with("YY-"));
            assert!(carton.bundle_code.starts_with("A-"));
        }

        // Verify packet codes reference correct carton
        for packet in &result.packets {
            assert!(packet.code.starts_with("YBZ-"));
            assert!(packet.carton_code.starts_with("YY-"));
        }

        // Verify unit codes reference correct packet
        for unit in &result.units {
            assert!(unit.code.starts_with("TSFG-"));
            assert!(unit.packet_code.starts_with("YBZ-"));
            assert_eq!(unit.authentication_code.len(), 16);
            assert_eq!(unit.serial_number.len(), 12);
        }
    }

    #[test]
    fn test_generate_hierarchical_with_international() {
        let result = generate_hierarchical_with_international(
            "B".to_string(),
            "ZZ".to_string(),
            "ABC".to_string(),
            "DEFG".to_string(),
            1,  // 1 bundle
            2,  // 2 cartons per bundle
            2,  // 2 packets per carton
            3,  // 3 units per packet
            "factory_456".to_string(),
            "123456".to_string(), // company prefix
        ).unwrap();

        assert!(result.success);
        assert!(!result.batch_id.is_empty());

        // Calculate expected totals: 1*2*2*3 = 12 units total
        // But we generate codes for all levels: 1 bundle + 2 cartons + 4 packets + 12 units = 19 codes
        assert_eq!(result.codes_generated, 19);

        // Verify all code lists are present
        assert!(!result.generated_codes.is_empty());
        assert!(result.qr_codes.as_ref().is_some_and(|v| !v.is_empty()));
        assert!(result.barcodes.as_ref().is_some_and(|v| !v.is_empty()));
        assert!(result.international_codes.as_ref().is_some_and(|v| !v.is_empty()));

        let codes = &result.generated_codes;
        let qr_codes = result.qr_codes.as_ref().unwrap();
        let barcodes = result.barcodes.as_ref().unwrap();
        let intl_codes = result.international_codes.as_ref().unwrap();

        assert_eq!(codes.len(), 19);
        assert_eq!(qr_codes.len(), 19);
        assert_eq!(barcodes.len(), 19);
        assert_eq!(intl_codes.len(), 19);
    }

    #[test]
    fn test_validate_hierarchical_config() {
        // Valid configuration
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 5, 6, 24,
            "factory_123"
        ).is_ok());

        // Invalid bundle prefix
        assert!(validate_hierarchical_config(
            "a", "YY", "YBZ", "TSFG", // lowercase prefix
            10, 5, 6, 24,
            "factory_123"
        ).is_err());

        // Invalid carton prefix
        assert!(validate_hierarchical_config(
            "A", "Y", "YBZ", "TSFG", // single character
            10, 5, 6, 24,
            "factory_123"
        ).is_err());

        // Invalid packet prefix
        assert!(validate_hierarchical_config(
            "A", "YY", "YB", "TSFG", // two characters
            10, 5, 6, 24,
            "factory_123"
        ).is_err());

        // Invalid unit prefix
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSF", // three characters
            10, 5, 6, 24,
            "factory_123"
        ).is_err());

        // Zero bundle count
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            0, 5, 6, 24,
            "factory_123"
        ).is_err());

        // Too many bundles
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            101, 5, 6, 24,
            "factory_123"
        ).is_err());

        // Zero cartons per bundle
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 0, 6, 24,
            "factory_123"
        ).is_err());

        // Too many cartons per bundle
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 101, 6, 24,
            "factory_123"
        ).is_err());

        // Zero packets per carton
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 5, 0, 24,
            "factory_123"
        ).is_err());

        // Too many packets per carton
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 5, 51, 24,
            "factory_123"
        ).is_err());

        // Zero units per packet
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 5, 6, 0,
            "factory_123"
        ).is_err());

        // Too many units per packet
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 5, 6, 101,
            "factory_123"
        ).is_err());

        // Empty factory ID
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            10, 5, 6, 24,
            ""
        ).is_err());

        // Too many total units (exceeds 1,000,000 limit)
        assert!(validate_hierarchical_config(
            "A", "YY", "YBZ", "TSFG",
            100, 100, 100, 100, // 100*100*100*100 = 100,000,000
            "factory_123"
        ).is_err());
    }

    #[test]
    fn test_calculate_hierarchy_totals() {
        let summary = calculate_hierarchy_totals(2, 3, 4, 5);

        assert_eq!(summary.bundle_count, 2);
        assert_eq!(summary.cartons_per_bundle, 3);
        assert_eq!(summary.packets_per_carton, 4);
        assert_eq!(summary.units_per_packet, 5);
        assert_eq!(summary.total_bundles, 2);
        assert_eq!(summary.total_cartons, 6);    // 2 * 3
        assert_eq!(summary.total_packets, 24);   // 6 * 4
        assert_eq!(summary.total_units, 120);    // 24 * 5
    }

    #[test]
    fn test_prefix_validators() {
        // Bundle prefix tests
        assert!(is_valid_bundle_prefix("A"));
        assert!(is_valid_bundle_prefix("AB"));
        assert!(is_valid_bundle_prefix("ABC"));
        assert!(!is_valid_bundle_prefix(""));     // empty
        assert!(!is_valid_bundle_prefix("ABCD")); // too long
        assert!(!is_valid_bundle_prefix("a"));    // lowercase
        assert!(!is_valid_bundle_prefix("A1"));   // contains number

        // Carton prefix tests
        assert!(is_valid_carton_prefix("YY"));
        assert!(is_valid_carton_prefix("ZZZ"));
        assert!(!is_valid_carton_prefix("Y"));     // too short
        assert!(!is_valid_carton_prefix("YYYY"));  // too long
        assert!(!is_valid_carton_prefix("yy"));    // lowercase
        assert!(!is_valid_carton_prefix("Y1"));    // contains number

        // Packet prefix tests
        assert!(is_valid_packet_prefix("YBZ"));
        assert!(is_valid_packet_prefix("ABC"));
        assert!(!is_valid_packet_prefix("AB"));     // too short
        assert!(!is_valid_packet_prefix("ABCD"));   // too long
        assert!(!is_valid_packet_prefix("ybz"));    // lowercase
        assert!(!is_valid_packet_prefix("AB1"));    // contains number

        // Unit prefix tests
        assert!(is_valid_unit_prefix("TSFG"));
        assert!(is_valid_unit_prefix("ABCD"));
        assert!(!is_valid_unit_prefix("TSF"));      // too short
        assert!(!is_valid_unit_prefix("TSFGG"));    // too long
        assert!(!is_valid_unit_prefix("tsfg"));     // lowercase
        assert!(!is_valid_unit_prefix("TSF1"));     // contains number
    }
}
