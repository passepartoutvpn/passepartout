//
//  OnDemand+Rules.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

extension Profile.OnDemand {
    func rules(withCustomRules: Bool) -> [NEOnDemandRule] {

        // TODO: on-demand, drop hardcoding when "trusted networks" -> "on-demand"
//        isEnabled = true
//        policy = .excluding
        assert(policy == .excluding)

        var rules: [NEOnDemandRule] = []
        if withCustomRules {
            #if os(iOS)
            if withMobileNetwork {
                let rule = policyRule
                rule.interfaceTypeMatch = .cellular
                rules.append(rule)
            }
            #else
            if withEthernetNetwork {
                let rule = policyRule
                rule.interfaceTypeMatch = .ethernet
                rules.append(rule)
            }
            #endif
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
        return disconnectsIfNotMatching ? NEOnDemandRuleDisconnect() : NEOnDemandRuleIgnore()
    }
}
