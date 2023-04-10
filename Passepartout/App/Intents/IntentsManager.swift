//
//  IntentsManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/30/22.
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
import Intents
import IntentsUI
import Combine
import PassepartoutLibrary

@MainActor
class IntentsManager: NSObject, ObservableObject {
    @Published private(set) var isReloadingShortcuts = false

    @Published private(set) var shortcuts: [UUID: Shortcut] = [:]

    let shouldDismissIntentView = PassthroughSubject<Void, Never>()

    private var continuation: CheckedContinuation<[INVoiceShortcut], Never>?

    override init() {
        super.init()
        Task {
            await reloadShortcuts()
        }
    }

    func reloadShortcuts() async {
        isReloadingShortcuts = true
        do {
            let vs = try await INVoiceShortcutCenter.shared.allVoiceShortcuts()
            shortcuts = vs.reduce(into: [UUID: Shortcut]()) {
                $0[$1.identifier] = Shortcut($1)
            }
            isReloadingShortcuts = false
        } catch {
            pp_log.error("Unable to fetch existing shortcuts: \(error)")
            isReloadingShortcuts = false
        }
    }
}

extension IntentsManager: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        guard let vs = voiceShortcut else {
            shouldDismissIntentView.send()
            return
        }
        shortcuts[vs.identifier] = Shortcut(vs)
        shouldDismissIntentView.send()
   }

   func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
       shouldDismissIntentView.send()
   }
}

extension IntentsManager: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        guard let vs = voiceShortcut else {
            return
        }

        shortcuts[vs.identifier] = Shortcut(vs)
        shouldDismissIntentView.send()

        // XXX: iOS bug, vs.invocationPhrase here is still the old one before edit
        //
        // additionally, back from edit view controller does not trigger either onAppear or
        // scenePhase .active FFS
        //
        // so damn it, reload manually after a delay
        Task {
            await Task.maybeWait(forMilliseconds: Constants.Delays.xxxReloadEditedShortcut)
            await reloadShortcuts()
        }
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        shortcuts.removeValue(forKey: deletedVoiceShortcutIdentifier)
        shouldDismissIntentView.send()
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        shouldDismissIntentView.send()
    }
}
