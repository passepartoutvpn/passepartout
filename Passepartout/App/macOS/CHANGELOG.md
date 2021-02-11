# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

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
