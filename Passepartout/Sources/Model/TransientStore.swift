//
//  TransientStore.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/16/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

class TransientStore {
    private struct Keys {
        static let didHandleSubreddit = "DidHandleSubreddit"
    }
    
    static let shared = TransientStore()
    
    private let servicePath: URL
    
    let service: ConnectionService
    
    var didHandleSubreddit: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.didHandleSubreddit)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.didHandleSubreddit)
        }
    }

    private init() {
        servicePath = FileManager.default.userURL(
            for: .documentDirectory,
            appending: AppConstants.Store.serviceFilename
        )
        let cfg = AppConstants.VPN.tunnelConfiguration()
        do {
            let data = try Data(contentsOf: servicePath)
            if let content = String(data: data, encoding: .utf8) {
                log.verbose("Service JSON:")
                log.verbose(content)
            }
            service = try JSONDecoder().decode(ConnectionService.self, from: data)
            service.tunnelConfiguration = cfg
        } catch let e {
            log.error("Could not decode service: \(e)")
            service = ConnectionService(
                withAppGroup: GroupConstants.App.appGroup,
                tunnelConfiguration: cfg
            )

//            // hardcoded loading
//            _ = service.addProfile(ProviderConnectionProfile(name: .pia), credentials: nil)
//            _ = service.addProfile(HostConnectionProfile(title: "vps"), credentials: Credentials(username: "foo", password: "bar"))
//            service.activateProfile(service.profiles.first!)
        }
    }
    
    func serialize() {
        try? JSONEncoder().encode(service).write(to: servicePath)
    }
}
