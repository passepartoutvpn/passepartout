// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Strings {
  public enum Alerts {
    public enum ConfirmQuit {
      /// The VPN, if enabled, will still run in the background. Do you want to quit?
      public static let message = Strings.tr("Localizable", "alerts.confirm_quit.message", fallback: "The VPN, if enabled, will still run in the background. Do you want to quit?")
      /// Quit %@
      public static func title(_ p1: Any) -> String {
        return Strings.tr("Localizable", "alerts.confirm_quit.title", String(describing: p1), fallback: "Quit %@")
      }
    }
    public enum Iap {
      public enum Restricted {
        /// The requested feature is unavailable in this build.
        public static let message = Strings.tr("Localizable", "alerts.iap.restricted.message", fallback: "The requested feature is unavailable in this build.")
        /// Restricted
        public static let title = Strings.tr("Localizable", "alerts.iap.restricted.title", fallback: "Restricted")
      }
    }
  }
  public enum Entities {
    public enum ConnectionStatus {
      /// Connected
      public static let connected = Strings.tr("Localizable", "entities.connection_status.connected", fallback: "Connected")
      /// Connecting
      public static let connecting = Strings.tr("Localizable", "entities.connection_status.connecting", fallback: "Connecting")
      /// Disconnected
      public static let disconnected = Strings.tr("Localizable", "entities.connection_status.disconnected", fallback: "Disconnected")
      /// Disconnecting
      public static let disconnecting = Strings.tr("Localizable", "entities.connection_status.disconnecting", fallback: "Disconnecting")
    }
    public enum Dns {
      /// Search domains
      public static let searchDomains = Strings.tr("Localizable", "entities.dns.search_domains", fallback: "Search domains")
      /// Servers
      public static let servers = Strings.tr("Localizable", "entities.dns.servers", fallback: "Servers")
    }
    public enum DnsProtocol {
      /// Cleartext
      public static let cleartext = Strings.tr("Localizable", "entities.dns_protocol.cleartext", fallback: "Cleartext")
      /// Over HTTPS
      public static let https = Strings.tr("Localizable", "entities.dns_protocol.https", fallback: "Over HTTPS")
      /// Over TLS
      public static let tls = Strings.tr("Localizable", "entities.dns_protocol.tls", fallback: "Over TLS")
    }
    public enum HttpProxy {
      /// Bypass domains
      public static let bypassDomains = Strings.tr("Localizable", "entities.http_proxy.bypass_domains", fallback: "Bypass domains")
    }
    public enum OnDemand {
      public enum Policy {
        /// All networks
        public static let any = Strings.tr("Localizable", "entities.on_demand.policy.any", fallback: "All networks")
        /// Excluding
        public static let excluding = Strings.tr("Localizable", "entities.on_demand.policy.excluding", fallback: "Excluding")
        /// Including
        public static let including = Strings.tr("Localizable", "entities.on_demand.policy.including", fallback: "Including")
      }
    }
    public enum Openvpn {
      public enum CompressionAlgorithm {
        /// Unsupported
        public static let other = Strings.tr("Localizable", "entities.openvpn.compression_algorithm.other", fallback: "Unsupported")
      }
      public enum OtpMethod {
        /// Append
        public static let append = Strings.tr("Localizable", "entities.openvpn.otp_method.append", fallback: "Append")
        /// Encode
        public static let encode = Strings.tr("Localizable", "entities.openvpn.otp_method.encode", fallback: "Encode")
        /// None
        public static let `none` = Strings.tr("Localizable", "entities.openvpn.otp_method.none", fallback: "None")
      }
    }
    public enum Profile {
      public enum Name {
        /// New profile
        public static let new = Strings.tr("Localizable", "entities.profile.name.new", fallback: "New profile")
      }
    }
    public enum TunnelStatus {
      /// Activating
      public static let activating = Strings.tr("Localizable", "entities.tunnel_status.activating", fallback: "Activating")
      /// Active
      public static let active = Strings.tr("Localizable", "entities.tunnel_status.active", fallback: "Active")
      /// Deactivating
      public static let deactivating = Strings.tr("Localizable", "entities.tunnel_status.deactivating", fallback: "Deactivating")
      /// Inactive
      public static let inactive = Strings.tr("Localizable", "entities.tunnel_status.inactive", fallback: "Inactive")
    }
  }
  public enum Errors {
    public enum App {
      /// Unable to complete operation.
      public static let `default` = Strings.tr("Localizable", "errors.app.default", fallback: "Unable to complete operation.")
      /// Profile name is empty.
      public static let emptyProfileName = Strings.tr("Localizable", "errors.app.empty_profile_name", fallback: "Profile name is empty.")
      /// IP module can only be enabled together with a connection.
      public static let ipModuleRequiresConnection = Strings.tr("Localizable", "errors.app.ip_module_requires_connection", fallback: "IP module can only be enabled together with a connection.")
      /// Module %@ is malformed. %@
      public static func malformedModule(_ p1: Any, _ p2: Any) -> String {
        return Strings.tr("Localizable", "errors.app.malformed_module", String(describing: p1), String(describing: p2), fallback: "Module %@ is malformed. %@")
      }
      /// Only one connection module can be active at a time.
      public static let multipleConnectionModules = Strings.tr("Localizable", "errors.app.multiple_connection_modules", fallback: "Only one connection module can be active at a time.")
      public enum Passepartout {
        /// Unable to complete operation (code=%@).
        public static func `default`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.default", String(describing: p1), fallback: "Unable to complete operation (code=%@).")
        }
        /// Invalid fields (%@).
        public static func invalidFields(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.invalid_fields", String(describing: p1), fallback: "Invalid fields (%@).")
        }
        /// Unable to parse file.
        public static let parsing = Strings.tr("Localizable", "errors.app.passepartout.parsing", fallback: "Unable to parse file.")
      }
    }
    public enum Tunnel {
      /// Auth failed
      public static let auth = Strings.tr("Localizable", "errors.tunnel.auth", fallback: "Auth failed")
      /// Compression unsupported
      public static let compression = Strings.tr("Localizable", "errors.tunnel.compression", fallback: "Compression unsupported")
      /// DNS failed
      public static let dns = Strings.tr("Localizable", "errors.tunnel.dns", fallback: "DNS failed")
      /// Encryption failed
      public static let encryption = Strings.tr("Localizable", "errors.tunnel.encryption", fallback: "Encryption failed")
      /// Failed
      public static let generic = Strings.tr("Localizable", "errors.tunnel.generic", fallback: "Failed")
      /// Missing routing
      public static let routing = Strings.tr("Localizable", "errors.tunnel.routing", fallback: "Missing routing")
      /// Server shutdown
      public static let shutdown = Strings.tr("Localizable", "errors.tunnel.shutdown", fallback: "Server shutdown")
      /// Timeout
      public static let timeout = Strings.tr("Localizable", "errors.tunnel.timeout", fallback: "Timeout")
      /// TLS failed
      public static let tls = Strings.tr("Localizable", "errors.tunnel.tls", fallback: "TLS failed")
    }
  }
  public enum Global {
    /// About
    public static let about = Strings.tr("Localizable", "global.about", fallback: "About")
    /// Account
    public static let account = Strings.tr("Localizable", "global.account", fallback: "Account")
    /// Address
    public static let address = Strings.tr("Localizable", "global.address", fallback: "Address")
    /// Addresses
    public static let addresses = Strings.tr("Localizable", "global.addresses", fallback: "Addresses")
    /// Any
    public static let any = Strings.tr("Localizable", "global.any", fallback: "Any")
    /// Cancel
    public static let cancel = Strings.tr("Localizable", "global.cancel", fallback: "Cancel")
    /// Certificate
    public static let certificate = Strings.tr("Localizable", "global.certificate", fallback: "Certificate")
    /// Compression
    public static let compression = Strings.tr("Localizable", "global.compression", fallback: "Compression")
    /// Connect
    public static let connect = Strings.tr("Localizable", "global.connect", fallback: "Connect")
    /// Connection
    public static let connection = Strings.tr("Localizable", "global.connection", fallback: "Connection")
    /// Default
    public static let `default` = Strings.tr("Localizable", "global.default", fallback: "Default")
    /// Destination
    public static let destination = Strings.tr("Localizable", "global.destination", fallback: "Destination")
    /// Disable
    public static let disable = Strings.tr("Localizable", "global.disable", fallback: "Disable")
    /// Disabled
    public static let disabled = Strings.tr("Localizable", "global.disabled", fallback: "Disabled")
    /// Disconnect
    public static let disconnect = Strings.tr("Localizable", "global.disconnect", fallback: "Disconnect")
    /// Don't ask again
    public static let doNotAskAgain = Strings.tr("Localizable", "global.do_not_ask_again", fallback: "Don't ask again")
    /// Domain
    public static let domain = Strings.tr("Localizable", "global.domain", fallback: "Domain")
    /// Done
    public static let done = Strings.tr("Localizable", "global.done", fallback: "Done")
    /// Duplicate
    public static let duplicate = Strings.tr("Localizable", "global.duplicate", fallback: "Duplicate")
    /// Edit
    public static let edit = Strings.tr("Localizable", "global.edit", fallback: "Edit")
    /// Empty
    public static let empty = Strings.tr("Localizable", "global.empty", fallback: "Empty")
    /// Enable
    public static let enable = Strings.tr("Localizable", "global.enable", fallback: "Enable")
    /// Enabled
    public static let enabled = Strings.tr("Localizable", "global.enabled", fallback: "Enabled")
    /// Endpoint
    public static let endpoint = Strings.tr("Localizable", "global.endpoint", fallback: "Endpoint")
    /// Folder
    public static let folder = Strings.tr("Localizable", "global.folder", fallback: "Folder")
    /// Gateway
    public static let gateway = Strings.tr("Localizable", "global.gateway", fallback: "Gateway")
    /// General
    public static let general = Strings.tr("Localizable", "global.general", fallback: "General")
    /// Hostname
    public static let hostname = Strings.tr("Localizable", "global.hostname", fallback: "Hostname")
    /// Interface
    public static let interface = Strings.tr("Localizable", "global.interface", fallback: "Interface")
    /// Keep-alive
    public static let keepAlive = Strings.tr("Localizable", "global.keep_alive", fallback: "Keep-alive")
    /// Key
    public static let key = Strings.tr("Localizable", "global.key", fallback: "Key")
    /// Method
    public static let method = Strings.tr("Localizable", "global.method", fallback: "Method")
    /// Modules
    public static let modules = Strings.tr("Localizable", "global.modules", fallback: "Modules")
    /// %d seconds
    public static func nSeconds(_ p1: Int) -> String {
      return Strings.tr("Localizable", "global.n_seconds", p1, fallback: "%d seconds")
    }
    /// Name
    public static let name = Strings.tr("Localizable", "global.name", fallback: "Name")
    /// Networks
    public static let networks = Strings.tr("Localizable", "global.networks", fallback: "Networks")
    /// No content
    public static let noContent = Strings.tr("Localizable", "global.no_content", fallback: "No content")
    /// No selection
    public static let noSelection = Strings.tr("Localizable", "global.no_selection", fallback: "No selection")
    /// None
    public static let `none` = Strings.tr("Localizable", "global.none", fallback: "None")
    /// OK
    public static let ok = Strings.tr("Localizable", "global.ok", fallback: "OK")
    /// On demand
    public static let onDemand = Strings.tr("Localizable", "global.on_demand", fallback: "On demand")
    /// Other
    public static let other = Strings.tr("Localizable", "global.other", fallback: "Other")
    /// Password
    public static let password = Strings.tr("Localizable", "global.password", fallback: "Password")
    /// Port
    public static let port = Strings.tr("Localizable", "global.port", fallback: "Port")
    /// Private key
    public static let privateKey = Strings.tr("Localizable", "global.private_key", fallback: "Private key")
    /// Protocol
    public static let `protocol` = Strings.tr("Localizable", "global.protocol", fallback: "Protocol")
    /// Public key
    public static let publicKey = Strings.tr("Localizable", "global.public_key", fallback: "Public key")
    /// Delete
    public static let remove = Strings.tr("Localizable", "global.remove", fallback: "Delete")
    /// Restart
    public static let restart = Strings.tr("Localizable", "global.restart", fallback: "Restart")
    /// Route
    public static let route = Strings.tr("Localizable", "global.route", fallback: "Route")
    /// Routes
    public static let routes = Strings.tr("Localizable", "global.routes", fallback: "Routes")
    /// Save
    public static let save = Strings.tr("Localizable", "global.save", fallback: "Save")
    /// Server
    public static let server = Strings.tr("Localizable", "global.server", fallback: "Server")
    /// Servers
    public static let servers = Strings.tr("Localizable", "global.servers", fallback: "Servers")
    /// Settings
    public static let settings = Strings.tr("Localizable", "global.settings", fallback: "Settings")
    /// Status
    public static let status = Strings.tr("Localizable", "global.status", fallback: "Status")
    /// Storage
    public static let storage = Strings.tr("Localizable", "global.storage", fallback: "Storage")
    /// Subnet
    public static let subnet = Strings.tr("Localizable", "global.subnet", fallback: "Subnet")
    /// Uninstall
    public static let uninstall = Strings.tr("Localizable", "global.uninstall", fallback: "Uninstall")
    /// Unknown
    public static let unknown = Strings.tr("Localizable", "global.unknown", fallback: "Unknown")
    /// Username
    public static let username = Strings.tr("Localizable", "global.username", fallback: "Username")
    /// Version
    public static let version = Strings.tr("Localizable", "global.version", fallback: "Version")
  }
  public enum Modules {
    public enum Dns {
      public enum SearchDomains {
        /// Add domain
        public static let add = Strings.tr("Localizable", "modules.dns.search_domains.add", fallback: "Add domain")
      }
      public enum Servers {
        /// Add address
        public static let add = Strings.tr("Localizable", "modules.dns.servers.add", fallback: "Add address")
      }
    }
    public enum HttpProxy {
      public enum BypassDomains {
        /// Add bypass domain
        public static let add = Strings.tr("Localizable", "modules.http_proxy.bypass_domains.add", fallback: "Add bypass domain")
      }
    }
    public enum Ip {
      public enum Routes {
        /// Add %@
        public static func addFamily(_ p1: Any) -> String {
          return Strings.tr("Localizable", "modules.ip.routes.add_family", String(describing: p1), fallback: "Add %@")
        }
        /// Exclude route
        public static let exclude = Strings.tr("Localizable", "modules.ip.routes.exclude", fallback: "Exclude route")
        /// Excluded routes
        public static let excluded = Strings.tr("Localizable", "modules.ip.routes.excluded", fallback: "Excluded routes")
        /// Include route
        public static let include = Strings.tr("Localizable", "modules.ip.routes.include", fallback: "Include route")
        /// Included routes
        public static let included = Strings.tr("Localizable", "modules.ip.routes.included", fallback: "Included routes")
      }
    }
    public enum OnDemand {
      /// Ethernet
      public static let ethernet = Strings.tr("Localizable", "modules.on_demand.ethernet", fallback: "Ethernet")
      /// Mobile
      public static let mobile = Strings.tr("Localizable", "modules.on_demand.mobile", fallback: "Mobile")
      /// Policy
      public static let policy = Strings.tr("Localizable", "modules.on_demand.policy", fallback: "Policy")
      public enum Policy {
        /// Activate the VPN %@.
        public static func footer(_ p1: Any) -> String {
          return Strings.tr("Localizable", "modules.on_demand.policy.footer", String(describing: p1), fallback: "Activate the VPN %@.")
        }
        public enum Footer {
          /// in any network
          public static let any = Strings.tr("Localizable", "modules.on_demand.policy.footer.any", fallback: "in any network")
          /// except in the networks below
          public static let excluding = Strings.tr("Localizable", "modules.on_demand.policy.footer.excluding", fallback: "except in the networks below")
          /// only in the networks below
          public static let including = Strings.tr("Localizable", "modules.on_demand.policy.footer.including", fallback: "only in the networks below")
        }
      }
      public enum Ssid {
        /// Add SSID
        public static let add = Strings.tr("Localizable", "modules.on_demand.ssid.add", fallback: "Add SSID")
      }
    }
    public enum Openvpn {
      /// Cipher
      public static let cipher = Strings.tr("Localizable", "modules.openvpn.cipher", fallback: "Cipher")
      /// Communication
      public static let communication = Strings.tr("Localizable", "modules.openvpn.communication", fallback: "Communication")
      /// Compression
      public static let compression = Strings.tr("Localizable", "modules.openvpn.compression", fallback: "Compression")
      /// Algorithm
      public static let compressionAlgorithm = Strings.tr("Localizable", "modules.openvpn.compression_algorithm", fallback: "Algorithm")
      /// Framing
      public static let compressionFraming = Strings.tr("Localizable", "modules.openvpn.compression_framing", fallback: "Framing")
      /// Credentials
      public static let credentials = Strings.tr("Localizable", "modules.openvpn.credentials", fallback: "Credentials")
      /// Digest
      public static let digest = Strings.tr("Localizable", "modules.openvpn.digest", fallback: "Digest")
      /// Extended verification
      public static let eku = Strings.tr("Localizable", "modules.openvpn.eku", fallback: "Extended verification")
      /// Pull
      public static let pull = Strings.tr("Localizable", "modules.openvpn.pull", fallback: "Pull")
      /// Randomize endpoint
      public static let randomizeEndpoint = Strings.tr("Localizable", "modules.openvpn.randomize_endpoint", fallback: "Randomize endpoint")
      /// Randomize hostname
      public static let randomizeHostname = Strings.tr("Localizable", "modules.openvpn.randomize_hostname", fallback: "Randomize hostname")
      /// Redirect gateway
      public static let redirectGateway = Strings.tr("Localizable", "modules.openvpn.redirect_gateway", fallback: "Redirect gateway")
      /// Remotes
      public static let remotes = Strings.tr("Localizable", "modules.openvpn.remotes", fallback: "Remotes")
      /// Renegotiation
      public static let renegotiation = Strings.tr("Localizable", "modules.openvpn.renegotiation", fallback: "Renegotiation")
      /// Wrapping
      public static let tlsWrap = Strings.tr("Localizable", "modules.openvpn.tls_wrap", fallback: "Wrapping")
      public enum Credentials {
        /// Interactive
        public static let interactive = Strings.tr("Localizable", "modules.openvpn.credentials.interactive", fallback: "Interactive")
        public enum Interactive {
          /// On-demand will be disabled.
          public static let footer = Strings.tr("Localizable", "modules.openvpn.credentials.interactive.footer", fallback: "On-demand will be disabled.")
        }
        public enum OtpMethod {
          public enum Approach {
            /// The OTP will be appended to the password.
            public static let append = Strings.tr("Localizable", "modules.openvpn.credentials.otp_method.approach.append", fallback: "The OTP will be appended to the password.")
            /// The OTP will be encoded in Base64 with the password.
            public static let encode = Strings.tr("Localizable", "modules.openvpn.credentials.otp_method.approach.encode", fallback: "The OTP will be encoded in Base64 with the password.")
          }
        }
      }
    }
    public enum Wireguard {
      /// Allowed IPs
      public static let allowedIps = Strings.tr("Localizable", "modules.wireguard.allowed_ips", fallback: "Allowed IPs")
      /// Interface
      public static let interface = Strings.tr("Localizable", "modules.wireguard.interface", fallback: "Interface")
      /// Peer #%d
      public static func peer(_ p1: Int) -> String {
        return Strings.tr("Localizable", "modules.wireguard.peer", p1, fallback: "Peer #%d")
      }
      /// Pre-shared key
      public static let presharedKey = Strings.tr("Localizable", "modules.wireguard.preshared_key", fallback: "Pre-shared key")
    }
  }
  public enum Placeholders {
    /// secret
    public static let secret = Strings.tr("Localizable", "placeholders.secret", fallback: "secret")
    /// username
    public static let username = Strings.tr("Localizable", "placeholders.username", fallback: "username")
    public enum OnDemand {
      /// My SSID
      public static let ssid = Strings.tr("Localizable", "placeholders.on_demand.ssid", fallback: "My SSID")
    }
    public enum Profile {
      /// My profile
      public static let name = Strings.tr("Localizable", "placeholders.profile.name", fallback: "My profile")
    }
  }
  public enum Views {
    public enum About {
      /// About
      public static let title = Strings.tr("Localizable", "views.about.title", fallback: "About")
      public enum Credits {
        /// Licenses
        public static let licenses = Strings.tr("Localizable", "views.about.credits.licenses", fallback: "Licenses")
        /// Notices
        public static let notices = Strings.tr("Localizable", "views.about.credits.notices", fallback: "Notices")
        /// Credits
        public static let title = Strings.tr("Localizable", "views.about.credits.title", fallback: "Credits")
        /// Translations
        public static let translations = Strings.tr("Localizable", "views.about.credits.translations", fallback: "Translations")
      }
      public enum Links {
        /// Links
        public static let title = Strings.tr("Localizable", "views.about.links.title", fallback: "Links")
        public enum Rows {
          /// Disclaimer
          public static let disclaimer = Strings.tr("Localizable", "views.about.links.rows.disclaimer", fallback: "Disclaimer")
          /// Home page
          public static let homePage = Strings.tr("Localizable", "views.about.links.rows.home_page", fallback: "Home page")
          /// Join community
          public static let joinCommunity = Strings.tr("Localizable", "views.about.links.rows.join_community", fallback: "Join community")
          /// Privacy policy
          public static let privacyPolicy = Strings.tr("Localizable", "views.about.links.rows.privacy_policy", fallback: "Privacy policy")
          /// Write a review
          public static let writeReview = Strings.tr("Localizable", "views.about.links.rows.write_review", fallback: "Write a review")
        }
        public enum Sections {
          /// Support
          public static let support = Strings.tr("Localizable", "views.about.links.sections.support", fallback: "Support")
          /// Web
          public static let web = Strings.tr("Localizable", "views.about.links.sections.web", fallback: "Web")
        }
      }
      public enum Sections {
        /// Resources
        public static let resources = Strings.tr("Localizable", "views.about.sections.resources", fallback: "Resources")
      }
    }
    public enum Diagnostics {
      /// Diagnostics
      public static let title = Strings.tr("Localizable", "views.diagnostics.title", fallback: "Diagnostics")
      public enum Alerts {
        public enum ReportIssue {
          /// The device is not configured to send e-mails.
          public static let email = Strings.tr("Localizable", "views.diagnostics.alerts.report_issue.email", fallback: "The device is not configured to send e-mails.")
        }
      }
      public enum Openvpn {
        public enum Rows {
          /// Server configuration
          public static let serverConfiguration = Strings.tr("Localizable", "views.diagnostics.openvpn.rows.server_configuration", fallback: "Server configuration")
        }
      }
      public enum ReportIssue {
        /// Report issue
        public static let title = Strings.tr("Localizable", "views.diagnostics.report_issue.title", fallback: "Report issue")
      }
      public enum Rows {
        /// App
        public static let app = Strings.tr("Localizable", "views.diagnostics.rows.app", fallback: "App")
        /// Include private data
        public static let includePrivateData = Strings.tr("Localizable", "views.diagnostics.rows.include_private_data", fallback: "Include private data")
        /// Delete all logs
        public static let removeTunnelLogs = Strings.tr("Localizable", "views.diagnostics.rows.remove_tunnel_logs", fallback: "Delete all logs")
        /// Tunnel
        public static let tunnel = Strings.tr("Localizable", "views.diagnostics.rows.tunnel", fallback: "Tunnel")
      }
      public enum Sections {
        /// Live log
        public static let live = Strings.tr("Localizable", "views.diagnostics.sections.live", fallback: "Live log")
        /// Tunnel logs
        public static let tunnel = Strings.tr("Localizable", "views.diagnostics.sections.tunnel", fallback: "Tunnel logs")
      }
    }
    public enum Donate {
      /// Make a donation
      public static let title = Strings.tr("Localizable", "views.donate.title", fallback: "Make a donation")
    }
    public enum Profile {
      public enum ModuleList {
        public enum Section {
          /// Drag modules to rearrange them, as their order determines priority.
          public static let footer = Strings.tr("Localizable", "views.profile.module_list.section.footer", fallback: "Drag modules to rearrange them, as their order determines priority.")
        }
      }
      public enum Rows {
        /// Add module
        public static let addModule = Strings.tr("Localizable", "views.profile.rows.add_module", fallback: "Add module")
      }
    }
    public enum Profiles {
      public enum Alerts {
        public enum Import {
          public enum Passphrase {
            /// Enter passphrase for '%@'.
            public static func message(_ p1: Any) -> String {
              return Strings.tr("Localizable", "views.profiles.alerts.import.passphrase.message", String(describing: p1), fallback: "Enter passphrase for '%@'.")
            }
            /// Decrypt
            public static let ok = Strings.tr("Localizable", "views.profiles.alerts.import.passphrase.ok", fallback: "Decrypt")
          }
        }
      }
      public enum Errors {
        /// Unable to duplicate profile '%@'.
        public static func duplicate(_ p1: Any) -> String {
          return Strings.tr("Localizable", "views.profiles.errors.duplicate", String(describing: p1), fallback: "Unable to duplicate profile '%@'.")
        }
        /// Unable to import profiles.
        public static let `import` = Strings.tr("Localizable", "views.profiles.errors.import", fallback: "Unable to import profiles.")
        /// Unable to execute tunnel operation.
        public static let tunnel = Strings.tr("Localizable", "views.profiles.errors.tunnel", fallback: "Unable to execute tunnel operation.")
      }
      public enum Folders {
        /// Installed profile
        public static let activeProfile = Strings.tr("Localizable", "views.profiles.folders.active_profile", fallback: "Installed profile")
        /// Add profile
        public static let addProfile = Strings.tr("Localizable", "views.profiles.folders.add_profile", fallback: "Add profile")
        /// My profiles
        public static let `default` = Strings.tr("Localizable", "views.profiles.folders.default", fallback: "My profiles")
        /// No profiles
        public static let noProfiles = Strings.tr("Localizable", "views.profiles.folders.no_profiles", fallback: "No profiles")
      }
      public enum Rows {
        /// %d modules
        public static func modules(_ p1: Int) -> String {
          return Strings.tr("Localizable", "views.profiles.rows.modules", p1, fallback: "%d modules")
        }
        /// Select a profile
        public static let notInstalled = Strings.tr("Localizable", "views.profiles.rows.not_installed", fallback: "Select a profile")
      }
      public enum Toolbar {
        /// Import profile
        public static let importProfile = Strings.tr("Localizable", "views.profiles.toolbar.import_profile", fallback: "Import profile")
        /// New profile
        public static let newProfile = Strings.tr("Localizable", "views.profiles.toolbar.new_profile", fallback: "New profile")
      }
    }
    public enum Settings {
      public enum Rows {
        /// Confirm quit
        public static let confirmQuit = Strings.tr("Localizable", "views.settings.rows.confirm_quit", fallback: "Confirm quit")
        /// Lock in background
        public static let lockInBackground = Strings.tr("Localizable", "views.settings.rows.lock_in_background", fallback: "Lock in background")
        public enum LockInBackground {
          /// Passepartout is locked
          public static let message = Strings.tr("Localizable", "views.settings.rows.lock_in_background.message", fallback: "Passepartout is locked")
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
