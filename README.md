<p style="text-align: center; padding: 0em 1em"><img src="res/logo.svg" width="300" height="300" /></p>

# [Passepartout][about-website]

![iOS 12+](https://img.shields.io/badge/ios-12+-green.svg)
![macOS 10.15+](https://img.shields.io/badge/macos-10.15+-green.svg)
[![TunnelKit 3.2](https://img.shields.io/badge/tunnelkit-3.2-d69c68.svg)][dep-tunnelkit]
[![License GPLv3](https://img.shields.io/badge/license-GPLv3-lightgray.svg)](LICENSE)
[![Join Reddit](https://img.shields.io/badge/discuss-Reddit-orange.svg)][about-reddit]
[![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?url=https%3A%2F%2Fpassepartoutvpn.app%2F&via=keeshux&text=Passepartout%20is%20an%20user-friendly%2C%20open%20source%20%23OpenVPN%20client%20for%20%23iOS%20and%20%23macOS)
 
Passepartout is a non-official, user-friendly [OpenVPN®][openvpn] client for iOS and macOS.

## Overview

### All profiles in one place

Passepartout lets you handle multiple profiles in one single place and quickly switch between them.

[<img src="res/ios/snap-home.png" width="300">](res/ios/snap-home.png)

[<img src="res/macos/snap-home.png" width="300">](res/macos/snap-home.png)

### Ease of use

With its native look & feel, Passepartout focuses on ease of use. It does so by stripping the .ovpn flags that are today obsolete or rarely used. With good approximation, it mimics the most relevant features you will find in OpenVPN 2.4.x.

[<img src="res/ios/snap-profile.png" width="300">](res/ios/snap-profile.png)

### Trusted networks

Trust Wi-Fi, cellular (iOS) or wired (macOS) networks to fine-grain your connectivity. You can then choose to retain a VPN connection when entering a trusted network, or prevent it completely.

[<img src="res/ios/snap-trusted.png" width="300">](res/ios/snap-trusted.png)

[<img src="res/macos/snap-trusted.png" width="300">](res/macos/snap-trusted.png)

### Siri shortcuts (iOS)

Enjoy the convenience of Siri shortcuts to automate frequent VPN actions.

[<img src="res/ios/snap-shortcuts.png" width="300">](res/ios/snap-shortcuts.png)

### Override network settings

Override default gateway, DNS, proxy and MTU settings right from the app. Don't bother editing the .ovpn file or your pushed server settings. This is especially useful if you want to override your provider settings, e.g. to integrate your own DNS-based ad blocking.

[<img src="res/ios/snap-network.png" width="300">](res/ios/snap-network.png)

[<img src="res/macos/snap-network.png" width="300">](res/macos/snap-network.png)

### See your connection parameters

Passepartout strives for transparency, by showing a fairly detailed yet understandable resume of your connection parameters.

[<img src="res/ios/snap-parameters.png" width="300">](res/ios/snap-parameters.png)

### Disconnect on sleep

Keeping the VPN active in the background provides smoother operation, but may be tough for the battery. You might want to use this feature if you're concerned about battery life. When the device goes to sleep, the VPN will disconnect to then reconnect on device wake-up.

### No unrequested activity

Passepartout is a VPN client and does absolutely nothing else without your consent. The providers infrastructures are obtained via a [static GitHub API][app-api] if and only if you manually refresh them.

### Presets for major providers

Passepartout can connect to a few well-known VPN providers with an existing account:

- [Child Safe VPN][app-net-csv]
- [Hide.me][app-net-hideme]
- [Mullvad][app-net-mullvad]
- [NordVPN][app-net-nordvpn]
- [Private Internet Access][app-net-pia]
- [ProtonVPN][app-net-protonvpn]
- [TorGuard][app-net-torguard]
- [TunnelBear][app-net-tunnelbear]
- [VyprVPN][app-net-vyprvpn]
- [Windscribe][app-net-windscribe]

In preset mode, you can pick pre-resolved IPv4 endpoints when DNS is problematic.

### Import .ovpn profiles

Passepartout can import .ovpn configuration files. This way you can fine-tune encryption without tweaking and reimporting a new configuration. 

You can find details on what may or may not work in the related section of the [TunnelKit README][dep-tunnelkit-ovpn].

## Installation

### Requirements

- iOS 12.0+ / macOS 10.15+
- Xcode 11+ (Swift 5)
- Git (preinstalled with Xcode Command Line Tools)
- Ruby (preinstalled with macOS)
- [CocoaPods 1.8.0][dep-cocoapods]

It's highly recommended to use the Git and Ruby packages provided by [Homebrew][dep-brew].

### Testing

Download the app codebase locally:

    $ git clone https://github.com/passepartoutvpn/passepartout-apple.git

Enter the directory and clone the submodules:

    $ git submodule init
    $ git submodule update

Assuming you have a [working CocoaPods environment][dep-cocoapods], setting up the app workspace only requires installing the pod dependencies:

    $ pod install

For the VPN to work properly, the app requires:

- _App Groups_ and _Keychain Sharing_ capabilities
- App IDs with _Packet Tunnel_ entitlements

both in the main app and the tunnel extension target.

Make sure to update `Config.xcconfig` according to your developer account and your identifiers:

    CFG_TEAM_ID = A1B2C3D4E5
    CFG_APP_IOS_ID = com.example.ios.MyApp
    CFG_APP_MACOS_ID = com.example.macos.MyApp
    CFG_GROUP_ID = com.example.MyAppGroup // omit the "group." prefix
    CFG_APPSTORE_IOS_ID = 1234567890 // optional for development, can be bogus
    CFG_APPSTORE_MACOS_ID = 1234567890 // optional for development, can be bogus

After that, open `Passepartout.xcworkspace` in Xcode and run the `Passepartout-iOS` or `Passepartout-macOS` target.

## License

Copyright (c) 2021 Davide De Rosa. All rights reserved.

This project is licensed under the [GPLv3][license-content].

### Contributing

By contributing to this project you are agreeing to the terms stated in the [Contributor License Agreement (CLA)][contrib-cla]. For more details please see [CONTRIBUTING][contrib-readme].

## Credits

The logo is taken from the awesome Circle Icons set by Nick Roach.

The country flags are taken from: <https://github.com/lipis/flag-icon-css/>

- Kvitto - Copyright (c) 2015 Oliver Drobnik
- lzo - Copyright (c) 1996-2017 Markus F.X.J. Oberhumer
- MBProgressHUD - Copyright (c) 2009-2016 Matej Bukovinski
- PIATunnel - Copyright (c) 2018-Present Private Internet Access
- SSZipArchive - Copyright (c) 2010-2012 Sam Soffes
- SwiftGen - Copyright (c) 2018 SwiftGen
- SwiftyBeaver - Copyright (c) 2015 Sebastian Kreutzberger

This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit. ([https://www.openssl.org/][dep-openssl])

Copyright (c) 2002-2018 OpenVPN Inc. - OpenVPN is a registered trademark of OpenVPN Inc.

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

## Usage

You are strongly encouraged to read carefully both the [disclaimer][web-disclaimer] and [privacy policy][web-privacy] before using this software.

## Contacts

Twitter: [@keeshux][about-twitter]

Website: [passepartoutvpn.app][about-website] ([FAQ][about-faq])

[openvpn]: https://openvpn.net/index.php/open-source/overview.html

[app-api]: https://github.com/passepartoutvpn/passepartout-api
[app-net-csv]: https://childsafevpn.com
[app-net-hideme]: https://member.hide.me/en/checkout?plan=new_default_prices&coupon=6CB-BDB-802&duration=24
[app-net-mullvad]: https://mullvad.net/en/account/create/
[app-net-nordvpn]: https://go.nordvpn.net/SH21Z
[app-net-pia]: https://www.privateinternetaccess.com/pages/buy-vpn/
[app-net-protonvpn]: https://proton.go2cloud.org/SHZ
[app-net-torguard]: https://torguard.net/
[app-net-tunnelbear]: https://www.tunnelbear.com/
[app-net-vyprvpn]: https://www.vyprvpn.com/
[app-net-windscribe]: https://secure.link/kCsD0prd

[dep-cocoapods]: https://guides.cocoapods.org/using/getting-started.html
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
