//
//  ShortcutsViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/27/19.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import Intents
import IntentsUI
import PassepartoutCore
import ConvenienceUI

@available(iOS 12, *)
protocol ShortcutsIntentDelegate: AnyObject {
    func shortcutsDidSelectIntent(intent: INIntent)
}

@available(iOS 12, *)
private struct ShortcutWrapper: Comparable {
    let phrase: String

    let intentDescription: String?
    
    let original: INVoiceShortcut

    static func from(_ vs: INVoiceShortcut) -> ShortcutWrapper {
        return ShortcutWrapper(
            phrase: vs.invocationPhrase,
            intentDescription: vs.shortcut.intent?.intentDescription,
            original: vs
        )
    }
    
    // MARK: Equatable
    
    static func ==(lhs: ShortcutWrapper, rhs: ShortcutWrapper) -> Bool {
        return lhs.phrase == rhs.phrase
    }

    // MARK: Comparable
    
    static func <(lhs: ShortcutWrapper, rhs: ShortcutWrapper) -> Bool {
        return lhs.phrase < rhs.phrase
    }
}

@available(iOS 12, *)
class ShortcutsViewController: UITableViewController, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate, ShortcutsIntentDelegate, StrongTableHost {
    private var wrappers: [ShortcutWrapper]?
    
    private var pendingShortcut: INShortcut?
    
    private var editedIndexPath: IndexPath?
    
    // MARK: StrongTableModel
    
    let model: StrongTableModel<SectionType, RowType> = {
        let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
        model.add(.all)
        model.setHeader(L10n.Shortcuts.Edit.Sections.All.header, forSection: .all)
        model.set([], forSection: .all)
        return model
    }()
    
    func reloadModel() {
        var rows = [RowType](repeating: .shortcut, count: wrappers?.count ?? 0)
        rows.append(.addShortcut)
        model.set(rows, forSection: .all)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Organizer.Cells.SiriShortcuts.caption

        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { [weak self] (shortcuts, error) in
            DispatchQueue.main.async {
                guard let shortcuts = shortcuts else {
                    self?.handleShortcutsFetchError(error)
                    return
                }
                self?.handleShortcuts(shortcuts)
            }
        }
    }
    
    // MARK: Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let vc = nav.topViewController as? ShortcutsAddViewController {
            vc.delegate = self
        }
    }
    
    private func addShortcut() {
        perform(segue: StoryboardSegue.Shortcuts.shortcutAddSegueIdentifier)
    }

    private func handleShortcutsFetchError(_ error: Error?) {
        
        // TODO: really show it?
//        let alert = UIAlertController.asAlert(
//            title,
//            L10n.Shortcuts.Edit.message(error?.localizedDescription ?? "")
//        )
//        alert.addCancelAction(L10n.Global.ok) {
//            self.close()
//        }
//        present(alert, animated: true, completion: nil)
    }

    private func handleShortcuts(_ shortcuts: [INVoiceShortcut]) {
        wrappers = shortcuts.map { ShortcutWrapper.from($0) }
        wrappers?.sort()
        reloadModel()
        tableView.reloadData()
    }
    
    private func finishAddingPendingShortcut() {
        guard let shortcut = pendingShortcut else {
            return
        }
        if let ip = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: ip, animated: true)
        }
        pendingShortcut = nil
        let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        vc.applyModalPresentation(.current)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: UITableViewController
    
    enum SectionType {
        case all
    }
    
    enum RowType {
        case shortcut

        case addShortcut
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .shortcut:
            guard let wrapper = wrappers?[indexPath.row] else {
                break
            }
            cell.apply(.current)
            cell.leftText = wrapper.phrase
            cell.rightText = wrapper.intentDescription

        case .addShortcut:
            cell.applyAction(.current)
            cell.leftText = L10n.Shortcuts.Edit.Cells.AddShortcut.caption
            cell.accessoryType = .none
            cell.isTappable = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .shortcut:
            guard let wrapper = wrappers?[indexPath.row] else {
                break
            }
            let vc = INUIEditVoiceShortcutViewController(voiceShortcut: wrapper.original)
            vc.applyModalPresentation(.current)
            vc.delegate = self
            editedIndexPath = indexPath
            present(vc, animated: true, completion: nil)
            
        case .addShortcut:
            addShortcut()
        }
    }
    
    // MARK: ShortcutsIntentDelegate
    
    func shortcutsDidSelectIntent(intent: INIntent) {
        pendingShortcut = INShortcut(intent: intent)
        dismiss(animated: true) {
            self.finishAddingPendingShortcut()
        }
    }
    
    // MARK: INUIAddVoiceShortcutViewControllerDelegate
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        guard let voiceShortcut = voiceShortcut else {
            dismiss(animated: true, completion: nil)
            return
        }

        wrappers?.append(ShortcutWrapper.from(voiceShortcut))
        wrappers?.sort()
        reloadModel()
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: INUIEditVoiceShortcutViewControllerDelegate
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        guard let indexPath = editedIndexPath, let voiceShortcut = voiceShortcut else {
            return
        }
        editedIndexPath = nil
        wrappers?[indexPath.row] = ShortcutWrapper.from(voiceShortcut)
        wrappers?.sort()
        tableView.reloadData()

        dismiss(animated: true)
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        guard let indexPath = editedIndexPath else {
            return
        }
        editedIndexPath = nil
        wrappers?.remove(at: indexPath.row)
        reloadModel()

        dismiss(animated: true) {
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        editedIndexPath = nil
        dismiss(animated: true, completion: nil)
    }
}
