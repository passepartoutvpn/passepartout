//
//  OnDemand+Rules.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import NetworkExtension
import PassepartoutCore
import PassepartoutUtils

extension NEOnDemandRuleInterfaceType {
    static var compatibleEthernet: NEOnDemandRuleInterfaceType? {
        #if targetEnvironment(macCatalyst)
        // FIXME: Catalyst, missing enum case, try hardcoding
        // https://developer.apple.com/documentation/networkextension/neondemandruleinterfacetype/ethernet
        NEOnDemandRuleInterfaceType(rawValue: 1)
        #elseif os(macOS)
        .ethernet
        #else
        nil
        #endif
    }
}

extension Profile {
    func onDemandRules(withCustomRules: Bool) -> [NEOnDemandRule] {
        onDemand.rules(isInteractive: account.authenticationMethod == .interactive, withCustomRules: withCustomRules)
    }
}

private extension Profile.OnDemand {
    func rules(isInteractive: Bool, withCustomRules: Bool) -> [NEOnDemandRule] {
        guard isEnabled && !isInteractive else {
            return []
        }

        // TODO: on-demand, drop hardcoding when "trusted networks" -> "on-demand"
//        isEnabled = true
//        policy = .excluding
        assert(policy == .excluding)

        var rules: [NEOnDemandRule] = []
        if withCustomRules {
            #if os(iOS)
            if Utils.hasCellularData() && withMobileNetwork {
                let rule = policyRule
                rule.interfaceTypeMatch = .cellular
                rules.append(rule)
            }
            #endif
            if Utils.hasEthernet() && withEthernetNetwork {
                if let compatibleEthernet = NEOnDemandRuleInterfaceType.compatibleEthernet {
                    let rule = policyRule
                    rule.interfaceTypeMatch = compatibleEthernet
                    rules.append(rule)
                } else {
                    pp_log.warning("Unable to add rule for NEOnDemandRuleInterfaceType.ethernet (not compatible)")
                }
            }
            let SSIDs = Array(withSSIDs.filter { $1 }.keys)
            if !SSIDs.isEmpty {
                let rule = policyRule
                rule.interfaceTypeMatch = .wiFi
                rule.ssidMatch = SSIDs
                rules.append(rule)
            }
        }
        let connection = NEOnDemandRuleConnect()
        connection.interfaceTypeMatch = .any
        rules.append(connection)
        return rules
    }

    private var policyRule: NEOnDemandRule {
        disconnectsIfNotMatching ? NEOnDemandRuleDisconnect() : NEOnDemandRuleIgnore()
    }
}
