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
- Allow Oeck provider without any purchase.

### Fixed

- iOS 15: Navigation bar has broken appearance.
- Missing account guidance footer in some providers.
- Files imported via Music (iTunes) File Sharing did not show up.

## 1.16.0 (2021-08-09)

### Added

- Support for `--scramble xormask`. [tunnelkit#38](https://github.com/passepartoutvpn/tunnelkit/issues/38)
- Oeck provider.

## 1.15.4 (2021-07-21)

### Added

- SurfShark provider.
- Support for `--compress stub-v2`.

## 1.15.2 (2021-04-17)

### Changed

- Drop Twitch link.

## 1.15.1 (2021-02-14)

### Fixed

- No way to set DNS servers when using DNS over HTTPS. [#171](https://github.com/passepartoutvpn/passepartout-apple/issues/171)

## 1.15.0 (2021-02-09)

### Added

- Support `--data-ciphers` from OpenVPN 2.5. [tunnelkit#193](https://github.com/passepartoutvpn/tunnelkit/issues/193)
- Support DNS over HTTPS/TLS in "Network settings". [#91](https://github.com/passepartoutvpn/passepartout-apple/issues/91)

### Changed

- Drop hosts restriction in free version ("Unlimited hosts").

### Fixed

- Redundant keychain items.
- Keyboard not dismissed in "Network settings".
- "Reset configuration" not working with encrypted configuration files.
- "Update list" locks up in providers.

## 1.14.0 (2021-01-07)

### Added

- Can now copy entries in "Server network".

### Changed

- Rendering of provider infrastructures.
- Default to low MTU (1200) when unspecified.

## 1.13.1 (2021-01-03)

### Fixed

- Losing profiles on upgrade. [#163](https://github.com/passepartoutvpn/passepartout-ios/issues/163)
- Twitch link does not work when Twitch app not installed. [#162](https://github.com/passepartoutvpn/passepartout-ios/issues/162)

## 1.13.0 (2021-01-01)

### Added

- Customize MTU in network settings.

### Changed

- Enter explicit Wi-Fi SSID to trust.
- Use default tunnel MTU rather than 1250.

## 1.12.1 (2020-11-15)

### Added

- Watch me make Passepartout live on Twitch.

## 1.12.0 (2020-10-06)

### Added

- Child Safe VPN provider.

### Changed

- Improved host import flow.
- Use active profile name in iOS settings.

### Fixed

- In-app purchases may not be credited/restored (Radu Ursache). [#153](https://github.com/passepartoutvpn/passepartout-ios/issues/153)

## 1.11.5 (2020-06-23)

### Fixed

- Skip DNS resolution of provider servers without a hostname (e.g. ProtonVPN "Secure Core").

## 1.11.4 (2020-06-03)

### Added

- Customize host endpoint.

### Fixed

- Invisible buttons in document browser. [#145](https://github.com/passepartoutvpn/passepartout-ios/issues/145)

## 1.11.3 (2020-05-21)

### Added

- TorGuard provider (Jorrit Visser). [api-source#5](https://github.com/passepartoutvpn/api-source/issues/5)

### Fixed

- Persistent crash on launch after "Add new provider > Update list".

## 1.11.2 (2020-05-12)

### Changed

- Relax keyboard for host titles.

### Fixed

- In-app purchase unavailable for new providers. [#141](https://github.com/passepartoutvpn/passepartout-ios/issues/141)
- Hosts may be renamed to same title. [#140](https://github.com/passepartoutvpn/passepartout-ios/issues/140)

## 1.11.1 (2020-05-11)

### Added

- Hide.me provider.

## 1.11.0 (2020-04-29)

### Changed

- Allow any character in host profile name. [#26](https://github.com/passepartoutvpn/passepartout-ios/issues/26)

### Fixed

- Programming error in some SoftEther negotiation (Grivus). [tunnelkit#143](https://github.com/passepartoutvpn/tunnelkit/pull/143)
- Default gateway not yet enforced for providers (e.g. TunnelBear). [passepartout-core-apple#4](https://github.com/passepartoutvpn/passepartout-core-apple/pull/4)
- Active profile lost after renaming. [#128](https://github.com/passepartoutvpn/passepartout-ios/issues/128)
- Handle server shutdown/restart (remote `--explicit-exit-notify`). [tunnelkit#131](https://github.com/passepartoutvpn/tunnelkit/issues/131)
- Handle explicit IPv4/IPv6 protocols (`4` or `6` suffix in `--proto`). [tunnelkit#153](https://github.com/passepartoutvpn/tunnelkit/issues/153)
- IPv6 traffic broken on Mojave. [tunnelkit#146](https://github.com/passepartoutvpn/tunnelkit/issues/146), [#169](https://github.com/passepartoutvpn/tunnelkit/pull/169)
- Transient connected state upon connection failure (rob-patchett). [tunnelkit#128](https://github.com/passepartoutvpn/tunnelkit/pull/128)

## 1.10.1 (2019-12-24)

### Fixed

- Provider purchases were not properly recognized/restored. [#124](https://github.com/passepartoutvpn/passepartout-ios/pull/124)

## 1.10.0 (2019-12-19)

### Added

- Dynamic providers, refresh supported list in real time.
- Favorite provider locations. [#118](https://github.com/passepartoutvpn/passepartout-ios/issues/118)
- Polish translations (Piotr Książek).

### Changed

- "Trusted networks" settings are now saved per profile. [#114](https://github.com/passepartoutvpn/passepartout-ios/issues/114)
- Require explicit `--ca` and `--cipher` in .ovpn configuration file.
- Revert fallback to CloudFlare DNS when no servers provided. [#116](https://github.com/passepartoutvpn/passepartout-ios/issues/116)
- German translations (Theodor Tietze).

### Fixed

- Only show pushed server configuration.
- Adjust UI to device text size. [#117](https://github.com/passepartoutvpn/passepartout-ios/pull/117)
- Restore provider flow after purchase.
- Improved some translations.

## 1.9.1 (2019-11-10)

### Changed

- Polish purchase screen.

## 1.9.0 (2019-11-05)

### Added

- Import host via document picker.
- Support for `--ping-restart` (Robert Patchett). [tunnelkit#122](https://github.com/passepartoutvpn/tunnelkit/pull/122)
- Support for proxy auto-configuration URL (ThinkChaos). [tunnelkit#125](https://github.com/passepartoutvpn/tunnelkit/pull/125)
- Disclose server configuration and network settings in Diagnostics. [#101](https://github.com/passepartoutvpn/passepartout-ios/issues/101)
- Support multiple DNS search domains. [tunnelkit#127](https://github.com/passepartoutvpn/tunnelkit/issues/127)

### Changed

- Upgrade project to Xcode 11.

### Fixed

- Cannot enter IP addresses in some localizations. [#103](https://github.com/passepartoutvpn/passepartout-ios/issues/103)
- Cannot easily trust Wi-Fi networks in iOS 13. [#100](https://github.com/passepartoutvpn/passepartout-ios/issues/100)
- Infrastructures not updated in non-English locales.
- Default gateway not enforced for providers (e.g. TunnelBear).

## 1.8.1 (2019-09-15)

### Added

- Chinese (Simplified) translations (OnlyThen). [#95](https://github.com/passepartoutvpn/passepartout-ios/pull/95)
- Support for iOS 13 Dark Mode. [#93](https://github.com/passepartoutvpn/passepartout-ios/issues/93)

### Fixed

- Transparent navigation bar in iPadOS 13.
- Unable to open .ovpn files in iOS 13. [#99](https://github.com/passepartoutvpn/passepartout-ios/issues/99)
- Premature disconnection due to .staleSession error. [tunnelkit#120](https://github.com/passepartoutvpn/tunnelkit/issues/120)

## 1.8.0 (2019-08-01)

### Added

- "Custom DNS" preset for Mullvad. [api-source-mullvad#1](https://github.com/passepartoutvpn/api-source-mullvad/issues/1)
- Change app language from Settings in iOS 13. [#90](https://github.com/passepartoutvpn/passepartout-ios/issues/90)

### Changed

- Disconnect on "No buffer space available" rather than leaving a stale connection (improve later). [tunnelkit#104](https://github.com/passepartoutvpn/tunnelkit/issues/104)

### Fixed

- VPN staying active while it's not. [tunnelkit#106](https://github.com/passepartoutvpn/tunnelkit/issues/106)
- Disconnection on renegotiation. [tunnelkit#105](https://github.com/passepartoutvpn/tunnelkit/issues/105)
- Support third party apps when sending e-mails.
- Refreshed infrastructures are not retained. [passepartout-core-apple#1](https://github.com/passepartoutvpn/passepartout-core-apple/issues/1)
- Portuguese bound to Brazil region.
- German spelling of "Default gateway".
- Some French wording (Joel Gallant).
- Erroneous placeholders in Network Settings (Joel Gallant).

## 1.7.0 (2019-06-02)

### Added

- Dutch translations (Norbert de Vreede). [#81](https://github.com/passepartoutvpn/passepartout-ios/pull/81)
- Greek translations (Konstantinos Koukoulakis).
- French translations (Julien Laniel).
- Spanish translations (Davide De Rosa, Elena Vivó).
- Swedish translations (Henry Gross-Hellsen). [#82](https://github.com/passepartoutvpn/passepartout-ios/pull/82)

## 1.6.1 (2019-05-20)

### Added

- Override network settings. [#77](https://github.com/passepartoutvpn/passepartout-ios/pull/77)
- Support for `--redirect-gateway block-local` (partial). [tunnelkit#81](https://github.com/passepartoutvpn/tunnelkit/issues/81)
- Russian translations (Alexander Korobynikov).

### Changed

- Host compression framing and algorithm are now editable.

### Fixed

- NordVPN double servers not connecting out of the box. [#78](https://github.com/passepartoutvpn/passepartout-ios/issues/78)
- Authentication with OpenVPN AS. [tunnelkit#95](https://github.com/passepartoutvpn/tunnelkit/issues/95)
- TLS failed with some servers. [tunnelkit#97](https://github.com/passepartoutvpn/tunnelkit/issues/97)

## 1.6.0 (2019-05-01)

### Added

- VyprVPN provider. [#72](https://github.com/passepartoutvpn/passepartout-ios/pull/72)
- More infrastructure metadata.
- Portuguese translations (Helder Santana). [#70](https://github.com/passepartoutvpn/passepartout-ios/pull/70)
- German translations (Christian Lederer).
- Russian translations (Alexander Korobynikov).

### Changed

- Do not redirect all traffic to VPN unless `--redirect-gateway` specified. [#71](https://github.com/passepartoutvpn/passepartout-ios/pull/71)

### Fixed

- Fall back to CloudFlare DNS when no servers provided. [tunnelkit#84](https://github.com/passepartoutvpn/tunnelkit/issues/84)
- UDP may disconnect on high speeds. [tunnelkit#87](https://github.com/passepartoutvpn/tunnelkit/issues/87)
- SoftEther connects without VPN icon. [#69](https://github.com/passepartoutvpn/passepartout-ios/issues/69)
- Misleading Mullvad password suggestion. [#75](https://github.com/passepartoutvpn/passepartout-ios/issues/75)
- Leave digest editable despite cipher. [#74](https://github.com/passepartoutvpn/passepartout-ios/issues/74)
- TLS errors with passphrase-protected .ovpn profiles. [tunnelkit#91](https://github.com/passepartoutvpn/tunnelkit/issues/91)
- Issue with DNS-only VPN profiles. [#73](https://github.com/passepartoutvpn/passepartout-ios/issues/73)

## 1.5.0 (2019-04-17)

### Added

- NordVPN provider. [#65](https://github.com/passepartoutvpn/passepartout-ios/pull/65)
- Support for `dhcp-option PROXY_HTTP[S]`. [tunnelkit#74](https://github.com/passepartoutvpn/tunnelkit/issues/74)

### Fixed

- Regression in DNS configuration. [#68](https://github.com/passepartoutvpn/passepartout-ios/issues/68)
- SoftEther timing out. [tunnelkit#67](https://github.com/passepartoutvpn/tunnelkit/issues/67)
- VPN status cell doesn't always enter active profile. [#63](https://github.com/passepartoutvpn/passepartout-ios/issues/63)
- Masking preference not retained. [#64](https://github.com/passepartoutvpn/passepartout-ios/issues/64)
- Issues with very long PUSH_REPLY. [tunnelkit#71](https://github.com/passepartoutvpn/tunnelkit/issues/71)
- Missing app icon in Credits.

## 1.4.0 (2019-04-11)

### Added

- ProtonVPN provider. [#7](https://github.com/passepartoutvpn/passepartout-ios/issues/7)
- Italian translations. [#58](https://github.com/passepartoutvpn/passepartout-ios/pull/58)
- In-app donations.
- Provider logos. [#55](https://github.com/passepartoutvpn/passepartout-ios/pull/55)
- Country flags. [#56](https://github.com/passepartoutvpn/passepartout-ios/pull/56)
- VPN status shortcut, enters active profile on selection.

### Changed

- Automatic protocol defaults to UDP endpoints. [#61](https://github.com/passepartoutvpn/passepartout-ios/pull/61)
- Improved Account screen, footers were hardly tappable.

### Fixed

- Some providers may crash on VPN activation. [#57](https://github.com/passepartoutvpn/passepartout-ios/issues/57)
- Mullvad dying due to ping timeout. [#62](https://github.com/passepartoutvpn/passepartout-ios/issues/62)
- Pushing DOMAIN has no effect. [#48](https://github.com/passepartoutvpn/passepartout-ios/issues/48)

## 1.3.0 (2019-04-03)

### Added

- Windscribe provider. [#39](https://github.com/passepartoutvpn/passepartout-ios/issues/39)

### Fixed

- Support PKCS#8 encrypted cert keys. [#43](https://github.com/passepartoutvpn/passepartout-ios/issues/43)
- Handle PEM with preamble. [tunnelkit#78](https://github.com/passepartoutvpn/tunnelkit/issues/78)
- Infrastructures not retained after refresh. [#54](https://github.com/passepartoutvpn/passepartout-ios/issues/54)

## 1.2.0 (2019-04-01)

### Added

- Siri Shortcuts in-app manager. [#46](https://github.com/passepartoutvpn/passepartout-ios/pull/46)
- Background data count updates in diagnostics. [#51](https://github.com/passepartoutvpn/passepartout-ios/pull/51)
- Configure masking in debug log for improved diagnostics.
- Mullvad provider. [#45](https://github.com/passepartoutvpn/passepartout-ios/pull/45)
- Support for encrypted certificate private keys. [#43](https://github.com/passepartoutvpn/passepartout-ios/pull/43)

### Changed

- Upgraded to Swift 5.

### Fixed

- EKU not verified with providers (regression).
- Occasionally overlapping footers in organizer.

## 1.1.0 (2019-03-22)

### Added

- Support for LZO compression. [#32](https://github.com/passepartoutvpn/passepartout-ios/issues/32)
- Siri shortcuts. [#41](https://github.com/passepartoutvpn/passepartout-ios/pull/41)
- Custom intents, have a look at Spotlight suggestions for Passepartout. [#40](https://github.com/passepartoutvpn/passepartout-ios/pull/40)
- TunnelBear provider. [#35](https://github.com/passepartoutvpn/passepartout-ios/pull/35)

### Changed

- Normalize localization of provider locations.

### Fixed

- Profile not activating if none is active. [#42](https://github.com/passepartoutvpn/passepartout-ios/issues/42)
- EKU verification enabled when it shouldn't be.
- Incorrect VPN status after renaming. [#37](https://github.com/passepartoutvpn/passepartout-ios/issues/37)
- Profile change doesn't disconnect active VPN. [#38](https://github.com/passepartoutvpn/passepartout-ios/issues/38)
- Some reconnection issues encountered with TunnelBear and NordVPN.
- Hosts gone while connected (credit to Aston Martin). [#19](https://github.com/passepartoutvpn/passepartout-ios/issues/19)

## 1.0.3 (2019-03-06)

### Fixed

- Regression in profile activation. [#36](https://github.com/passepartoutvpn/passepartout-ios/issues/36)

## 1.0.2 (2019-03-04)

### Fixed

- Profile sometimes not connecting right after add.
- Custom DNS servers were not applied.
- Shut down if server uses compression at all.
- Broken link to SwiftGen license.

## 1.0.1 (2019-02-27)

### Added

- Override DNS servers via `dhcp-option DNS`. [tunnelkit#56](https://github.com/passepartoutvpn/tunnelkit/pull/56)
- About link to FAQ.

### Changed

- Only enable EKU verification if `remote-cert-tls server`. [tunnelkit#64](https://github.com/passepartoutvpn/tunnelkit/pull/64)

### Fixed

- Shut down if server pushes a compression directive. [tunnelkit#65](https://github.com/passepartoutvpn/tunnelkit/pull/65)
- Retain DNS reply order in resolved endpoint addresses. [#31](https://github.com/passepartoutvpn/passepartout-ios/pull/31)

## 1.0 (2019-01-16)

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
- AES-GCM and new endpoints to PIA network preset. [tunnelkit#32](https://github.com/passepartoutvpn/tunnelkit/pull/32)
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
- Fixed Mullvad abrupt disconnection. [tunnelkit#30](https://github.com/passepartoutvpn/tunnelkit/issues/30)
- Credentials are now optional for host profiles. [#4](https://github.com/passepartoutvpn/passepartout-ios/pull/4)
- Can now import .ovpn files from Apple Files app. [#1](https://github.com/passepartoutvpn/passepartout-ios/pull/1)
- Reject unrecognized values for `cipher`, `auth` and `proto`. [#1](https://github.com/passepartoutvpn/passepartout-ios/pull/1)
- Alert unsupported configuration options.
- Use accent color for checkmarks in table cells.

## 1.0 beta 975 (2018-10-11)

First public beta release.
