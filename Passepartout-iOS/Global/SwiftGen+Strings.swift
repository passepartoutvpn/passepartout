// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  internal enum App {
    internal enum Account {
      internal enum Sections {
        internal enum Credentials {
          /// Credentials
          internal static let header = L10n.tr("App", "account.sections.credentials.header")
        }
      }
    }
    internal enum Endpoint {
      internal enum Sections {
        internal enum LocationAddresses {
          /// Addresses
          internal static let header = L10n.tr("App", "endpoint.sections.location_addresses.header")
        }
        internal enum LocationProtocols {
          /// Protocols
          internal static let header = L10n.tr("App", "endpoint.sections.location_protocols.header")
        }
      }
    }
    internal enum ImportedHosts {
      /// Imported hosts
      internal static let title = L10n.tr("App", "imported_hosts.title")
    }
    internal enum NetworkSettings {
      internal enum Cells {
        internal enum AddDnsDomain {
          /// Add search domain
          internal static let caption = L10n.tr("App", "network_settings.cells.add_dns_domain.caption")
        }
        internal enum AddDnsServer {
          /// Add address
          internal static let caption = L10n.tr("App", "network_settings.cells.add_dns_server.caption")
        }
        internal enum AddProxyBypass {
          /// Add bypass domain
          internal static let caption = L10n.tr("App", "network_settings.cells.add_proxy_bypass.caption")
        }
        internal enum ProxyBypass {
          /// Bypass domain
          internal static let caption = L10n.tr("App", "network_settings.cells.proxy_bypass.caption")
        }
      }
    }
    internal enum Organizer {
      internal enum Cells {
        internal enum AddHost {
          /// Add new host
          internal static let caption = L10n.tr("App", "organizer.cells.add_host.caption")
        }
        internal enum AddProvider {
          /// Add new provider
          internal static let caption = L10n.tr("App", "organizer.cells.add_provider.caption")
        }
      }
    }
    internal enum Provider {
      internal enum Preset {
        internal enum Cells {
          internal enum TechDetails {
            /// Technical details
            internal static let caption = L10n.tr("App", "provider.preset.cells.tech_details.caption")
          }
        }
      }
    }
    internal enum Purchase {
      /// Purchase
      internal static let title = L10n.tr("App", "purchase.title")
      internal enum Cells {
        internal enum FullVersion {
          /// - All providers (including the future ones)\n%@
          internal static func extraDescription(_ p1: String) -> String {
            return L10n.tr("App", "purchase.cells.full_version.extra_description", p1)
          }
        }
        internal enum Restore {
          /// If you bought this app or feature in the past, you can restore your purchases and this screen won't show again.
          internal static let description = L10n.tr("App", "purchase.cells.restore.description")
          /// Restore purchases
          internal static let title = L10n.tr("App", "purchase.cells.restore.title")
        }
      }
      internal enum Sections {
        internal enum Products {
          /// Every product is a one-time purchase.
          internal static let footer = L10n.tr("App", "purchase.sections.products.footer")
        }
      }
    }
    internal enum Service {
      internal enum Alerts {
        internal enum Location {
          internal enum Button {
            /// Settings
            internal static let settings = L10n.tr("App", "service.alerts.location.button.settings")
          }
          internal enum Message {
            /// You must allow location access to trust this Wi-Fi network. Go to iOS settings and review your location permissions for Passepartout.
            internal static let denied = L10n.tr("App", "service.alerts.location.message.denied")
          }
        }
      }
      internal enum Cells {
        internal enum Host {
          internal enum Parameters {
            /// Parameters
            internal static let caption = L10n.tr("App", "service.cells.host.parameters.caption")
          }
        }
        internal enum Provider {
          internal enum Refresh {
            /// Refresh infrastructure
            internal static let caption = L10n.tr("App", "service.cells.provider.refresh.caption")
          }
        }
        internal enum TrustedAddWifi {
          /// Add current Wi-Fi
          internal static let caption = L10n.tr("App", "service.cells.trusted_add_wifi.caption")
        }
        internal enum UseProfile {
          /// Use this profile
          internal static let caption = L10n.tr("App", "service.cells.use_profile.caption")
        }
        internal enum VpnService {
          /// Enabled
          internal static let caption = L10n.tr("App", "service.cells.vpn_service.caption")
        }
      }
      internal enum Sections {
        internal enum Configuration {
          /// Configuration
          internal static let header = L10n.tr("App", "service.sections.configuration.header")
        }
        internal enum Status {
          /// Connection
          internal static let header = L10n.tr("App", "service.sections.status.header")
        }
        internal enum Vpn {
          /// VPN
          internal static let header = L10n.tr("App", "service.sections.vpn.header")
        }
      }
    }
    internal enum Shortcuts {
      internal enum Add {
        /// Add shortcut
        internal static let title = L10n.tr("App", "shortcuts.add.title")
      }
      internal enum Edit {
        /// Manage shortcuts
        internal static let title = L10n.tr("App", "shortcuts.edit.title")
        internal enum Cells {
          internal enum AddShortcut {
            /// Add shortcut
            internal static let caption = L10n.tr("App", "shortcuts.edit.cells.add_shortcut.caption")
          }
        }
      }
    }
    internal enum Wizards {
      internal enum Host {
        internal enum Cells {
          internal enum TitleInput {
            /// Title
            internal static let caption = L10n.tr("App", "wizards.host.cells.title_input.caption")
          }
        }
        internal enum Sections {
          internal enum Existing {
            /// Existing profiles
            internal static let header = L10n.tr("App", "wizards.host.sections.existing.header")
          }
        }
      }
    }
  }
  internal enum Core {
    internal enum About {
      /// About
      internal static let title = L10n.tr("Core", "about.title")
      internal enum Cells {
        internal enum Credits {
          /// Credits
          internal static let caption = L10n.tr("Core", "about.cells.credits.caption")
        }
        internal enum Disclaimer {
          /// Disclaimer
          internal static let caption = L10n.tr("Core", "about.cells.disclaimer.caption")
        }
        internal enum Faq {
          /// FAQ
          internal static let caption = L10n.tr("Core", "about.cells.faq.caption")
        }
        internal enum PrivacyPolicy {
          /// Privacy policy
          internal static let caption = L10n.tr("Core", "about.cells.privacy_policy.caption")
        }
        internal enum ShareGeneric {
          /// Invite a friend
          internal static let caption = L10n.tr("Core", "about.cells.share_generic.caption")
        }
        internal enum ShareTwitter {
          /// Tweet about it!
          internal static let caption = L10n.tr("Core", "about.cells.share_twitter.caption")
        }
        internal enum Website {
          /// Home page
          internal static let caption = L10n.tr("Core", "about.cells.website.caption")
        }
      }
      internal enum Sections {
        internal enum Share {
          /// Share
          internal static let header = L10n.tr("Core", "about.sections.share.header")
        }
        internal enum Web {
          /// Web
          internal static let header = L10n.tr("Core", "about.sections.web.header")
        }
      }
    }
    internal enum Account {
      /// Account
      internal static let title = L10n.tr("Core", "account.title")
      internal enum Cells {
        internal enum OpenGuide {
          /// See your credentials
          internal static let caption = L10n.tr("Core", "account.cells.open_guide.caption")
        }
        internal enum Password {
          /// Password
          internal static let caption = L10n.tr("Core", "account.cells.password.caption")
          /// secret
          internal static let placeholder = L10n.tr("Core", "account.cells.password.placeholder")
        }
        internal enum Signup {
          /// Register with %@
          internal static func caption(_ p1: String) -> String {
            return L10n.tr("Core", "account.cells.signup.caption", p1)
          }
        }
        internal enum Username {
          /// Username
          internal static let caption = L10n.tr("Core", "account.cells.username.caption")
          /// username
          internal static let placeholder = L10n.tr("Core", "account.cells.username.placeholder")
        }
      }
      internal enum Sections {
        internal enum Guidance {
          internal enum Footer {
            internal enum Infrastructure {
              /// Use your %@ website credentials. Your username is usually numeric.
              internal static func mullvad(_ p1: String) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.mullvad", p1)
              }
              /// Use your %@ website credentials. Your username is usually your e-mail.
              internal static func nordvpn(_ p1: String) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.nordvpn", p1)
              }
              /// Use your %@ website credentials. Your username is usually numeric with a "p" prefix.
              internal static func pia(_ p1: String) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.pia", p1)
              }
              /// Find your %@ credentials in the "Account > OpenVPN / IKEv2 Username" section of the website.
              internal static func protonvpn(_ p1: String) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.protonvpn", p1)
              }
              /// Use your %@ website credentials. Your username is usually your e-mail.
              internal static func tunnelbear(_ p1: String) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.tunnelbear", p1)
              }
              /// Use your %@ website credentials. Your username is usually your e-mail.
              internal static func vyprvpn(_ p1: String) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.vyprvpn", p1)
              }
              /// Find your %@ credentials in the OpenVPN Config Generator on the website.
              internal static func windscribe(_ p1: String) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.windscribe", p1)
              }
            }
          }
        }
        internal enum Registration {
          /// Go get an account on the %@ website.
          internal static func footer(_ p1: String) -> String {
            return L10n.tr("Core", "account.sections.registration.footer", p1)
          }
        }
      }
    }
    internal enum Configuration {
      internal enum Cells {
        internal enum Cipher {
          /// Cipher
          internal static let caption = L10n.tr("Core", "configuration.cells.cipher.caption")
        }
        internal enum Client {
          /// Client certificate
          internal static let caption = L10n.tr("Core", "configuration.cells.client.caption")
          internal enum Value {
            /// Not verified
            internal static let disabled = L10n.tr("Core", "configuration.cells.client.value.disabled")
            /// Verified
            internal static let enabled = L10n.tr("Core", "configuration.cells.client.value.enabled")
          }
        }
        internal enum CompressionAlgorithm {
          /// Algorithm
          internal static let caption = L10n.tr("Core", "configuration.cells.compression_algorithm.caption")
          internal enum Value {
            /// LZO
            internal static let lzo = L10n.tr("Core", "configuration.cells.compression_algorithm.value.lzo")
            /// Unsupported
            internal static let other = L10n.tr("Core", "configuration.cells.compression_algorithm.value.other")
          }
        }
        internal enum CompressionFraming {
          /// Framing
          internal static let caption = L10n.tr("Core", "configuration.cells.compression_framing.caption")
          internal enum Value {
            /// --compress
            internal static let compress = L10n.tr("Core", "configuration.cells.compression_framing.value.compress")
            /// --comp-lzo
            internal static let lzo = L10n.tr("Core", "configuration.cells.compression_framing.value.lzo")
          }
        }
        internal enum Digest {
          /// Authentication
          internal static let caption = L10n.tr("Core", "configuration.cells.digest.caption")
          internal enum Value {
            /// Embedded
            internal static let embedded = L10n.tr("Core", "configuration.cells.digest.value.embedded")
          }
        }
        internal enum Eku {
          /// Extended verification
          internal static let caption = L10n.tr("Core", "configuration.cells.eku.caption")
        }
        internal enum KeepAlive {
          /// Keep-alive
          internal static let caption = L10n.tr("Core", "configuration.cells.keep_alive.caption")
          internal enum Value {
            /// %d seconds
            internal static func seconds(_ p1: Int) -> String {
              return L10n.tr("Core", "configuration.cells.keep_alive.value.seconds", p1)
            }
          }
        }
        internal enum RandomEndpoint {
          /// Randomize endpoint
          internal static let caption = L10n.tr("Core", "configuration.cells.random_endpoint.caption")
        }
        internal enum RenegotiationSeconds {
          /// Renegotiation
          internal static let caption = L10n.tr("Core", "configuration.cells.renegotiation_seconds.caption")
          internal enum Value {
            /// after %@
            internal static func after(_ p1: String) -> String {
              return L10n.tr("Core", "configuration.cells.renegotiation_seconds.value.after", p1)
            }
          }
        }
        internal enum ResetOriginal {
          /// Reset configuration
          internal static let caption = L10n.tr("Core", "configuration.cells.reset_original.caption")
        }
        internal enum TlsWrapping {
          /// Wrapping
          internal static let caption = L10n.tr("Core", "configuration.cells.tls_wrapping.caption")
          internal enum Value {
            /// Authentication
            internal static let auth = L10n.tr("Core", "configuration.cells.tls_wrapping.value.auth")
            /// Encryption
            internal static let crypt = L10n.tr("Core", "configuration.cells.tls_wrapping.value.crypt")
          }
        }
      }
      internal enum Sections {
        internal enum Communication {
          /// Communication
          internal static let header = L10n.tr("Core", "configuration.sections.communication.header")
        }
        internal enum Compression {
          /// Compression
          internal static let header = L10n.tr("Core", "configuration.sections.compression.header")
        }
        internal enum Network {
          /// Network
          internal static let header = L10n.tr("Core", "configuration.sections.network.header")
        }
        internal enum Other {
          /// Other
          internal static let header = L10n.tr("Core", "configuration.sections.other.header")
        }
        internal enum Reset {
          /// If you ended up with broken connectivity after changing the communication parameters, tap to revert to the original configuration.
          internal static let footer = L10n.tr("Core", "configuration.sections.reset.footer")
        }
        internal enum Tls {
          /// TLS
          internal static let header = L10n.tr("Core", "configuration.sections.tls.header")
        }
      }
    }
    internal enum Credits {
      /// Credits
      internal static let title = L10n.tr("Core", "credits.title")
      internal enum Sections {
        internal enum Licenses {
          /// Licenses
          internal static let header = L10n.tr("Core", "credits.sections.licenses.header")
        }
        internal enum Notices {
          /// Notices
          internal static let header = L10n.tr("Core", "credits.sections.notices.header")
        }
        internal enum Translations {
          /// Translations
          internal static let header = L10n.tr("Core", "credits.sections.translations.header")
        }
      }
    }
    internal enum DebugLog {
      internal enum Alerts {
        internal enum EmptyLog {
          /// The debug log is empty.
          internal static let message = L10n.tr("Core", "debug_log.alerts.empty_log.message")
        }
      }
      internal enum Buttons {
        /// Next
        internal static let next = L10n.tr("Core", "debug_log.buttons.next")
        /// Previous
        internal static let previous = L10n.tr("Core", "debug_log.buttons.previous")
      }
    }
    internal enum Donation {
      /// Donate
      internal static let title = L10n.tr("Core", "donation.title")
      internal enum Alerts {
        internal enum Purchase {
          internal enum Failure {
            /// Unable to perform the donation. %@
            internal static func message(_ p1: String) -> String {
              return L10n.tr("Core", "donation.alerts.purchase.failure.message", p1)
            }
          }
          internal enum Success {
            /// This means a lot to me and I really hope you keep using and promoting this app.
            internal static let message = L10n.tr("Core", "donation.alerts.purchase.success.message")
            /// Thank you
            internal static let title = L10n.tr("Core", "donation.alerts.purchase.success.title")
          }
        }
      }
      internal enum Cells {
        internal enum Loading {
          /// Loading donations
          internal static let caption = L10n.tr("Core", "donation.cells.loading.caption")
        }
        internal enum Purchasing {
          /// Performing donation
          internal static let caption = L10n.tr("Core", "donation.cells.purchasing.caption")
        }
      }
      internal enum Sections {
        internal enum OneTime {
          /// If you want to display gratitude for my free work, here are a couple amounts you can donate instantly.\n\nYou will only be charged once per donation, and you can donate multiple times.
          internal static let footer = L10n.tr("Core", "donation.sections.one_time.footer")
          /// One time
          internal static let header = L10n.tr("Core", "donation.sections.one_time.header")
        }
      }
    }
    internal enum Endpoint {
      /// Endpoint
      internal static let title = L10n.tr("Core", "endpoint.title")
      internal enum Cells {
        internal enum AnyAddress {
          /// Automatic
          internal static let caption = L10n.tr("Core", "endpoint.cells.any_address.caption")
        }
        internal enum AnyProtocol {
          /// Automatic
          internal static let caption = L10n.tr("Core", "endpoint.cells.any_protocol.caption")
        }
      }
    }
    internal enum Global {
      /// Cancel
      internal static let cancel = L10n.tr("Core", "global.cancel")
      /// Close
      internal static let close = L10n.tr("Core", "global.close")
      /// No e-mail account is configured.
      internal static let emailNotConfigured = L10n.tr("Core", "global.email_not_configured")
      /// Next
      internal static let next = L10n.tr("Core", "global.next")
      /// OK
      internal static let ok = L10n.tr("Core", "global.ok")
      internal enum Captions {
        /// Address
        internal static let address = L10n.tr("Core", "global.captions.address")
        /// Port
        internal static let port = L10n.tr("Core", "global.captions.port")
      }
      internal enum Host {
        internal enum TitleInput {
          /// Acceptable characters are alphanumerics plus dash "-", underscore "_" and dot ".".
          internal static let message = L10n.tr("Core", "global.host.title_input.message")
          /// My profile
          internal static let placeholder = L10n.tr("Core", "global.host.title_input.placeholder")
        }
      }
      internal enum Values {
        /// Automatic
        internal static let automatic = L10n.tr("Core", "global.values.automatic")
        /// Disabled
        internal static let disabled = L10n.tr("Core", "global.values.disabled")
        /// Enabled
        internal static let enabled = L10n.tr("Core", "global.values.enabled")
        /// Manual
        internal static let manual = L10n.tr("Core", "global.values.manual")
        /// None
        internal static let `none` = L10n.tr("Core", "global.values.none")
      }
    }
    internal enum IssueReporter {
      /// The debug log of your latest connections is crucial to resolve your connectivity issues and is completely anonymous.\n\nThe .ovpn configuration file, if any, is attached stripped of any sensitive data.\n\nPlease double check the e-mail attachments if unsure.
      internal static let message = L10n.tr("Core", "issue_reporter.message")
      /// Report issue
      internal static let title = L10n.tr("Core", "issue_reporter.title")
      internal enum Buttons {
        /// I understand
        internal static let accept = L10n.tr("Core", "issue_reporter.buttons.accept")
      }
    }
    internal enum Label {
      internal enum License {
        /// Unable to download full license content.
        internal static let error = L10n.tr("Core", "label.license.error")
      }
    }
    internal enum NetworkChoice {
      /// Read .ovpn
      internal static let client = L10n.tr("Core", "network_choice.client")
      /// Pull from server
      internal static let server = L10n.tr("Core", "network_choice.server")
    }
    internal enum NetworkSettings {
      /// Network settings
      internal static let title = L10n.tr("Core", "network_settings.title")
      internal enum Dns {
        /// DNS
        internal static let title = L10n.tr("Core", "network_settings.dns.title")
        internal enum Cells {
          internal enum Domain {
            /// Domain
            internal static let caption = L10n.tr("Core", "network_settings.dns.cells.domain.caption")
          }
        }
      }
      internal enum Gateway {
        /// Default gateway
        internal static let title = L10n.tr("Core", "network_settings.gateway.title")
      }
      internal enum Proxy {
        /// Proxy
        internal static let title = L10n.tr("Core", "network_settings.proxy.title")
      }
    }
    internal enum Organizer {
      internal enum Alerts {
        internal enum AddHost {
          /// Open an URL to an .ovpn configuration file from Safari, Mail or another app to set up a host profile.\n\nYou can also import an .ovpn with iTunes File Sharing.
          internal static let message = L10n.tr("Core", "organizer.alerts.add_host.message")
        }
        internal enum CannotDonate {
          /// There is no payment method configured on this device.
          internal static let message = L10n.tr("Core", "organizer.alerts.cannot_donate.message")
        }
        internal enum DeleteVpnProfile {
          /// Do you really want to erase the VPN configuration from your device settings? This may fix some broken VPN states and will not affect your provider and host profiles.
          internal static let message = L10n.tr("Core", "organizer.alerts.delete_vpn_profile.message")
        }
        internal enum ExhaustedProviders {
          /// You have created profiles for any available provider.
          internal static let message = L10n.tr("Core", "organizer.alerts.exhausted_providers.message")
        }
      }
      internal enum Cells {
        internal enum About {
          /// About %@
          internal static func caption(_ p1: String) -> String {
            return L10n.tr("Core", "organizer.cells.about.caption", p1)
          }
        }
        internal enum Donate {
          /// Make a donation
          internal static let caption = L10n.tr("Core", "organizer.cells.donate.caption")
        }
        internal enum JoinCommunity {
          /// Join community
          internal static let caption = L10n.tr("Core", "organizer.cells.join_community.caption")
        }
        internal enum Patreon {
          /// Support me on Patreon
          internal static let caption = L10n.tr("Core", "organizer.cells.patreon.caption")
        }
        internal enum Profile {
          internal enum Value {
            /// In use
            internal static let current = L10n.tr("Core", "organizer.cells.profile.value.current")
          }
        }
        internal enum SiriShortcuts {
          /// Manage shortcuts
          internal static let caption = L10n.tr("Core", "organizer.cells.siri_shortcuts.caption")
        }
        internal enum Translate {
          /// Offer to translate
          internal static let caption = L10n.tr("Core", "organizer.cells.translate.caption")
        }
        internal enum Uninstall {
          /// Remove VPN configuration
          internal static let caption = L10n.tr("Core", "organizer.cells.uninstall.caption")
        }
        internal enum WriteReview {
          /// Write a review
          internal static let caption = L10n.tr("Core", "organizer.cells.write_review.caption")
        }
      }
      internal enum Sections {
        internal enum Feedback {
          /// Feedback
          internal static let header = L10n.tr("Core", "organizer.sections.feedback.header")
        }
        internal enum Hosts {
          /// Import hosts from raw .ovpn configuration files.
          internal static let footer = L10n.tr("Core", "organizer.sections.hosts.footer")
          /// Hosts
          internal static let header = L10n.tr("Core", "organizer.sections.hosts.header")
        }
        internal enum Providers {
          /// Here you find a few providers with preset configuration profiles.
          internal static let footer = L10n.tr("Core", "organizer.sections.providers.footer")
          /// Providers
          internal static let header = L10n.tr("Core", "organizer.sections.providers.header")
        }
        internal enum Siri {
          /// Get help from Siri to speed up your most common interactions with the app.
          internal static let footer = L10n.tr("Core", "organizer.sections.siri.footer")
          /// Siri
          internal static let header = L10n.tr("Core", "organizer.sections.siri.header")
        }
        internal enum Support {
          /// Support
          internal static let header = L10n.tr("Core", "organizer.sections.support.header")
        }
      }
    }
    internal enum ParsedFile {
      internal enum Alerts {
        internal enum Buttons {
          /// Report an issue
          internal static let report = L10n.tr("Core", "parsed_file.alerts.buttons.report")
        }
        internal enum Decryption {
          /// The configuration contains an encrypted private key and it could not be decrypted. Double check your entered passphrase.
          internal static let message = L10n.tr("Core", "parsed_file.alerts.decryption.message")
        }
        internal enum EncryptionPassphrase {
          /// Please enter the encryption passphrase.
          internal static let message = L10n.tr("Core", "parsed_file.alerts.encryption_passphrase.message")
        }
        internal enum Malformed {
          /// The configuration file contains a malformed option (%@).
          internal static func message(_ p1: String) -> String {
            return L10n.tr("Core", "parsed_file.alerts.malformed.message", p1)
          }
        }
        internal enum Missing {
          /// The configuration file lacks a required option (%@).
          internal static func message(_ p1: String) -> String {
            return L10n.tr("Core", "parsed_file.alerts.missing.message", p1)
          }
        }
        internal enum Parsing {
          /// Unable to parse the provided configuration file (%@).
          internal static func message(_ p1: String) -> String {
            return L10n.tr("Core", "parsed_file.alerts.parsing.message", p1)
          }
        }
        internal enum PotentiallyUnsupported {
          /// The configuration file is correct but contains a potentially unsupported option (%@).\n\nConnectivity may break depending on server settings.
          internal static func message(_ p1: String) -> String {
            return L10n.tr("Core", "parsed_file.alerts.potentially_unsupported.message", p1)
          }
        }
        internal enum Unsupported {
          /// The configuration file contains an unsupported option (%@).
          internal static func message(_ p1: String) -> String {
            return L10n.tr("Core", "parsed_file.alerts.unsupported.message", p1)
          }
        }
      }
    }
    internal enum Reddit {
      /// Did you know that Passepartout has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.\n\nIt's also a great way to show you care about this project.
      internal static let message = L10n.tr("Core", "reddit.message")
      /// Reddit
      internal static let title = L10n.tr("Core", "reddit.title")
      internal enum Buttons {
        /// Don't ask again
        internal static let never = L10n.tr("Core", "reddit.buttons.never")
        /// Remind me later
        internal static let remind = L10n.tr("Core", "reddit.buttons.remind")
        /// Subscribe now!
        internal static let subscribe = L10n.tr("Core", "reddit.buttons.subscribe")
      }
    }
    internal enum ServerNetwork {
      internal enum Cells {
        internal enum Route {
          /// Route
          internal static let caption = L10n.tr("Core", "server_network.cells.route.caption")
        }
      }
    }
    internal enum Service {
      internal enum Alerts {
        internal enum Buttons {
          /// Reconnect
          internal static let reconnect = L10n.tr("Core", "service.alerts.buttons.reconnect")
        }
        internal enum Configuration {
          /// Configuration unavailable, make sure you are connected to the VPN.
          internal static let disconnected = L10n.tr("Core", "service.alerts.configuration.disconnected")
        }
        internal enum CredentialsNeeded {
          /// You need to enter account credentials first.
          internal static let message = L10n.tr("Core", "service.alerts.credentials_needed.message")
        }
        internal enum Download {
          /// Failed to download configuration files. %@
          internal static func failed(_ p1: String) -> String {
            return L10n.tr("Core", "service.alerts.download.failed", p1)
          }
          /// %@ requires the download of additional configuration files.\n\nConfirm to start the download.
          internal static func message(_ p1: String) -> String {
            return L10n.tr("Core", "service.alerts.download.message", p1)
          }
          /// Download required
          internal static let title = L10n.tr("Core", "service.alerts.download.title")
          internal enum Hud {
            /// Extracting files, please be patient...
            internal static let extracting = L10n.tr("Core", "service.alerts.download.hud.extracting")
          }
        }
        internal enum MasksPrivateData {
          internal enum Messages {
            /// In order to safely reset the current debug log and apply the new masking preference, you must reconnect to the VPN now.
            internal static let mustReconnect = L10n.tr("Core", "service.alerts.masks_private_data.messages.must_reconnect")
          }
        }
        internal enum ReconnectVpn {
          /// Do you want to reconnect to the VPN?
          internal static let message = L10n.tr("Core", "service.alerts.reconnect_vpn.message")
        }
        internal enum Rename {
          /// Rename profile
          internal static let title = L10n.tr("Core", "service.alerts.rename.title")
        }
        internal enum TestConnectivity {
          /// Connectivity
          internal static let title = L10n.tr("Core", "service.alerts.test_connectivity.title")
          internal enum Messages {
            /// Your device has no Internet connectivity, please review your profile parameters.
            internal static let failure = L10n.tr("Core", "service.alerts.test_connectivity.messages.failure")
            /// Your device is connected to the Internet!
            internal static let success = L10n.tr("Core", "service.alerts.test_connectivity.messages.success")
          }
        }
        internal enum Trusted {
          internal enum NoNetwork {
            /// You are not connected to any Wi-Fi network.
            internal static let message = L10n.tr("Core", "service.alerts.trusted.no_network.message")
          }
          internal enum WillDisconnectPolicy {
            /// By changing the trust policy, the VPN may be disconnected. Continue?
            internal static let message = L10n.tr("Core", "service.alerts.trusted.will_disconnect_policy.message")
          }
          internal enum WillDisconnectTrusted {
            /// By trusting this network, the VPN may be disconnected. Continue?
            internal static let message = L10n.tr("Core", "service.alerts.trusted.will_disconnect_trusted.message")
          }
        }
      }
      internal enum Cells {
        internal enum ConnectionStatus {
          /// Status
          internal static let caption = L10n.tr("Core", "service.cells.connection_status.caption")
        }
        internal enum DataCount {
          /// Exchanged data
          internal static let caption = L10n.tr("Core", "service.cells.data_count.caption")
          /// Unavailable
          internal static let `none` = L10n.tr("Core", "service.cells.data_count.none")
        }
        internal enum DebugLog {
          /// Debug log
          internal static let caption = L10n.tr("Core", "service.cells.debug_log.caption")
        }
        internal enum MasksPrivateData {
          /// Mask network data
          internal static let caption = L10n.tr("Core", "service.cells.masks_private_data.caption")
        }
        internal enum Provider {
          internal enum Pool {
            /// Location
            internal static let caption = L10n.tr("Core", "service.cells.provider.pool.caption")
          }
          internal enum Preset {
            /// Preset
            internal static let caption = L10n.tr("Core", "service.cells.provider.preset.caption")
          }
        }
        internal enum Reconnect {
          /// Reconnect
          internal static let caption = L10n.tr("Core", "service.cells.reconnect.caption")
        }
        internal enum ReportIssue {
          /// Report connectivity issue
          internal static let caption = L10n.tr("Core", "service.cells.report_issue.caption")
        }
        internal enum ServerConfiguration {
          /// Server configuration
          internal static let caption = L10n.tr("Core", "service.cells.server_configuration.caption")
        }
        internal enum ServerNetwork {
          /// Server network
          internal static let caption = L10n.tr("Core", "service.cells.server_network.caption")
        }
        internal enum TestConnectivity {
          /// Test connectivity
          internal static let caption = L10n.tr("Core", "service.cells.test_connectivity.caption")
        }
        internal enum TrustedMobile {
          /// Cellular network
          internal static let caption = L10n.tr("Core", "service.cells.trusted_mobile.caption")
        }
        internal enum TrustedPolicy {
          /// Trust disables VPN
          internal static let caption = L10n.tr("Core", "service.cells.trusted_policy.caption")
        }
        internal enum VpnResolvesHostname {
          /// Resolve provider hostname
          internal static let caption = L10n.tr("Core", "service.cells.vpn_resolves_hostname.caption")
        }
        internal enum VpnSurvivesSleep {
          /// Keep alive on sleep
          internal static let caption = L10n.tr("Core", "service.cells.vpn_survives_sleep.caption")
        }
      }
      internal enum Sections {
        internal enum Diagnostics {
          /// Masking status will be effective after reconnecting. Network data are hostnames, IP addresses, routing, SSID. Credentials and private keys are not logged regardless.
          internal static let footer = L10n.tr("Core", "service.sections.diagnostics.footer")
          /// Diagnostics
          internal static let header = L10n.tr("Core", "service.sections.diagnostics.header")
        }
        internal enum ProviderInfrastructure {
          /// Last updated on %@.
          internal static func footer(_ p1: String) -> String {
            return L10n.tr("Core", "service.sections.provider_infrastructure.footer", p1)
          }
        }
        internal enum Trusted {
          /// When entering a trusted network, the VPN is normally shut down and kept disconnected. Disable this option to not enforce such behavior.
          internal static let footer = L10n.tr("Core", "service.sections.trusted.footer")
          /// Trusted networks
          internal static let header = L10n.tr("Core", "service.sections.trusted.header")
        }
        internal enum Vpn {
          /// The connection will be established whenever necessary.
          internal static let footer = L10n.tr("Core", "service.sections.vpn.footer")
        }
        internal enum VpnResolvesHostname {
          /// Preferred in most networks and required in some IPv6 networks. Disable where DNS is blocked, or to speed up negotiation when DNS is slow to respond.
          internal static let footer = L10n.tr("Core", "service.sections.vpn_resolves_hostname.footer")
        }
        internal enum VpnSurvivesSleep {
          /// Disable to improve battery usage, at the expense of occasional slowdowns due to wake-up reconnections.
          internal static let footer = L10n.tr("Core", "service.sections.vpn_survives_sleep.footer")
        }
      }
      internal enum Welcome {
        /// Welcome to Passepartout!\n\nUse the organizer to add a new profile.
        internal static let message = L10n.tr("Core", "service.welcome.message")
      }
    }
    internal enum Share {
      /// Passepartout is an user-friendly, open source OpenVPN client for iOS and macOS
      internal static let message = L10n.tr("Core", "share.message")
    }
    internal enum Shortcuts {
      internal enum Add {
        internal enum Alerts {
          internal enum NoProfiles {
            /// There is no profile to connect to.
            internal static let message = L10n.tr("Core", "shortcuts.add.alerts.no_profiles.message")
          }
        }
        internal enum Cells {
          internal enum Connect {
            /// Connect to
            internal static let caption = L10n.tr("Core", "shortcuts.add.cells.connect.caption")
          }
          internal enum DisableVpn {
            /// Disable VPN
            internal static let caption = L10n.tr("Core", "shortcuts.add.cells.disable_vpn.caption")
          }
          internal enum EnableVpn {
            /// Enable VPN
            internal static let caption = L10n.tr("Core", "shortcuts.add.cells.enable_vpn.caption")
          }
          internal enum TrustCellular {
            /// Trust cellular network
            internal static let caption = L10n.tr("Core", "shortcuts.add.cells.trust_cellular.caption")
          }
          internal enum TrustCurrentWifi {
            /// Trust current Wi-Fi
            internal static let caption = L10n.tr("Core", "shortcuts.add.cells.trust_current_wifi.caption")
          }
          internal enum UntrustCellular {
            /// Untrust cellular network
            internal static let caption = L10n.tr("Core", "shortcuts.add.cells.untrust_cellular.caption")
          }
          internal enum UntrustCurrentWifi {
            /// Untrust current Wi-Fi
            internal static let caption = L10n.tr("Core", "shortcuts.add.cells.untrust_current_wifi.caption")
          }
        }
        internal enum Sections {
          internal enum Cellular {
            /// Cellular
            internal static let header = L10n.tr("Core", "shortcuts.add.sections.cellular.header")
          }
          internal enum Vpn {
            /// VPN
            internal static let header = L10n.tr("Core", "shortcuts.add.sections.vpn.header")
          }
          internal enum Wifi {
            /// Wi-Fi
            internal static let header = L10n.tr("Core", "shortcuts.add.sections.wifi.header")
          }
        }
      }
      internal enum Edit {
        internal enum Sections {
          internal enum All {
            /// Existing shortcuts
            internal static let header = L10n.tr("Core", "shortcuts.edit.sections.all.header")
          }
        }
      }
    }
    internal enum Translations {
      /// Translations
      internal static let title = L10n.tr("Core", "translations.title")
    }
    internal enum Version {
      /// Version
      internal static let title = L10n.tr("Core", "version.title")
      internal enum Labels {
        /// Passepartout and TunnelKit are written and maintained by Davide De Rosa (keeshux).\n\nSource code for Passepartout and TunnelKit is publicly available on GitHub under the GPLv3, you can find links in the home page.\n\nPassepartout is a non-official client and is in no way affiliated with OpenVPN Inc.
        internal static let intro = L10n.tr("Core", "version.labels.intro")
      }
    }
    internal enum Vpn {
      /// Active
      internal static let active = L10n.tr("Core", "vpn.active")
      /// Connecting
      internal static let connecting = L10n.tr("Core", "vpn.connecting")
      /// Disabled
      internal static let disabled = L10n.tr("Core", "vpn.disabled")
      /// Disconnecting
      internal static let disconnecting = L10n.tr("Core", "vpn.disconnecting")
      /// Inactive
      internal static let inactive = L10n.tr("Core", "vpn.inactive")
      internal enum Errors {
        /// Auth failed
        internal static let auth = L10n.tr("Core", "vpn.errors.auth")
        /// Compression unsupported
        internal static let compression = L10n.tr("Core", "vpn.errors.compression")
        /// DNS failed
        internal static let dns = L10n.tr("Core", "vpn.errors.dns")
        /// Encryption failed
        internal static let encryption = L10n.tr("Core", "vpn.errors.encryption")
        /// No gateway
        internal static let gateway = L10n.tr("Core", "vpn.errors.gateway")
        /// Network changed
        internal static let network = L10n.tr("Core", "vpn.errors.network")
        /// Missing routing
        internal static let routing = L10n.tr("Core", "vpn.errors.routing")
        /// Timeout
        internal static let timeout = L10n.tr("Core", "vpn.errors.timeout")
        /// TLS failed
        internal static let tls = L10n.tr("Core", "vpn.errors.tls")
      }
    }
    internal enum Wizards {
      internal enum Host {
        internal enum Alerts {
          internal enum Existing {
            /// A host profile with the same title already exists. Replace it?
            internal static let message = L10n.tr("Core", "wizards.host.alerts.existing.message")
          }
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
