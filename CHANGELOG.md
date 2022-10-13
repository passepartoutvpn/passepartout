# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- IVPN provider.
- OpenVPN: Support for `--route-nopull`. [#230](https://github.com/passepartoutvpn/passepartout-apple/pull/230)

### Changed

- Retain whitespaces in imported file names.

### Fixed

- Oeck provider is available again to free users.
- Randomic crashes on profile updates. [#229](https://github.com/passepartoutvpn/passepartout-apple/pull/229)

## 2.0.0 (2022-10-02)

### Added

- WireGuard support. [#201](https://github.com/passepartoutvpn/passepartout-apple/issues/201)
- iCloud support. [#137](https://github.com/passepartoutvpn/passepartout-apple/issues/137)

### Changed

- App completely rewritten in SwiftUI.

### Fixed

- Files occasionally not selectable in browser. [#215](https://github.com/passepartoutvpn/passepartout-apple/issues/215)
