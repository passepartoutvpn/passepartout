# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Fixed

- Restricted profile not updated. [#481](https://github.com/passepartoutvpn/passepartout-apple/pull/481)
- Selection and switch have the same color in organizer. [#458](https://github.com/passepartoutvpn/passepartout-apple/issues/458), [#486](https://github.com/passepartoutvpn/passepartout-apple/pull/486), [#490](https://github.com/passepartoutvpn/passepartout-apple/pull/490)

## 2.3.5 (2024-01-19)

### Fixed

- Minor stuff.

## 2.3.4 (2024-01-14)

### Fixed

- Unintended sensitive data in issue reports. [#471](https://github.com/passepartoutvpn/passepartout-apple/pull/471)

## 2.3.3 (2024-01-11)

### Fixed

- Platform purchasers cannot upgrade to full version. [#464](https://github.com/passepartoutvpn/passepartout-apple/issues/464)

## 2.3.2 (2024-01-11)

### Fixed

- "Restore purchases" not working. [#459](https://github.com/passepartoutvpn/passepartout-apple/issues/459)
- Purchase is not credited if any refund was issued in the past. [#461](https://github.com/passepartoutvpn/passepartout-apple/issues/461)
- On-demand not applying to wired connections. [#463](https://github.com/passepartoutvpn/passepartout-apple/pull/463)

## 2.3.1 (2024-01-06)

### Fixed

- OpenVPN: Regressions from the upgrade to OpenSSL 3. [tunnelkit#403](https://github.com/passepartoutvpn/tunnelkit/issues/403)

## 2.3.0 (2023-12-31)

### Added

- App for tvOS. [#315](https://github.com/passepartoutvpn/passepartout-apple/issues/315)
- WireGuard: Show data count. [#312](https://github.com/passepartoutvpn/passepartout-apple/issues/312)

### Changed

- Upgrade OpenSSL to 3.2.0. [tunnelkit#336](https://github.com/passepartoutvpn/tunnelkit/issues/336)
- Encrypt profiles stored to iCloud. [#436](https://github.com/passepartoutvpn/passepartout-apple/pull/436)

## 2.2.1 (2023-10-14)

### Fixed

- Persisted profile is overwritten with its former value. [#367](https://github.com/passepartoutvpn/passepartout-apple/issues/367)

## 2.2.0 (2023-10-10)

### Added

- OpenVPN: Allow editing of endpoints. [#335](https://github.com/passepartoutvpn/passepartout-apple/pull/335)

### Changed

- Make iCloud an opt-in preference. [#227](https://github.com/passepartoutvpn/passepartout-apple/issues/227)
- OpenVPN: Endpoint UX. [#332](https://github.com/passepartoutvpn/passepartout-apple/pull/332)
- Convert trusted networks to on demand activation. [#119](https://github.com/passepartoutvpn/passepartout-apple/issues/119)

## 2.1.2 (2023-07-06)

### Fixed

- Allow wildcards in proxy bypass domains. [#296](https://github.com/passepartoutvpn/passepartout-apple/issues/296)
- Fail gracefully when refreshing infrastructure. [#307](https://github.com/passepartoutvpn/passepartout-apple/pull/307)
- Only show 'Reconnect' on active profile. [#311](https://github.com/passepartoutvpn/passepartout-apple/pull/311)
- IPv4/6 address validation. [#308](https://github.com/passepartoutvpn/passepartout-apple/pull/308)
- Domain name validation. [#297](https://github.com/passepartoutvpn/passepartout-apple/pull/297)

## 2.1.1 (2023-04-19)

### Added

- Show app version in Mac menu (macOS). [#286](https://github.com/passepartoutvpn/passepartout-apple/pull/286)

### Fixed

- Roll back broken kill switch flag. [#294](https://github.com/passepartoutvpn/passepartout-apple/pull/294)
- Remove nonsense Mac menus (macOS). [#285](https://github.com/passepartoutvpn/passepartout-apple/pull/285)

## 2.1.0 (2023-04-07)

### Added

- Option to lock app when entering background (iOS). [#270](https://github.com/passepartoutvpn/passepartout-apple/pull/270)
- 3D Touch items (iOS). [#267](https://github.com/passepartoutvpn/passepartout-apple/pull/267)
- Ukranian translations (@josser). [#243](https://github.com/passepartoutvpn/passepartout-apple/pull/243)
- Randomize provider server. [#263](https://github.com/passepartoutvpn/passepartout-apple/pull/263)
- Restore DNS "Domain" setting. [#260](https://github.com/passepartoutvpn/passepartout-apple/pull/260)
- OpenVPN: Full implementation of Tunnelblick XOR patch (@tmthecoder). [#245](https://github.com/passepartoutvpn/passepartout-apple/pull/245), [tunnelkit#255](https://github.com/passepartoutvpn/tunnelkit/pull/255)
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
