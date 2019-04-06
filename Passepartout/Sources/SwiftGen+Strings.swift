// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum L10n {

  public enum About {
    /// About
    public static let title = L10n.tr("Localizable", "about.title")
    public enum Cells {
      public enum Disclaimer {
        /// Disclaimer
        public static let caption = L10n.tr("Localizable", "about.cells.disclaimer.caption")
      }
      public enum Faq {
        /// FAQ
        public static let caption = L10n.tr("Localizable", "about.cells.faq.caption")
      }
      public enum JoinCommunity {
        /// Join community
        public static let caption = L10n.tr("Localizable", "about.cells.join_community.caption")
      }
      public enum PrivacyPolicy {
        /// Privacy policy
        public static let caption = L10n.tr("Localizable", "about.cells.privacy_policy.caption")
      }
      public enum ShareGeneric {
        /// Invite a friend
        public static let caption = L10n.tr("Localizable", "about.cells.share_generic.caption")
      }
      public enum ShareTwitter {
        /// Tweet about it!
        public static let caption = L10n.tr("Localizable", "about.cells.share_twitter.caption")
      }
      public enum Website {
        /// Home page
        public static let caption = L10n.tr("Localizable", "about.cells.website.caption")
      }
      public enum WriteReview {
        /// Write a review
        public static let caption = L10n.tr("Localizable", "about.cells.write_review.caption")
      }
    }
    public enum Sections {
      public enum Feedback {
        /// Feedback
        public static let header = L10n.tr("Localizable", "about.sections.feedback.header")
      }
      public enum Share {
        /// Share
        public static let header = L10n.tr("Localizable", "about.sections.share.header")
      }
      public enum Web {
        /// Web
        public static let header = L10n.tr("Localizable", "about.sections.web.header")
      }
    }
  }

  public enum Account {
    public enum Cells {
      public enum OpenGuide {
        /// See your credentials
        public static let caption = L10n.tr("Localizable", "account.cells.open_guide.caption")
      }
      public enum Password {
        /// Password
        public static let caption = L10n.tr("Localizable", "account.cells.password.caption")
        /// secret
        public static let placeholder = L10n.tr("Localizable", "account.cells.password.placeholder")
      }
      public enum Signup {
        /// Register with %@
        public static func caption(_ p1: String) -> String {
          return L10n.tr("Localizable", "account.cells.signup.caption", p1)
        }
      }
      public enum Username {
        /// Username
        public static let caption = L10n.tr("Localizable", "account.cells.username.caption")
        /// username
        public static let placeholder = L10n.tr("Localizable", "account.cells.username.placeholder")
      }
    }
    public enum Sections {
      public enum Credentials {
        /// Credentials
        public static let header = L10n.tr("Localizable", "account.sections.credentials.header")
      }
      public enum Guidance {
        public enum Footer {
          public enum Infrastructure {
            /// Use your %@ website account number and password "m".
            public static func mullvad(_ p1: String) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.mullvad", p1)
            }
            /// Use your %@ website credentials. Your username is usually numeric with a "p" prefix.
            public static func pia(_ p1: String) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.pia", p1)
            }
            /// Find your %@ credentials in the "Account > OpenVPN Login" section of the website.
            public static func protonvpn(_ p1: String) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.protonvpn", p1)
            }
            /// Use your %@ website credentials. Your username is usually your e-mail.
            public static func tunnelbear(_ p1: String) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.tunnelbear", p1)
            }
            /// Find your %@ credentials in the OpenVPN Config Generator on the website.
            public static func windscribe(_ p1: String) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.windscribe", p1)
            }
          }
        }
      }
      public enum Registration {
        /// Go get an account on the %@ website.
        public static func footer(_ p1: String) -> String {
          return L10n.tr("Localizable", "account.sections.registration.footer", p1)
        }
      }
    }
  }

  public enum Configuration {
    public enum Cells {
      public enum All {
        public enum Value {
          /// Disabled
          public static let disabled = L10n.tr("Localizable", "configuration.cells.all.value.disabled")
          /// Enabled
          public static let enabled = L10n.tr("Localizable", "configuration.cells.all.value.enabled")
        }
      }
      public enum Cipher {
        /// Cipher
        public static let caption = L10n.tr("Localizable", "configuration.cells.cipher.caption")
      }
      public enum Client {
        /// Client certificate
        public static let caption = L10n.tr("Localizable", "configuration.cells.client.caption")
        public enum Value {
          /// Not verified
          public static let disabled = L10n.tr("Localizable", "configuration.cells.client.value.disabled")
          /// Verified
          public static let enabled = L10n.tr("Localizable", "configuration.cells.client.value.enabled")
        }
      }
      public enum CompressionAlgorithm {
        /// Algorithm
        public static let caption = L10n.tr("Localizable", "configuration.cells.compression_algorithm.caption")
        public enum Value {
          /// LZO
          public static let lzo = L10n.tr("Localizable", "configuration.cells.compression_algorithm.value.lzo")
          /// Unsupported
          public static let other = L10n.tr("Localizable", "configuration.cells.compression_algorithm.value.other")
        }
      }
      public enum CompressionFraming {
        /// Framing
        public static let caption = L10n.tr("Localizable", "configuration.cells.compression_framing.caption")
        public enum Value {
          /// --compress
          public static let compress = L10n.tr("Localizable", "configuration.cells.compression_framing.value.compress")
          /// --comp-lzo
          public static let lzo = L10n.tr("Localizable", "configuration.cells.compression_framing.value.lzo")
        }
      }
      public enum Digest {
        /// Authentication
        public static let caption = L10n.tr("Localizable", "configuration.cells.digest.caption")
        public enum Value {
          /// Embedded
          public static let embedded = L10n.tr("Localizable", "configuration.cells.digest.value.embedded")
        }
      }
      public enum DnsDomain {
        /// Domain
        public static let caption = L10n.tr("Localizable", "configuration.cells.dns_domain.caption")
        public enum Value {
          /// None
          public static let `none` = L10n.tr("Localizable", "configuration.cells.dns_domain.value.none")
        }
      }
      public enum DnsServer {
        /// Address
        public static let caption = L10n.tr("Localizable", "configuration.cells.dns_server.caption")
      }
      public enum Eku {
        /// Extended verification
        public static let caption = L10n.tr("Localizable", "configuration.cells.eku.caption")
      }
      public enum KeepAlive {
        /// Keep-alive
        public static let caption = L10n.tr("Localizable", "configuration.cells.keep_alive.caption")
        public enum Value {
          /// %d seconds
          public static func seconds(_ p1: Int) -> String {
            return L10n.tr("Localizable", "configuration.cells.keep_alive.value.seconds", p1)
          }
        }
      }
      public enum RandomEndpoint {
        /// Randomize endpoint
        public static let caption = L10n.tr("Localizable", "configuration.cells.random_endpoint.caption")
      }
      public enum RenegotiationSeconds {
        /// Renegotiation
        public static let caption = L10n.tr("Localizable", "configuration.cells.renegotiation_seconds.caption")
        public enum Value {
          /// after %@
          public static func after(_ p1: String) -> String {
            return L10n.tr("Localizable", "configuration.cells.renegotiation_seconds.value.after", p1)
          }
        }
      }
      public enum ResetOriginal {
        /// Reset configuration
        public static let caption = L10n.tr("Localizable", "configuration.cells.reset_original.caption")
      }
      public enum TlsWrapping {
        /// Wrapping
        public static let caption = L10n.tr("Localizable", "configuration.cells.tls_wrapping.caption")
        public enum Value {
          /// Authentication
          public static let auth = L10n.tr("Localizable", "configuration.cells.tls_wrapping.value.auth")
          /// Encryption
          public static let crypt = L10n.tr("Localizable", "configuration.cells.tls_wrapping.value.crypt")
        }
      }
    }
    public enum Sections {
      public enum Communication {
        /// Communication
        public static let header = L10n.tr("Localizable", "configuration.sections.communication.header")
      }
      public enum Compression {
        /// Compression
        public static let header = L10n.tr("Localizable", "configuration.sections.compression.header")
      }
      public enum Dns {
        /// DNS
        public static let header = L10n.tr("Localizable", "configuration.sections.dns.header")
      }
      public enum Other {
        /// Other
        public static let header = L10n.tr("Localizable", "configuration.sections.other.header")
      }
      public enum Reset {
        /// If you ended up with broken connectivity after changing the communication parameters, tap to revert to the original configuration.
        public static let footer = L10n.tr("Localizable", "configuration.sections.reset.footer")
      }
      public enum Tls {
        /// TLS
        public static let header = L10n.tr("Localizable", "configuration.sections.tls.header")
      }
    }
  }

  public enum Credits {
    /// Credits
    public static let title = L10n.tr("Localizable", "credits.title")
    public enum Sections {
      public enum Licenses {
        /// Licenses
        public static let header = L10n.tr("Localizable", "credits.sections.licenses.header")
      }
      public enum Notices {
        /// Notices
        public static let header = L10n.tr("Localizable", "credits.sections.notices.header")
      }
    }
  }

  public enum DebugLog {
    public enum Alerts {
      public enum EmptyLog {
        /// The debug log is empty.
        public static let message = L10n.tr("Localizable", "debug_log.alerts.empty_log.message")
      }
    }
    public enum Buttons {
      /// Next
      public static let next = L10n.tr("Localizable", "debug_log.buttons.next")
      /// Previous
      public static let previous = L10n.tr("Localizable", "debug_log.buttons.previous")
    }
  }

  public enum Endpoint {
    public enum Cells {
      public enum AnyAddress {
        /// Automatic
        public static let caption = L10n.tr("Localizable", "endpoint.cells.any_address.caption")
      }
      public enum AnyProtocol {
        /// Automatic
        public static let caption = L10n.tr("Localizable", "endpoint.cells.any_protocol.caption")
      }
    }
    public enum Sections {
      public enum LocationAddresses {
        /// Addresses
        public static let header = L10n.tr("Localizable", "endpoint.sections.location_addresses.header")
      }
      public enum LocationProtocols {
        /// Protocols
        public static let header = L10n.tr("Localizable", "endpoint.sections.location_protocols.header")
      }
    }
  }

  public enum Global {
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "global.cancel")
    /// Close
    public static let close = L10n.tr("Localizable", "global.close")
    /// Next
    public static let next = L10n.tr("Localizable", "global.next")
    /// OK
    public static let ok = L10n.tr("Localizable", "global.ok")
    public enum Host {
      public enum TitleInput {
        /// Acceptable characters are alphanumerics plus dash "-", underscore "_" and dot ".".
        public static let message = L10n.tr("Localizable", "global.host.title_input.message")
        /// My profile
        public static let placeholder = L10n.tr("Localizable", "global.host.title_input.placeholder")
      }
    }
  }

  public enum ImportedHosts {
    /// Imported hosts
    public static let title = L10n.tr("Localizable", "imported_hosts.title")
  }

  public enum IssueReporter {
    /// The debug log of your latest connections is crucial to resolve your connectivity issues and is completely anonymous.\n\nThe .ovpn configuration file, if any, is attached stripped of any sensitive data.\n\nPlease double check the e-mail attachments if unsure.
    public static let message = L10n.tr("Localizable", "issue_reporter.message")
    /// Report issue
    public static let title = L10n.tr("Localizable", "issue_reporter.title")
    public enum Alerts {
      public enum EmailNotConfigured {
        /// No e-mail account is configured.
        public static let message = L10n.tr("Localizable", "issue_reporter.alerts.email_not_configured.message")
      }
    }
    public enum Buttons {
      /// I understand
      public static let accept = L10n.tr("Localizable", "issue_reporter.buttons.accept")
    }
    public enum Email {
      /// Hi,\n\n%@\n\n%@\n\nRegards
      public static func body(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "issue_reporter.email.body", p1, p2)
      }
      /// description of the issue:
      public static let description = L10n.tr("Localizable", "issue_reporter.email.description")
      /// %@ - Report issue
      public static func subject(_ p1: String) -> String {
        return L10n.tr("Localizable", "issue_reporter.email.subject", p1)
      }
    }
  }

  public enum Label {
    public enum License {
      /// Unable to download full license content.
      public static let error = L10n.tr("Localizable", "label.license.error")
    }
  }

  public enum Organizer {
    public enum Alerts {
      public enum AddHost {
        /// Open an URL to an .ovpn configuration file from Safari, Mail or another app to set up a host profile.\n\nYou can also import an .ovpn with iTunes File Sharing.
        public static let message = L10n.tr("Localizable", "organizer.alerts.add_host.message")
      }
      public enum DeleteVpnProfile {
        /// Do you really want to erase the VPN configuration from your device settings? This may fix some broken VPN states and will not affect your provider and host profiles.
        public static let message = L10n.tr("Localizable", "organizer.alerts.delete_vpn_profile.message")
      }
      public enum ExhaustedProviders {
        /// You have created profiles for any available provider.
        public static let message = L10n.tr("Localizable", "organizer.alerts.exhausted_providers.message")
      }
    }
    public enum Cells {
      public enum About {
        /// About %@
        public static func caption(_ p1: String) -> String {
          return L10n.tr("Localizable", "organizer.cells.about.caption", p1)
        }
      }
      public enum AddHost {
        /// Add new host
        public static let caption = L10n.tr("Localizable", "organizer.cells.add_host.caption")
      }
      public enum AddProvider {
        /// Add new provider
        public static let caption = L10n.tr("Localizable", "organizer.cells.add_provider.caption")
      }
      public enum Donate {
        /// Make a donation
        public static let caption = L10n.tr("Localizable", "organizer.cells.donate.caption")
      }
      public enum Patreon {
        /// Support me on Patreon
        public static let caption = L10n.tr("Localizable", "organizer.cells.patreon.caption")
      }
      public enum Profile {
        public enum Value {
          /// In use
          public static let current = L10n.tr("Localizable", "organizer.cells.profile.value.current")
        }
      }
      public enum SiriShortcuts {
        /// Manage shortcuts
        public static let caption = L10n.tr("Localizable", "organizer.cells.siri_shortcuts.caption")
      }
      public enum Uninstall {
        /// Remove VPN configuration
        public static let caption = L10n.tr("Localizable", "organizer.cells.uninstall.caption")
      }
    }
    public enum Sections {
      public enum Hosts {
        /// Import hosts from raw .ovpn configuration files.
        public static let footer = L10n.tr("Localizable", "organizer.sections.hosts.footer")
        /// Hosts
        public static let header = L10n.tr("Localizable", "organizer.sections.hosts.header")
      }
      public enum Providers {
        /// Here you find a few providers with preset configuration profiles.
        public static let footer = L10n.tr("Localizable", "organizer.sections.providers.footer")
        /// Providers
        public static let header = L10n.tr("Localizable", "organizer.sections.providers.header")
      }
      public enum Siri {
        /// Get help from Siri to speed up your most common interactions with the app.
        public static let footer = L10n.tr("Localizable", "organizer.sections.siri.footer")
        /// Siri
        public static let header = L10n.tr("Localizable", "organizer.sections.siri.header")
      }
      public enum Support {
        /// Support
        public static let header = L10n.tr("Localizable", "organizer.sections.support.header")
      }
    }
  }

  public enum ParsedFile {
    public enum Alerts {
      public enum Buttons {
        /// Report an issue
        public static let report = L10n.tr("Localizable", "parsed_file.alerts.buttons.report")
      }
      public enum Decryption {
        /// The configuration contains an encrypted private key and it could not be decrypted. Double check your entered passphrase.
        public static let message = L10n.tr("Localizable", "parsed_file.alerts.decryption.message")
      }
      public enum EncryptionPassphrase {
        /// Please enter the encryption passphrase.
        public static let message = L10n.tr("Localizable", "parsed_file.alerts.encryption_passphrase.message")
      }
      public enum Malformed {
        /// The configuration file contains a malformed option (%@).
        public static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.malformed.message", p1)
        }
      }
      public enum Missing {
        /// The configuration file lacks a required option (%@).
        public static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.missing.message", p1)
        }
      }
      public enum Parsing {
        /// Unable to parse the provided configuration file (%@).
        public static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.parsing.message", p1)
        }
      }
      public enum PotentiallyUnsupported {
        /// The configuration file is correct but contains a potentially unsupported option (%@).\n\nConnectivity may break depending on server settings.
        public static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.potentially_unsupported.message", p1)
        }
      }
      public enum Unsupported {
        /// The configuration file contains an unsupported option (%@).
        public static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "parsed_file.alerts.unsupported.message", p1)
        }
      }
    }
  }

  public enum Provider {
    public enum Pool {
      public enum Sections {
        public enum Free {
          /// Free
          public static let header = L10n.tr("Localizable", "provider.pool.sections.free.header")
        }
        public enum Paid {
          /// Paid
          public static let header = L10n.tr("Localizable", "provider.pool.sections.paid.header")
        }
      }
    }
    public enum Preset {
      public enum Cells {
        public enum TechDetails {
          /// Technical details
          public static let caption = L10n.tr("Localizable", "provider.preset.cells.tech_details.caption")
        }
      }
    }
  }

  public enum Reddit {
    /// Did you know that Passepartout has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.\n\nIt's also a great way to show you care about this project.
    public static let message = L10n.tr("Localizable", "reddit.message")
    /// Reddit
    public static let title = L10n.tr("Localizable", "reddit.title")
    public enum Buttons {
      /// Don't ask again
      public static let never = L10n.tr("Localizable", "reddit.buttons.never")
      /// Remind me later
      public static let remind = L10n.tr("Localizable", "reddit.buttons.remind")
      /// Subscribe now!
      public static let subscribe = L10n.tr("Localizable", "reddit.buttons.subscribe")
    }
  }

  public enum Service {
    public enum Alerts {
      public enum Buttons {
        /// Reconnect
        public static let reconnect = L10n.tr("Localizable", "service.alerts.buttons.reconnect")
      }
      public enum CredentialsNeeded {
        /// You need to enter account credentials first.
        public static let message = L10n.tr("Localizable", "service.alerts.credentials_needed.message")
      }
      public enum DataCount {
        public enum Messages {
          /// Received: %llu\nSent: %llu
          public static func current(_ p1: Int, _ p2: Int) -> String {
            return L10n.tr("Localizable", "service.alerts.data_count.messages.current", p1, p2)
          }
          /// Information not available, are you connected?
          public static let notAvailable = L10n.tr("Localizable", "service.alerts.data_count.messages.not_available")
        }
      }
      public enum MasksPrivateData {
        public enum Messages {
          /// In order to safely reset the current debug log and apply the new masking preference, you must reconnect to the VPN now.
          public static let mustReconnect = L10n.tr("Localizable", "service.alerts.masks_private_data.messages.must_reconnect")
        }
      }
      public enum ReconnectVpn {
        /// Do you want to reconnect to the VPN?
        public static let message = L10n.tr("Localizable", "service.alerts.reconnect_vpn.message")
      }
      public enum Rename {
        /// Rename profile
        public static let title = L10n.tr("Localizable", "service.alerts.rename.title")
      }
      public enum TestConnectivity {
        /// Connectivity
        public static let title = L10n.tr("Localizable", "service.alerts.test_connectivity.title")
        public enum Messages {
          /// Your device has no Internet connectivity, please review your profile parameters.
          public static let failure = L10n.tr("Localizable", "service.alerts.test_connectivity.messages.failure")
          /// Your device is connected to the Internet!
          public static let success = L10n.tr("Localizable", "service.alerts.test_connectivity.messages.success")
        }
      }
      public enum Trusted {
        public enum NoNetwork {
          /// You are not connected to any Wi-Fi network.
          public static let message = L10n.tr("Localizable", "service.alerts.trusted.no_network.message")
        }
        public enum WillDisconnectPolicy {
          /// By changing the trust policy, the VPN may be disconnected. Continue?
          public static let message = L10n.tr("Localizable", "service.alerts.trusted.will_disconnect_policy.message")
        }
        public enum WillDisconnectTrusted {
          /// By trusting this network, the VPN may be disconnected. Continue?
          public static let message = L10n.tr("Localizable", "service.alerts.trusted.will_disconnect_trusted.message")
        }
      }
    }
    public enum Cells {
      public enum Account {
        /// Account
        public static let caption = L10n.tr("Localizable", "service.cells.account.caption")
        /// None configured
        public static let `none` = L10n.tr("Localizable", "service.cells.account.none")
      }
      public enum ConnectionStatus {
        /// Status
        public static let caption = L10n.tr("Localizable", "service.cells.connection_status.caption")
      }
      public enum DataCount {
        /// Exchanged data
        public static let caption = L10n.tr("Localizable", "service.cells.data_count.caption")
        /// Unavailable
        public static let `none` = L10n.tr("Localizable", "service.cells.data_count.none")
        /// ↓%@ / ↑%@
        public static func value(_ p1: String, _ p2: String) -> String {
          return L10n.tr("Localizable", "service.cells.data_count.value", p1, p2)
        }
      }
      public enum DebugLog {
        /// Debug log
        public static let caption = L10n.tr("Localizable", "service.cells.debug_log.caption")
      }
      public enum Endpoint {
        /// Endpoint
        public static let caption = L10n.tr("Localizable", "service.cells.endpoint.caption")
        public enum Value {
          /// Automatic
          public static let automatic = L10n.tr("Localizable", "service.cells.endpoint.value.automatic")
          /// Manual
          public static let manual = L10n.tr("Localizable", "service.cells.endpoint.value.manual")
        }
      }
      public enum Host {
        public enum Parameters {
          /// Parameters
          public static let caption = L10n.tr("Localizable", "service.cells.host.parameters.caption")
          public enum Value {
            /// %@
            public static func cipher(_ p1: String) -> String {
              return L10n.tr("Localizable", "service.cells.host.parameters.value.cipher", p1)
            }
            /// %@ / %@
            public static func cipherDigest(_ p1: String, _ p2: String) -> String {
              return L10n.tr("Localizable", "service.cells.host.parameters.value.cipher_digest", p1, p2)
            }
          }
        }
      }
      public enum MasksPrivateData {
        /// Mask network data
        public static let caption = L10n.tr("Localizable", "service.cells.masks_private_data.caption")
      }
      public enum Provider {
        public enum Pool {
          /// Location
          public static let caption = L10n.tr("Localizable", "service.cells.provider.pool.caption")
        }
        public enum Preset {
          /// Preset
          public static let caption = L10n.tr("Localizable", "service.cells.provider.preset.caption")
        }
        public enum Refresh {
          /// Refresh infrastructure
          public static let caption = L10n.tr("Localizable", "service.cells.provider.refresh.caption")
        }
      }
      public enum Reconnect {
        /// Reconnect
        public static let caption = L10n.tr("Localizable", "service.cells.reconnect.caption")
      }
      public enum ReportIssue {
        /// Report connectivity issue
        public static let caption = L10n.tr("Localizable", "service.cells.report_issue.caption")
      }
      public enum TestConnectivity {
        /// Test connectivity
        public static let caption = L10n.tr("Localizable", "service.cells.test_connectivity.caption")
      }
      public enum TrustedAddWifi {
        /// Add current Wi-Fi
        public static let caption = L10n.tr("Localizable", "service.cells.trusted_add_wifi.caption")
      }
      public enum TrustedMobile {
        /// Cellular network
        public static let caption = L10n.tr("Localizable", "service.cells.trusted_mobile.caption")
      }
      public enum TrustedPolicy {
        /// Trust disables VPN
        public static let caption = L10n.tr("Localizable", "service.cells.trusted_policy.caption")
      }
      public enum TrustedWifi {
        /// %@
        public static func caption(_ p1: String) -> String {
          return L10n.tr("Localizable", "service.cells.trusted_wifi.caption", p1)
        }
      }
      public enum UseProfile {
        /// Use this profile
        public static let caption = L10n.tr("Localizable", "service.cells.use_profile.caption")
      }
      public enum VpnResolvesHostname {
        /// Resolve server hostname
        public static let caption = L10n.tr("Localizable", "service.cells.vpn_resolves_hostname.caption")
      }
      public enum VpnService {
        /// Enabled
        public static let caption = L10n.tr("Localizable", "service.cells.vpn_service.caption")
      }
      public enum VpnSurvivesSleep {
        /// Keep alive on sleep
        public static let caption = L10n.tr("Localizable", "service.cells.vpn_survives_sleep.caption")
      }
    }
    public enum Sections {
      public enum Configuration {
        /// Configuration
        public static let header = L10n.tr("Localizable", "service.sections.configuration.header")
      }
      public enum Diagnostics {
        /// Masking status will be effective after reconnecting. Network data is hostnames, IP addresses, routing, SSID. Credentials and private keys are not logged regardless.
        public static let footer = L10n.tr("Localizable", "service.sections.diagnostics.footer")
        /// Diagnostics
        public static let header = L10n.tr("Localizable", "service.sections.diagnostics.header")
      }
      public enum General {
        /// General
        public static let header = L10n.tr("Localizable", "service.sections.general.header")
      }
      public enum ProviderInfrastructure {
        /// Last updated on %@.
        public static func footer(_ p1: String) -> String {
          return L10n.tr("Localizable", "service.sections.provider_infrastructure.footer", p1)
        }
      }
      public enum Status {
        /// Connection
        public static let header = L10n.tr("Localizable", "service.sections.status.header")
      }
      public enum Trusted {
        /// When entering a trusted network, the VPN is normally shut down and kept disconnected. Disable this option to not enforce such behavior.
        public static let footer = L10n.tr("Localizable", "service.sections.trusted.footer")
        /// Trusted networks
        public static let header = L10n.tr("Localizable", "service.sections.trusted.header")
      }
      public enum Vpn {
        /// The connection will be established whenever necessary.
        public static let footer = L10n.tr("Localizable", "service.sections.vpn.footer")
        /// VPN
        public static let header = L10n.tr("Localizable", "service.sections.vpn.header")
      }
      public enum VpnResolvesHostname {
        /// Preferred in most networks and required in some IPv6 networks. Disable where DNS is blocked, or to speed up negotiation when DNS is slow to respond.
        public static let footer = L10n.tr("Localizable", "service.sections.vpn_resolves_hostname.footer")
      }
      public enum VpnSurvivesSleep {
        /// Disable to improve battery usage, at the expense of occasional slowdowns due to wake-up reconnections.
        public static let footer = L10n.tr("Localizable", "service.sections.vpn_survives_sleep.footer")
      }
    }
    public enum Welcome {
      /// Welcome to Passepartout!\n\nUse the organizer to add a new profile.
      public static let message = L10n.tr("Localizable", "service.welcome.message")
    }
  }

  public enum Share {
    /// Passepartout is an user-friendly, open source OpenVPN client for iOS and macOS
    public static let message = L10n.tr("Localizable", "share.message")
  }

  public enum Shortcuts {
    public enum Add {
      /// Add shortcut
      public static let title = L10n.tr("Localizable", "shortcuts.add.title")
      public enum Alerts {
        public enum NoProfiles {
          /// There is no profile to connect to.
          public static let message = L10n.tr("Localizable", "shortcuts.add.alerts.no_profiles.message")
        }
      }
      public enum Cells {
        public enum Connect {
          /// Connect to
          public static let caption = L10n.tr("Localizable", "shortcuts.add.cells.connect.caption")
        }
        public enum DisableVpn {
          /// Disable VPN
          public static let caption = L10n.tr("Localizable", "shortcuts.add.cells.disable_vpn.caption")
        }
        public enum EnableVpn {
          /// Enable VPN
          public static let caption = L10n.tr("Localizable", "shortcuts.add.cells.enable_vpn.caption")
        }
        public enum TrustCellular {
          /// Trust cellular network
          public static let caption = L10n.tr("Localizable", "shortcuts.add.cells.trust_cellular.caption")
        }
        public enum TrustCurrentWifi {
          /// Trust current Wi-Fi
          public static let caption = L10n.tr("Localizable", "shortcuts.add.cells.trust_current_wifi.caption")
        }
        public enum UntrustCellular {
          /// Untrust cellular network
          public static let caption = L10n.tr("Localizable", "shortcuts.add.cells.untrust_cellular.caption")
        }
        public enum UntrustCurrentWifi {
          /// Untrust current Wi-Fi
          public static let caption = L10n.tr("Localizable", "shortcuts.add.cells.untrust_current_wifi.caption")
        }
      }
      public enum Sections {
        public enum Cellular {
          /// Cellular
          public static let header = L10n.tr("Localizable", "shortcuts.add.sections.cellular.header")
        }
        public enum Vpn {
          /// VPN
          public static let header = L10n.tr("Localizable", "shortcuts.add.sections.vpn.header")
        }
        public enum Wifi {
          /// Wi-Fi
          public static let header = L10n.tr("Localizable", "shortcuts.add.sections.wifi.header")
        }
      }
    }
    public enum Edit {
      /// Manage shortcuts
      public static let title = L10n.tr("Localizable", "shortcuts.edit.title")
      public enum Cells {
        public enum AddShortcut {
          /// Add shortcut
          public static let caption = L10n.tr("Localizable", "shortcuts.edit.cells.add_shortcut.caption")
        }
      }
      public enum Sections {
        public enum All {
          /// Existing shortcuts
          public static let header = L10n.tr("Localizable", "shortcuts.edit.sections.all.header")
        }
      }
    }
  }

  public enum Version {
    /// Version
    public static let title = L10n.tr("Localizable", "version.title")
    public enum Buttons {
      /// CHANGELOG
      public static let changelog = L10n.tr("Localizable", "version.buttons.changelog")
      /// CREDITS
      public static let credits = L10n.tr("Localizable", "version.buttons.credits")
    }
    public enum Labels {
      /// Passepartout and TunnelKit are written and maintained by Davide De Rosa (keeshux).\n\nSource code for Passepartout and TunnelKit is publicly available on GitHub under the GPLv3, you can find links in the home page.\n\nPassepartout is a non-official client and is in no way affiliated with OpenVPN Inc.
      public static let intro = L10n.tr("Localizable", "version.labels.intro")
    }
  }

  public enum Vpn {
    /// Active
    public static let active = L10n.tr("Localizable", "vpn.active")
    /// Connecting
    public static let connecting = L10n.tr("Localizable", "vpn.connecting")
    /// Disabled
    public static let disabled = L10n.tr("Localizable", "vpn.disabled")
    /// Disconnecting
    public static let disconnecting = L10n.tr("Localizable", "vpn.disconnecting")
    /// Inactive
    public static let inactive = L10n.tr("Localizable", "vpn.inactive")
    public enum Errors {
      /// Auth failed
      public static let auth = L10n.tr("Localizable", "vpn.errors.auth")
      /// Compression unsupported
      public static let compression = L10n.tr("Localizable", "vpn.errors.compression")
      /// DNS failed
      public static let dns = L10n.tr("Localizable", "vpn.errors.dns")
      /// Encryption failed
      public static let encryption = L10n.tr("Localizable", "vpn.errors.encryption")
      /// Network changed
      public static let network = L10n.tr("Localizable", "vpn.errors.network")
      /// Timeout
      public static let timeout = L10n.tr("Localizable", "vpn.errors.timeout")
      /// TLS failed
      public static let tls = L10n.tr("Localizable", "vpn.errors.tls")
    }
  }

  public enum Wizards {
    public enum Host {
      public enum Alerts {
        public enum Existing {
          /// A host profile with the same title already exists. Replace it?
          public static let message = L10n.tr("Localizable", "wizards.host.alerts.existing.message")
        }
      }
      public enum Cells {
        public enum TitleInput {
          /// Title
          public static let caption = L10n.tr("Localizable", "wizards.host.cells.title_input.caption")
        }
      }
      public enum Sections {
        public enum Existing {
          /// Existing profiles
          public static let header = L10n.tr("Localizable", "wizards.host.sections.existing.header")
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
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
