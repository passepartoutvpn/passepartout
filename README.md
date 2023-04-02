<p style="text-align: center; padding: 0em 1em"><img src="res/logo.svg" width="300" height="300" /></p>

![iOS 15+](https://img.shields.io/badge/iOS-15+-green.svg)
![macOS 12+](https://img.shields.io/badge/macOS-12+-green.svg)
[![TunnelKit 6.0](https://img.shields.io/badge/TunnelKit-6.0-d69c68.svg)][dep-tunnelkit]
[![License GPLv3](https://img.shields.io/badge/License-GPLv3-lightgray.svg)](LICENSE)

[![Unit Tests](https://github.com/passepartoutvpn/passepartout-apple/actions/workflows/test.yml/badge.svg)](https://github.com/passepartoutvpn/passepartout-apple/actions/workflows/test.yml)
[![Release](https://github.com/passepartoutvpn/passepartout-apple/actions/workflows/release.yml/badge.svg)](https://github.com/passepartoutvpn/passepartout-apple/actions/workflows/release.yml)

# [Passepartout][about-website]

Passepartout is a user-friendly [OpenVPN®][openvpn] and [WireGuard®][wireguard] client for iOS and macOS.
 
[![Join Reddit](https://img.shields.io/badge/discuss-Reddit-orange.svg)][about-reddit]
[![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?url=https%3A%2F%2Fpassepartoutvpn.app%2F&via=keeshux&text=Passepartout%20is%20an%20user-friendly%2C%20open%20source%20%23OpenVPN%20client%20for%20%23iOS%20and%20%23macOS)

## Overview

### All profiles in one place

Passepartout lets you handle multiple profiles in one single place and quickly switch between them.

[<img src="res/ios/snap-home.png" width="300">](res/ios/snap-home.png)

### Ease of use

With its native look & feel, Passepartout focuses on ease of use. It does so by stripping the flags that are today obsolete or rarely used. With good approximation, it mimics the most relevant features you will find in the official OpenVPN and WireGuard clients.

Not to mention iCloud support, which makes your VPN profiles available on all your devices without any additional effort!

### Trusted networks

Trust Wi-Fi, cellular (iOS) or wired (macOS) networks to fine-grain your connectivity. You can then choose to retain a VPN connection when entering a trusted network, or prevent it completely.

[<img src="res/ios/snap-trusted.png" width="300">](res/ios/snap-trusted.png)

### Siri shortcuts

Enjoy the convenience of Siri shortcuts to automate frequent VPN actions.

[<img src="res/ios/snap-shortcuts.png" width="300">](res/ios/snap-shortcuts.png)

### Override network settings

Override default gateway, DNS (plus DoH/DoT), proxy and MTU settings right from the app. Don't bother editing the configuration file or your server settings. This is especially useful if you want to override your provider settings, e.g. to integrate your own DNS-based ad blocking.

[<img src="res/ios/snap-network.png" width="300">](res/ios/snap-network.png)

### See your connection parameters

Passepartout strives for transparency, by showing a fairly detailed yet understandable resume of your connection parameters.

[<img src="res/ios/snap-parameters.png" width="300">](res/ios/snap-parameters.png)

### Disconnect on sleep

Keeping the VPN active in the background provides smoother operation, but may be tough for the battery. You might want to use this feature if you're concerned about battery life. When the device goes to sleep, the VPN will disconnect to then reconnect on device wake-up.

### No unrequested activity

Passepartout is a VPN client and does absolutely nothing else without your consent. The providers infrastructures are obtained via a [static GitHub API][app-api] if and only if you manually refresh them.

### Presets for major providers

Passepartout can connect to a few well-known VPN providers with an existing account:

- [Hide.me][app-net-hideme]
- [Mullvad][app-net-mullvad]
- [NordVPN][app-net-nordvpn]
- [Oeck][app-net-oeck]
- [Private Internet Access][app-net-pia]
- [ProtonVPN][app-net-protonvpn]
- [SurfShark][app-net-surfshark]
- [TorGuard][app-net-torguard]
- [TunnelBear][app-net-tunnelbear]
- [VyprVPN][app-net-vyprvpn]
- [Windscribe][app-net-windscribe]

In preset mode, you can pick pre-resolved IPv4 endpoints when DNS is problematic.

### Import configuration files

Passepartout can import .ovpn (OpenVPN) and .conf/.wg (WireGuard) configuration files as is. You can find details on what may or may not work in the related section of the [TunnelKit README][dep-tunnelkit-ovpn].

## Installation

### Requirements

- iOS 15+ / macOS 12+
- Xcode 13+ (SwiftPM 5.3)
- Git (preinstalled with Xcode Command Line Tools)
- Ruby (preinstalled with macOS)
- golang

It's highly recommended to use the Git and Ruby packages provided by [Homebrew][dep-brew].

### Testing

Download the app codebase locally:

    $ git clone https://github.com/passepartoutvpn/passepartout-apple.git

Enter the directory and clone the submodules:

    $ git submodule init
    $ git submodule update

For everything to work properly, make sure to comply with all the capabilities/entitlements, both in the main app and the tunnel extension target.

Make sure to update `Config.xcconfig` according to your developer account and your identifiers:

    CFG_TEAM_ID = A1B2C3D4E5
    CFG_APP_ID = com.example.MyApp
    CFG_APP_LAUNCHER_ID = com.example.MyApp.Launcher // macOS only
    CFG_GROUP_ID = com.example.MyAppGroup // omit the "group." prefix
    CFG_APPSTORE_ID = 1234567890 // optional for development, can be bogus

Also, `PATH` must include your golang installation in order to compile WireGuardKit:
    
    PATH = $(PATH):/path/to/golang

To eventually test the app, open `Passepartout.xcodeproj` in Xcode and run the `Passepartout` target.

## License

Copyright (c) 2023 Davide De Rosa. All rights reserved.

This project is licensed under the [GPLv3][license-content].

### Contributing

By contributing to this project you are agreeing to the terms stated in the [Contributor License Agreement (CLA)][contrib-cla]. For more details please see [CONTRIBUTING][contrib-readme].

## Credits

The logo is taken from the awesome Circle Icons set by Nick Roach.

The country flags are taken from: <https://github.com/lipis/flag-icon-css/>

- Kvitto - Copyright (c) 2015 Oliver Drobnik
- lzo - Copyright (c) 1996-2017 Markus F.X.J. Oberhumer
- PIATunnel - Copyright (c) 2018-Present Private Internet Access
- SwiftGen - Copyright (c) 2018 SwiftGen
- SwiftyBeaver - Copyright (c) 2015 Sebastian Kreutzberger

### OpenVPN

© Copyright 2022 OpenVPN | OpenVPN is a registered trademark of OpenVPN, Inc.

### WireGuard

© Copyright 2015-2022 Jason A. Donenfeld. All Rights Reserved. "WireGuard" and the "WireGuard" logo are registered trademarks of Jason A. Donenfeld.

### OpenSSL

This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit. ([https://www.openssl.org/][dep-openssl])

### Community

A _huge_ credit goes to:

- My tiny group of 3 private beta testers
- The 3600+ public testers using the beta on a daily basis
- The continued support and feedback from the [Passepartout community on Reddit][about-reddit]
- The overall patience of users affected by my bugs that actively collaborate in resolving them
- All those who contributed to the amazingly high rating on the App Store

## Translations

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

You are strongly encouraged to read carefully both the [disclaimer][web-disclaimer] and [privacy policy][web-privacy] before using this software.

## Contacts

Twitter: [@keeshux][about-twitter]

Website: [passepartoutvpn.app][about-website] ([FAQ][about-faq])

[openvpn]: https://openvpn.net/index.php/open-source/overview.html
[wireguard]: https://www.wireguard.com/

[app-api]: https://github.com/passepartoutvpn/passepartout-api
[app-net-hideme]: https://member.hide.me/en/checkout?plan=new_default_prices&coupon=6CB-BDB-802&duration=24
[app-net-mullvad]: https://mullvad.net/en/account/create/
[app-net-nordvpn]: https://go.nordvpn.net/SH21Z
[app-net-oeck]: https://www.oeck.com
[app-net-pia]: https://www.privateinternetaccess.com/pages/buy-vpn/
[app-net-protonvpn]: https://proton.go2cloud.org/SHZ
[app-net-surfshark]: https://surfshark.com
[app-net-torguard]: https://torguard.net/
[app-net-tunnelbear]: https://www.tunnelbear.com/
[app-net-vyprvpn]: https://www.vyprvpn.com/
[app-net-windscribe]: https://secure.link/kCsD0prd

[dep-brew]: https://brew.sh/
[dep-tunnelkit]: https://github.com/passepartoutvpn/tunnelkit
[dep-tunnelkit-ovpn]: https://github.com/passepartoutvpn/tunnelkit#support-for-ovpn-configuration
[dep-openssl]: https://www.openssl.org/

[license-content]: LICENSE
[contrib-cla]: CLA.rst
[contrib-readme]: CONTRIBUTING.md

[web-disclaimer]: https://passepartoutvpn.app/disclaimer/
[web-privacy]: https://passepartoutvpn.app/privacy/

[about-twitter]: https://twitter.com/keeshux
[about-website]: https://passepartoutvpn.app
[about-faq]: https://passepartoutvpn.app/faq/
[about-reddit]: https://www.reddit.com/r/passepartout
