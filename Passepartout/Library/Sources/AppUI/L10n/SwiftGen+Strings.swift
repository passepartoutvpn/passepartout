// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Strings {
  public enum Alerts {
    public enum Iap {
      public enum Restricted {
        /// The requested feature is unavailable in this build.
        public static let message = Strings.tr("Localizable", "alerts.iap.restricted.message", fallback: "The requested feature is unavailable in this build.")
        /// Restricted
        public static let title = Strings.tr("Localizable", "alerts.iap.restricted.title", fallback: "Restricted")
      }
    }
    public enum Import {
      public enum Passphrase {
        /// Enter passphrase for '%@'.
        public static func message(_ p1: Any) -> String {
          return Strings.tr("Localizable", "alerts.import.passphrase.message", String(describing: p1), fallback: "Enter passphrase for '%@'.")
        }
        /// Decrypt
        public static let ok = Strings.tr("Localizable", "alerts.import.passphrase.ok", fallback: "Decrypt")
      }
    }
  }
  public enum AppMenu {
    public enum Items {
      /// Launch on Login
      public static let launchOnLogin = Strings.tr("Localizable", "app_menu.items.launch_on_login", fallback: "Launch on Login")
      /// Quit %@
      public static func quit(_ p1: Any) -> String {
        return Strings.tr("Localizable", "app_menu.items.quit", String(describing: p1), fallback: "Quit %@")
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
      /// Module %@ is malformed. %@
      public static func malformedModule(_ p1: Any, _ p2: Any) -> String {
        return Strings.tr("Localizable", "errors.app.malformed_module", String(describing: p1), String(describing: p2), fallback: "Module %@ is malformed. %@")
      }
      public enum Passepartout {
        /// Routing module can only be enabled together with a connection.
        public static let connectionModuleRequired = Strings.tr("Localizable", "errors.app.passepartout.connection_module_required", fallback: "Routing module can only be enabled together with a connection.")
        /// Unable to connect to provider server (reason=%@).
        public static func corruptProviderModule(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.corrupt_provider_module", String(describing: p1), fallback: "Unable to connect to provider server (reason=%@).")
        }
        /// Unable to complete operation (code=%@).
        public static func `default`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.default", String(describing: p1), fallback: "Unable to complete operation (code=%@).")
        }
        /// Some active modules are incompatible, try to only activate one of them.
        public static let incompatibleModules = Strings.tr("Localizable", "errors.app.passepartout.incompatible_modules", fallback: "Some active modules are incompatible, try to only activate one of them.")
        /// Invalid fields.
        public static let invalidFields = Strings.tr("Localizable", "errors.app.passepartout.invalid_fields", fallback: "Invalid fields.")
        /// No provider server selected.
        public static let missingProviderEntity = Strings.tr("Localizable", "errors.app.passepartout.missing_provider_entity", fallback: "No provider server selected.")
        /// The profile has no active modules.
        public static let noActiveModules = Strings.tr("Localizable", "errors.app.passepartout.no_active_modules", fallback: "The profile has no active modules.")
        /// Unable to parse file.
        public static let parsing = Strings.tr("Localizable", "errors.app.passepartout.parsing", fallback: "Unable to parse file.")
        /// No provider selected.
        public static let providerRequired = Strings.tr("Localizable", "errors.app.passepartout.provider_required", fallback: "No provider selected.")
      }
      public enum Provider {
        /// No provider selected.
        public static let `required` = Strings.tr("Localizable", "errors.app.provider.required", fallback: "No provider selected.")
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
    /// Category
    public static let category = Strings.tr("Localizable", "global.category", fallback: "Category")
    /// Certificate
    public static let certificate = Strings.tr("Localizable", "global.certificate", fallback: "Certificate")
    /// Compression
    public static let compression = Strings.tr("Localizable", "global.compression", fallback: "Compression")
    /// Connect
    public static let connect = Strings.tr("Localizable", "global.connect", fallback: "Connect")
    /// Connection
    public static let connection = Strings.tr("Localizable", "global.connection", fallback: "Connection")
    /// Country
    public static let country = Strings.tr("Localizable", "global.country", fallback: "Country")
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
    /// Filters
    public static let filters = Strings.tr("Localizable", "global.filters", fallback: "Filters")
    /// Folder
    public static let folder = Strings.tr("Localizable", "global.folder", fallback: "Folder")
    /// Gateway
    public static let gateway = Strings.tr("Localizable", "global.gateway", fallback: "Gateway")
    /// General
    public static let general = Strings.tr("Localizable", "global.general", fallback: "General")
    /// Hide
    public static let hide = Strings.tr("Localizable", "global.hide", fallback: "Hide")
    /// Hostname
    public static let hostname = Strings.tr("Localizable", "global.hostname", fallback: "Hostname")
    /// Interface
    public static let interface = Strings.tr("Localizable", "global.interface", fallback: "Interface")
    /// Keep-alive
    public static let keepAlive = Strings.tr("Localizable", "global.keep_alive", fallback: "Keep-alive")
    /// Key
    public static let key = Strings.tr("Localizable", "global.key", fallback: "Key")
    /// Loading
    public static let loading = Strings.tr("Localizable", "global.loading", fallback: "Loading")
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
    /// On-demand
    public static let onDemand = Strings.tr("Localizable", "global.on_demand", fallback: "On-demand")
    /// Other
    public static let other = Strings.tr("Localizable", "global.other", fallback: "Other")
    /// Password
    public static let password = Strings.tr("Localizable", "global.password", fallback: "Password")
    /// Port
    public static let port = Strings.tr("Localizable", "global.port", fallback: "Port")
    /// Private key
    public static let privateKey = Strings.tr("Localizable", "global.private_key", fallback: "Private key")
    /// Profile
    public static let profile = Strings.tr("Localizable", "global.profile", fallback: "Profile")
    /// Protocol
    public static let `protocol` = Strings.tr("Localizable", "global.protocol", fallback: "Protocol")
    /// Provider
    public static let provider = Strings.tr("Localizable", "global.provider", fallback: "Provider")
    /// Public key
    public static let publicKey = Strings.tr("Localizable", "global.public_key", fallback: "Public key")
    /// Purchase
    public static let purchase = Strings.tr("Localizable", "global.purchase", fallback: "Purchase")
    /// Region
    public static let region = Strings.tr("Localizable", "global.region", fallback: "Region")
    /// Delete
    public static let remove = Strings.tr("Localizable", "global.remove", fallback: "Delete")
    /// Restart
    public static let restart = Strings.tr("Localizable", "global.restart", fallback: "Restart")
    /// Route
    public static let route = Strings.tr("Localizable", "global.route", fallback: "Route")
    /// Routes
    public static let routes = Strings.tr("Localizable", "global.routes", fallback: "Routes")
    /// Routing
    public static let routing = Strings.tr("Localizable", "global.routing", fallback: "Routing")
    /// Save
    public static let save = Strings.tr("Localizable", "global.save", fallback: "Save")
    /// Select
    public static let select = Strings.tr("Localizable", "global.select", fallback: "Select")
    /// Server
    public static let server = Strings.tr("Localizable", "global.server", fallback: "Server")
    /// Servers
    public static let servers = Strings.tr("Localizable", "global.servers", fallback: "Servers")
    /// Settings
    public static let settings = Strings.tr("Localizable", "global.settings", fallback: "Settings")
    /// Show
    public static let show = Strings.tr("Localizable", "global.show", fallback: "Show")
    /// Status
    public static let status = Strings.tr("Localizable", "global.status", fallback: "Status")
    /// Storage
    public static let storage = Strings.tr("Localizable", "global.storage", fallback: "Storage")
    /// Subnet
    public static let subnet = Strings.tr("Localizable", "global.subnet", fallback: "Subnet")
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
    public enum General {
      public enum Rows {
        /// Shared on iCloud
        public static let icloudSharing = Strings.tr("Localizable", "modules.general.rows.icloud_sharing", fallback: "Shared on iCloud")
        /// Import from file...
        public static let importFromFile = Strings.tr("Localizable", "modules.general.rows.import_from_file", fallback: "Import from file...")
        public enum IcloudSharing {
          /// Share on iCloud
          public static let purchase = Strings.tr("Localizable", "modules.general.rows.icloud_sharing.purchase", fallback: "Share on iCloud")
        }
      }
      public enum Sections {
        public enum Storage {
          /// Profiles are stored to iCloud encrypted.
          public static let footer = Strings.tr("Localizable", "modules.general.sections.storage.footer", fallback: "Profiles are stored to iCloud encrypted.")
        }
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
      /// Add on-demand rules
      public static let purchase = Strings.tr("Localizable", "modules.on_demand.purchase", fallback: "Add on-demand rules")
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
          /// Log in interactively
          public static let purchase = Strings.tr("Localizable", "modules.openvpn.credentials.interactive.purchase", fallback: "Log in interactively")
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
  public enum Providers {
    /// Clear filters
    public static let clearFilters = Strings.tr("Localizable", "providers.clear_filters", fallback: "Clear filters")
    /// Last updated on %@
    public static func lastUpdated(_ p1: Any) -> String {
      return Strings.tr("Localizable", "providers.last_updated", String(describing: p1), fallback: "Last updated on %@")
    }
    /// None
    public static let noProvider = Strings.tr("Localizable", "providers.no_provider", fallback: "None")
    /// Only favorites
    public static let onlyFavorites = Strings.tr("Localizable", "providers.only_favorites", fallback: "Only favorites")
    /// Refresh infrastructure
    public static let refreshInfrastructure = Strings.tr("Localizable", "providers.refresh_infrastructure", fallback: "Refresh infrastructure")
    /// Select
    public static let selectEntity = Strings.tr("Localizable", "providers.select_entity", fallback: "Select")
    /// Select a provider
    public static let selectProvider = Strings.tr("Localizable", "providers.select_provider", fallback: "Select a provider")
    public enum LastUpdated {
      /// Loading...
      public static let loading = Strings.tr("Localizable", "providers.last_updated.loading", fallback: "Loading...")
    }
    public enum Picker {
      /// Add more providers
      public static let purchase = Strings.tr("Localizable", "providers.picker.purchase", fallback: "Add more providers")
    }
    public enum Vpn {
      /// No servers
      public static let noServers = Strings.tr("Localizable", "providers.vpn.no_servers", fallback: "No servers")
      /// Preset
      public static let preset = Strings.tr("Localizable", "providers.vpn.preset", fallback: "Preset")
      public enum Category {
        /// All categories
        public static let any = Strings.tr("Localizable", "providers.vpn.category.any", fallback: "All categories")
      }
    }
  }
  public enum Theme {
    public enum Confirmation {
      /// Cancel
      public static let cancel = Strings.tr("Localizable", "theme.confirmation.cancel", fallback: "Cancel")
      /// Are you sure you want to proceed with this operation?
      public static let message = Strings.tr("Localizable", "theme.confirmation.message", fallback: "Are you sure you want to proceed with this operation?")
      /// Confirm
      public static let ok = Strings.tr("Localizable", "theme.confirmation.ok", fallback: "Confirm")
    }
    public enum LockScreen {
      /// Passepartout is locked
      public static let reason = Strings.tr("Localizable", "theme.lock_screen.reason", fallback: "Passepartout is locked")
    }
  }
  public enum Ui {
    public enum ConnectionStatus {
      ///  (on-demand)
      public static let onDemandSuffix = Strings.tr("Localizable", "ui.connection_status.on_demand_suffix", fallback: " (on-demand)")
    }
    public enum ProfileContext {
      /// Connect to...
      public static let connectTo = Strings.tr("Localizable", "ui.profile_context.connect_to", fallback: "Connect to...")
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
        /// Erase iCloud store
        public static let eraseIcloud = Strings.tr("Localizable", "views.settings.rows.erase_icloud", fallback: "Erase iCloud store")
        /// Keep in menu bar
        public static let keepsInMenu = Strings.tr("Localizable", "views.settings.rows.keeps_in_menu", fallback: "Keep in menu bar")
        /// Lock in background
        public static let locksInBackground = Strings.tr("Localizable", "views.settings.rows.locks_in_background", fallback: "Lock in background")
      }
      public enum Sections {
        public enum Icloud {
          /// To erase the iCloud store securely, do so on all your synced devices. This will not affect local profiles.
          public static let footer = Strings.tr("Localizable", "views.settings.sections.icloud.footer", fallback: "To erase the iCloud store securely, do so on all your synced devices. This will not affect local profiles.")
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
// swiftlint:enable all
