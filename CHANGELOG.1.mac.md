# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.18.0 (2022-02-15)

### Added

- Handle `--keepalive` option.

### Changed

- Release app in the open via GitHub Actions.

### Fixed

- Last update was not refreshed on "Refresh infrastructure".
- Trim whitespaces in text fields.

## 1.17.2 (2021-11-30)

### Changed

- Revert to OpenSSL.

### Fixed

- "TLS failed" with some certificates (e.g. Let's Encrypt).
- Newer infrastructure discarded over bundle.

## 1.17.0 (2021-11-16)

### Changed

- Replace OpenSSL with BoringSSL.
- Restrict support to secure TLS algorithms (security level).
- Drop status bar icon color to automatically adjust to desktop background color. [#199](https://github.com/passepartoutvpn/passepartout-apple/issues/199)
- Allow Oeck provider without any purchase.

### Fixed

- Location areas were not sorted in menu.

## 1.16.0 (2021-08-09)

### Added

- Support for `--scramble xormask`. [tunnelkit#38](https://github.com/passepartoutvpn/tunnelkit/issues/38)
- Favorite provider locations.
- Oeck provider.
- In-app donations.

## 1.15.3 (2021-07-20)

### Added

- SurfShark provider.
- Support for `--compress stub-v2`.

### Fixed

- Crash when adding dynamically updated provider.
- In-app purchases might crash the app and not be credited until relaunch.

## 1.15.2 (2021-04-17)

### Added

- Website guidance in provider account screen.
- Missing translations (German, Greek, Spanish, French, Dutch, Polish, Portuguese, Russian, Swedish, Chinese Simplified).

### Changed

- Improve debug log appearance.

### Fixed

- Prevent ineffective editing of trusted network SSID.
- VPN not being disabled when "Inactive" due to trusted network.

## 1.15.1 (2021-02-14)

### Changed

- Skip keychain password prompt. [tunnelkit#200](https://github.com/passepartoutvpn/tunnelkit/issues/200)

### Fixed

- No way to set DNS servers when using DNS over HTTPS. [#171](https://github.com/passepartoutvpn/passepartout-apple/issues/171)

## 1.15.0 (2021-02-09)

### Added

- Support `--data-ciphers` from OpenVPN 2.5. [tunnelkit#193](https://github.com/passepartoutvpn/tunnelkit/issues/193)
- Support DNS over HTTPS/TLS in "Network settings". [#91](https://github.com/passepartoutvpn/passepartout-apple/issues/91)
- Menu tooltip describing active profile and status.
- Make "Confirm quit" a preference.

### Changed

- Rendering of profile configuration.
- Color-blind friendly menu icon.

### Fixed

- Missing PAC URL in proxy settings.
- Redundant keychain items.

## 1.14.0 (2021-01-07)

### Added

- Country flags in provider infrastructure menu.

### Changed

- Rendering of provider infrastructures.

### Fixed

- Provider infrastructure selectors not reloaded on profile change.

## 1.0.0 (2021-01-01)

### Added

- Launch on boot/login.
- Change active profile from menu.
- Edit credentials/profile from menu.
- Links in About dialog.

### Changed

- Mimic iOS app when activating a profile (Use then Enable).
- Do not autoconnect to selected location.

### Fixed

- Unsaved settings.
- Incorrect keychain management.
- Menu inconsistencies.

## 1.0.0 beta 345 (2018-10-01)

First private beta release.
