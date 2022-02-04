//
//  AppDelegate.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/6/18.
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

import Cocoa
import PassepartoutCore
import Convenience
import ServiceManagement

// comment on release
//import AppCenter
//import AppCenterAnalytics
//import AppCenterCrashes

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let appCenterSecret = GroupConstants.App.config?["appcenter_secret"] as? String
    
    private var importer: HostImporter?
    
    override init() {
        AppConstants.Log.configure()
        InfrastructureFactory.shared.preload()
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Reviewer.shared.eventCountBeforeRating = AppConstants.Rating.eventCount
        ProductManager.shared.listProducts(completionHandler: nil)

        NSApp.mainMenu = loadMainMenu()
        StatusMenu.shared.install()
        ProductManager.shared.reviewPurchases()
        
//        if let appCenterSecret = appCenterSecret, !appCenterSecret.isEmpty {
//            AppCenter.start(withAppSecret: appCenterSecret, services: [Analytics.self, Crashes.self])
//        }

        // launcher configuration
        
        let launcherAppId = AppConstants.App.appLauncherId
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty

        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }

        if !TransientStore.didHandleSubreddit {
            let alert = Macros.warning(L10n.Reddit.title, L10n.Reddit.message)
            alert.present(in: nil, withOK: L10n.Reddit.Buttons.subscribe, cancel: L10n.Reddit.Buttons.never, dummy: L10n.Reddit.Buttons.remind, handler: {
                TransientStore.didHandleSubreddit = true
                self.subscribeSubreddit()
            }, cancelHandler: {
                TransientStore.didHandleSubreddit = true
            })
        }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
//        TransientStore.shared.service.preferences.confirmsQuit = true
        guard TransientStore.shared.service.preferences.confirmsQuit ?? true else {
            return .terminateNow
        }
        let alert = Macros.warning(
            L10n.Menu.Quit.title(GroupConstants.App.name),
            L10n.Menu.Quit.Messages.confirm
        )
        switch alert.presentModallyEx(withOK: L10n.Global.ok, other1: L10n.Global.cancel, other2: L10n.Reddit.Buttons.never) {
        case .alertSecondButtonReturn:
            return .terminateCancel

        case .alertThirdButtonReturn:
            TransientStore.shared.service.preferences.confirmsQuit = false
            break

        default:
            break
        }
        return .terminateNow
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        TransientStore.shared.serialize(withProfiles: true) // exit
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        importer = HostImporter(withConfigurationURL: url)
        importer?.importHost(withPassphrase: nil)
        return true
    }
    
    // MARK: Helpers
    
    private func loadMainMenu() -> NSMenu? {
        let nibName = "MainMenu"
        guard let nib = NSNib(nibNamed: nibName, bundle: nil) else {
            fatalError(nibName)
        }
        var objects: NSArray?
        guard nib.instantiate(withOwner: nil, topLevelObjects: &objects) else {
            fatalError(nibName)
        }
        guard let nonOptionalObjects = objects else {
            fatalError(nibName)
        }
        for o in nonOptionalObjects {
            if let menu = o as? NSMenu {
                return menu
            }
        }
        return nil
    }

    private func subscribeSubreddit() {
        NSWorkspace.shared.open(AppConstants.URLs.subreddit)
    }
}
