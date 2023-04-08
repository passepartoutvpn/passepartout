# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Show app version in Mac menu (macOS). [#286](https://github.com/passepartoutvpn/passepartout-apple/pull/286)

### Fixed

- Remove nonsense Mac menus (macOS). [#285](https://github.com/passepartoutvpn/passepartout-apple/pull/285)

## 2.1.0 (2023-04-07)

### Added

- Option to lock app when entering background (iOS). [#270](https://github.com/passepartoutvpn/passepartout-apple/pull/270)
- 3D Touch items (iOS). [#267](https://github.com/passepartoutvpn/passepartout-apple/pull/267)
- Ukranian translations (Dmitry Chirkin). [#243](https://github.com/passepartoutvpn/passepartout-apple/pull/243)
- Randomize provider server. [#263](https://github.com/passepartoutvpn/passepartout-apple/pull/263)
- Restore DNS "Domain" setting. [#260](https://github.com/passepartoutvpn/passepartout-apple/pull/260)
- OpenVPN: Full implementation of Tunnelblick XOR patch (tmthecoder). [#245](https://github.com/passepartoutvpn/passepartout-apple/pull/245), [tunnelkit#255](https://github.com/passepartoutvpn/tunnelkit/pull/255)
- WireGuard: DoH/DoT options. [#264](https://github.com/passepartoutvpn/passepartout-apple/pull/264)

### Changed

- Bump targets to iOS 15 / macOS 12.
- Always show "Reconnect" button. [#277](https://github.com/passepartoutvpn/passepartout-apple/pull/277)
- Move Diagnostics view to Profile bottom. [#261](https://github.com/passepartoutvpn/passepartout-apple/pull/261)

### Fixed

- Improve kill switch behavior. [#181](https://github.com/passepartoutvpn/passepartout-apple/issues/181)
- Retain original filename as imported profile name. [#240](https://github.com/passepartoutvpn/passepartout-apple/pull/240)
- In-app purchases other than full version were not recognized (macOS). [#281](https://github.com/passepartoutvpn/passepartout-apple/pull/281)

## 2.0.2 (2022-10-31)

### Added

- OpenVPN: Support for `--remote-random-hostname`. [tunnelkit#286](https://github.com/passepartoutvpn/tunnelkit/pull/286)

### Fixed

- OpenVPN: Tunnel dying prematurely. [tunnelkit#289](https://github.com/passepartoutvpn/tunnelkit/issues/289), [#237](https://github.com/passepartoutvpn/passepartout-apple/issues/237)
- OpenVPN: Local network settings being ignored. [tunnelkit#290](https://github.com/passepartoutvpn/tunnelkit/issues/290)
- OpenVPN: Routes from configuration file are ignored. [tunnelkit#278](https://github.com/passepartoutvpn/tunnelkit/issues/278)
- OpenVPN: Parse IPv6 endpoints properly. [tunnelkit#294](https://github.com/passepartoutvpn/tunnelkit/issues/294)
- Restore "Reconnect" action in profiles. [#232](https://github.com/passepartoutvpn/passepartout-apple/pull/232)
- Systematic uninstallation of VPN profile if any IAP was refunded. [#238](https://github.com/passepartoutvpn/passepartout-apple/issues/238)
- Use .includeAllNetworks for best-effort kill switch. [#181](https://github.com/passepartoutvpn/passepartout-apple/issues/181), [tunnelkit#300](https://github.com/passepartoutvpn/tunnelkit/pull/300)

## 2.0.1 (2022-10-17)

### Added

- IVPN provider.
- OpenVPN: Support for `--route-nopull`. [#230](https://github.com/passepartoutvpn/passepartout-apple/pull/230)
- App log in Diagnostics screen. [#234](https://github.com/passepartoutvpn/passepartout-apple/pull/234)

### Changed

- Retain whitespaces in imported file names.

### Fixed

- Oeck provider is available again to free users.
- Randomic crashes on profile updates. [#229](https://github.com/passepartoutvpn/passepartout-apple/pull/229)
- Mullvad: enforce password to avoid "Auth failed". [#233](https://github.com/passepartoutvpn/passepartout-apple/pull/233)

## 2.0.0 (2022-10-02)

### Added

- WireGuard support. [#201](https://github.com/passepartoutvpn/passepartout-apple/issues/201)
- iCloud support. [#137](https://github.com/passepartoutvpn/passepartout-apple/issues/137)

### Changed

- App completely rewritten in SwiftUI.

### Fixed

- Files occasionally not selectable in browser. [#215](https://github.com/passepartoutvpn/passepartout-apple/issues/215)
