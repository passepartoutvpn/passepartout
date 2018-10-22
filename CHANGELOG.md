# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Tunnel failure reporting in UI. [#8](https://github.com/keeshux/passepartout-ios/pull/8)
- Explicit "Reconnect" button. [#9](https://github.com/keeshux/passepartout-ios/pull/9)
- Option to revert host parameters to original configuration (Nicholas Caito). [#10](https://github.com/keeshux/passepartout-ios/pull/10)

### Fixed

- .ovpn files could not be imported without OpenVPN Connect installed. [#6](https://github.com/keeshux/passepartout-ios/issues/6)

## 1.0 beta 1040 (2018-10-19)

### Added

- Support for TLS wrapping (tls-auth and tls-crypt). [#5](https://github.com/keeshux/passepartout-ios/pull/5)

### Fixed

- Fixed Mullvad abrupt disconnection. [tunnelkit#30](https://github.com/keeshux/tunnelkit/issues/30)
- Credentials are now optional for host profiles. [#4](https://github.com/keeshux/passepartout-ios/pull/4)

## 1.0 beta 1018 (2018-10-18)

### Changed

- Drive generic support requests on Reddit.

## 1.0 beta 1013 (2018-10-18)

### Added

- AES-GCM and new endpoints to PIA network preset. [tunnelkit#32](https://github.com/keeshux/tunnelkit/pull/32)
- Disclosure indicators in profile organizer (Samuel Michaels).
- Disclaimer for app usage.

### Fixed

- Can now import .ovpn files from Apple Files app. [#1](https://github.com/keeshux/passepartout-ios/pull/1)
- Reject unrecognized values for `cipher`, `auth` and `proto`. [#1](https://github.com/keeshux/passepartout-ios/pull/1)

## 1.0 beta 989 (2018-10-16)

### Fixed

- Alert unsupported configuration options.
- Use accent color for checkmarks in table cells.

## 1.0 beta 975 (2018-10-11)

First public beta release.
