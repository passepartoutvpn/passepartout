<p style="text-align: center; padding: 0em 1em; background-color: #515D70"><img src="Passepartout/App/Assets.xcassets/Logo.imageset/Logo@2x.png" width="300" height="300" /></p>

![iOS 16+](https://img.shields.io/badge/iOS-16+-green.svg)
![macOS 13+](https://img.shields.io/badge/macOS-13+-green.svg)
![tvOS 17+](https://img.shields.io/badge/tvOS-17+-green.svg)
[![License GPLv3](https://img.shields.io/badge/License-GPLv3-lightgray.svg)](LICENSE)

[![Unit Tests](https://github.com/passepartoutvpn/passepartout/actions/workflows/test.yml/badge.svg?branch=)](https://github.com/passepartoutvpn/passepartout/actions/workflows/test.yml)
[![Release](https://github.com/passepartoutvpn/passepartout/actions/workflows/release.yml/badge.svg?branch=)](https://github.com/passepartoutvpn/passepartout/actions/workflows/release.yml)

# [Passepartout][about-website]

Passepartout is your go-to app for VPN and privacy.

[OpenVPN®][openvpn] and [WireGuard®][wireguard] client for Apple platforms, the OpenVPN stack also implements the [Tunnelblick XOR patch][openvpn-xor-patch].

[![Join Reddit](https://img.shields.io/badge/discuss-Reddit-orange.svg)][about-reddit]
[![Join TestFlight](https://img.shields.io/badge/beta-Testflight-blue.svg)][about-testflight]

## Installation

### Requirements

- iOS 16+ / macOS 13+ / tvOS 17+
- Xcode 15+ (SwiftPM 5.5)
- Git (preinstalled with Xcode Command Line Tools)
- Ruby (preinstalled with macOS)

It's highly recommended that you use the Git and Ruby packages provided by [Homebrew][dep-brew].

### Testing

**WARNING: This will not work because PassepartoutKit is a private repository, as it's not ready for public use yet.**

Download the app codebase locally:

    $ git clone https://github.com/passepartoutvpn/passepartout.git

For everything to work properly, you must comply with all the capabilities and entitlements in the main app and the tunnel extension target. Therefore, you must update the `Config.xcconfig` file according to your developer account.

To eventually test the app, open `Passepartout.xcodeproj` in Xcode and run the `Passepartout` target.

## License

Copyright (c) 2024 Davide De Rosa. All rights reserved.

This project is licensed under the [GPLv3][license-content].

### Contributing

By contributing to this project you are agreeing to the terms stated in the [Contributor License Agreement (CLA)][contrib-cla]. For more details please see [CONTRIBUTING][contrib-readme].

## Credits

- [fastlane][credits-fastlane]
- [GenericJSON][credits-genericjson]
- [Kvitto][credits-kvitto]
- [lzo][credits-lzo]
- [SwiftGen][credits-swiftgen]
- [SwiftLint][credits-swiftlint]

The logo is taken from the awesome Circle Icons set by Nick Roach.

### OpenVPN

© Copyright 2024 OpenVPN | OpenVPN is a registered trademark of OpenVPN, Inc.

### WireGuard

© Copyright 2015-2024 Jason A. Donenfeld. All Rights Reserved. "WireGuard" and the "WireGuard" logo are registered trademarks of Jason A. Donenfeld.

### OpenSSL

This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit. ([https://www.openssl.org/][dep-openssl])

### Community

A _huge_ credit goes to:

- My tiny group of 3 private beta testers
- The 9000+ public testers using the beta on a daily basis
- The continued support and feedback from the [Passepartout community on Reddit][about-reddit]
- The overall patience of users affected by my bugs that actively collaborate in resolving them
- All those who contributed to the amazingly high rating on the App Store

## Translations

The app is mostly translated with [ChatGPT][credits-chatgpt], but these are the acknowledgments to the original translators:

- Chinese (Simplified): OnlyThen - [@OnlyThen](https://github.com/OnlyThen)
- Dutch: Norbert de Vreede - [@paxpacis](https://github.com/paxpacis)
- English: Davide De Rosa (author)
- French: Julien Laniel - [@linkjul](https://github.com/linkjul)
- German: Christian Lederer, Theodor Tietze
- Greek: Konstantinos Koukoulakis
- Italian: Davide De Rosa (author)
- Polish: Piotr Książek
- Portuguese: Helder Santana - [@heldr](https://github.com/heldr)
- Russian: Alexander Korobynikov
- Spanish: Davide De Rosa (author), Elena Vivó
- Swedish: Henry Gross-Hellsen - [@cowpod](https://github.com/cowpod)
- Ukranian: Dmitry Chirkin - [@josser](https://github.com/josser)

## Usage

You are encouraged to read carefully both the [disclaimer][web-disclaimer] and [privacy policy][web-privacy] before using this software.

## Contacts

Twitter: [@keeshux][about-twitter]

Website: [passepartoutvpn.app][about-website] ([FAQ][about-faq])

[openvpn]: https://openvpn.net/index.php/open-source/overview.html
[openvpn-xor-patch]: https://tunnelblick.net/cOpenvpn_xorpatch.html
[wireguard]: https://www.wireguard.com/

[dep-brew]: https://brew.sh/
[dep-openssl]: https://www.openssl.org/

[license-content]: LICENSE
[contrib-cla]: CLA.rst
[contrib-readme]: CONTRIBUTING.md

[credits-fastlane]: https://github.com/fastlane/fastlane
[credits-genericjson]: https://github.com/iwill/generic-json-swift
[credits-kvitto]: https://github.com/Cocoanetics/Kvitto
[credits-lzo]: https://www.oberhumer.com/opensource/lzo/
[credits-swiftgen]: https://github.com/SwiftGen/SwiftGen
[credits-swiftlint]: https://github.com/realm/SwiftLint
[credits-chatgpt]: https://chatgpt.com/

[web-disclaimer]: https://passepartoutvpn.app/disclaimer/
[web-privacy]: https://passepartoutvpn.app/privacy/

[about-twitter]: https://twitter.com/keeshux
[about-website]: https://passepartoutvpn.app
[about-faq]: https://passepartoutvpn.app/faq/
[about-reddit]: https://www.reddit.com/r/passepartout
[about-testflight]: https://testflight.apple.com/join/K71mtLjZ
