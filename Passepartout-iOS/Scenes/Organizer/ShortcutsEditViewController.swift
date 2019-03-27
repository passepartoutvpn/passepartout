//
//  ShortcutsEditViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 3/27/19.
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
import Intents
import IntentsUI
import Passepartout_Core

private struct ShortcutWrapper {
    let phrase: String

    let intentDescription: String?
    
    let original: Any?

    @available(iOS 12, *)
    static func from(_ vs: INVoiceShortcut) -> ShortcutWrapper {
        return ShortcutWrapper(
            phrase: vs.invocationPhrase,
            intentDescription: vs.shortcut.intent?.suggestedInvocationPhrase,
            original: vs
        )
    }
}

class ShortcutsEditViewController: UITableViewController, TableModelHost {
    private var wrappers: [ShortcutWrapper]?
    
    private var editedIndexPath: IndexPath?
    
    // MARK: TableModel
    
    let model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.all)
        model.setHeader(L10n.Shortcuts.Edit.Sections.All.header, for: .all)
        model.set([], in: .all)
        return model
    }()
    
    func reloadModel() {
        model.set(.shortcut, count: wrappers?.count ?? 0, in: .all)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Organizer.Cells.SiriShortcuts.caption

        guard #available(iOS 12, *) else {
            return
        }
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

    private func handleShortcutsFetchError(_ error: Error?) {
        
        // TODO: really show it?
//        let alert = Macros.alert(
//            title,
//            L10n.Shortcuts.Edit.message(error?.localizedDescription ?? "")
//        )
//        alert.addCancelAction(L10n.Global.ok) {
//            self.close()
//        }
//        present(alert, animated: true, completion: nil)
    }

    @available(iOS 12, *)
    private func handleShortcuts(_ shortcuts: [INVoiceShortcut]) {
        wrappers = shortcuts.map { ShortcutWrapper.from($0) }
        reloadModel()
        tableView.reloadData()
    }

    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension ShortcutsEditViewController {
    enum SectionType {
        case all
    }
    
    enum RowType {
        case shortcut
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .shortcut:
            guard let wrapper = wrappers?[indexPath.row] else {
                break
            }
            cell.leftText = wrapper.phrase
            cell.rightText = wrapper.intentDescription
        }
        cell.apply(Theme.current)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard #available(iOS 12, *) else {
            return
        }
        switch model.row(at: indexPath) {
        case .shortcut:
            guard let wrapper = wrappers?[indexPath.row], let shortcut = wrapper.original as? INVoiceShortcut else {
                break
            }
            let vc = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
            vc.delegate = self
            editedIndexPath = indexPath
            present(vc, animated: true, completion: nil)
        }
    }
}

@available(iOS 12, *)
extension ShortcutsEditViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        editedIndexPath = nil
        dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        guard let indexPath = editedIndexPath, let voiceShortcut = voiceShortcut else {
            return
        }
        editedIndexPath = nil
        wrappers?[indexPath.row] = ShortcutWrapper.from(voiceShortcut)

        dismiss(animated: true) {
            self.tableView.reloadData()
        }
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
}
