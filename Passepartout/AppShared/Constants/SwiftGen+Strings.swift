// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum About {
    /// MARK: AboutView
    internal static let title = L10n.tr("Localizable", "about.title", fallback: "About")
    internal enum Items {
      internal enum Credits {
        /// Credits
        internal static let caption = L10n.tr("Localizable", "about.items.credits.caption", fallback: "Credits")
      }
      internal enum Disclaimer {
        /// Disclaimer
        internal static let caption = L10n.tr("Localizable", "about.items.disclaimer.caption", fallback: "Disclaimer")
      }
      internal enum JoinCommunity {
        /// Join community
        internal static let caption = L10n.tr("Localizable", "about.items.join_community.caption", fallback: "Join community")
      }
      internal enum PrivacyPolicy {
        /// Privacy policy
        internal static let caption = L10n.tr("Localizable", "about.items.privacy_policy.caption", fallback: "Privacy policy")
      }
      internal enum ShareTwitter {
        /// Tweet about it!
        internal static let caption = L10n.tr("Localizable", "about.items.share_twitter.caption", fallback: "Tweet about it!")
      }
      internal enum Website {
        /// Home page
        internal static let caption = L10n.tr("Localizable", "about.items.website.caption", fallback: "Home page")
      }
      internal enum WriteReview {
        /// Write a review
        internal static let caption = L10n.tr("Localizable", "about.items.write_review.caption", fallback: "Write a review")
      }
    }
    internal enum Sections {
      internal enum Web {
        /// Web
        internal static let header = L10n.tr("Localizable", "about.sections.web.header", fallback: "Web")
      }
    }
  }
  internal enum Account {
    /// MARK: ProfileView -> AccountView
    internal static let title = L10n.tr("Localizable", "account.title", fallback: "Account")
    internal enum Items {
      internal enum AuthenticationMethod {
        /// Interactive
        internal static let interactive = L10n.tr("Localizable", "account.items.authentication_method.interactive", fallback: "Interactive")
        /// Persistent
        internal static let persistent = L10n.tr("Localizable", "account.items.authentication_method.persistent", fallback: "Persistent")
      }
      internal enum OpenGuide {
        /// See your credentials
        internal static let caption = L10n.tr("Localizable", "account.items.open_guide.caption", fallback: "See your credentials")
      }
      internal enum Password {
        /// Password
        internal static let caption = L10n.tr("Localizable", "account.items.password.caption", fallback: "Password")
        /// secret
        internal static let placeholder = L10n.tr("Localizable", "account.items.password.placeholder", fallback: "secret")
      }
      internal enum Seed {
        /// Seed
        internal static let caption = L10n.tr("Localizable", "account.items.seed.caption", fallback: "Seed")
      }
      internal enum Signup {
        /// Register with %@
        internal static func caption(_ p1: Any) -> String {
          return L10n.tr("Localizable", "account.items.signup.caption", String(describing: p1), fallback: "Register with %@")
        }
      }
      internal enum Username {
        /// Username
        internal static let caption = L10n.tr("Localizable", "account.items.username.caption", fallback: "Username")
        /// username
        internal static let placeholder = L10n.tr("Localizable", "account.items.username.placeholder", fallback: "username")
      }
    }
    internal enum Sections {
      internal enum Credentials {
        /// Credentials
        internal static let header = L10n.tr("Localizable", "account.sections.credentials.header", fallback: "Credentials")
      }
      internal enum Guidance {
        internal enum Footer {
          internal enum Infrastructure {
            /// Use your %@ website credentials. Your username is usually numeric (without spaces).
            internal static func mullvad(_ p1: Any) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.mullvad", String(describing: p1), fallback: "Use your %@ website credentials. Your username is usually numeric (without spaces).")
            }
            /// Use your %@ website credentials. Your username is usually your e-mail.
            internal static func nordvpn(_ p1: Any) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.nordvpn", String(describing: p1), fallback: "Use your %@ website credentials. Your username is usually your e-mail.")
            }
            /// Use your %@ website credentials. Your username is usually numeric with a "p" prefix.
            internal static func pia(_ p1: Any) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.pia", String(describing: p1), fallback: "Use your %@ website credentials. Your username is usually numeric with a \"p\" prefix.")
            }
            /// Find your %@ credentials in the "Account > OpenVPN / IKEv2 Username" section of the website.
            internal static func protonvpn(_ p1: Any) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.protonvpn", String(describing: p1), fallback: "Find your %@ credentials in the \"Account > OpenVPN / IKEv2 Username\" section of the website.")
            }
            /// Use your %@ website credentials. Your username is usually your e-mail.
            internal static func tunnelbear(_ p1: Any) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.tunnelbear", String(describing: p1), fallback: "Use your %@ website credentials. Your username is usually your e-mail.")
            }
            /// Use your %@ website credentials. Your username is usually your e-mail.
            internal static func vyprvpn(_ p1: Any) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.vyprvpn", String(describing: p1), fallback: "Use your %@ website credentials. Your username is usually your e-mail.")
            }
            /// Find your %@ credentials in the OpenVPN Config Generator on the website.
            internal static func windscribe(_ p1: Any) -> String {
              return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.windscribe", String(describing: p1), fallback: "Find your %@ credentials in the OpenVPN Config Generator on the website.")
            }
            internal enum Default {
              /// Use your %@ service credentials, which may differ from website credentials.
              internal static func specific(_ p1: Any) -> String {
                return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.default.specific", String(describing: p1), fallback: "Use your %@ service credentials, which may differ from website credentials.")
              }
              /// Use your %@ website credentials.
              internal static func web(_ p1: Any) -> String {
                return L10n.tr("Localizable", "account.sections.guidance.footer.infrastructure.default.web", String(describing: p1), fallback: "Use your %@ website credentials.")
              }
            }
          }
        }
      }
      internal enum Registration {
        /// Go get an account on the %@ website.
        internal static func footer(_ p1: Any) -> String {
          return L10n.tr("Localizable", "account.sections.registration.footer", String(describing: p1), fallback: "Go get an account on the %@ website.")
        }
      }
    }
  }
  internal enum AddProfile {
    internal enum Host {
      internal enum Sections {
        internal enum Encryption {
          /// MARK: AddHostView
          internal static let footer = L10n.tr("Localizable", "add_profile.host.sections.encryption.footer", fallback: "Enter passphrase")
        }
      }
    }
    internal enum Provider {
      internal enum Errors {
        /// Could not find any server.
        internal static let noDefaultServer = L10n.tr("Localizable", "add_profile.provider.errors.no_default_server", fallback: "Could not find any server.")
      }
      internal enum Items {
        /// Update list
        internal static let updateList = L10n.tr("Localizable", "add_profile.provider.items.update_list", fallback: "Update list")
      }
      internal enum Sections {
        internal enum Vpn {
          /// MARK: AddProviderView
          internal static let footer = L10n.tr("Localizable", "add_profile.provider.sections.vpn.footer", fallback: "Here you find a few providers with preset configuration profiles.")
        }
      }
    }
    internal enum Shared {
      /// MARK: AddProfileView
      internal static let title = L10n.tr("Localizable", "add_profile.shared.title", fallback: "New profile")
      internal enum Alerts {
        internal enum Overwrite {
          /// A profile with the same name already exists. Replace it?
          internal static let message = L10n.tr("Localizable", "add_profile.shared.alerts.overwrite.message", fallback: "A profile with the same name already exists. Replace it?")
        }
      }
      internal enum Views {
        internal enum Existing {
          /// Existing profiles
          internal static let header = L10n.tr("Localizable", "add_profile.shared.views.existing.header", fallback: "Existing profiles")
        }
      }
    }
  }
  internal enum Credits {
    /// MARK: AboutView -> CreditsView
    internal static let title = L10n.tr("Localizable", "credits.title", fallback: "Credits")
    internal enum Sections {
      internal enum Licenses {
        /// Licenses
        internal static let header = L10n.tr("Localizable", "credits.sections.licenses.header", fallback: "Licenses")
      }
      internal enum Notices {
        /// Notices
        internal static let header = L10n.tr("Localizable", "credits.sections.notices.header", fallback: "Notices")
      }
    }
  }
  internal enum DebugLog {
    /// MARK: DiagnosticsView -> DebugLogView
    internal static let title = L10n.tr("Localizable", "debug_log.title", fallback: "Debug log")
    internal enum Buttons {
      /// MARK: DiagnosticsView -> DebugLogView
      internal static let copy = L10n.tr("Localizable", "debug_log.buttons.copy", fallback: "Copy")
    }
  }
  internal enum Diagnostics {
    /// MARK: ProfileView -> DiagnosticsView
    internal static let title = L10n.tr("Localizable", "diagnostics.title", fallback: "Diagnostics")
    internal enum Alerts {
      internal enum MasksPrivateData {
        internal enum Messages {
          /// In order to safely reset the current debug log and apply the new masking preference, you must reconnect to the VPN now.
          internal static let mustReconnect = L10n.tr("Localizable", "diagnostics.alerts.masks_private_data.messages.must_reconnect", fallback: "In order to safely reset the current debug log and apply the new masking preference, you must reconnect to the VPN now.")
        }
      }
    }
    internal enum Items {
      internal enum AppLog {
        /// App
        internal static let title = L10n.tr("Localizable", "diagnostics.items.app_log.title", fallback: "App")
      }
      internal enum MasksPrivateData {
        /// Mask network data
        internal static let caption = L10n.tr("Localizable", "diagnostics.items.masks_private_data.caption", fallback: "Mask network data")
      }
      internal enum ReportIssue {
        /// Report connectivity issue
        internal static let caption = L10n.tr("Localizable", "diagnostics.items.report_issue.caption", fallback: "Report connectivity issue")
      }
      internal enum ServerConfiguration {
        /// Server configuration
        internal static let caption = L10n.tr("Localizable", "diagnostics.items.server_configuration.caption", fallback: "Server configuration")
      }
    }
    internal enum Sections {
      internal enum DebugLog {
        /// Masking status will be effective after reconnecting. Network data are hostnames, IP addresses, routing, SSID. Credentials and private keys are not logged regardless.
        internal static let footer = L10n.tr("Localizable", "diagnostics.sections.debug_log.footer", fallback: "Masking status will be effective after reconnecting. Network data are hostnames, IP addresses, routing, SSID. Credentials and private keys are not logged regardless.")
      }
    }
  }
  internal enum Donate {
    /// MARK: DonateView
    internal static let title = L10n.tr("Localizable", "donate.title", fallback: "Donate")
    internal enum Alerts {
      internal enum Purchase {
        internal enum Failure {
          /// Unable to perform the donation. %@
          internal static func message(_ p1: Any) -> String {
            return L10n.tr("Localizable", "donate.alerts.purchase.failure.message", String(describing: p1), fallback: "Unable to perform the donation. %@")
          }
        }
        internal enum Success {
          /// This means a lot to me and I really hope you keep using and promoting this app.
          internal static let message = L10n.tr("Localizable", "donate.alerts.purchase.success.message", fallback: "This means a lot to me and I really hope you keep using and promoting this app.")
          /// Thank you
          internal static let title = L10n.tr("Localizable", "donate.alerts.purchase.success.title", fallback: "Thank you")
        }
      }
    }
    internal enum Items {
      internal enum Loading {
        /// Loading donations
        internal static let caption = L10n.tr("Localizable", "donate.items.loading.caption", fallback: "Loading donations")
      }
      internal enum Purchasing {
        /// Performing donation
        internal static let caption = L10n.tr("Localizable", "donate.items.purchasing.caption", fallback: "Performing donation")
      }
    }
    internal enum Sections {
      internal enum OneTime {
        /// If you want to display gratitude for my free work, here are a couple amounts you can donate instantly.
        /// 
        /// You will only be charged once per donation, and you can donate multiple times.
        internal static let footer = L10n.tr("Localizable", "donate.sections.one_time.footer", fallback: "If you want to display gratitude for my free work, here are a couple amounts you can donate instantly.\n\nYou will only be charged once per donation, and you can donate multiple times.")
        /// One time
        internal static let header = L10n.tr("Localizable", "donate.sections.one_time.header", fallback: "One time")
      }
    }
  }
  internal enum Endpoint {
    internal enum Advanced {
      /// Technical details
      internal static let title = L10n.tr("Localizable", "endpoint.advanced.title", fallback: "Technical details")
      internal enum Openvpn {
        internal enum Items {
          internal enum Cipher {
            /// Cipher
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.cipher.caption", fallback: "Cipher")
          }
          internal enum Client {
            /// Certificate
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.client.caption", fallback: "Certificate")
            internal enum Value {
              /// Not verified
              internal static let disabled = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.client.value.disabled", fallback: "Not verified")
              /// Verified
              internal static let enabled = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.client.value.enabled", fallback: "Verified")
            }
          }
          internal enum ClientKey {
            /// Key
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.client_key.caption", fallback: "Key")
          }
          internal enum CompressionAlgorithm {
            /// Algorithm
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.compression_algorithm.caption", fallback: "Algorithm")
            internal enum Value {
              /// Unsupported
              internal static let other = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.compression_algorithm.value.other", fallback: "Unsupported")
            }
          }
          internal enum CompressionFraming {
            /// Framing
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.compression_framing.caption", fallback: "Framing")
          }
          internal enum Digest {
            /// Authentication
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.digest.caption", fallback: "Authentication")
            internal enum Value {
              /// Embedded
              internal static let embedded = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.digest.value.embedded", fallback: "Embedded")
            }
          }
          internal enum Eku {
            /// Extended verification
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.eku.caption", fallback: "Extended verification")
          }
          internal enum KeepAlive {
            internal enum Value {
              /// %d seconds
              internal static func seconds(_ p1: Int) -> String {
                return L10n.tr("Localizable", "endpoint.advanced.openvpn.items.keep_alive.value.seconds", p1, fallback: "%d seconds")
              }
            }
          }
          internal enum RandomEndpoint {
            /// Randomize endpoint
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.random_endpoint.caption", fallback: "Randomize endpoint")
          }
          internal enum RandomHostname {
            /// Randomize hostnames
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.random_hostname.caption", fallback: "Randomize hostnames")
          }
          internal enum RenegotiationSeconds {
            /// Renegotiation
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.renegotiation_seconds.caption", fallback: "Renegotiation")
            internal enum Value {
              /// after %@
              internal static func after(_ p1: Any) -> String {
                return L10n.tr("Localizable", "endpoint.advanced.openvpn.items.renegotiation_seconds.value.after", String(describing: p1), fallback: "after %@")
              }
            }
          }
          internal enum ResetOriginal {
            /// Reset configuration
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.reset_original.caption", fallback: "Reset configuration")
          }
          internal enum Route {
            /// Route
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.route.caption", fallback: "Route")
          }
          internal enum TlsWrapping {
            /// Wrapping
            internal static let caption = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.tls_wrapping.caption", fallback: "Wrapping")
            internal enum Value {
              /// Authentication
              internal static let auth = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.tls_wrapping.value.auth", fallback: "Authentication")
              /// Encryption
              internal static let crypt = L10n.tr("Localizable", "endpoint.advanced.openvpn.items.tls_wrapping.value.crypt", fallback: "Encryption")
            }
          }
        }
        internal enum Sections {
          internal enum Communication {
            /// Communication
            internal static let header = L10n.tr("Localizable", "endpoint.advanced.openvpn.sections.communication.header", fallback: "Communication")
          }
          internal enum Compression {
            /// Compression
            internal static let header = L10n.tr("Localizable", "endpoint.advanced.openvpn.sections.compression.header", fallback: "Compression")
          }
          internal enum Network {
            /// Network
            internal static let header = L10n.tr("Localizable", "endpoint.advanced.openvpn.sections.network.header", fallback: "Network")
          }
          internal enum Other {
            /// Other
            internal static let header = L10n.tr("Localizable", "endpoint.advanced.openvpn.sections.other.header", fallback: "Other")
          }
          internal enum Pull {
            /// Pull from server
            internal static let header = L10n.tr("Localizable", "endpoint.advanced.openvpn.sections.pull.header", fallback: "Pull from server")
          }
          internal enum Reset {
            /// If you ended up with broken connectivity after changing the communication parameters, tap to revert to the original configuration.
            internal static let footer = L10n.tr("Localizable", "endpoint.advanced.openvpn.sections.reset.footer", fallback: "If you ended up with broken connectivity after changing the communication parameters, tap to revert to the original configuration.")
          }
        }
      }
    }
    internal enum Wireguard {
      internal enum Items {
        internal enum AllowedIp {
          /// Allowed IP
          internal static let caption = L10n.tr("Localizable", "endpoint.wireguard.items.allowed_ip.caption", fallback: "Allowed IP")
        }
        internal enum Peer {
          /// MARK: ProfileView -> EndpointView
          internal static let caption = L10n.tr("Localizable", "endpoint.wireguard.items.peer.caption", fallback: "Peer")
        }
        internal enum PresharedKey {
          /// Preshared key
          internal static let caption = L10n.tr("Localizable", "endpoint.wireguard.items.preshared_key.caption", fallback: "Preshared key")
        }
      }
    }
  }
  internal enum Global {
    internal enum Alerts {
      internal enum Buttons {
        /// Don't ask again
        internal static let never = L10n.tr("Localizable", "global.alerts.buttons.never", fallback: "Don't ask again")
        /// Remind me later
        internal static let remind = L10n.tr("Localizable", "global.alerts.buttons.remind", fallback: "Remind me later")
      }
    }
    internal enum Errors {
      /// Missing account
      internal static let missingAccount = L10n.tr("Localizable", "global.errors.missing_account", fallback: "Missing account")
      /// Missing profile
      internal static let missingProfile = L10n.tr("Localizable", "global.errors.missing_profile", fallback: "Missing profile")
      /// Missing preset
      internal static let missingProviderPreset = L10n.tr("Localizable", "global.errors.missing_provider_preset", fallback: "Missing preset")
      /// Missing location
      internal static let missingProviderServer = L10n.tr("Localizable", "global.errors.missing_provider_server", fallback: "Missing location")
    }
    internal enum Messages {
      /// No e-mail account is configured.
      internal static let emailNotConfigured = L10n.tr("Localizable", "global.messages.email_not_configured", fallback: "No e-mail account is configured.")
      /// Passepartout is a user-friendly, open source OpenVPN / WireGuard client for iOS and macOS
      internal static let share = L10n.tr("Localizable", "global.messages.share", fallback: "Passepartout is a user-friendly, open source OpenVPN / WireGuard client for iOS and macOS")
      /// Passepartout is locked
      internal static let unlockApp = L10n.tr("Localizable", "global.messages.unlock_app", fallback: "Passepartout is locked")
    }
    internal enum Placeholders {
      /// My profile
      internal static let profileName = L10n.tr("Localizable", "global.placeholders.profile_name", fallback: "My profile")
    }
    internal enum Strings {
      /// Add
      internal static let add = L10n.tr("Localizable", "global.strings.add", fallback: "Add")
      /// Address
      internal static let address = L10n.tr("Localizable", "global.strings.address", fallback: "Address")
      /// Addresses
      internal static let addresses = L10n.tr("Localizable", "global.strings.addresses", fallback: "Addresses")
      /// Advanced
      internal static let advanced = L10n.tr("Localizable", "global.strings.advanced", fallback: "Advanced")
      /// Authentication
      internal static let authentication = L10n.tr("Localizable", "global.strings.authentication", fallback: "Authentication")
      /// Automatic
      internal static let automatic = L10n.tr("Localizable", "global.strings.automatic", fallback: "Automatic")
      /// Bytes
      internal static let bytes = L10n.tr("Localizable", "global.strings.bytes", fallback: "Bytes")
      /// MARK: Global
      internal static let cancel = L10n.tr("Localizable", "global.strings.cancel", fallback: "Cancel")
      /// Configuration
      internal static let configuration = L10n.tr("Localizable", "global.strings.configuration", fallback: "Configuration")
      /// Connect
      internal static let connect = L10n.tr("Localizable", "global.strings.connect", fallback: "Connect")
      /// Default
      internal static let `default` = L10n.tr("Localizable", "global.strings.default", fallback: "Default")
      /// Delete
      internal static let delete = L10n.tr("Localizable", "global.strings.delete", fallback: "Delete")
      /// Disabled
      internal static let disabled = L10n.tr("Localizable", "global.strings.disabled", fallback: "Disabled")
      /// Disconnect
      internal static let disconnect = L10n.tr("Localizable", "global.strings.disconnect", fallback: "Disconnect")
      /// Domain
      internal static let domain = L10n.tr("Localizable", "global.strings.domain", fallback: "Domain")
      /// Domains
      internal static let domains = L10n.tr("Localizable", "global.strings.domains", fallback: "Domains")
      /// Download
      internal static let download = L10n.tr("Localizable", "global.strings.download", fallback: "Download")
      /// Duplicate
      internal static let duplicate = L10n.tr("Localizable", "global.strings.duplicate", fallback: "Duplicate")
      /// Enabled
      internal static let enabled = L10n.tr("Localizable", "global.strings.enabled", fallback: "Enabled")
      /// Encryption
      internal static let encryption = L10n.tr("Localizable", "global.strings.encryption", fallback: "Encryption")
      /// Endpoint
      internal static let endpoint = L10n.tr("Localizable", "global.strings.endpoint", fallback: "Endpoint")
      /// Interface
      internal static let interface = L10n.tr("Localizable", "global.strings.interface", fallback: "Interface")
      /// Keep-alive
      internal static let keepalive = L10n.tr("Localizable", "global.strings.keepalive", fallback: "Keep-alive")
      /// Manual
      internal static let manual = L10n.tr("Localizable", "global.strings.manual", fallback: "Manual")
      /// Name
      internal static let name = L10n.tr("Localizable", "global.strings.name", fallback: "Name")
      /// Next
      internal static let next = L10n.tr("Localizable", "global.strings.next", fallback: "Next")
      /// None
      internal static let `none` = L10n.tr("Localizable", "global.strings.none", fallback: "None")
      /// MARK: Global
      internal static let ok = L10n.tr("Localizable", "global.strings.ok", fallback: "OK")
      /// Port
      internal static let port = L10n.tr("Localizable", "global.strings.port", fallback: "Port")
      /// Private key
      internal static let privateKey = L10n.tr("Localizable", "global.strings.private_key", fallback: "Private key")
      /// Profiles
      internal static let profiles = L10n.tr("Localizable", "global.strings.profiles", fallback: "Profiles")
      /// Protocol
      internal static let `protocol` = L10n.tr("Localizable", "global.strings.protocol", fallback: "Protocol")
      /// Protocols
      internal static let protocols = L10n.tr("Localizable", "global.strings.protocols", fallback: "Protocols")
      /// Provider
      internal static let provider = L10n.tr("Localizable", "global.strings.provider", fallback: "Provider")
      /// Providers
      internal static let providers = L10n.tr("Localizable", "global.strings.providers", fallback: "Providers")
      /// Proxy
      internal static let proxy = L10n.tr("Localizable", "global.strings.proxy", fallback: "Proxy")
      /// Public key
      internal static let publicKey = L10n.tr("Localizable", "global.strings.public_key", fallback: "Public key")
      /// Reconnect
      internal static let reconnect = L10n.tr("Localizable", "global.strings.reconnect", fallback: "Reconnect")
      /// Rename
      internal static let rename = L10n.tr("Localizable", "global.strings.rename", fallback: "Rename")
      /// Save
      internal static let save = L10n.tr("Localizable", "global.strings.save", fallback: "Save")
      /// Servers
      internal static let servers = L10n.tr("Localizable", "global.strings.servers", fallback: "Servers")
      /// Show
      internal static let show = L10n.tr("Localizable", "global.strings.show", fallback: "Show")
      /// Translations
      internal static let translations = L10n.tr("Localizable", "global.strings.translations", fallback: "Translations")
      /// Uninstall
      internal static let uninstall = L10n.tr("Localizable", "global.strings.uninstall", fallback: "Uninstall")
    }
  }
  internal enum Menu {
    internal enum All {
      internal enum About {
        /// About %@
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "menu.all.about.title", String(describing: p1), fallback: "About %@")
        }
      }
      internal enum Share {
        /// Share
        internal static let title = L10n.tr("Localizable", "menu.all.share.title", fallback: "Share")
      }
      internal enum Support {
        /// MARK: Menus
        internal static let title = L10n.tr("Localizable", "menu.all.support.title", fallback: "Support")
      }
    }
    internal enum Contextual {
      /// Invite
      internal static let shareGeneric = L10n.tr("Localizable", "menu.contextual.share_generic", fallback: "Invite")
      /// Tweet
      internal static let shareTwitter = L10n.tr("Localizable", "menu.contextual.share_twitter", fallback: "Tweet")
      internal enum AddProfile {
        /// From Files
        internal static let fromFiles = L10n.tr("Localizable", "menu.contextual.add_profile.from_files", fallback: "From Files")
        /// From text
        internal static let fromText = L10n.tr("Localizable", "menu.contextual.add_profile.from_text", fallback: "From text")
        /// Add %@
        internal static func imported(_ p1: Any) -> String {
          return L10n.tr("Localizable", "menu.contextual.add_profile.imported", String(describing: p1), fallback: "Add %@")
        }
      }
      internal enum Support {
        /// Community
        internal static let joinCommunity = L10n.tr("Localizable", "menu.contextual.support.join_community", fallback: "Community")
        /// Review
        internal static let writeReview = L10n.tr("Localizable", "menu.contextual.support.write_review", fallback: "Review")
      }
    }
    internal enum System {
      internal enum Quit {
        /// Quit %@
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "menu.system.quit.title", String(describing: p1), fallback: "Quit %@")
        }
        internal enum Messages {
          /// The VPN, if enabled, will still run in the background. Do you want to quit?
          internal static let confirm = L10n.tr("Localizable", "menu.system.quit.messages.confirm", fallback: "The VPN, if enabled, will still run in the background. Do you want to quit?")
        }
      }
    }
  }
  internal enum NetworkSettings {
    /// MARK: ProfileView -> NetworkSettingsView
    internal static let title = L10n.tr("Localizable", "network_settings.title", fallback: "Network settings")
    internal enum Gateway {
      /// Default gateway
      internal static let title = L10n.tr("Localizable", "network_settings.gateway.title", fallback: "Default gateway")
    }
    internal enum Items {
      internal enum AddDnsDomain {
        /// Add search domain
        internal static let caption = L10n.tr("Localizable", "network_settings.items.add_dns_domain.caption", fallback: "Add search domain")
      }
      internal enum AddDnsServer {
        /// Add address
        internal static let caption = L10n.tr("Localizable", "network_settings.items.add_dns_server.caption", fallback: "Add address")
      }
      internal enum AddProxyBypass {
        /// Add bypass domain
        internal static let caption = L10n.tr("Localizable", "network_settings.items.add_proxy_bypass.caption", fallback: "Add bypass domain")
      }
      internal enum ProxyBypass {
        /// Bypass domain
        internal static let caption = L10n.tr("Localizable", "network_settings.items.proxy_bypass.caption", fallback: "Bypass domain")
      }
    }
    internal enum Proxy {
      internal enum Items {
        internal enum BypassDomains {
          /// Bypass domains
          internal static let caption = L10n.tr("Localizable", "network_settings.proxy.items.bypass_domains.caption", fallback: "Bypass domains")
        }
      }
    }
    internal enum Sections {
      internal enum Choices {
        /// Override
        internal static let header = L10n.tr("Localizable", "network_settings.sections.choices.header", fallback: "Override")
      }
    }
  }
  internal enum OnDemand {
    /// MARK: ProfileView -> OnDemandView
    internal static let title = L10n.tr("Localizable", "on_demand.title", fallback: "Trusted networks")
    internal enum Items {
      internal enum Active {
        /// Trust
        internal static let caption = L10n.tr("Localizable", "on_demand.items.active.caption", fallback: "Trust")
      }
      internal enum AddSsid {
        /// Add Wi-Fi
        internal static let caption = L10n.tr("Localizable", "on_demand.items.add_ssid.caption", fallback: "Add Wi-Fi")
      }
      internal enum Ethernet {
        /// Trust wired connections
        internal static let caption = L10n.tr("Localizable", "on_demand.items.ethernet.caption", fallback: "Trust wired connections")
        /// Check to trust any wired cable connection.
        internal static let description = L10n.tr("Localizable", "on_demand.items.ethernet.description", fallback: "Check to trust any wired cable connection.")
      }
      internal enum Mobile {
        /// Cellular network
        internal static let caption = L10n.tr("Localizable", "on_demand.items.mobile.caption", fallback: "Cellular network")
      }
      internal enum Policy {
        /// Trust disables VPN
        internal static let caption = L10n.tr("Localizable", "on_demand.items.policy.caption", fallback: "Trust disables VPN")
      }
    }
    internal enum Sections {
      internal enum Policy {
        /// When entering a trusted network, the VPN is normally shut down and kept disconnected. Disable this option to not enforce such behavior.
        internal static let footer = L10n.tr("Localizable", "on_demand.sections.policy.footer", fallback: "When entering a trusted network, the VPN is normally shut down and kept disconnected. Disable this option to not enforce such behavior.")
      }
    }
  }
  internal enum Organizer {
    internal enum Alerts {
      internal enum Reddit {
        /// Did you know that Passepartout has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.
        /// 
        /// It's also a great way to show you care about this project.
        internal static let message = L10n.tr("Localizable", "organizer.alerts.reddit.message", fallback: "Did you know that Passepartout has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.\n\nIt's also a great way to show you care about this project.")
        internal enum Buttons {
          /// Subscribe now!
          internal static let subscribe = L10n.tr("Localizable", "organizer.alerts.reddit.buttons.subscribe", fallback: "Subscribe now!")
        }
      }
      internal enum RemoveProfile {
        /// Are you sure you want to delete profile %@?
        internal static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "organizer.alerts.remove_profile.message", String(describing: p1), fallback: "Are you sure you want to delete profile %@?")
        }
      }
    }
    internal enum Empty {
      /// MARK: OrganizerView
      internal static let noProfiles = L10n.tr("Localizable", "organizer.empty.no_profiles", fallback: "No profiles")
    }
    internal enum Sections {
      /// MARK: OrganizerView
      internal static let active = L10n.tr("Localizable", "organizer.sections.active", fallback: "In use")
    }
  }
  internal enum Paywall {
    /// MARK: PaywallView
    internal static let title = L10n.tr("Localizable", "paywall.title", fallback: "Purchase")
    internal enum Items {
      internal enum FullVersion {
        /// All providers (including future ones)
        /// %@
        internal static func extraDescription(_ p1: Any) -> String {
          return L10n.tr("Localizable", "paywall.items.full_version.extra_description", String(describing: p1), fallback: "All providers (including future ones)\n%@")
        }
      }
      internal enum Loading {
        /// Loading products
        internal static let caption = L10n.tr("Localizable", "paywall.items.loading.caption", fallback: "Loading products")
      }
      internal enum Restore {
        /// If you bought this app or feature in the past, you can restore your purchases and this screen won't show again.
        internal static let description = L10n.tr("Localizable", "paywall.items.restore.description", fallback: "If you bought this app or feature in the past, you can restore your purchases and this screen won't show again.")
        /// Restore purchases
        internal static let title = L10n.tr("Localizable", "paywall.items.restore.title", fallback: "Restore purchases")
      }
    }
    internal enum Sections {
      internal enum Products {
        /// Every product is a one-time purchase. Provider purchases do not include a VPN subscription.
        internal static let footer = L10n.tr("Localizable", "paywall.sections.products.footer", fallback: "Every product is a one-time purchase. Provider purchases do not include a VPN subscription.")
      }
    }
  }
  internal enum Preferences {
    /// MARK: PreferencesView (macOS)
    internal static let title = L10n.tr("Localizable", "preferences.title", fallback: "Preferences")
    internal enum Items {
      internal enum ConfirmQuit {
        /// Confirm quit
        internal static let caption = L10n.tr("Localizable", "preferences.items.confirm_quit.caption", fallback: "Confirm quit")
        /// Check to present a quit confirmation alert.
        internal static let footer = L10n.tr("Localizable", "preferences.items.confirm_quit.footer", fallback: "Check to present a quit confirmation alert.")
      }
      internal enum LaunchesOnLogin {
        /// Launch on login
        internal static let caption = L10n.tr("Localizable", "preferences.items.launches_on_login.caption", fallback: "Launch on login")
        /// Check to automatically launch the app on boot or login.
        internal static let footer = L10n.tr("Localizable", "preferences.items.launches_on_login.footer", fallback: "Check to automatically launch the app on boot or login.")
      }
    }
    internal enum Sections {
      internal enum General {
        /// General
        internal static let header = L10n.tr("Localizable", "preferences.sections.general.header", fallback: "General")
      }
    }
  }
  internal enum Profile {
    internal enum Alerts {
      internal enum ReconnectVpn {
        /// Do you want to reconnect to the VPN?
        internal static let message = L10n.tr("Localizable", "profile.alerts.reconnect_vpn.message", fallback: "Do you want to reconnect to the VPN?")
      }
      internal enum Rename {
        /// Rename profile
        internal static let title = L10n.tr("Localizable", "profile.alerts.rename.title", fallback: "Rename profile")
      }
      internal enum TestConnectivity {
        /// Connectivity
        internal static let title = L10n.tr("Localizable", "profile.alerts.test_connectivity.title", fallback: "Connectivity")
        internal enum Messages {
          /// Your device has no Internet connectivity, please review your profile parameters.
          internal static let failure = L10n.tr("Localizable", "profile.alerts.test_connectivity.messages.failure", fallback: "Your device has no Internet connectivity, please review your profile parameters.")
          /// Your device is connected to the Internet!
          internal static let success = L10n.tr("Localizable", "profile.alerts.test_connectivity.messages.success", fallback: "Your device is connected to the Internet!")
        }
      }
      internal enum UninstallVpn {
        /// Do you really want to erase the VPN configuration from your device settings? This may fix some broken VPN states and will not affect your provider and host profiles.
        internal static let message = L10n.tr("Localizable", "profile.alerts.uninstall_vpn.message", fallback: "Do you really want to erase the VPN configuration from your device settings? This may fix some broken VPN states and will not affect your provider and host profiles.")
      }
    }
    internal enum Items {
      internal enum Category {
        /// Category
        internal static let caption = L10n.tr("Localizable", "profile.items.category.caption", fallback: "Category")
      }
      internal enum ConnectionStatus {
        /// Status
        internal static let caption = L10n.tr("Localizable", "profile.items.connection_status.caption", fallback: "Status")
      }
      internal enum DataCount {
        /// Exchanged data
        internal static let caption = L10n.tr("Localizable", "profile.items.data_count.caption", fallback: "Exchanged data")
      }
      internal enum OnlyShowsFavorites {
        /// Only show favorite locations
        internal static let caption = L10n.tr("Localizable", "profile.items.only_shows_favorites.caption", fallback: "Only show favorite locations")
      }
      internal enum Provider {
        internal enum Refresh {
          /// Refresh infrastructure
          internal static let caption = L10n.tr("Localizable", "profile.items.provider.refresh.caption", fallback: "Refresh infrastructure")
        }
      }
      internal enum RandomizesServer {
        /// Randomize server
        internal static let caption = L10n.tr("Localizable", "profile.items.randomizes_server.caption", fallback: "Randomize server")
      }
      internal enum UseProfile {
        /// Use this profile
        internal static let caption = L10n.tr("Localizable", "profile.items.use_profile.caption", fallback: "Use this profile")
      }
      internal enum Vpn {
        internal enum TurnOff {
          /// Disable VPN
          internal static let caption = L10n.tr("Localizable", "profile.items.vpn.turn_off.caption", fallback: "Disable VPN")
        }
        internal enum TurnOn {
          /// Enable VPN
          internal static let caption = L10n.tr("Localizable", "profile.items.vpn.turn_on.caption", fallback: "Enable VPN")
        }
      }
      internal enum VpnResolvesHostname {
        /// Resolve provider hostname
        internal static let caption = L10n.tr("Localizable", "profile.items.vpn_resolves_hostname.caption", fallback: "Resolve provider hostname")
      }
      internal enum VpnService {
        /// Enabled
        internal static let caption = L10n.tr("Localizable", "profile.items.vpn_service.caption", fallback: "Enabled")
      }
      internal enum VpnSurvivesSleep {
        /// Keep alive on sleep
        internal static let caption = L10n.tr("Localizable", "profile.items.vpn_survives_sleep.caption", fallback: "Keep alive on sleep")
      }
    }
    internal enum Sections {
      internal enum Feedback {
        /// Feedback
        internal static let header = L10n.tr("Localizable", "profile.sections.feedback.header", fallback: "Feedback")
      }
      internal enum ProviderInfrastructure {
        /// Last updated on %@.
        internal static func footer(_ p1: Any) -> String {
          return L10n.tr("Localizable", "profile.sections.provider_infrastructure.footer", String(describing: p1), fallback: "Last updated on %@.")
        }
      }
      internal enum Status {
        /// Connection
        internal static let header = L10n.tr("Localizable", "profile.sections.status.header", fallback: "Connection")
      }
      internal enum Vpn {
        /// The connection will be established whenever necessary.
        internal static let footer = L10n.tr("Localizable", "profile.sections.vpn.footer", fallback: "The connection will be established whenever necessary.")
      }
      internal enum VpnResolvesHostname {
        /// Preferred in most networks and required in some IPv6 networks. Disable where DNS is blocked, or to speed up negotiation when DNS is slow to respond.
        internal static let footer = L10n.tr("Localizable", "profile.sections.vpn_resolves_hostname.footer", fallback: "Preferred in most networks and required in some IPv6 networks. Disable where DNS is blocked, or to speed up negotiation when DNS is slow to respond.")
      }
      internal enum VpnSurvivesSleep {
        /// Disable to improve battery usage, at the expense of occasional slowdowns due to wake-up reconnections.
        internal static let footer = L10n.tr("Localizable", "profile.sections.vpn_survives_sleep.footer", fallback: "Disable to improve battery usage, at the expense of occasional slowdowns due to wake-up reconnections.")
      }
    }
    internal enum Welcome {
      /// MARK: ProfileView
      internal static let message = L10n.tr("Localizable", "profile.welcome.message", fallback: "Welcome to Passepartout!\n\nUse the organizer to add a new profile.")
    }
  }
  internal enum Provider {
    internal enum Location {
      /// MARK: ProfileView -> Provider*View
      internal static let title = L10n.tr("Localizable", "provider.location.title", fallback: "Location")
      internal enum Actions {
        /// Favorite
        internal static let favorite = L10n.tr("Localizable", "provider.location.actions.favorite", fallback: "Favorite")
        /// Unfavorite
        internal static let unfavorite = L10n.tr("Localizable", "provider.location.actions.unfavorite", fallback: "Unfavorite")
      }
      internal enum Sections {
        internal enum EmptyFavorites {
          /// Swipe left on a location to add or remove it from Favorites.
          internal static let footer = L10n.tr("Localizable", "provider.location.sections.empty_favorites.footer", fallback: "Swipe left on a location to add or remove it from Favorites.")
        }
      }
    }
    internal enum Preset {
      /// Preset
      internal static let title = L10n.tr("Localizable", "provider.preset.title", fallback: "Preset")
    }
  }
  internal enum ReportIssue {
    internal enum Alert {
      /// MARK: DiagnosticsView -> ReportIssueView
      internal static let title = L10n.tr("Localizable", "report_issue.alert.title", fallback: "Report issue")
    }
  }
  internal enum Settings {
    /// MARK: SettingsView
    internal static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
    internal enum Items {
      internal enum Donate {
        /// Make a donation
        internal static let caption = L10n.tr("Localizable", "settings.items.donate.caption", fallback: "Make a donation")
      }
      internal enum LocksInBackground {
        /// Lock app access
        internal static let caption = L10n.tr("Localizable", "settings.items.locks_in_background.caption", fallback: "Lock app access")
      }
    }
  }
  internal enum Shortcuts {
    internal enum Add {
      /// MARK: ShortcutsView
      internal static let title = L10n.tr("Localizable", "shortcuts.add.title", fallback: "Add shortcut")
      internal enum Alerts {
        internal enum NoProfiles {
          /// There is no profile to connect to.
          internal static let message = L10n.tr("Localizable", "shortcuts.add.alerts.no_profiles.message", fallback: "There is no profile to connect to.")
        }
      }
      internal enum Items {
        internal enum Connect {
          /// Connect to
          internal static let caption = L10n.tr("Localizable", "shortcuts.add.items.connect.caption", fallback: "Connect to")
        }
        internal enum DisableVpn {
          /// Disable VPN
          internal static let caption = L10n.tr("Localizable", "shortcuts.add.items.disable_vpn.caption", fallback: "Disable VPN")
        }
        internal enum EnableVpn {
          /// Enable VPN
          internal static let caption = L10n.tr("Localizable", "shortcuts.add.items.enable_vpn.caption", fallback: "Enable VPN")
        }
        internal enum TrustCellular {
          /// Trust cellular network
          internal static let caption = L10n.tr("Localizable", "shortcuts.add.items.trust_cellular.caption", fallback: "Trust cellular network")
        }
        internal enum TrustCurrentWifi {
          /// Trust current Wi-Fi
          internal static let caption = L10n.tr("Localizable", "shortcuts.add.items.trust_current_wifi.caption", fallback: "Trust current Wi-Fi")
        }
        internal enum UntrustCellular {
          /// Untrust cellular network
          internal static let caption = L10n.tr("Localizable", "shortcuts.add.items.untrust_cellular.caption", fallback: "Untrust cellular network")
        }
        internal enum UntrustCurrentWifi {
          /// Untrust current Wi-Fi
          internal static let caption = L10n.tr("Localizable", "shortcuts.add.items.untrust_current_wifi.caption", fallback: "Untrust current Wi-Fi")
        }
      }
      internal enum Sections {
        internal enum Cellular {
          /// Cellular
          internal static let header = L10n.tr("Localizable", "shortcuts.add.sections.cellular.header", fallback: "Cellular")
        }
        internal enum Wifi {
          /// Wi-Fi
          internal static let header = L10n.tr("Localizable", "shortcuts.add.sections.wifi.header", fallback: "Wi-Fi")
        }
      }
    }
    internal enum Edit {
      /// Manage shortcuts
      internal static let title = L10n.tr("Localizable", "shortcuts.edit.title", fallback: "Manage shortcuts")
      internal enum Items {
        internal enum AddShortcut {
          /// Add shortcut
          internal static let caption = L10n.tr("Localizable", "shortcuts.edit.items.add_shortcut.caption", fallback: "Add shortcut")
        }
      }
      internal enum Sections {
        internal enum Add {
          /// Get help from Siri to speed up your most common interactions with the app.
          internal static let footer = L10n.tr("Localizable", "shortcuts.edit.sections.add.footer", fallback: "Get help from Siri to speed up your most common interactions with the app.")
        }
        internal enum All {
          /// Existing shortcuts
          internal static let header = L10n.tr("Localizable", "shortcuts.edit.sections.all.header", fallback: "Existing shortcuts")
        }
      }
    }
  }
  internal enum Tunnelkit {
    internal enum Errors {
      /// Unable to parse the provided configuration file (%@).
      internal static func parsing(_ p1: Any) -> String {
        return L10n.tr("Localizable", "tunnelkit.errors.parsing", String(describing: p1), fallback: "Unable to parse the provided configuration file (%@).")
      }
      internal enum Openvpn {
        /// Unable to decrypt private key.
        internal static let decryption = L10n.tr("Localizable", "tunnelkit.errors.openvpn.decryption", fallback: "Unable to decrypt private key.")
        /// The configuration file contains a malformed option (%@).
        internal static func malformed(_ p1: Any) -> String {
          return L10n.tr("Localizable", "tunnelkit.errors.openvpn.malformed", String(describing: p1), fallback: "The configuration file contains a malformed option (%@).")
        }
        /// Please enter the encryption passphrase.
        internal static let passphraseRequired = L10n.tr("Localizable", "tunnelkit.errors.openvpn.passphrase_required", fallback: "Please enter the encryption passphrase.")
        /// The configuration file is correct but contains a potentially unsupported option (%@).
        /// 
        /// Connectivity may break depending on server settings.
        internal static func potentiallyUnsupportedOption(_ p1: Any) -> String {
          return L10n.tr("Localizable", "tunnelkit.errors.openvpn.potentially_unsupported_option", String(describing: p1), fallback: "The configuration file is correct but contains a potentially unsupported option (%@).\n\nConnectivity may break depending on server settings.")
        }
        /// The configuration file lacks a required option (%@).
        internal static func requiredOption(_ p1: Any) -> String {
          return L10n.tr("Localizable", "tunnelkit.errors.openvpn.required_option", String(describing: p1), fallback: "The configuration file lacks a required option (%@).")
        }
        /// The configuration file contains an unsupported option (%@).
        internal static func unsupportedOption(_ p1: Any) -> String {
          return L10n.tr("Localizable", "tunnelkit.errors.openvpn.unsupported_option", String(describing: p1), fallback: "The configuration file contains an unsupported option (%@).")
        }
      }
      internal enum Vpn {
        /// Auth failed
        internal static let auth = L10n.tr("Localizable", "tunnelkit.errors.vpn.auth", fallback: "Auth failed")
        /// Compression unsupported
        internal static let compression = L10n.tr("Localizable", "tunnelkit.errors.vpn.compression", fallback: "Compression unsupported")
        /// DNS failed
        internal static let dns = L10n.tr("Localizable", "tunnelkit.errors.vpn.dns", fallback: "DNS failed")
        /// Encryption failed
        internal static let encryption = L10n.tr("Localizable", "tunnelkit.errors.vpn.encryption", fallback: "Encryption failed")
        /// No gateway
        internal static let gateway = L10n.tr("Localizable", "tunnelkit.errors.vpn.gateway", fallback: "No gateway")
        /// Network changed
        internal static let network = L10n.tr("Localizable", "tunnelkit.errors.vpn.network", fallback: "Network changed")
        /// Missing routing
        internal static let routing = L10n.tr("Localizable", "tunnelkit.errors.vpn.routing", fallback: "Missing routing")
        /// Server shutdown
        internal static let shutdown = L10n.tr("Localizable", "tunnelkit.errors.vpn.shutdown", fallback: "Server shutdown")
        /// Timeout
        internal static let timeout = L10n.tr("Localizable", "tunnelkit.errors.vpn.timeout", fallback: "Timeout")
        /// TLS failed
        internal static let tls = L10n.tr("Localizable", "tunnelkit.errors.vpn.tls", fallback: "TLS failed")
      }
    }
    internal enum Vpn {
      /// Active
      internal static let active = L10n.tr("Localizable", "tunnelkit.vpn.active", fallback: "Active")
      /// MARK: TunnelKit
      internal static let connecting = L10n.tr("Localizable", "tunnelkit.vpn.connecting", fallback: "Connecting")
      /// Disabled
      internal static let disabled = L10n.tr("Localizable", "tunnelkit.vpn.disabled", fallback: "Disabled")
      /// Disconnecting
      internal static let disconnecting = L10n.tr("Localizable", "tunnelkit.vpn.disconnecting", fallback: "Disconnecting")
      /// Inactive
      internal static let inactive = L10n.tr("Localizable", "tunnelkit.vpn.inactive", fallback: "Inactive")
      /// Off
      internal static let unused = L10n.tr("Localizable", "tunnelkit.vpn.unused", fallback: "Off")
    }
  }
  internal enum Version {
    /// MARK: AboutView -> VersionView
    internal static let title = L10n.tr("Localizable", "version.title", fallback: "Version")
    internal enum Labels {
      /// Passepartout and TunnelKit are written and maintained by Davide De Rosa (keeshux).
      /// 
      /// Source code for Passepartout and TunnelKit is publicly available on GitHub under the GPLv3, you can find links in the home page.
      internal static let intro = L10n.tr("Localizable", "version.labels.intro", fallback: "Passepartout and TunnelKit are written and maintained by Davide De Rosa (keeshux).\n\nSource code for Passepartout and TunnelKit is publicly available on GitHub under the GPLv3, you can find links in the home page.")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
