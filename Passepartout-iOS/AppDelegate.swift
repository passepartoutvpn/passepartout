//
//  AppDelegate.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/6/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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

import UIKit
import TunnelKit
import PassepartoutCore
import Convenience

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    private var importer: HostImporter?

    override init() {
        AppConstants.Log.configure()
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        InfrastructureFactory.shared.loadCache()
        Theme.current.applyAppearance()
        Reviewer.shared.eventCountBeforeRating = AppConstants.Rating.eventCount

        // Override point for customization after application launch.
        let splitViewController = window!.rootViewController as! UISplitViewController
//        splitViewController.preferredPrimaryColumnWidthFraction = 0.4
//        splitViewController.minimumPrimaryColumnWidth = 360.0
        splitViewController.maximumPrimaryColumnWidth = .infinity
        splitViewController.delegate = self
        if UI_USER_INTERFACE_IDIOM() == .pad {
            splitViewController.preferredDisplayMode = .allVisible
//        } else {
//            splitViewController.preferredDisplayMode = .primaryOverlay
        }
        
        ProductManager.shared.listProducts(completionHandler: nil)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        TransientStore.shared.serialize(withProfiles: true) // synchronize
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return !TransientStore.shared.service.hasActiveProfile()
    }

    // MARK: URLs
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let root = window?.rootViewController else {
            fatalError("No window.rootViewController?")
        }
        
        let topmost = root.presentedViewController ?? root
        return tryParseURL(url, passphrase: nil, target: topmost)
    }
    
    private func tryParseURL(_ url: URL, passphrase: String?, target: UIViewController) -> Bool {
        guard let rootViewController = window?.rootViewController else {
            return false
        }
        importer = HostImporter(withConfigurationURL: url, parentViewController: rootViewController)
        importer?.importHost(withPassphrase: passphrase, removeOnError: true, removeOnCancel: true) {
            self.handleParsingResult($0, in: rootViewController)
        }
        return true
    }
    
    private func handleParsingResult(_ parsingResult: OpenVPN.ConfigurationParser.Result, in target: UIViewController) {

        // already presented: update parsed configuration
        if let nav = target as? UINavigationController, let wizard = nav.topViewController as? WizardHostViewController {
            if let oldURL = wizard.parsingResult?.url {
                try? FileManager.default.removeItem(at: oldURL)
            }
            wizard.parsingResult = parsingResult
            wizard.removesConfigurationOnCancel = true
            return
        }

        // present now
        let wizardNav = StoryboardScene.Organizer.wizardHostIdentifier.instantiate()
        guard let wizard = wizardNav.topViewController as? WizardHostViewController else {
            fatalError("Expected WizardHostViewController from storyboard")
        }
        wizard.parsingResult = parsingResult
        wizard.removesConfigurationOnCancel = true

        wizardNav.modalPresentationStyle = .formSheet
        target.present(wizardNav, animated: true, completion: nil)
    }
}

extension UISplitViewController {
    var serviceViewController: ServiceViewController? {
        for vc in viewControllers {
            guard let nav = vc as? UINavigationController else {
                continue
            }
            if let found = nav.viewControllers.first(where: {
                $0 as? ServiceViewController != nil
            }) as? ServiceViewController {
                return found
            }
        }
        return nil
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let interaction = userActivity.interaction else {
            return false
        }
        if #available(iOS 12, *) {
            IntentDispatcher.handleInteraction(interaction, completionHandler: nil)
        }
        return true
    }
}
