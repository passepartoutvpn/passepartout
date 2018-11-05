// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum About {
    /// About
    internal static let title = L10n.tr("Localizable", "about.title")
    internal enum Cells {
      internal enum Disclaimer {
        /// Disclaimer
        internal static let caption = L10n.tr("Localizable", "about.cells.disclaimer.caption")
      }
      internal enum JoinCommunity {
        /// Join community
        internal static let caption = L10n.tr("Localizable", "about.cells.join_community.caption")
      }
      internal enum PrivacyPolicy {
        /// Privacy policy
        internal static let caption = L10n.tr("Localizable", "about.cells.privacy_policy.caption")
      }
      internal enum ShareGeneric {
        /// Invite a friend
        internal static let caption = L10n.tr("Localizable", "about.cells.share_generic.caption")
      }
      internal enum ShareTwitter {
        /// Tweet about it!
        internal static let caption = L10n.tr("Localizable", "about.cells.share_twitter.caption")
      }
      internal enum Website {
        /// Home page
        internal static let caption = L10n.tr("Localizable", "about.cells.website.caption")
      }
      internal enum WriteReview {
        /// Write a review
        internal static let caption = L10n.tr("Localizable", "about.cells.write_review.caption")
      }
    }
    internal enum Sections {
      internal enum Feedback {
        /// Feedback
        internal static let header = L10n.tr("Localizable", "about.sections.feedback.header")
      }
      internal enum Share {
        /// Share
        internal static let header = L10n.tr("Localizable", "about.sections.share.header")
      }
      internal enum Web {
        /// Web
        internal static let header = L10n.tr("Localizable", "about.sections.web.header")
      }
    }
  }

  internal enum Account {
    internal enum Cells {
      internal enum Password {
        /// Password
        internal static let caption = L10n.tr("Localizable", "account.cells.password.caption")
        /// secret
        internal static let placeholder = L10n.tr("Localizable", "account.cells.password.placeholder")
      }
      internal enum Username {
        /// Username
        internal static let caption = L10n.tr("Localizable", "account.cells.username.caption")
        /// username
        internal static let placeholder = L10n.tr("Localizable", "account.cells.username.placeholder")
      }
    }
    internal enum SuggestionFooter {
      internal enum Infrastructure {
        /// Use your website credentials. Your username is usually numeric with a "p" prefix.
        internal static let pia = L10n.tr("Localizable", "account.suggestion_footer.infrastructure.pia")
      }
    }
  }

  internal enum Configuration {
    internal enum Cells {
      internal enum Cipher {
        /// Cipher
        internal static let caption = L10n.tr("Localizable", "configuration.cells.cipher.caption")
      }
      internal enum Client {
        /// Client certificate
        internal static let caption = L10n.tr("Localizable", "configuration.cells.client.caption")
        internal enum Value {
          /// Not verified
          internal static let disabled = L10n.tr("Localizable", "configuration.cells.client.value.disabled")
          /// Verified
          internal static let enabled = L10n.tr("Localizable", "configuration.cells.client.value.enabled")
        }
      }
      internal enum CompressionAlgorithm {
        /// Compression
        internal static let caption = L10n.tr("Localizable", "configuration.cells.compression_algorithm.caption")
        internal enum Value {
          /// Disabled
          internal static let disabled = L10n.tr("Localizable", "configuration.cells.compression_algorithm.value.disabled")
        }
      }
      internal enum CompressionFrame {
        /// Framing
        internal static let caption = L10n.tr("Localizable", "configuration.cells.compression_frame.caption")
        internal enum Value {
          /// Compress
          internal static let compress = L10n.tr("Localizable", "configuration.cells.compression_frame.value.compress")
          /// None
          internal static let disabled = L10n.tr("Localizable", "configuration.cells.compression_frame.value.disabled")
          /// LZO
          internal static let lzo = L10n.tr("Localizable", "configuration.cells.compression_frame.value.lzo")
        }
      }
      internal enum Digest {
        /// Authentication
        internal static let caption = L10n.tr("Localizable", "configuration.cells.digest.caption")
        internal enum Value {
          /// Embedded
          internal static let embedded = L10n.tr("Localizable", "configuration.cells.digest.value.embedded")
        }
      }
      internal enum KeepAlive {
        /// Keep-alive
        internal static let caption = L10n.tr("Localizable", "configuration.cells.keep_alive.caption")
        internal enum Value {
          /// Disabled
          internal static let never = L10n.tr("Localizable", "configuration.cells.keep_alive.value.never")
          /// %d seconds
          internal static func seconds(_ p1: Int) -> String {
            return L10n.tr("Localizable", "configuration.cells.keep_alive.value.seconds", p1)
          }
        }
      }
      internal enum RenegotiationSeconds {
        /// Renegotiation
        internal static let caption = L10n.tr("Localizable", "configuration.cells.renegotiation_seconds.caption")
        internal enum Value {
          /// after %@
          internal static func after(_ p1: String) -> String {
            return L10n.tr("Localizable", "configuration.cells.renegotiation_seconds.value.after", p1)
          }
          /// Disabled
          internal static let never = L10n.tr("Localizable", "configuration.cells.renegotiation_seconds.value.never")
        }
      }
      internal enum ResetOriginal {
        /// Reset configuration
        internal static let caption = L10n.tr("Localizable", "configuration.cells.reset_original.caption")
      }
      internal enum TlsWrapping {
        /// Wrapping
        internal static let caption = L10n.tr("Localizable", "configuration.cells.tls_wrapping.caption")
        internal enum Value {
          /// Authentication
          internal static let auth = L10n.tr("Localizable", "configuration.cells.tls_wrapping.value.auth")
          /// Encryption
          internal static let crypt = L10n.tr("Localizable", "configuration.cells.tls_wrapping.value.crypt")
          /// Disabled
          internal static let disabled = L10n.tr("Localizable", "configuration.cells.tls_wrapping.value.disabled")
        }
      }
    }
    internal enum Sections {
      internal enum Communication {
        /// Communication
        internal static let header = L10n.tr("Localizable", "configuration.sections.communication.header")
      }
      internal enum Other {
        /// Other
        internal static let header = L10n.tr("Localizable", "configuration.sections.other.header")
      }
      internal enum Reset {
        /// If you ended up with broken connectivity after changing the communication parameters, tap to revert to the original configuration.
        internal static let footer = L10n.tr("Localizable", "configuration.sections.reset.footer")
      }
      internal enum Tls {
        /// TLS
        internal static let header = L10n.tr("Localizable", "configuration.sections.tls.header")
      }
    }
  }

  internal enum Credits {
    /// Credits
    internal static let title = L10n.tr("Localizable", "credits.title")
    internal enum Labels {
      /// The logo is taken from the awesome Circle Icons set by Nick Roach.
      internal static let thirdParties = L10n.tr("Localizable", "credits.labels.third_parties")
    }
  }

  internal enum DebugLog {
    internal enum Alerts {
      internal enum EmptyLog {
        /// The debug log is empty.
        internal static let message = L10n.tr("Localizable", "debug_log.alerts.empty_log.message")
      }
    }
    internal enum Buttons {
      /// Next
      internal static let next = L10n.tr("Localizable", "debug_log.buttons.next")
      /// Previous
      internal static let previous = L10n.tr("Localizable", "debug_log.buttons.previous")
    }
  }

  internal enum Endpoint {
    internal enum Cells {
      internal enum AnyAddress {
        /// Any
        internal static let caption = L10n.tr("Localizable", "endpoint.cells.any_address.caption")
      }
      internal enum AnyProtocol {
        /// Any
        internal static let caption = L10n.tr("Localizable", "endpoint.cells.any_protocol.caption")
      }
    }
    internal enum Sections {
      internal enum LocationAddresses {
        /// Addresses
        internal static let header = L10n.tr("Localizable", "endpoint.sections.location_addresses.header")
      }
      internal enum LocationProtocols {
        /// Protocols
        internal static let header = L10n.tr("Localizable", "endpoint.sections.location_protocols.header")
      }
    }
  }

  internal enum Global {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "global.cancel")
    /// Next
    internal static let next = L10n.tr("Localizable", "global.next")
    /// OK
    internal static let ok = L10n.tr("Localizable", "global.ok")
    internal enum Host {
      internal enum TitleInput {
        /// Legal characters are alphanumerics plus dash (-), underscore (_) and dot (.).
        internal static let message = L10n.tr("Localizable", "global.host.title_input.message")
        /// My Profile
        internal static let placeholder = L10n.tr("Localizable", "global.host.title_input.placeholder")
      }
    }
  }

  internal enum ImportedHosts {
    /// Imported hosts
    internal static let title = L10n.tr("Localizable", "imported_hosts.title")
  }

  internal enum IssueReporter {
    /// The debug log of your latest connections is crucial to resolve your connectivity issues and is completely anonymous.\n\nThe .ovpn configuration file, if any, is attached stripped of any sensitive data.\n\nPlease double check the email attachments if unsure.
    internal static let message = L10n.tr("Localizable", "issue_reporter.message")
    /// Report issue
    internal static let title = L10n.tr("Localizable", "issue_reporter.title")
    internal enum Alerts {
      internal enum EmailNotConfigured {
        /// No e-mail account is configured.
        internal static let message = L10n.tr("Localizable", "issue_reporter.alerts.email_not_configured.message")
      }
    }
    internal enum Buttons {
      /// I understand
      internal static let accept = L10n.tr("Localizable", "issue_reporter.buttons.accept")
    }
    internal enum Email {
      /// Hi,\n\n%@\n\n%@\n\nRegards
      internal static func body(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "issue_reporter.email.body", p1, p2)
      }
      /// description of the issue:
      internal static let description = L10n.tr("Localizable", "issue_reporter.email.description")
      /// %@ - Report issue
      internal static func subject(_ p1: String) -> String {
        return L10n.tr("Localizable", "issue_reporter.email.subject", p1)
      }
    }
  }

  internal enum Organizer {
    internal enum Alerts {
      internal enum AddHost {
        /// Open an URL to an .ovpn configuration file from Safari, Mail or another app to set up a host profile.\n\nYou can also import an .ovpn with iTunes File Sharing.
        internal static let message = L10n.tr("Localizable", "organizer.alerts.add_host.message")
      }
      internal enum DeleteVpnProfile {
        /// Do you really want to delete the VPN profile from the device?
        internal static let message = L10n.tr("Localizable", "organizer.alerts.delete_vpn_profile.message")
      }
      internal enum ExhaustedProviders {
        /// You have created profiles for any available network.
        internal static let message = L10n.tr("Localizable", "organizer.alerts.exhausted_providers.message")
      }
    }
    internal enum Cells {
      internal enum About {
        /// About %@
        internal static func caption(_ p1: String) -> String {
          return L10n.tr("Localizable", "organizer.cells.about.caption", p1)
        }
      }
      internal enum AddHost {
        /// Add new host
        internal static let caption = L10n.tr("Localizable", "organizer.cells.add_host.caption")
      }
      internal enum AddProvider {
        /// Add new network
        internal static let caption = L10n.tr("Localizable", "organizer.cells.add_provider.caption")
      }
      internal enum Profile {
        internal enum Value {
          /// In use
          internal static let current = L10n.tr("Localizable", "organizer.cells.profile.value.current")
        }
      }
      internal enum Uninstall {
        /// Delete VPN profile
        internal static let caption = L10n.tr("Localizable", "organizer.cells.uninstall.caption")
      }
    }
    internal enum Sections {
      internal enum Hosts {
        /// Import hosts from raw .ovpn configuration files.
        internal static let footer = L10n.tr("Localizable", "organizer.sections.hosts.footer")
        /// Hosts
        internal static let header = L10n.tr("Localizable", "organizer.sections.hosts.header")
      }
      internal enum Providers {
        /// Here you find a few public infrastructures offering preset configuration profiles.
        internal static let footer = L10n.tr("Localizable", "organizer.sections.providers.footer")
        /// Networks
        internal static let header = L10n.tr("Localizable", "organizer.sections.providers.header")
      }
    }
  }

  internal enum ParsedFile {
    internal enum Alerts {
      internal enum Buttons {
        /// Report an issue
        internal static let report = L10n.tr("Localizable", "parsed_file.alerts.buttons.report")
      }
      internal enum Missing {
        /// The configuration file lacks a required option (%@).
        internal static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.missing.message", p1)
        }
      }
      internal enum Parsing {
        /// Unable to parse the provided configuration file (%@).
        internal static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.parsing.message", p1)
        }
      }
      internal enum PotentiallyUnsupported {
        /// The configuration file is correct but contains a potentially unsupported option (%@).\n\nConnectivity may break depending on server settings.
        internal static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.potentially_unsupported.message", p1)
        }
      }
      internal enum Unsupported {
        /// The configuration file contains an unsupported option (%@).
        internal static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.unsupported.message", p1)
        }
      }
    }
  }

  internal enum Provider {
    internal enum Preset {
      internal enum Cells {
        internal enum TechDetails {
          /// Technical details
          internal static let caption = L10n.tr("Localizable", "provider.preset.cells.tech_details.caption")
        }
      }
    }
  }

  internal enum Reddit {
    /// Did you know that Passepartout has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.\n\nIt's also a great way to show you care about this project.
    internal static let message = L10n.tr("Localizable", "reddit.message")
    /// Reddit
    internal static let title = L10n.tr("Localizable", "reddit.title")
    internal enum Buttons {
      /// Don't ask again
      internal static let never = L10n.tr("Localizable", "reddit.buttons.never")
      /// Remind me later
      internal static let remind = L10n.tr("Localizable", "reddit.buttons.remind")
      /// Subscribe now!
      internal static let subscribe = L10n.tr("Localizable", "reddit.buttons.subscribe")
    }
  }

  internal enum Service {
    internal enum Alerts {
      internal enum CredentialsNeeded {
        /// You need to enter account credentials first.
        internal static let message = L10n.tr("Localizable", "service.alerts.credentials_needed.message")
      }
      internal enum DataCount {
        internal enum Messages {
          /// Received: %llu\nSent: %llu
          internal static func current(_ p1: Int, _ p2: Int) -> String {
            return L10n.tr("Localizable", "service.alerts.data_count.messages.current", p1, p2)
          }
          /// Information not available, are you connected?
          internal static let notAvailable = L10n.tr("Localizable", "service.alerts.data_count.messages.not_available")
        }
      }
      internal enum ReconnectVpn {
        /// Do you want to reconnect to the VPN?
        internal static let message = L10n.tr("Localizable", "service.alerts.reconnect_vpn.message")
      }
      internal enum Rename {
        /// Rename profile
        internal static let title = L10n.tr("Localizable", "service.alerts.rename.title")
      }
      internal enum TestConnectivity {
        /// Connectivity
        internal static let title = L10n.tr("Localizable", "service.alerts.test_connectivity.title")
        internal enum Messages {
          /// Your device has no Internet connectivity, please review your profile parameters.
          internal static let failure = L10n.tr("Localizable", "service.alerts.test_connectivity.messages.failure")
          /// Your device is connected to the Internet!
          internal static let success = L10n.tr("Localizable", "service.alerts.test_connectivity.messages.success")
        }
      }
      internal enum Trusted {
        internal enum NoNetwork {
          /// You are not connected to any Wi-Fi network.
          internal static let message = L10n.tr("Localizable", "service.alerts.trusted.no_network.message")
        }
        internal enum WillDisconnectPolicy {
          /// By changing the trust policy, the VPN may be disconnected. Continue?
          internal static let message = L10n.tr("Localizable", "service.alerts.trusted.will_disconnect_policy.message")
        }
        internal enum WillDisconnectTrusted {
          /// By trusting this network, the VPN may be disconnected. Continue?
          internal static let message = L10n.tr("Localizable", "service.alerts.trusted.will_disconnect_trusted.message")
        }
      }
    }
    internal enum Cells {
      internal enum Account {
        /// Account
        internal static let caption = L10n.tr("Localizable", "service.cells.account.caption")
        /// None configured
        internal static let `none` = L10n.tr("Localizable", "service.cells.account.none")
      }
      internal enum ConnectionStatus {
        /// Status
        internal static let caption = L10n.tr("Localizable", "service.cells.connection_status.caption")
      }
      internal enum DataCount {
        /// Exchanged bytes count
        internal static let caption = L10n.tr("Localizable", "service.cells.data_count.caption")
      }
      internal enum DebugLog {
        /// Debug log
        internal static let caption = L10n.tr("Localizable", "service.cells.debug_log.caption")
      }
      internal enum Endpoint {
        /// Endpoint
        internal static let caption = L10n.tr("Localizable", "service.cells.endpoint.caption")
        internal enum Value {
          /// Automatic
          internal static let automatic = L10n.tr("Localizable", "service.cells.endpoint.value.automatic")
          /// Manual
          internal static let manual = L10n.tr("Localizable", "service.cells.endpoint.value.manual")
        }
      }
      internal enum Host {
        internal enum Parameters {
          /// Parameters
          internal static let caption = L10n.tr("Localizable", "service.cells.host.parameters.caption")
          internal enum Value {
            /// %@
            internal static func cipher(_ p1: String) -> String {
              return L10n.tr("Localizable", "service.cells.host.parameters.value.cipher", p1)
            }
            /// %@ / %@
            internal static func cipherDigest(_ p1: String, _ p2: String) -> String {
              return L10n.tr("Localizable", "service.cells.host.parameters.value.cipher_digest", p1, p2)
            }
          }
        }
      }
      internal enum Provider {
        internal enum Pool {
          /// Location
          internal static let caption = L10n.tr("Localizable", "service.cells.provider.pool.caption")
        }
        internal enum Preset {
          /// Preset
          internal static let caption = L10n.tr("Localizable", "service.cells.provider.preset.caption")
        }
        internal enum Refresh {
          /// Refresh infrastructure
          internal static let caption = L10n.tr("Localizable", "service.cells.provider.refresh.caption")
        }
      }
      internal enum Reconnect {
        /// Reconnect
        internal static let caption = L10n.tr("Localizable", "service.cells.reconnect.caption")
      }
      internal enum ReportIssue {
        /// Report connectivity issue
        internal static let caption = L10n.tr("Localizable", "service.cells.report_issue.caption")
      }
      internal enum TestConnectivity {
        /// Test connectivity
        internal static let caption = L10n.tr("Localizable", "service.cells.test_connectivity.caption")
      }
      internal enum TrustedAddWifi {
        /// Add current Wi-Fi
        internal static let caption = L10n.tr("Localizable", "service.cells.trusted_add_wifi.caption")
      }
      internal enum TrustedMobile {
        /// Cellular network
        internal static let caption = L10n.tr("Localizable", "service.cells.trusted_mobile.caption")
      }
      internal enum TrustedPolicy {
        /// Trust disables VPN
        internal static let caption = L10n.tr("Localizable", "service.cells.trusted_policy.caption")
      }
      internal enum TrustedWifi {
        /// %@
        internal static func caption(_ p1: String) -> String {
          return L10n.tr("Localizable", "service.cells.trusted_wifi.caption", p1)
        }
      }
      internal enum UseProfile {
        /// Use this profile
        internal static let caption = L10n.tr("Localizable", "service.cells.use_profile.caption")
      }
      internal enum VpnResolvesHostname {
        /// Resolve server hostname
        internal static let caption = L10n.tr("Localizable", "service.cells.vpn_resolves_hostname.caption")
      }
      internal enum VpnService {
        /// Enabled
        internal static let caption = L10n.tr("Localizable", "service.cells.vpn_service.caption")
      }
      internal enum VpnSurvivesSleep {
        /// Keep alive on sleep
        internal static let caption = L10n.tr("Localizable", "service.cells.vpn_survives_sleep.caption")
      }
    }
    internal enum Sections {
      internal enum Configuration {
        /// Configuration
        internal static let header = L10n.tr("Localizable", "service.sections.configuration.header")
      }
      internal enum Diagnostics {
        /// Diagnostics
        internal static let header = L10n.tr("Localizable", "service.sections.diagnostics.header")
      }
      internal enum General {
        /// General
        internal static let header = L10n.tr("Localizable", "service.sections.general.header")
      }
      internal enum ProviderInfrastructure {
        /// Last updated on %@.
        internal static func footer(_ p1: String) -> String {
          return L10n.tr("Localizable", "service.sections.provider_infrastructure.footer", p1)
        }
      }
      internal enum Status {
        /// Connection
        internal static let header = L10n.tr("Localizable", "service.sections.status.header")
      }
      internal enum Trusted {
        /// When entering a trusted network, the VPN is normally shut down and kept disconnected. Disable this option to not enforce such behavior.
        internal static let footer = L10n.tr("Localizable", "service.sections.trusted.footer")
        /// Trusted networks
        internal static let header = L10n.tr("Localizable", "service.sections.trusted.header")
      }
      internal enum Vpn {
        /// The connection will be established whenever necessary.
        internal static let footer = L10n.tr("Localizable", "service.sections.vpn.footer")
        /// VPN
        internal static let header = L10n.tr("Localizable", "service.sections.vpn.header")
      }
      internal enum VpnResolvesHostname {
        /// Preferred in most networks and required in some IPv6 networks. Disable where DNS is blocked, or to speed up negotiation when DNS is slow to respond.
        internal static let footer = L10n.tr("Localizable", "service.sections.vpn_resolves_hostname.footer")
      }
      internal enum VpnSurvivesSleep {
        /// Disable to improve battery usage, at the expense of occasional slowdowns due to wake-up reconnections.
        internal static let footer = L10n.tr("Localizable", "service.sections.vpn_survives_sleep.footer")
      }
    }
    internal enum Welcome {
      /// Welcome to Passepartout!\n\nUse the organizer to add a new profile.
      internal static let message = L10n.tr("Localizable", "service.welcome.message")
    }
  }

  internal enum Share {
    /// Passepartout is an user-friendly, open source OpenVPN client for iOS and macOS
    internal static let message = L10n.tr("Localizable", "share.message")
  }

  internal enum Version {
    /// Version
    internal static let title = L10n.tr("Localizable", "version.title")
    internal enum Buttons {
      /// CHANGELOG
      internal static let changelog = L10n.tr("Localizable", "version.buttons.changelog")
      /// CREDITS
      internal static let credits = L10n.tr("Localizable", "version.buttons.credits")
    }
    internal enum Labels {
      /// Passepartout and TunnelKit are written and maintained by Davide De Rosa (keeshux).\n\nSource code for Passepartout and TunnelKit is publicly available on GitHub under the GPLv3, you can find links in the home page.\n\nPassepartout is a non-official client and is in no way affiliated with OpenVPN Inc.
      internal static let intro = L10n.tr("Localizable", "version.labels.intro")
    }
  }

  internal enum Vpn {
    /// Active
    internal static let active = L10n.tr("Localizable", "vpn.active")
    /// Connecting
    internal static let connecting = L10n.tr("Localizable", "vpn.connecting")
    /// Disabled
    internal static let disabled = L10n.tr("Localizable", "vpn.disabled")
    /// Disconnecting
    internal static let disconnecting = L10n.tr("Localizable", "vpn.disconnecting")
    /// Inactive
    internal static let inactive = L10n.tr("Localizable", "vpn.inactive")
    internal enum Errors {
      /// Auth failed
      internal static let auth = L10n.tr("Localizable", "vpn.errors.auth")
      /// DNS failed
      internal static let dns = L10n.tr("Localizable", "vpn.errors.dns")
      /// Encryption failed
      internal static let encryption = L10n.tr("Localizable", "vpn.errors.encryption")
      /// Network changed
      internal static let network = L10n.tr("Localizable", "vpn.errors.network")
      /// Timeout
      internal static let timeout = L10n.tr("Localizable", "vpn.errors.timeout")
      /// TLS failed
      internal static let tls = L10n.tr("Localizable", "vpn.errors.tls")
    }
  }

  internal enum Wizards {
    internal enum Host {
      internal enum Alerts {
        internal enum Existing {
          /// A host profile with the same title already exists. Replace it?
          internal static let message = L10n.tr("Localizable", "wizards.host.alerts.existing.message")
        }
      }
      internal enum Cells {
        internal enum TitleInput {
          /// Title
          internal static let caption = L10n.tr("Localizable", "wizards.host.cells.title_input.caption")
        }
      }
      internal enum Sections {
        internal enum Existing {
          /// Existing profiles
          internal static let header = L10n.tr("Localizable", "wizards.host.sections.existing.header")
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
