# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0 GM 1281 (2018-12-15)

### Added

- Automated app rating mechanism.
- Dot as a legal character in host profile title. [#22](https://github.com/passepartoutvpn/passepartout-ios/issues/22)
- Host profiles can now be renamed. [#24](https://github.com/passepartoutvpn/passepartout-ios/issues/24)
- Explicit rejection of encrypted client certificate keys. [#15](https://github.com/passepartoutvpn/passepartout-ios/issues/15)
- Attach .ovpn when reporting a connectivity issue, stripped of sensitive data. [#13](https://github.com/passepartoutvpn/passepartout-ios/pull/13)
- iTunes File Sharing (skythedesu). [#14](https://github.com/passepartoutvpn/passepartout-ios/pull/14)
- Tunnel failure reporting in UI. [#8](https://github.com/passepartoutvpn/passepartout-ios/pull/8)
- Explicit "Reconnect" button. [#9](https://github.com/passepartoutvpn/passepartout-ios/pull/9)
- Option to revert host parameters to original configuration (Nicholas Caito). [#10](https://github.com/passepartoutvpn/passepartout-ios/pull/10)
- Support for TLS wrapping (tls-auth and tls-crypt). [#5](https://github.com/passepartoutvpn/passepartout-ios/pull/5)
- AES-GCM and new endpoints to PIA network preset. [tunnelkit#32](https://github.com/keeshux/tunnelkit/pull/32)
- Disclosure indicators in profile organizer (Samuel Michaels).
- Disclaimer for app usage.

### Removed

- "Test connectivity" until it's more transparent.
- Password confirmation field, redundant with authentication failure message.

### Changed

- Relocated API endpoints, better before first release.
- Reorganized credits page.
- Internal refactoring (nothing visible).
- Disconnect VPN by default when entering a trusted network. [#25](https://github.com/passepartoutvpn/passepartout-ios/pull/25)
- Host parameters are read-only if there isn't an original configuration to revert to.
- Overall serialization performance.
- Drive generic support requests on Reddit.
- Add current Wi-Fi to trusted networks list but don't trust it by default.

### Fixed

- Infrastructures not refreshed. [#29](https://github.com/passepartoutvpn/passepartout-ios/issues/29)
- Incorrect compression warnings when importing host configurations. [#20](https://github.com/passepartoutvpn/passepartout-ios/pull/20)
- Regression in provider endpoints, IPv4 appearing reversed. [#23](https://github.com/passepartoutvpn/passepartout-ios/pull/23)
- Handling of extra whitespaces in .ovpn (Mike Mayer). [#17](https://github.com/passepartoutvpn/passepartout-ios/issues/17)
- Glitches in import wizard flow, sometimes not even appearing.
- Warn about .ovpn containing potentially unsupported compression. [#16](https://github.com/passepartoutvpn/passepartout-ios/issues/16)
- Retain credentials of replaced host profile.
- Original configuration not saved after reset.
- Connection occasionally turning inactive after a while.
- Improved performance and privacy of debug log.
- .ovpn files could not be imported without OpenVPN Connect installed. [#6](https://github.com/passepartoutvpn/passepartout-ios/issues/6)
- Fixed Mullvad abrupt disconnection. [tunnelkit#30](https://github.com/keeshux/tunnelkit/issues/30)
- Credentials are now optional for host profiles. [#4](https://github.com/passepartoutvpn/passepartout-ios/pull/4)
- Can now import .ovpn files from Apple Files app. [#1](https://github.com/passepartoutvpn/passepartout-ios/pull/1)
- Reject unrecognized values for `cipher`, `auth` and `proto`. [#1](https://github.com/passepartoutvpn/passepartout-ios/pull/1)
- Alert unsupported configuration options.
- Use accent color for checkmarks in table cells.

## 1.0 beta 975 (2018-10-11)

First public beta release.
