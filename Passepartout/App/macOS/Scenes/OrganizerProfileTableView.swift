//
//  OrganizerProfileTableView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/23/19.
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

protocol OrganizerProfileTableViewDelegate: AnyObject {
    func profileTableViewDidRequestAdd(_ profileTableView: OrganizerProfileTableView, sender: NSView)

    func profileTableView(_ profileTableView: OrganizerProfileTableView, didRequestRemove profile: ConnectionProfile)

    func profileTableView(_ profileTableView: OrganizerProfileTableView, didRequestRename profile: HostConnectionProfile)
}

class OrganizerProfileTableView: NSView {
    @IBOutlet private weak var tableView: NSTableView!

    @IBOutlet private weak var buttonAdd: NSButton!

    @IBOutlet private weak var buttonRemove: NSButton!

    @IBOutlet private weak var buttonRename: NSButton!
    
    private let service = TransientStore.shared.service
    
    var rows: [ConnectionProfile] = []
    
    var selectedRow: Int?
    
    var selectionBlock: ((ConnectionProfile) -> Void)?
    
    var deselectionBlock: (() -> Void)?
    
    private var isAddEnabled: Bool {
        get {
            return buttonAdd.isEnabled
        }
        set {
            buttonAdd.isEnabled = newValue
        }
    }
    
    private var isRemoveEnabled: Bool {
        get {
            return buttonRemove.isEnabled
        }
        set {
            buttonRemove.isEnabled = newValue
        }
    }

    private var isRenameEnabled: Bool {
        get {
            return buttonRename.isEnabled
        }
        set {
            buttonRename.isEnabled = newValue
        }
    }
    
    weak var delegate: OrganizerProfileTableViewDelegate?
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        super.viewWillMove(toSuperview: newSuperview)
        
        buttonAdd.image = NSImage(named: NSImage.addTemplateName)
        buttonRemove.image = NSImage(named: NSImage.removeTemplateName)
        buttonRename.image = NSImage(named: NSImage.actionTemplateName)
    }
    
    func reloadData() {
        tableView.reloadData()
        if let i = selectedRow {
            tableView.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: false)
        }
        updateButtonsStatus()
    }
    
    // MARK: Actions
    
    @IBAction private func addProfile(_ sender: Any?) {
        delegate?.profileTableViewDidRequestAdd(self, sender: sender as! NSButton)
    }

    @IBAction private func removeProfile(_ sender: Any?) {
        let index = tableView.selectedRow
        guard index != -1 else {
            return
        }
        delegate?.profileTableView(self, didRequestRemove: rows[index])
    }
    
    @IBAction private func renameProfile(_ sender: Any?) {
        let index = tableView.selectedRow
        guard index != -1 else {
            return
        }
        guard let hostProfile = rows[index] as? HostConnectionProfile else {
            return
        }
        delegate?.profileTableView(self, didRequestRename: hostProfile)
    }
    
    // MARK: Helpers
    
    private func updateButtonsStatus() {
        let index = tableView.selectedRow
        guard index != -1 else {
            isRemoveEnabled = false
            isRenameEnabled = false
            deselectionBlock?()
            return
        }
        isRemoveEnabled = true
        isRenameEnabled = (rows[index] as? HostConnectionProfile != nil)
    }
}

class OrganizerProfileTableViewCell: NSTableCellView {
    @IBOutlet private weak var imageActive: NSImageView?
    
    override var objectValue: Any? {
        didSet {
            guard let objectValue = objectValue else {
                return
            }
            guard let pair = objectValue as? (ConnectionService, ConnectionProfile) else {
                fatalError("objectValue is not a (ConnectionService, ConnectionProfile)")
            }
            imageView?.image = pair.1.image
            textField?.stringValue = pair.0.screenTitle(ProfileKey(pair.1))

            // FIXME: active profile icon
            imageActive?.image = NSImage(named: NSImage.menuOnStateTemplateName)
            imageActive?.isHidden = !TransientStore.shared.service.isActiveProfile(pair.1)
        }
    }
}

extension OrganizerProfileTableView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return (service, rows[row])
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonsStatus()

        let index = tableView.selectedRow
        if index != -1 {
            selectionBlock?(rows[index])
        }
    }
}
