// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {
  internal enum Alerts {
    internal enum Iap {
      internal enum Restricted {
        /// The requested feature is unavailable in this build.
        internal static let message = Strings.tr("Localizable", "alerts.iap.restricted.message", fallback: "The requested feature is unavailable in this build.")
        /// Restricted
        internal static let title = Strings.tr("Localizable", "alerts.iap.restricted.title", fallback: "Restricted")
      }
    }
  }
  internal enum Entities {
    internal enum ConnectionStatus {
      /// Connected
      internal static let connected = Strings.tr("Localizable", "entities.connection_status.connected", fallback: "Connected")
      /// Connecting
      internal static let connecting = Strings.tr("Localizable", "entities.connection_status.connecting", fallback: "Connecting")
      /// Disconnected
      internal static let disconnected = Strings.tr("Localizable", "entities.connection_status.disconnected", fallback: "Disconnected")
      /// Disconnecting
      internal static let disconnecting = Strings.tr("Localizable", "entities.connection_status.disconnecting", fallback: "Disconnecting")
    }
    internal enum Dns {
      /// Search domains
      internal static let searchDomains = Strings.tr("Localizable", "entities.dns.search_domains", fallback: "Search domains")
      /// Servers
      internal static let servers = Strings.tr("Localizable", "entities.dns.servers", fallback: "Servers")
    }
    internal enum DnsProtocol {
      /// Cleartext
      internal static let cleartext = Strings.tr("Localizable", "entities.dns_protocol.cleartext", fallback: "Cleartext")
      /// Over HTTPS
      internal static let https = Strings.tr("Localizable", "entities.dns_protocol.https", fallback: "Over HTTPS")
      /// Over TLS
      internal static let tls = Strings.tr("Localizable", "entities.dns_protocol.tls", fallback: "Over TLS")
    }
    internal enum HttpProxy {
      /// Bypass domains
      internal static let bypassDomains = Strings.tr("Localizable", "entities.http_proxy.bypass_domains", fallback: "Bypass domains")
    }
    internal enum OnDemand {
      internal enum Policy {
        /// All networks
        internal static let any = Strings.tr("Localizable", "entities.on_demand.policy.any", fallback: "All networks")
        /// Excluding
        internal static let excluding = Strings.tr("Localizable", "entities.on_demand.policy.excluding", fallback: "Excluding")
        /// Including
        internal static let including = Strings.tr("Localizable", "entities.on_demand.policy.including", fallback: "Including")
      }
    }
    internal enum Openvpn {
      internal enum CompressionAlgorithm {
        /// Unsupported
        internal static let other = Strings.tr("Localizable", "entities.openvpn.compression_algorithm.other", fallback: "Unsupported")
      }
      internal enum OtpMethod {
        /// Append
        internal static let append = Strings.tr("Localizable", "entities.openvpn.otp_method.append", fallback: "Append")
        /// Encode
        internal static let encode = Strings.tr("Localizable", "entities.openvpn.otp_method.encode", fallback: "Encode")
        /// None
        internal static let `none` = Strings.tr("Localizable", "entities.openvpn.otp_method.none", fallback: "None")
      }
    }
    internal enum Profile {
      internal enum Name {
        /// New profile
        internal static let new = Strings.tr("Localizable", "entities.profile.name.new", fallback: "New profile")
      }
    }
    internal enum TunnelStatus {
      /// Activating
      internal static let activating = Strings.tr("Localizable", "entities.tunnel_status.activating", fallback: "Activating")
      /// Active
      internal static let active = Strings.tr("Localizable", "entities.tunnel_status.active", fallback: "Active")
      /// Deactivating
      internal static let deactivating = Strings.tr("Localizable", "entities.tunnel_status.deactivating", fallback: "Deactivating")
      /// Inactive
      internal static let inactive = Strings.tr("Localizable", "entities.tunnel_status.inactive", fallback: "Inactive")
    }
  }
  internal enum Errors {
    internal enum App {
      /// Unable to complete operation.
      internal static let `default` = Strings.tr("Localizable", "errors.app.default", fallback: "Unable to complete operation.")
      /// Profile name is empty.
      internal static let emptyProfileName = Strings.tr("Localizable", "errors.app.empty_profile_name", fallback: "Profile name is empty.")
      /// IP module can only be enabled together with a connection.
      internal static let ipModuleRequiresConnection = Strings.tr("Localizable", "errors.app.ip_module_requires_connection", fallback: "IP module can only be enabled together with a connection.")
      /// Module %@ is malformed. %@
      internal static func malformedModule(_ p1: Any, _ p2: Any) -> String {
        return Strings.tr("Localizable", "errors.app.malformed_module", String(describing: p1), String(describing: p2), fallback: "Module %@ is malformed. %@")
      }
      /// Only one connection module can be active at a time.
      internal static let multipleConnectionModules = Strings.tr("Localizable", "errors.app.multiple_connection_modules", fallback: "Only one connection module can be active at a time.")
      internal enum Passepartout {
        /// Unable to complete operation (code=%@).
        internal static func `default`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.default", String(describing: p1), fallback: "Unable to complete operation (code=%@).")
        }
        /// Invalid fields (%@).
        internal static func invalidFields(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.invalid_fields", String(describing: p1), fallback: "Invalid fields (%@).")
        }
        /// Unable to parse file.
        internal static let parsing = Strings.tr("Localizable", "errors.app.passepartout.parsing", fallback: "Unable to parse file.")
      }
    }
    internal enum Tunnel {
      /// Auth failed
      internal static let auth = Strings.tr("Localizable", "errors.tunnel.auth", fallback: "Auth failed")
      /// Compression unsupported
      internal static let compression = Strings.tr("Localizable", "errors.tunnel.compression", fallback: "Compression unsupported")
      /// DNS failed
      internal static let dns = Strings.tr("Localizable", "errors.tunnel.dns", fallback: "DNS failed")
      /// Encryption failed
      internal static let encryption = Strings.tr("Localizable", "errors.tunnel.encryption", fallback: "Encryption failed")
      /// Failed
      internal static let generic = Strings.tr("Localizable", "errors.tunnel.generic", fallback: "Failed")
      /// Missing routing
      internal static let routing = Strings.tr("Localizable", "errors.tunnel.routing", fallback: "Missing routing")
      /// Server shutdown
      internal static let shutdown = Strings.tr("Localizable", "errors.tunnel.shutdown", fallback: "Server shutdown")
      /// Timeout
      internal static let timeout = Strings.tr("Localizable", "errors.tunnel.timeout", fallback: "Timeout")
      /// TLS failed
      internal static let tls = Strings.tr("Localizable", "errors.tunnel.tls", fallback: "TLS failed")
    }
  }
  internal enum Global {
    /// About
    internal static let about = Strings.tr("Localizable", "global.about", fallback: "About")
    /// Account
    internal static let account = Strings.tr("Localizable", "global.account", fallback: "Account")
    /// Address
    internal static let address = Strings.tr("Localizable", "global.address", fallback: "Address")
    /// Addresses
    internal static let addresses = Strings.tr("Localizable", "global.addresses", fallback: "Addresses")
    /// Any
    internal static let any = Strings.tr("Localizable", "global.any", fallback: "Any")
    /// Cancel
    internal static let cancel = Strings.tr("Localizable", "global.cancel", fallback: "Cancel")
    /// Certificate
    internal static let certificate = Strings.tr("Localizable", "global.certificate", fallback: "Certificate")
    /// Compression
    internal static let compression = Strings.tr("Localizable", "global.compression", fallback: "Compression")
    /// Connect
    internal static let connect = Strings.tr("Localizable", "global.connect", fallback: "Connect")
    /// Connection
    internal static let connection = Strings.tr("Localizable", "global.connection", fallback: "Connection")
    /// Default
    internal static let `default` = Strings.tr("Localizable", "global.default", fallback: "Default")
    /// Destination
    internal static let destination = Strings.tr("Localizable", "global.destination", fallback: "Destination")
    /// Disable
    internal static let disable = Strings.tr("Localizable", "global.disable", fallback: "Disable")
    /// Disabled
    internal static let disabled = Strings.tr("Localizable", "global.disabled", fallback: "Disabled")
    /// Disconnect
    internal static let disconnect = Strings.tr("Localizable", "global.disconnect", fallback: "Disconnect")
    /// Domain
    internal static let domain = Strings.tr("Localizable", "global.domain", fallback: "Domain")
    /// Done
    internal static let done = Strings.tr("Localizable", "global.done", fallback: "Done")
    /// Duplicate
    internal static let duplicate = Strings.tr("Localizable", "global.duplicate", fallback: "Duplicate")
    /// Edit
    internal static let edit = Strings.tr("Localizable", "global.edit", fallback: "Edit")
    /// Empty
    internal static let empty = Strings.tr("Localizable", "global.empty", fallback: "Empty")
    /// Enable
    internal static let enable = Strings.tr("Localizable", "global.enable", fallback: "Enable")
    /// Enabled
    internal static let enabled = Strings.tr("Localizable", "global.enabled", fallback: "Enabled")
    /// Endpoint
    internal static let endpoint = Strings.tr("Localizable", "global.endpoint", fallback: "Endpoint")
    /// Folder
    internal static let folder = Strings.tr("Localizable", "global.folder", fallback: "Folder")
    /// Gateway
    internal static let gateway = Strings.tr("Localizable", "global.gateway", fallback: "Gateway")
    /// General
    internal static let general = Strings.tr("Localizable", "global.general", fallback: "General")
    /// Hostname
    internal static let hostname = Strings.tr("Localizable", "global.hostname", fallback: "Hostname")
    /// Interface
    internal static let interface = Strings.tr("Localizable", "global.interface", fallback: "Interface")
    /// Keep-alive
    internal static let keepAlive = Strings.tr("Localizable", "global.keep_alive", fallback: "Keep-alive")
    /// Key
    internal static let key = Strings.tr("Localizable", "global.key", fallback: "Key")
    /// Method
    internal static let method = Strings.tr("Localizable", "global.method", fallback: "Method")
    /// Modules
    internal static let modules = Strings.tr("Localizable", "global.modules", fallback: "Modules")
    /// %d seconds
    internal static func nSeconds(_ p1: Int) -> String {
      return Strings.tr("Localizable", "global.n_seconds", p1, fallback: "%d seconds")
    }
    /// Name
    internal static let name = Strings.tr("Localizable", "global.name", fallback: "Name")
    /// Networks
    internal static let networks = Strings.tr("Localizable", "global.networks", fallback: "Networks")
    /// No content
    internal static let noContent = Strings.tr("Localizable", "global.no_content", fallback: "No content")
    /// No selection
    internal static let noSelection = Strings.tr("Localizable", "global.no_selection", fallback: "No selection")
    /// None
    internal static let `none` = Strings.tr("Localizable", "global.none", fallback: "None")
    /// OK
    internal static let ok = Strings.tr("Localizable", "global.ok", fallback: "OK")
    /// On demand
    internal static let onDemand = Strings.tr("Localizable", "global.on_demand", fallback: "On demand")
    /// Other
    internal static let other = Strings.tr("Localizable", "global.other", fallback: "Other")
    /// Password
    internal static let password = Strings.tr("Localizable", "global.password", fallback: "Password")
    /// Port
    internal static let port = Strings.tr("Localizable", "global.port", fallback: "Port")
    /// Private key
    internal static let privateKey = Strings.tr("Localizable", "global.private_key", fallback: "Private key")
    /// Protocol
    internal static let `protocol` = Strings.tr("Localizable", "global.protocol", fallback: "Protocol")
    /// Public key
    internal static let publicKey = Strings.tr("Localizable", "global.public_key", fallback: "Public key")
    /// Delete
    internal static let remove = Strings.tr("Localizable", "global.remove", fallback: "Delete")
    /// Restart
    internal static let restart = Strings.tr("Localizable", "global.restart", fallback: "Restart")
    /// Route
    internal static let route = Strings.tr("Localizable", "global.route", fallback: "Route")
    /// Routes
    internal static let routes = Strings.tr("Localizable", "global.routes", fallback: "Routes")
    /// Save
    internal static let save = Strings.tr("Localizable", "global.save", fallback: "Save")
    /// Server
    internal static let server = Strings.tr("Localizable", "global.server", fallback: "Server")
    /// Servers
    internal static let servers = Strings.tr("Localizable", "global.servers", fallback: "Servers")
    /// Settings
    internal static let settings = Strings.tr("Localizable", "global.settings", fallback: "Settings")
    /// Status
    internal static let status = Strings.tr("Localizable", "global.status", fallback: "Status")
    /// Storage
    internal static let storage = Strings.tr("Localizable", "global.storage", fallback: "Storage")
    /// Subnet
    internal static let subnet = Strings.tr("Localizable", "global.subnet", fallback: "Subnet")
    /// Uninstall
    internal static let uninstall = Strings.tr("Localizable", "global.uninstall", fallback: "Uninstall")
    /// Unknown
    internal static let unknown = Strings.tr("Localizable", "global.unknown", fallback: "Unknown")
    /// Username
    internal static let username = Strings.tr("Localizable", "global.username", fallback: "Username")
    /// Version
    internal static let version = Strings.tr("Localizable", "global.version", fallback: "Version")
  }
  internal enum Modules {
    internal enum Dns {
      internal enum SearchDomains {
        /// Add domain
        internal static let add = Strings.tr("Localizable", "modules.dns.search_domains.add", fallback: "Add domain")
      }
      internal enum Servers {
        /// Add address
        internal static let add = Strings.tr("Localizable", "modules.dns.servers.add", fallback: "Add address")
      }
    }
    internal enum HttpProxy {
      internal enum BypassDomains {
        /// Add bypass domain
        internal static let add = Strings.tr("Localizable", "modules.http_proxy.bypass_domains.add", fallback: "Add bypass domain")
      }
    }
    internal enum Ip {
      internal enum Routes {
        /// Add %@
        internal static func addFamily(_ p1: Any) -> String {
          return Strings.tr("Localizable", "modules.ip.routes.add_family", String(describing: p1), fallback: "Add %@")
        }
        /// Exclude route
        internal static let exclude = Strings.tr("Localizable", "modules.ip.routes.exclude", fallback: "Exclude route")
        /// Excluded routes
        internal static let excluded = Strings.tr("Localizable", "modules.ip.routes.excluded", fallback: "Excluded routes")
        /// Include route
        internal static let include = Strings.tr("Localizable", "modules.ip.routes.include", fallback: "Include route")
        /// Included routes
        internal static let included = Strings.tr("Localizable", "modules.ip.routes.included", fallback: "Included routes")
      }
    }
    internal enum OnDemand {
      /// Ethernet
      internal static let ethernet = Strings.tr("Localizable", "modules.on_demand.ethernet", fallback: "Ethernet")
      /// Mobile
      internal static let mobile = Strings.tr("Localizable", "modules.on_demand.mobile", fallback: "Mobile")
      /// Policy
      internal static let policy = Strings.tr("Localizable", "modules.on_demand.policy", fallback: "Policy")
      internal enum Policy {
        /// Activate the VPN %@.
        internal static func footer(_ p1: Any) -> String {
          return Strings.tr("Localizable", "modules.on_demand.policy.footer", String(describing: p1), fallback: "Activate the VPN %@.")
        }
        internal enum Footer {
          /// in any network
          internal static let any = Strings.tr("Localizable", "modules.on_demand.policy.footer.any", fallback: "in any network")
          /// except in the networks below
          internal static let excluding = Strings.tr("Localizable", "modules.on_demand.policy.footer.excluding", fallback: "except in the networks below")
          /// only in the networks below
          internal static let including = Strings.tr("Localizable", "modules.on_demand.policy.footer.including", fallback: "only in the networks below")
        }
      }
      internal enum Ssid {
        /// Add SSID
        internal static let add = Strings.tr("Localizable", "modules.on_demand.ssid.add", fallback: "Add SSID")
      }
    }
    internal enum Openvpn {
      /// Cipher
      internal static let cipher = Strings.tr("Localizable", "modules.openvpn.cipher", fallback: "Cipher")
      /// Communication
      internal static let communication = Strings.tr("Localizable", "modules.openvpn.communication", fallback: "Communication")
      /// Compression
      internal static let compression = Strings.tr("Localizable", "modules.openvpn.compression", fallback: "Compression")
      /// Algorithm
      internal static let compressionAlgorithm = Strings.tr("Localizable", "modules.openvpn.compression_algorithm", fallback: "Algorithm")
      /// Framing
      internal static let compressionFraming = Strings.tr("Localizable", "modules.openvpn.compression_framing", fallback: "Framing")
      /// Credentials
      internal static let credentials = Strings.tr("Localizable", "modules.openvpn.credentials", fallback: "Credentials")
      /// Digest
      internal static let digest = Strings.tr("Localizable", "modules.openvpn.digest", fallback: "Digest")
      /// Extended verification
      internal static let eku = Strings.tr("Localizable", "modules.openvpn.eku", fallback: "Extended verification")
      /// Pull
      internal static let pull = Strings.tr("Localizable", "modules.openvpn.pull", fallback: "Pull")
      /// Randomize endpoint
      internal static let randomizeEndpoint = Strings.tr("Localizable", "modules.openvpn.randomize_endpoint", fallback: "Randomize endpoint")
      /// Randomize hostname
      internal static let randomizeHostname = Strings.tr("Localizable", "modules.openvpn.randomize_hostname", fallback: "Randomize hostname")
      /// Redirect gateway
      internal static let redirectGateway = Strings.tr("Localizable", "modules.openvpn.redirect_gateway", fallback: "Redirect gateway")
      /// Remotes
      internal static let remotes = Strings.tr("Localizable", "modules.openvpn.remotes", fallback: "Remotes")
      /// Renegotiation
      internal static let renegotiation = Strings.tr("Localizable", "modules.openvpn.renegotiation", fallback: "Renegotiation")
      /// Wrapping
      internal static let tlsWrap = Strings.tr("Localizable", "modules.openvpn.tls_wrap", fallback: "Wrapping")
      internal enum Credentials {
        /// Interactive
        internal static let interactive = Strings.tr("Localizable", "modules.openvpn.credentials.interactive", fallback: "Interactive")
        internal enum Interactive {
          /// On-demand will be disabled.
          internal static let footer = Strings.tr("Localizable", "modules.openvpn.credentials.interactive.footer", fallback: "On-demand will be disabled.")
        }
        internal enum OtpMethod {
          internal enum Approach {
            /// The OTP will be appended to the password.
            internal static let append = Strings.tr("Localizable", "modules.openvpn.credentials.otp_method.approach.append", fallback: "The OTP will be appended to the password.")
            /// The OTP will be encoded in Base64 with the password.
            internal static let encode = Strings.tr("Localizable", "modules.openvpn.credentials.otp_method.approach.encode", fallback: "The OTP will be encoded in Base64 with the password.")
          }
        }
      }
    }
    internal enum Wireguard {
      /// Allowed IPs
      internal static let allowedIps = Strings.tr("Localizable", "modules.wireguard.allowed_ips", fallback: "Allowed IPs")
      /// Interface
      internal static let interface = Strings.tr("Localizable", "modules.wireguard.interface", fallback: "Interface")
      /// Peer #%d
      internal static func peer(_ p1: Int) -> String {
        return Strings.tr("Localizable", "modules.wireguard.peer", p1, fallback: "Peer #%d")
      }
      /// Pre-shared key
      internal static let presharedKey = Strings.tr("Localizable", "modules.wireguard.preshared_key", fallback: "Pre-shared key")
    }
  }
  internal enum Placeholders {
    /// secret
    internal static let secret = Strings.tr("Localizable", "placeholders.secret", fallback: "secret")
    /// username
    internal static let username = Strings.tr("Localizable", "placeholders.username", fallback: "username")
    internal enum OnDemand {
      /// My SSID
      internal static let ssid = Strings.tr("Localizable", "placeholders.on_demand.ssid", fallback: "My SSID")
    }
    internal enum Profile {
      /// My profile
      internal static let name = Strings.tr("Localizable", "placeholders.profile.name", fallback: "My profile")
    }
  }
  internal enum Views {
    internal enum About {
      /// About
      internal static let title = Strings.tr("Localizable", "views.about.title", fallback: "About")
      internal enum Credits {
        /// Licenses
        internal static let licenses = Strings.tr("Localizable", "views.about.credits.licenses", fallback: "Licenses")
        /// Notices
        internal static let notices = Strings.tr("Localizable", "views.about.credits.notices", fallback: "Notices")
        /// Credits
        internal static let title = Strings.tr("Localizable", "views.about.credits.title", fallback: "Credits")
        /// Translations
        internal static let translations = Strings.tr("Localizable", "views.about.credits.translations", fallback: "Translations")
      }
      internal enum Links {
        /// Links
        internal static let title = Strings.tr("Localizable", "views.about.links.title", fallback: "Links")
        internal enum Rows {
          /// Disclaimer
          internal static let disclaimer = Strings.tr("Localizable", "views.about.links.rows.disclaimer", fallback: "Disclaimer")
          /// Home page
          internal static let homePage = Strings.tr("Localizable", "views.about.links.rows.home_page", fallback: "Home page")
          /// Join community
          internal static let joinCommunity = Strings.tr("Localizable", "views.about.links.rows.join_community", fallback: "Join community")
          /// Privacy policy
          internal static let privacyPolicy = Strings.tr("Localizable", "views.about.links.rows.privacy_policy", fallback: "Privacy policy")
          /// Write a review
          internal static let writeReview = Strings.tr("Localizable", "views.about.links.rows.write_review", fallback: "Write a review")
        }
        internal enum Sections {
          /// Support
          internal static let support = Strings.tr("Localizable", "views.about.links.sections.support", fallback: "Support")
          /// Web
          internal static let web = Strings.tr("Localizable", "views.about.links.sections.web", fallback: "Web")
        }
      }
      internal enum Sections {
        /// Resources
        internal static let resources = Strings.tr("Localizable", "views.about.sections.resources", fallback: "Resources")
      }
    }
    internal enum Diagnostics {
      /// Diagnostics
      internal static let title = Strings.tr("Localizable", "views.diagnostics.title", fallback: "Diagnostics")
      internal enum Alerts {
        internal enum ReportIssue {
          /// The device is not configured to send e-mails.
          internal static let email = Strings.tr("Localizable", "views.diagnostics.alerts.report_issue.email", fallback: "The device is not configured to send e-mails.")
        }
      }
      internal enum Openvpn {
        internal enum Rows {
          /// Server configuration
          internal static let serverConfiguration = Strings.tr("Localizable", "views.diagnostics.openvpn.rows.server_configuration", fallback: "Server configuration")
        }
      }
      internal enum ReportIssue {
        /// Report issue
        internal static let title = Strings.tr("Localizable", "views.diagnostics.report_issue.title", fallback: "Report issue")
      }
      internal enum Rows {
        /// App
        internal static let app = Strings.tr("Localizable", "views.diagnostics.rows.app", fallback: "App")
        /// Include private data
        internal static let includePrivateData = Strings.tr("Localizable", "views.diagnostics.rows.include_private_data", fallback: "Include private data")
        /// Delete all logs
        internal static let removeTunnelLogs = Strings.tr("Localizable", "views.diagnostics.rows.remove_tunnel_logs", fallback: "Delete all logs")
        /// Tunnel
        internal static let tunnel = Strings.tr("Localizable", "views.diagnostics.rows.tunnel", fallback: "Tunnel")
      }
      internal enum Sections {
        /// Live log
        internal static let live = Strings.tr("Localizable", "views.diagnostics.sections.live", fallback: "Live log")
        /// Tunnel logs
        internal static let tunnel = Strings.tr("Localizable", "views.diagnostics.sections.tunnel", fallback: "Tunnel logs")
      }
    }
    internal enum Donate {
      /// Make a donation
      internal static let title = Strings.tr("Localizable", "views.donate.title", fallback: "Make a donation")
    }
    internal enum Profile {
      internal enum ModuleList {
        internal enum Section {
          /// Drag modules to rearrange them, as their order determines priority.
          internal static let footer = Strings.tr("Localizable", "views.profile.module_list.section.footer", fallback: "Drag modules to rearrange them, as their order determines priority.")
        }
      }
      internal enum Rows {
        /// Add module
        internal static let addModule = Strings.tr("Localizable", "views.profile.rows.add_module", fallback: "Add module")
      }
    }
    internal enum Profiles {
      internal enum Alerts {
        internal enum Import {
          internal enum Passphrase {
            /// Enter passphrase for '%@'.
            internal static func message(_ p1: Any) -> String {
              return Strings.tr("Localizable", "views.profiles.alerts.import.passphrase.message", String(describing: p1), fallback: "Enter passphrase for '%@'.")
            }
            /// Decrypt
            internal static let ok = Strings.tr("Localizable", "views.profiles.alerts.import.passphrase.ok", fallback: "Decrypt")
          }
        }
      }
      internal enum Errors {
        /// Unable to duplicate profile '%@'.
        internal static func duplicate(_ p1: Any) -> String {
          return Strings.tr("Localizable", "views.profiles.errors.duplicate", String(describing: p1), fallback: "Unable to duplicate profile '%@'.")
        }
        /// Unable to import profiles.
        internal static let `import` = Strings.tr("Localizable", "views.profiles.errors.import", fallback: "Unable to import profiles.")
        /// Unable to execute tunnel operation.
        internal static let tunnel = Strings.tr("Localizable", "views.profiles.errors.tunnel", fallback: "Unable to execute tunnel operation.")
      }
      internal enum Folders {
        /// Installed profile
        internal static let activeProfile = Strings.tr("Localizable", "views.profiles.folders.active_profile", fallback: "Installed profile")
        /// Add profile
        internal static let addProfile = Strings.tr("Localizable", "views.profiles.folders.add_profile", fallback: "Add profile")
        /// My profiles
        internal static let `default` = Strings.tr("Localizable", "views.profiles.folders.default", fallback: "My profiles")
        /// No profiles
        internal static let noProfiles = Strings.tr("Localizable", "views.profiles.folders.no_profiles", fallback: "No profiles")
      }
      internal enum Rows {
        /// %d modules
        internal static func modules(_ p1: Int) -> String {
          return Strings.tr("Localizable", "views.profiles.rows.modules", p1, fallback: "%d modules")
        }
        /// Select a profile
        internal static let notInstalled = Strings.tr("Localizable", "views.profiles.rows.not_installed", fallback: "Select a profile")
      }
      internal enum Toolbar {
        /// Import profile
        internal static let importProfile = Strings.tr("Localizable", "views.profiles.toolbar.import_profile", fallback: "Import profile")
        /// New profile
        internal static let newProfile = Strings.tr("Localizable", "views.profiles.toolbar.new_profile", fallback: "New profile")
      }
    }
    internal enum Settings {
      internal enum Rows {
        /// Confirm quit
        internal static let confirmQuit = Strings.tr("Localizable", "views.settings.rows.confirm_quit", fallback: "Confirm quit")
        /// Lock in background
        internal static let lockInBackground = Strings.tr("Localizable", "views.settings.rows.lock_in_background", fallback: "Lock in background")
        internal enum LockInBackground {
          /// Passepartout is locked
          internal static let message = Strings.tr("Localizable", "views.settings.rows.lock_in_background.message", fallback: "Passepartout is locked")
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
