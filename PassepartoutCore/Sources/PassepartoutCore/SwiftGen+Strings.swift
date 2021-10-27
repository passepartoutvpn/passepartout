// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {

  public enum About {
    /// About
    public static let title = L10n.tr("Core", "about.title")
    public enum Cells {
      public enum Credits {
        /// Credits
        public static let caption = L10n.tr("Core", "about.cells.credits.caption")
      }
      public enum Disclaimer {
        /// Disclaimer
        public static let caption = L10n.tr("Core", "about.cells.disclaimer.caption")
      }
      public enum Faq {
        /// FAQ
        public static let caption = L10n.tr("Core", "about.cells.faq.caption")
      }
      public enum PrivacyPolicy {
        /// Privacy policy
        public static let caption = L10n.tr("Core", "about.cells.privacy_policy.caption")
      }
      public enum ShareGeneric {
        /// Invite a friend
        public static let caption = L10n.tr("Core", "about.cells.share_generic.caption")
      }
      public enum ShareTwitter {
        /// Tweet about it!
        public static let caption = L10n.tr("Core", "about.cells.share_twitter.caption")
      }
      public enum Website {
        /// Home page
        public static let caption = L10n.tr("Core", "about.cells.website.caption")
      }
    }
    public enum Sections {
      public enum Share {
        /// Share
        public static let header = L10n.tr("Core", "about.sections.share.header")
      }
      public enum Web {
        /// Web
        public static let header = L10n.tr("Core", "about.sections.web.header")
      }
    }
  }

  public enum Account {
    /// Account
    public static let title = L10n.tr("Core", "account.title")
    public enum Cells {
      public enum OpenGuide {
        /// See your credentials
        public static let caption = L10n.tr("Core", "account.cells.open_guide.caption")
      }
      public enum Password {
        /// Password
        public static let caption = L10n.tr("Core", "account.cells.password.caption")
        /// secret
        public static let placeholder = L10n.tr("Core", "account.cells.password.placeholder")
      }
      public enum Signup {
        /// Register with %@
        public static func caption(_ p1: Any) -> String {
          return L10n.tr("Core", "account.cells.signup.caption", String(describing: p1))
        }
      }
      public enum Username {
        /// Username
        public static let caption = L10n.tr("Core", "account.cells.username.caption")
        /// username
        public static let placeholder = L10n.tr("Core", "account.cells.username.placeholder")
      }
    }
    public enum Sections {
      public enum Credentials {
        /// Credentials
        public static let header = L10n.tr("Core", "account.sections.credentials.header")
      }
      public enum Guidance {
        public enum Footer {
          public enum Infrastructure {
            /// Use your %@ website credentials. Your username is usually numeric (without spaces).
            public static func mullvad(_ p1: Any) -> String {
              return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.mullvad", String(describing: p1))
            }
            /// Use your %@ website credentials. Your username is usually your e-mail.
            public static func nordvpn(_ p1: Any) -> String {
              return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.nordvpn", String(describing: p1))
            }
            /// Use your %@ website credentials. Your username is usually numeric with a "p" prefix.
            public static func pia(_ p1: Any) -> String {
              return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.pia", String(describing: p1))
            }
            /// Find your %@ credentials in the "Account > OpenVPN / IKEv2 Username" section of the website.
            public static func protonvpn(_ p1: Any) -> String {
              return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.protonvpn", String(describing: p1))
            }
            /// Use your %@ website credentials. Your username is usually your e-mail.
            public static func tunnelbear(_ p1: Any) -> String {
              return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.tunnelbear", String(describing: p1))
            }
            /// Use your %@ website credentials. Your username is usually your e-mail.
            public static func vyprvpn(_ p1: Any) -> String {
              return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.vyprvpn", String(describing: p1))
            }
            /// Find your %@ credentials in the OpenVPN Config Generator on the website.
            public static func windscribe(_ p1: Any) -> String {
              return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.windscribe", String(describing: p1))
            }
            public enum Default {
              /// Use your %@ service credentials, which may differ from website credentials.
              public static func specific(_ p1: Any) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.default.specific", String(describing: p1))
              }
              /// Use your %@ website credentials.
              public static func web(_ p1: Any) -> String {
                return L10n.tr("Core", "account.sections.guidance.footer.infrastructure.default.web", String(describing: p1))
              }
            }
          }
        }
      }
      public enum Registration {
        /// Go get an account on the %@ website.
        public static func footer(_ p1: Any) -> String {
          return L10n.tr("Core", "account.sections.registration.footer", String(describing: p1))
        }
      }
    }
  }

  public enum Configuration {
    /// Configuration
    public static let title = L10n.tr("Core", "configuration.title")
    public enum Alerts {
      public enum Commit {
        /// New parameters will not be effective until you reconnect manually. Changes in trusted networks will apply immediately.
        public static let message = L10n.tr("Core", "configuration.alerts.commit.message")
        public enum Buttons {
          /// Reconnect now
          public static let reconnect = L10n.tr("Core", "configuration.alerts.commit.buttons.reconnect")
          /// Skip
          public static let skip = L10n.tr("Core", "configuration.alerts.commit.buttons.skip")
        }
      }
    }
    public enum Cells {
      public enum Cipher {
        /// Cipher
        public static let caption = L10n.tr("Core", "configuration.cells.cipher.caption")
      }
      public enum Client {
        /// Client certificate
        public static let caption = L10n.tr("Core", "configuration.cells.client.caption")
        public enum Value {
          /// Not verified
          public static let disabled = L10n.tr("Core", "configuration.cells.client.value.disabled")
          /// Verified
          public static let enabled = L10n.tr("Core", "configuration.cells.client.value.enabled")
        }
      }
      public enum CompressionAlgorithm {
        /// Algorithm
        public static let caption = L10n.tr("Core", "configuration.cells.compression_algorithm.caption")
        public enum Value {
          /// LZO
          public static let lzo = L10n.tr("Core", "configuration.cells.compression_algorithm.value.lzo")
          /// Unsupported
          public static let other = L10n.tr("Core", "configuration.cells.compression_algorithm.value.other")
        }
      }
      public enum CompressionFraming {
        /// Framing
        public static let caption = L10n.tr("Core", "configuration.cells.compression_framing.caption")
        public enum Value {
          /// --compress
          public static let compress = L10n.tr("Core", "configuration.cells.compression_framing.value.compress")
          /// --comp-lzo
          public static let lzo = L10n.tr("Core", "configuration.cells.compression_framing.value.lzo")
        }
      }
      public enum Digest {
        /// Authentication
        public static let caption = L10n.tr("Core", "configuration.cells.digest.caption")
        public enum Value {
          /// Embedded
          public static let embedded = L10n.tr("Core", "configuration.cells.digest.value.embedded")
        }
      }
      public enum Eku {
        /// Extended verification
        public static let caption = L10n.tr("Core", "configuration.cells.eku.caption")
      }
      public enum KeepAlive {
        /// Keep-alive
        public static let caption = L10n.tr("Core", "configuration.cells.keep_alive.caption")
        public enum Value {
          /// %d seconds
          public static func seconds(_ p1: Int) -> String {
            return L10n.tr("Core", "configuration.cells.keep_alive.value.seconds", p1)
          }
        }
      }
      public enum RandomEndpoint {
        /// Randomize endpoint
        public static let caption = L10n.tr("Core", "configuration.cells.random_endpoint.caption")
      }
      public enum RenegotiationSeconds {
        /// Renegotiation
        public static let caption = L10n.tr("Core", "configuration.cells.renegotiation_seconds.caption")
        public enum Value {
          /// after %@
          public static func after(_ p1: Any) -> String {
            return L10n.tr("Core", "configuration.cells.renegotiation_seconds.value.after", String(describing: p1))
          }
        }
      }
      public enum ResetOriginal {
        /// Reset configuration
        public static let caption = L10n.tr("Core", "configuration.cells.reset_original.caption")
      }
      public enum TlsWrapping {
        /// Wrapping
        public static let caption = L10n.tr("Core", "configuration.cells.tls_wrapping.caption")
        public enum Value {
          /// Authentication
          public static let auth = L10n.tr("Core", "configuration.cells.tls_wrapping.value.auth")
          /// Encryption
          public static let crypt = L10n.tr("Core", "configuration.cells.tls_wrapping.value.crypt")
        }
      }
    }
    public enum Sections {
      public enum Communication {
        /// Communication
        public static let header = L10n.tr("Core", "configuration.sections.communication.header")
      }
      public enum Compression {
        /// Compression
        public static let header = L10n.tr("Core", "configuration.sections.compression.header")
      }
      public enum Network {
        /// Network
        public static let header = L10n.tr("Core", "configuration.sections.network.header")
      }
      public enum Other {
        /// Other
        public static let header = L10n.tr("Core", "configuration.sections.other.header")
      }
      public enum Reset {
        /// If you ended up with broken connectivity after changing the communication parameters, tap to revert to the original configuration.
        public static let footer = L10n.tr("Core", "configuration.sections.reset.footer")
      }
      public enum Tls {
        /// TLS
        public static let header = L10n.tr("Core", "configuration.sections.tls.header")
      }
    }
  }

  public enum Credits {
    /// Credits
    public static let title = L10n.tr("Core", "credits.title")
    public enum Sections {
      public enum Licenses {
        /// Licenses
        public static let header = L10n.tr("Core", "credits.sections.licenses.header")
      }
      public enum Notices {
        /// Notices
        public static let header = L10n.tr("Core", "credits.sections.notices.header")
      }
      public enum Translations {
        /// Translations
        public static let header = L10n.tr("Core", "credits.sections.translations.header")
      }
    }
  }

  public enum DebugLog {
    public enum Alerts {
      public enum EmptyLog {
        /// The debug log is empty.
        public static let message = L10n.tr("Core", "debug_log.alerts.empty_log.message")
      }
    }
    public enum Buttons {
      /// Copy
      public static let copy = L10n.tr("Core", "debug_log.buttons.copy")
      /// Next
      public static let next = L10n.tr("Core", "debug_log.buttons.next")
      /// Previous
      public static let previous = L10n.tr("Core", "debug_log.buttons.previous")
    }
  }

  public enum Donation {
    /// Donate
    public static let title = L10n.tr("Core", "donation.title")
    public enum Alerts {
      public enum Purchase {
        public enum Failure {
          /// Unable to perform the donation. %@
          public static func message(_ p1: Any) -> String {
            return L10n.tr("Core", "donation.alerts.purchase.failure.message", String(describing: p1))
          }
        }
        public enum Success {
          /// This means a lot to me and I really hope you keep using and promoting this app.
          public static let message = L10n.tr("Core", "donation.alerts.purchase.success.message")
          /// Thank you
          public static let title = L10n.tr("Core", "donation.alerts.purchase.success.title")
        }
      }
    }
    public enum Cells {
      public enum Loading {
        /// Loading donations
        public static let caption = L10n.tr("Core", "donation.cells.loading.caption")
      }
      public enum Purchasing {
        /// Performing donation
        public static let caption = L10n.tr("Core", "donation.cells.purchasing.caption")
      }
    }
    public enum Sections {
      public enum OneTime {
        /// If you want to display gratitude for my free work, here are a couple amounts you can donate instantly.\n\nYou will only be charged once per donation, and you can donate multiple times.
        public static let footer = L10n.tr("Core", "donation.sections.one_time.footer")
        /// One time
        public static let header = L10n.tr("Core", "donation.sections.one_time.header")
      }
    }
  }

  public enum Endpoint {
    /// Endpoint
    public static let title = L10n.tr("Core", "endpoint.title")
    public enum Cells {
      /// Address
      public static let address = L10n.tr("Core", "endpoint.cells.address")
      /// Protocol
      public static let `protocol` = L10n.tr("Core", "endpoint.cells.protocol")
      public enum AnyAddress {
        /// Automatic
        public static let caption = L10n.tr("Core", "endpoint.cells.any_address.caption")
      }
      public enum AnyProtocol {
        /// Automatic
        public static let caption = L10n.tr("Core", "endpoint.cells.any_protocol.caption")
      }
    }
    public enum Sections {
      public enum LocationAddresses {
        /// Addresses
        public static let header = L10n.tr("Core", "endpoint.sections.location_addresses.header")
      }
      public enum LocationProtocols {
        /// Protocols
        public static let header = L10n.tr("Core", "endpoint.sections.location_protocols.header")
      }
    }
  }

  public enum Global {
    /// Cancel
    public static let cancel = L10n.tr("Core", "global.cancel")
    /// Close
    public static let close = L10n.tr("Core", "global.close")
    /// No e-mail account is configured.
    public static let emailNotConfigured = L10n.tr("Core", "global.email_not_configured")
    /// Next
    public static let next = L10n.tr("Core", "global.next")
    /// OK
    public static let ok = L10n.tr("Core", "global.ok")
    public enum Captions {
      /// Address
      public static let address = L10n.tr("Core", "global.captions.address")
      /// Port
      public static let port = L10n.tr("Core", "global.captions.port")
      /// Protocol
      public static let `protocol` = L10n.tr("Core", "global.captions.protocol")
    }
    public enum Host {
      public enum TitleInput {
        /// Acceptable characters are alphanumerics plus dash "-", underscore "_" and dot ".".
        public static let message = L10n.tr("Core", "global.host.title_input.message")
        /// My profile
        public static let placeholder = L10n.tr("Core", "global.host.title_input.placeholder")
      }
    }
    public enum Values {
      /// Automatic
      public static let automatic = L10n.tr("Core", "global.values.automatic")
      /// Default
      public static let `default` = L10n.tr("Core", "global.values.default")
      /// Disabled
      public static let disabled = L10n.tr("Core", "global.values.disabled")
      /// Enabled
      public static let enabled = L10n.tr("Core", "global.values.enabled")
      /// Manual
      public static let manual = L10n.tr("Core", "global.values.manual")
      /// None
      public static let `none` = L10n.tr("Core", "global.values.none")
    }
  }

  public enum ImportedHosts {
    /// Imported hosts
    public static let title = L10n.tr("Core", "imported_hosts.title")
  }

  public enum IssueReporter {
    /// The debug log of your latest connections is crucial to resolve your connectivity issues and is completely anonymous.\n\nThe .ovpn configuration file, if any, is attached stripped of any sensitive data.\n\nPlease double check the e-mail attachments if unsure.
    public static let message = L10n.tr("Core", "issue_reporter.message")
    /// Report issue
    public static let title = L10n.tr("Core", "issue_reporter.title")
    public enum Buttons {
      /// I understand
      public static let accept = L10n.tr("Core", "issue_reporter.buttons.accept")
    }
  }

  public enum Label {
    public enum License {
      /// Unable to download full license content.
      public static let error = L10n.tr("Core", "label.license.error")
    }
  }

  public enum Menu {
    public enum ActiveProfile {
      public enum Items {
        public enum Customize {
          /// Customize...
          public static let title = L10n.tr("Core", "menu.active_profile.items.customize.title")
        }
      }
      public enum Messages {
        /// No account configured
        public static let missingCredentials = L10n.tr("Core", "menu.active_profile.messages.missing_credentials")
      }
      public enum Title {
        /// No active profile
        public static let `none` = L10n.tr("Core", "menu.active_profile.title.none")
      }
    }
    public enum Organizer {
      /// Organizer
      public static let title = L10n.tr("Core", "menu.organizer.title")
    }
    public enum Preferences {
      /// Preferences
      public static let title = L10n.tr("Core", "menu.preferences.title")
    }
    public enum Quit {
      /// Quit %@
      public static func title(_ p1: Any) -> String {
        return L10n.tr("Core", "menu.quit.title", String(describing: p1))
      }
      public enum Messages {
        /// The VPN, if enabled, will still run in the background. Do you want to quit?
        public static let confirm = L10n.tr("Core", "menu.quit.messages.confirm")
      }
    }
    public enum Show {
      /// Show
      public static let title = L10n.tr("Core", "menu.show.title")
    }
    public enum Support {
      /// Support
      public static let title = L10n.tr("Core", "menu.support.title")
    }
    public enum SwitchProfile {
      /// Active profile
      public static let title = L10n.tr("Core", "menu.switch_profile.title")
    }
  }

  public enum NetworkChoice {
    /// Read .ovpn
    public static let client = L10n.tr("Core", "network_choice.client")
    /// Pull from server
    public static let server = L10n.tr("Core", "network_choice.server")
  }

  public enum NetworkSettings {
    /// Network settings
    public static let title = L10n.tr("Core", "network_settings.title")
    public enum Cells {
      public enum AddDnsDomain {
        /// Add search domain
        public static let caption = L10n.tr("Core", "network_settings.cells.add_dns_domain.caption")
      }
      public enum AddDnsServer {
        /// Add address
        public static let caption = L10n.tr("Core", "network_settings.cells.add_dns_server.caption")
      }
      public enum AddProxyBypass {
        /// Add bypass domain
        public static let caption = L10n.tr("Core", "network_settings.cells.add_proxy_bypass.caption")
      }
      public enum ProxyBypass {
        /// Bypass domain
        public static let caption = L10n.tr("Core", "network_settings.cells.proxy_bypass.caption")
      }
    }
    public enum Dns {
      /// DNS
      public static let title = L10n.tr("Core", "network_settings.dns.title")
      public enum Cells {
        public enum Addresses {
          /// Servers
          public static let title = L10n.tr("Core", "network_settings.dns.cells.addresses.title")
        }
        public enum Domain {
          /// Domain
          public static let caption = L10n.tr("Core", "network_settings.dns.cells.domain.caption")
        }
        public enum Domains {
          /// Domains
          public static let title = L10n.tr("Core", "network_settings.dns.cells.domains.title")
        }
      }
    }
    public enum Gateway {
      /// Default gateway
      public static let title = L10n.tr("Core", "network_settings.gateway.title")
    }
    public enum Mtu {
      /// MTU
      public static let title = L10n.tr("Core", "network_settings.mtu.title")
      public enum Cells {
        public enum Bytes {
          /// Bytes
          public static let caption = L10n.tr("Core", "network_settings.mtu.cells.bytes.caption")
        }
      }
    }
    public enum Proxy {
      /// Proxy
      public static let title = L10n.tr("Core", "network_settings.proxy.title")
      public enum Cells {
        public enum BypassDomains {
          /// Bypass domains
          public static let title = L10n.tr("Core", "network_settings.proxy.cells.bypass_domains.title")
        }
      }
    }
  }

  public enum Organizer {
    /// %@
    public static func title(_ p1: Any) -> String {
      return L10n.tr("Core", "organizer.title", String(describing: p1))
    }
    public enum Alerts {
      public enum AddHost {
        /// Open an URL to an .ovpn configuration file from Safari, Mail or another app to set up a host profile.\n\nYou can also import an .ovpn with iTunes File Sharing.
        public static let message = L10n.tr("Core", "organizer.alerts.add_host.message")
      }
      public enum CannotDonate {
        /// There is no payment method configured on this device.
        public static let message = L10n.tr("Core", "organizer.alerts.cannot_donate.message")
      }
      public enum DeleteVpnProfile {
        /// Do you really want to erase the VPN configuration from your device settings? This may fix some broken VPN states and will not affect your provider and host profiles.
        public static let message = L10n.tr("Core", "organizer.alerts.delete_vpn_profile.message")
      }
      public enum ExhaustedProviders {
        /// You have created profiles for any available provider.
        public static let message = L10n.tr("Core", "organizer.alerts.exhausted_providers.message")
      }
      public enum OpenHostFile {
        /// Select an .ovpn file
        public static let title = L10n.tr("Core", "organizer.alerts.open_host_file.title")
      }
      public enum RemoveProfile {
        /// Are you sure you want to delete profile %@?
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Core", "organizer.alerts.remove_profile.message", String(describing: p1))
        }
        /// Remove profile
        public static let title = L10n.tr("Core", "organizer.alerts.remove_profile.title")
      }
    }
    public enum Cells {
      public enum About {
        /// About %@
        public static func caption(_ p1: Any) -> String {
          return L10n.tr("Core", "organizer.cells.about.caption", String(describing: p1))
        }
      }
      public enum AddHost {
        /// Add from Files
        public static let caption = L10n.tr("Core", "organizer.cells.add_host.caption")
      }
      public enum AddProvider {
        /// Add new provider
        public static let caption = L10n.tr("Core", "organizer.cells.add_provider.caption")
      }
      public enum Donate {
        /// Make a donation
        public static let caption = L10n.tr("Core", "organizer.cells.donate.caption")
      }
      public enum FollowTwitch {
        /// Watch Passepartout on Twitch
        public static let caption = L10n.tr("Core", "organizer.cells.follow_twitch.caption")
      }
      public enum GithubSponsors {
        /// Support me on GitHub
        public static let caption = L10n.tr("Core", "organizer.cells.github_sponsors.caption")
      }
      public enum ImportHost {
        /// Add from imported
        public static let caption = L10n.tr("Core", "organizer.cells.import_host.caption")
      }
      public enum JoinCommunity {
        /// Join community
        public static let caption = L10n.tr("Core", "organizer.cells.join_community.caption")
      }
      public enum Profile {
        public enum Value {
          /// In use
          public static let current = L10n.tr("Core", "organizer.cells.profile.value.current")
        }
      }
      public enum SiriShortcuts {
        /// Manage shortcuts
        public static let caption = L10n.tr("Core", "organizer.cells.siri_shortcuts.caption")
      }
      public enum Translate {
        /// Offer to translate
        public static let caption = L10n.tr("Core", "organizer.cells.translate.caption")
      }
      public enum Uninstall {
        /// Remove VPN configuration
        public static let caption = L10n.tr("Core", "organizer.cells.uninstall.caption")
      }
      public enum WriteReview {
        /// Write a review
        public static let caption = L10n.tr("Core", "organizer.cells.write_review.caption")
      }
    }
    public enum Menus {
      /// Host
      public static let host = L10n.tr("Core", "organizer.menus.host")
      /// Provider
      public static let provider = L10n.tr("Core", "organizer.menus.provider")
      public enum Provider {
        /// No providers left
        public static let unavailable = L10n.tr("Core", "organizer.menus.provider.unavailable")
      }
    }
    public enum Sections {
      public enum Feedback {
        /// Feedback
        public static let header = L10n.tr("Core", "organizer.sections.feedback.header")
      }
      public enum Hosts {
        /// Import hosts from raw .ovpn configuration files.
        public static let footer = L10n.tr("Core", "organizer.sections.hosts.footer")
        /// Hosts
        public static let header = L10n.tr("Core", "organizer.sections.hosts.header")
      }
      public enum Providers {
        /// Here you find a few providers with preset configuration profiles.
        public static let footer = L10n.tr("Core", "organizer.sections.providers.footer")
        /// Providers
        public static let header = L10n.tr("Core", "organizer.sections.providers.header")
      }
      public enum Siri {
        /// Get help from Siri to speed up your most common interactions with the app.
        public static let footer = L10n.tr("Core", "organizer.sections.siri.footer")
        /// Siri
        public static let header = L10n.tr("Core", "organizer.sections.siri.header")
      }
      public enum Support {
        /// Support
        public static let header = L10n.tr("Core", "organizer.sections.support.header")
      }
      public enum Twitch {
        /// Come watch me make Passepartout live on Twitch, join the chat to interact and contribute!
        public static let footer = L10n.tr("Core", "organizer.sections.twitch.footer")
        /// Twitch
        public static let header = L10n.tr("Core", "organizer.sections.twitch.header")
      }
    }
  }

  public enum ParsedFile {
    public enum Alerts {
      public enum Buttons {
        /// Report an issue
        public static let report = L10n.tr("Core", "parsed_file.alerts.buttons.report")
      }
      public enum Decryption {
        /// The configuration contains an encrypted private key and it could not be decrypted. Double check your entered passphrase.
        public static let message = L10n.tr("Core", "parsed_file.alerts.decryption.message")
      }
      public enum EncryptionPassphrase {
        /// Please enter the encryption passphrase.
        public static let message = L10n.tr("Core", "parsed_file.alerts.encryption_passphrase.message")
      }
      public enum Malformed {
        /// The configuration file contains a malformed option (%@).
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Core", "parsed_file.alerts.malformed.message", String(describing: p1))
        }
      }
      public enum Missing {
        /// The configuration file lacks a required option (%@).
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Core", "parsed_file.alerts.missing.message", String(describing: p1))
        }
      }
      public enum Parsing {
        /// Unable to parse the provided configuration file (%@).
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Core", "parsed_file.alerts.parsing.message", String(describing: p1))
        }
      }
      public enum PotentiallyUnsupported {
        /// The configuration file is correct but contains a potentially unsupported option (%@).\n\nConnectivity may break depending on server settings.
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Core", "parsed_file.alerts.potentially_unsupported.message", String(describing: p1))
        }
      }
      public enum Unsupported {
        /// The configuration file contains an unsupported option (%@).
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Core", "parsed_file.alerts.unsupported.message", String(describing: p1))
        }
      }
    }
  }

  public enum Preferences {
    /// Preferences
    public static let title = L10n.tr("Core", "preferences.title")
    public enum Cells {
      public enum ConfirmQuit {
        /// Confirm quit
        public static let caption = L10n.tr("Core", "preferences.cells.confirm_quit.caption")
        /// Check to present a quit confirmation alert.
        public static let footer = L10n.tr("Core", "preferences.cells.confirm_quit.footer")
      }
      public enum LaunchesOnLogin {
        /// Launch on login
        public static let caption = L10n.tr("Core", "preferences.cells.launches_on_login.caption")
        /// Check to automatically launch the app on boot or login.
        public static let footer = L10n.tr("Core", "preferences.cells.launches_on_login.footer")
      }
    }
    public enum Sections {
      public enum General {
        /// General
        public static let header = L10n.tr("Core", "preferences.sections.general.header")
      }
    }
  }

  public enum Provider {
    public enum Pool {
      public enum Actions {
        /// Favorite
        public static let favorite = L10n.tr("Core", "provider.pool.actions.favorite")
        /// Unfavorite
        public static let unfavorite = L10n.tr("Core", "provider.pool.actions.unfavorite")
      }
      public enum Sections {
        public enum EmptyFavorites {
          /// Swipe left on a location to add or remove it from Favorites.
          public static let footer = L10n.tr("Core", "provider.pool.sections.empty_favorites.footer")
        }
      }
    }
    public enum Preset {
      public enum Cells {
        public enum TechDetails {
          /// Technical details
          public static let caption = L10n.tr("Core", "provider.preset.cells.tech_details.caption")
        }
      }
    }
  }

  public enum Purchase {
    /// Purchase
    public static let title = L10n.tr("Core", "purchase.title")
    public enum Cells {
      public enum FullVersion {
        /// All providers (including future ones)\n%@
        public static func extraDescription(_ p1: Any) -> String {
          return L10n.tr("Core", "purchase.cells.full_version.extra_description", String(describing: p1))
        }
      }
      public enum Restore {
        /// If you bought this app or feature in the past, you can restore your purchases and this screen won't show again.
        public static let description = L10n.tr("Core", "purchase.cells.restore.description")
        /// Restore purchases
        public static let title = L10n.tr("Core", "purchase.cells.restore.title")
      }
    }
    public enum Sections {
      public enum Products {
        /// Every product is a one-time purchase. Provider purchases do not include a VPN subscription.
        public static let footer = L10n.tr("Core", "purchase.sections.products.footer")
      }
    }
  }

  public enum Reddit {
    /// Did you know that Passepartout has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.\n\nIt's also a great way to show you care about this project.
    public static let message = L10n.tr("Core", "reddit.message")
    /// Reddit
    public static let title = L10n.tr("Core", "reddit.title")
    public enum Buttons {
      /// Don't ask again
      public static let never = L10n.tr("Core", "reddit.buttons.never")
      /// Remind me later
      public static let remind = L10n.tr("Core", "reddit.buttons.remind")
      /// Subscribe now!
      public static let subscribe = L10n.tr("Core", "reddit.buttons.subscribe")
    }
  }

  public enum ServerNetwork {
    public enum Cells {
      public enum Route {
        /// Route
        public static let caption = L10n.tr("Core", "server_network.cells.route.caption")
      }
    }
  }

  public enum Service {
    public enum Alerts {
      public enum Buttons {
        /// Reconnect
        public static let reconnect = L10n.tr("Core", "service.alerts.buttons.reconnect")
      }
      public enum Configuration {
        /// Configuration unavailable, make sure you are connected to the VPN.
        public static let disconnected = L10n.tr("Core", "service.alerts.configuration.disconnected")
      }
      public enum CredentialsNeeded {
        /// You need to enter account credentials first.
        public static let message = L10n.tr("Core", "service.alerts.credentials_needed.message")
      }
      public enum Download {
        /// Failed to download configuration files. %@
        public static func failed(_ p1: Any) -> String {
          return L10n.tr("Core", "service.alerts.download.failed", String(describing: p1))
        }
        /// %@ requires the download of additional configuration files.\n\nConfirm to start the download.
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Core", "service.alerts.download.message", String(describing: p1))
        }
        /// Download required
        public static let title = L10n.tr("Core", "service.alerts.download.title")
        public enum Hud {
          /// Extracting files, please be patient...
          public static let extracting = L10n.tr("Core", "service.alerts.download.hud.extracting")
        }
      }
      public enum Location {
        public enum Button {
          /// Settings
          public static let settings = L10n.tr("Core", "service.alerts.location.button.settings")
        }
        public enum Message {
          /// You must allow location access to trust this Wi-Fi network. Go to iOS settings and review your location permissions for Passepartout.
          public static let denied = L10n.tr("Core", "service.alerts.location.message.denied")
        }
      }
      public enum MasksPrivateData {
        public enum Messages {
          /// In order to safely reset the current debug log and apply the new masking preference, you must reconnect to the VPN now.
          public static let mustReconnect = L10n.tr("Core", "service.alerts.masks_private_data.messages.must_reconnect")
        }
      }
      public enum ReconnectVpn {
        /// Do you want to reconnect to the VPN?
        public static let message = L10n.tr("Core", "service.alerts.reconnect_vpn.message")
      }
      public enum Rename {
        /// Rename profile
        public static let title = L10n.tr("Core", "service.alerts.rename.title")
      }
      public enum TestConnectivity {
        /// Connectivity
        public static let title = L10n.tr("Core", "service.alerts.test_connectivity.title")
        public enum Messages {
          /// Your device has no Internet connectivity, please review your profile parameters.
          public static let failure = L10n.tr("Core", "service.alerts.test_connectivity.messages.failure")
          /// Your device is connected to the Internet!
          public static let success = L10n.tr("Core", "service.alerts.test_connectivity.messages.success")
        }
      }
      public enum Trusted {
        public enum NoNetwork {
          /// You are not connected to any Wi-Fi network.
          public static let message = L10n.tr("Core", "service.alerts.trusted.no_network.message")
        }
        public enum WillDisconnectPolicy {
          /// By changing the trust policy, the VPN may be disconnected. Continue?
          public static let message = L10n.tr("Core", "service.alerts.trusted.will_disconnect_policy.message")
        }
        public enum WillDisconnectTrusted {
          /// By trusting this network, the VPN may be disconnected. Continue?
          public static let message = L10n.tr("Core", "service.alerts.trusted.will_disconnect_trusted.message")
        }
      }
    }
    public enum Cells {
      public enum Addresses {
        /// Addresses
        public static let caption = L10n.tr("Core", "service.cells.addresses.caption")
      }
      public enum Category {
        /// Category
        public static let caption = L10n.tr("Core", "service.cells.category.caption")
      }
      public enum ConnectionStatus {
        /// Status
        public static let caption = L10n.tr("Core", "service.cells.connection_status.caption")
      }
      public enum DataCount {
        /// Exchanged data
        public static let caption = L10n.tr("Core", "service.cells.data_count.caption")
        /// Unavailable
        public static let `none` = L10n.tr("Core", "service.cells.data_count.none")
      }
      public enum DebugLog {
        /// Debug log
        public static let caption = L10n.tr("Core", "service.cells.debug_log.caption")
      }
      public enum Host {
        public enum Parameters {
          /// Parameters
          public static let caption = L10n.tr("Core", "service.cells.host.parameters.caption")
        }
      }
      public enum MasksPrivateData {
        /// Mask network data
        public static let caption = L10n.tr("Core", "service.cells.masks_private_data.caption")
      }
      public enum OnlyShowsFavorites {
        /// Only show favorite locations
        public static let caption = L10n.tr("Core", "service.cells.only_shows_favorites.caption")
      }
      public enum Provider {
        public enum Pool {
          /// Location
          public static let caption = L10n.tr("Core", "service.cells.provider.pool.caption")
        }
        public enum Preset {
          /// Preset
          public static let caption = L10n.tr("Core", "service.cells.provider.preset.caption")
        }
        public enum Refresh {
          /// Refresh infrastructure
          public static let caption = L10n.tr("Core", "service.cells.provider.refresh.caption")
        }
      }
      public enum Reconnect {
        /// Reconnect
        public static let caption = L10n.tr("Core", "service.cells.reconnect.caption")
      }
      public enum ReportIssue {
        /// Report connectivity issue
        public static let caption = L10n.tr("Core", "service.cells.report_issue.caption")
      }
      public enum ServerConfiguration {
        /// Server configuration
        public static let caption = L10n.tr("Core", "service.cells.server_configuration.caption")
      }
      public enum ServerNetwork {
        /// Server network
        public static let caption = L10n.tr("Core", "service.cells.server_network.caption")
      }
      public enum TestConnectivity {
        /// Test connectivity
        public static let caption = L10n.tr("Core", "service.cells.test_connectivity.caption")
      }
      public enum TrustedAddWifi {
        /// Add Wi-Fi
        public static let caption = L10n.tr("Core", "service.cells.trusted_add_wifi.caption")
      }
      public enum TrustedMobile {
        /// Cellular network
        public static let caption = L10n.tr("Core", "service.cells.trusted_mobile.caption")
      }
      public enum TrustedPolicy {
        /// Trust disables VPN
        public static let caption = L10n.tr("Core", "service.cells.trusted_policy.caption")
      }
      public enum UseProfile {
        /// Use this profile
        public static let caption = L10n.tr("Core", "service.cells.use_profile.caption")
      }
      public enum Vpn {
        public enum TurnOff {
          /// Disable VPN
          public static let caption = L10n.tr("Core", "service.cells.vpn.turn_off.caption")
        }
        public enum TurnOn {
          /// Enable VPN
          public static let caption = L10n.tr("Core", "service.cells.vpn.turn_on.caption")
        }
      }
      public enum VpnResolvesHostname {
        /// Resolve provider hostname
        public static let caption = L10n.tr("Core", "service.cells.vpn_resolves_hostname.caption")
      }
      public enum VpnService {
        /// Enabled
        public static let caption = L10n.tr("Core", "service.cells.vpn_service.caption")
      }
      public enum VpnSurvivesSleep {
        /// Keep alive on sleep
        public static let caption = L10n.tr("Core", "service.cells.vpn_survives_sleep.caption")
      }
    }
    public enum Sections {
      public enum Configuration {
        /// Configuration
        public static let header = L10n.tr("Core", "service.sections.configuration.header")
      }
      public enum Diagnostics {
        /// Masking status will be effective after reconnecting. Network data are hostnames, IP addresses, routing, SSID. Credentials and private keys are not logged regardless.
        public static let footer = L10n.tr("Core", "service.sections.diagnostics.footer")
        /// Diagnostics
        public static let header = L10n.tr("Core", "service.sections.diagnostics.header")
      }
      public enum ProviderInfrastructure {
        /// Last updated on %@.
        public static func footer(_ p1: Any) -> String {
          return L10n.tr("Core", "service.sections.provider_infrastructure.footer", String(describing: p1))
        }
      }
      public enum Status {
        /// Connection
        public static let header = L10n.tr("Core", "service.sections.status.header")
      }
      public enum Trusted {
        /// When entering a trusted network, the VPN is normally shut down and kept disconnected. Disable this option to not enforce such behavior.
        public static let footer = L10n.tr("Core", "service.sections.trusted.footer")
        /// Trusted networks
        public static let header = L10n.tr("Core", "service.sections.trusted.header")
      }
      public enum Vpn {
        /// The connection will be established whenever necessary.
        public static let footer = L10n.tr("Core", "service.sections.vpn.footer")
        /// VPN
        public static let header = L10n.tr("Core", "service.sections.vpn.header")
      }
      public enum VpnResolvesHostname {
        /// Preferred in most networks and required in some IPv6 networks. Disable where DNS is blocked, or to speed up negotiation when DNS is slow to respond.
        public static let footer = L10n.tr("Core", "service.sections.vpn_resolves_hostname.footer")
      }
      public enum VpnSurvivesSleep {
        /// Disable to improve battery usage, at the expense of occasional slowdowns due to wake-up reconnections.
        public static let footer = L10n.tr("Core", "service.sections.vpn_survives_sleep.footer")
      }
    }
    public enum Welcome {
      /// Welcome to Passepartout!\n\nUse the organizer to add a new profile.
      public static let message = L10n.tr("Core", "service.welcome.message")
    }
  }

  public enum Share {
    /// Passepartout is an user-friendly, open source OpenVPN client for iOS and macOS
    public static let message = L10n.tr("Core", "share.message")
  }

  public enum Shortcuts {
    public enum Add {
      /// Add shortcut
      public static let title = L10n.tr("Core", "shortcuts.add.title")
      public enum Alerts {
        public enum NoProfiles {
          /// There is no profile to connect to.
          public static let message = L10n.tr("Core", "shortcuts.add.alerts.no_profiles.message")
        }
      }
      public enum Cells {
        public enum Connect {
          /// Connect to
          public static let caption = L10n.tr("Core", "shortcuts.add.cells.connect.caption")
        }
        public enum DisableVpn {
          /// Disable VPN
          public static let caption = L10n.tr("Core", "shortcuts.add.cells.disable_vpn.caption")
        }
        public enum EnableVpn {
          /// Enable VPN
          public static let caption = L10n.tr("Core", "shortcuts.add.cells.enable_vpn.caption")
        }
        public enum TrustCellular {
          /// Trust cellular network
          public static let caption = L10n.tr("Core", "shortcuts.add.cells.trust_cellular.caption")
        }
        public enum TrustCurrentWifi {
          /// Trust current Wi-Fi
          public static let caption = L10n.tr("Core", "shortcuts.add.cells.trust_current_wifi.caption")
        }
        public enum UntrustCellular {
          /// Untrust cellular network
          public static let caption = L10n.tr("Core", "shortcuts.add.cells.untrust_cellular.caption")
        }
        public enum UntrustCurrentWifi {
          /// Untrust current Wi-Fi
          public static let caption = L10n.tr("Core", "shortcuts.add.cells.untrust_current_wifi.caption")
        }
      }
      public enum Sections {
        public enum Cellular {
          /// Cellular
          public static let header = L10n.tr("Core", "shortcuts.add.sections.cellular.header")
        }
        public enum Vpn {
          /// VPN
          public static let header = L10n.tr("Core", "shortcuts.add.sections.vpn.header")
        }
        public enum Wifi {
          /// Wi-Fi
          public static let header = L10n.tr("Core", "shortcuts.add.sections.wifi.header")
        }
      }
    }
    public enum Edit {
      /// Manage shortcuts
      public static let title = L10n.tr("Core", "shortcuts.edit.title")
      public enum Cells {
        public enum AddShortcut {
          /// Add shortcut
          public static let caption = L10n.tr("Core", "shortcuts.edit.cells.add_shortcut.caption")
        }
      }
      public enum Sections {
        public enum All {
          /// Existing shortcuts
          public static let header = L10n.tr("Core", "shortcuts.edit.sections.all.header")
        }
      }
    }
  }

  public enum Translations {
    /// Translations
    public static let title = L10n.tr("Core", "translations.title")
  }

  public enum Trusted {
    public enum Columns {
      public enum Trust {
        /// Trust
        public static let title = L10n.tr("Core", "trusted.columns.trust.title")
      }
    }
    public enum Ethernet {
      /// Check to trust any wired cable connection.
      public static let description = L10n.tr("Core", "trusted.ethernet.description")
      /// Trust wired connections
      public static let title = L10n.tr("Core", "trusted.ethernet.title")
    }
  }

  public enum Version {
    /// Version
    public static let title = L10n.tr("Core", "version.title")
    public enum Labels {
      /// Passepartout and TunnelKit are written and maintained by Davide De Rosa (keeshux).\n\nSource code for Passepartout and TunnelKit is publicly available on GitHub under the GPLv3, you can find links in the home page.\n\nPassepartout is a non-official client and is in no way affiliated with OpenVPN Inc.
      public static let intro = L10n.tr("Core", "version.labels.intro")
    }
  }

  public enum Vpn {
    /// Active
    public static let active = L10n.tr("Core", "vpn.active")
    /// Connecting
    public static let connecting = L10n.tr("Core", "vpn.connecting")
    /// Disabled
    public static let disabled = L10n.tr("Core", "vpn.disabled")
    /// Disconnecting
    public static let disconnecting = L10n.tr("Core", "vpn.disconnecting")
    /// Inactive
    public static let inactive = L10n.tr("Core", "vpn.inactive")
    /// Off
    public static let unused = L10n.tr("Core", "vpn.unused")
    public enum Errors {
      /// Auth failed
      public static let auth = L10n.tr("Core", "vpn.errors.auth")
      /// Compression unsupported
      public static let compression = L10n.tr("Core", "vpn.errors.compression")
      /// DNS failed
      public static let dns = L10n.tr("Core", "vpn.errors.dns")
      /// Encryption failed
      public static let encryption = L10n.tr("Core", "vpn.errors.encryption")
      /// No gateway
      public static let gateway = L10n.tr("Core", "vpn.errors.gateway")
      /// Network changed
      public static let network = L10n.tr("Core", "vpn.errors.network")
      /// Missing routing
      public static let routing = L10n.tr("Core", "vpn.errors.routing")
      /// Server shutdown
      public static let shutdown = L10n.tr("Core", "vpn.errors.shutdown")
      /// Timeout
      public static let timeout = L10n.tr("Core", "vpn.errors.timeout")
      /// TLS failed
      public static let tls = L10n.tr("Core", "vpn.errors.tls")
    }
  }

  public enum Wizards {
    public enum Host {
      public enum Alerts {
        public enum Existing {
          /// A host profile with the same title already exists. Replace it?
          public static let message = L10n.tr("Core", "wizards.host.alerts.existing.message")
        }
      }
      public enum Cells {
        public enum TitleInput {
          /// Title
          public static let caption = L10n.tr("Core", "wizards.host.cells.title_input.caption")
        }
      }
      public enum Sections {
        public enum Existing {
          /// Existing profiles
          public static let header = L10n.tr("Core", "wizards.host.sections.existing.header")
        }
      }
    }
    public enum Provider {
      public enum Alerts {
        public enum Unavailable {
          /// Could not download provider infrastructure, please retry later.
          public static let message = L10n.tr("Core", "wizards.provider.alerts.unavailable.message")
        }
      }
      public enum Cells {
        public enum UpdateList {
          /// Update list
          public static let caption = L10n.tr("Core", "wizards.provider.cells.update_list.caption")
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
