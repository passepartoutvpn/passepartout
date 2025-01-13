// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum WireGuardStrings {
  /// Interface addresses must be a list of comma-separated IP addresses, optionally in CIDR notation
  internal static let alertInvalidInterfaceMessageAddressInvalid = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceMessageAddressInvalid", fallback: "Interface addresses must be a list of comma-separated IP addresses, optionally in CIDR notation")
  /// Interface’s DNS servers must be a list of comma-separated IP addresses
  internal static let alertInvalidInterfaceMessageDNSInvalid = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceMessageDNSInvalid", fallback: "Interface’s DNS servers must be a list of comma-separated IP addresses")
  /// Interface’s listen port must be between 0 and 65535, or unspecified
  internal static let alertInvalidInterfaceMessageListenPortInvalid = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceMessageListenPortInvalid", fallback: "Interface’s listen port must be between 0 and 65535, or unspecified")
  /// Interface’s MTU must be between 576 and 65535, or unspecified
  internal static let alertInvalidInterfaceMessageMTUInvalid = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceMessageMTUInvalid", fallback: "Interface’s MTU must be between 576 and 65535, or unspecified")
  /// Any one of the following alert messages can go with the above title
  internal static let alertInvalidInterfaceMessageNameRequired = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceMessageNameRequired", fallback: "Interface name is required")
  /// Interface’s private key must be a 32-byte key in base64 encoding
  internal static let alertInvalidInterfaceMessagePrivateKeyInvalid = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceMessagePrivateKeyInvalid", fallback: "Interface’s private key must be a 32-byte key in base64 encoding")
  /// Interface’s private key is required
  internal static let alertInvalidInterfaceMessagePrivateKeyRequired = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceMessagePrivateKeyRequired", fallback: "Interface’s private key is required")
  /// Alert title for error in the interface data
  internal static let alertInvalidInterfaceTitle = WireGuardStrings.tr("Localizable", "alertInvalidInterfaceTitle", fallback: "Invalid interface")
  /// Peer’s allowed IPs must be a list of comma-separated IP addresses, optionally in CIDR notation
  internal static let alertInvalidPeerMessageAllowedIPsInvalid = WireGuardStrings.tr("Localizable", "alertInvalidPeerMessageAllowedIPsInvalid", fallback: "Peer’s allowed IPs must be a list of comma-separated IP addresses, optionally in CIDR notation")
  /// Peer’s endpoint must be of the form ‘host:port’ or ‘[host]:port’
  internal static let alertInvalidPeerMessageEndpointInvalid = WireGuardStrings.tr("Localizable", "alertInvalidPeerMessageEndpointInvalid", fallback: "Peer’s endpoint must be of the form ‘host:port’ or ‘[host]:port’")
  /// Peer’s persistent keepalive must be between 0 to 65535, or unspecified
  internal static let alertInvalidPeerMessagePersistentKeepaliveInvalid = WireGuardStrings.tr("Localizable", "alertInvalidPeerMessagePersistentKeepaliveInvalid", fallback: "Peer’s persistent keepalive must be between 0 to 65535, or unspecified")
  /// Peer’s preshared key must be a 32-byte key in base64 encoding
  internal static let alertInvalidPeerMessagePreSharedKeyInvalid = WireGuardStrings.tr("Localizable", "alertInvalidPeerMessagePreSharedKeyInvalid", fallback: "Peer’s preshared key must be a 32-byte key in base64 encoding")
  /// Two or more peers cannot have the same public key
  internal static let alertInvalidPeerMessagePublicKeyDuplicated = WireGuardStrings.tr("Localizable", "alertInvalidPeerMessagePublicKeyDuplicated", fallback: "Two or more peers cannot have the same public key")
  /// Peer’s public key must be a 32-byte key in base64 encoding
  internal static let alertInvalidPeerMessagePublicKeyInvalid = WireGuardStrings.tr("Localizable", "alertInvalidPeerMessagePublicKeyInvalid", fallback: "Peer’s public key must be a 32-byte key in base64 encoding")
  /// Any one of the following alert messages can go with the above title
  internal static let alertInvalidPeerMessagePublicKeyRequired = WireGuardStrings.tr("Localizable", "alertInvalidPeerMessagePublicKeyRequired", fallback: "Peer’s public key is required")
  /// Alert title for error in the peer data
  internal static let alertInvalidPeerTitle = WireGuardStrings.tr("Localizable", "alertInvalidPeerTitle", fallback: "Invalid peer")
  /// Address ‘%@’ is invalid.
  internal static func macAlertAddressInvalid(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertAddressInvalid (%@)", String(describing: p1), fallback: "Address ‘%@’ is invalid.")
  }
  /// Allowed IP ‘%@’ is invalid
  internal static func macAlertAllowedIPInvalid(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertAllowedIPInvalid (%@)", String(describing: p1), fallback: "Allowed IP ‘%@’ is invalid")
  }
  /// DNS ‘%@’ is invalid.
  internal static func macAlertDNSInvalid(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertDNSInvalid (%@)", String(describing: p1), fallback: "DNS ‘%@’ is invalid.")
  }
  /// Endpoint ‘%@’ is invalid
  internal static func macAlertEndpointInvalid(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertEndpointInvalid (%@)", String(describing: p1), fallback: "Endpoint ‘%@’ is invalid")
  }
  /// Valid keys are: ‘PrivateKey’, ‘ListenPort’, ‘Address’, ‘DNS’ and ‘MTU’.
  internal static let macAlertInfoUnrecognizedInterfaceKey = WireGuardStrings.tr("Localizable", "macAlertInfoUnrecognizedInterfaceKey", fallback: "Valid keys are: ‘PrivateKey’, ‘ListenPort’, ‘Address’, ‘DNS’ and ‘MTU’.")
  /// Valid keys are: ‘PublicKey’, ‘PresharedKey’, ‘AllowedIPs’, ‘Endpoint’ and ‘PersistentKeepalive’
  internal static let macAlertInfoUnrecognizedPeerKey = WireGuardStrings.tr("Localizable", "macAlertInfoUnrecognizedPeerKey", fallback: "Valid keys are: ‘PublicKey’, ‘PresharedKey’, ‘AllowedIPs’, ‘Endpoint’ and ‘PersistentKeepalive’")
  /// Invalid line: ‘%@’.
  internal static func macAlertInvalidLine(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertInvalidLine (%@)", String(describing: p1), fallback: "Invalid line: ‘%@’.")
  }
  /// Listen port ‘%@’ is invalid.
  internal static func macAlertListenPortInvalid(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertListenPortInvalid (%@)", String(describing: p1), fallback: "Listen port ‘%@’ is invalid.")
  }
  /// MTU ‘%@’ is invalid.
  internal static func macAlertMTUInvalid(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertMTUInvalid (%@)", String(describing: p1), fallback: "MTU ‘%@’ is invalid.")
  }
  /// There should be only one entry per section for key ‘%@’
  internal static func macAlertMultipleEntriesForKey(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertMultipleEntriesForKey (%@)", String(describing: p1), fallback: "There should be only one entry per section for key ‘%@’")
  }
  /// Configuration must have only one ‘Interface’ section.
  internal static let macAlertMultipleInterfaces = WireGuardStrings.tr("Localizable", "macAlertMultipleInterfaces", fallback: "Configuration must have only one ‘Interface’ section.")
  /// Configuration must have an ‘Interface’ section.
  internal static let macAlertNoInterface = WireGuardStrings.tr("Localizable", "macAlertNoInterface", fallback: "Configuration must have an ‘Interface’ section.")
  /// Persistent keepalive value ‘%@’ is invalid
  internal static func macAlertPersistentKeepliveInvalid(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertPersistentKeepliveInvalid (%@)", String(describing: p1), fallback: "Persistent keepalive value ‘%@’ is invalid")
  }
  /// Preshared key is invalid
  internal static let macAlertPreSharedKeyInvalid = WireGuardStrings.tr("Localizable", "macAlertPreSharedKeyInvalid", fallback: "Preshared key is invalid")
  /// Private key is invalid.
  internal static let macAlertPrivateKeyInvalid = WireGuardStrings.tr("Localizable", "macAlertPrivateKeyInvalid", fallback: "Private key is invalid.")
  /// Public key is invalid
  internal static let macAlertPublicKeyInvalid = WireGuardStrings.tr("Localizable", "macAlertPublicKeyInvalid", fallback: "Public key is invalid")
  /// Interface contains unrecognized key ‘%@’
  internal static func macAlertUnrecognizedInterfaceKey(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertUnrecognizedInterfaceKey (%@)", String(describing: p1), fallback: "Interface contains unrecognized key ‘%@’")
  }
  /// Peer contains unrecognized key ‘%@’
  internal static func macAlertUnrecognizedPeerKey(_ p1: Any) -> String {
    return WireGuardStrings.tr("Localizable", "macAlertUnrecognizedPeerKey (%@)", String(describing: p1), fallback: "Peer contains unrecognized key ‘%@’")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension WireGuardStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
// swiftlint:enable all
