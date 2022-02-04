//
//  TextTableView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/20/19.
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

class TextTableView: NSView {
    @IBOutlet private weak var labelTitle: NSTextField!

    @IBOutlet private weak var tableView: NSTableView!

    @IBOutlet private weak var buttonAdd: NSButton!

    @IBOutlet private weak var buttonRemove: NSButton!
    
    var title = ""

    private(set) var rows: [String] = []

    var selectedRow: Int? {
        didSet {
            guard let _ = selectedRow else {
                tableView.deselectColumn(0)
                return
            }
        }
    }
    
    var selectionBlock: ((String) -> Void)?
    
    var deselectionBlock: (() -> Void)?
    
    var updateBlock: (() -> Void)?
    
    var rowTemplate = ""

    var isEnabled: Bool = true {
        didSet {
            isAddEnabled = isEnabled
            isRemoveEnabled = isEnabled
        }
    }
    
    var isAddEnabled: Bool {
        get {
            return buttonAdd.isEnabled
        }
        set {
            buttonAdd.isEnabled = newValue
        }
    }
    
    var isRemoveEnabled: Bool {
        get {
            return buttonRemove.isEnabled
        }
        set {
            buttonRemove.isEnabled = newValue
        }
    }
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        super.viewWillMove(toSuperview: newSuperview)

        labelTitle.stringValue = title
        buttonAdd.image = NSImage(named: NSImage.addTemplateName)
        buttonRemove.image = NSImage(named: NSImage.removeTemplateName)

        if let i = selectedRow {
            tableView.reloadData()
            tableView.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: true)
        }
    }
    
    // MARK: Actions
    
    func reset(withRows rows: [String], isAddEnabled: Bool) {
        endEditing()
        self.rows = rows
        self.isAddEnabled = isAddEnabled
        isRemoveEnabled = false
        selectedRow = nil
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }

    @IBAction private func addElement(_ sender: Any?) {
        rows.append(rowTemplate)
        tableView.reloadData()
        tableView.editColumn(0, row: rows.count - 1, with: nil, select: true)
        updateBlock?()
    }

    @IBAction private func removeElement(_ sender: Any?) {
        let index = tableView.selectedRow
        guard index != -1 else {
            return
        }
        rows.remove(at: index)
        tableView.reloadData()
        updateBlock?()
    }
}

extension TextTableView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return rows[row]
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        defer {
            tableView.reloadData()
        }
        guard let string = object as? String, !string.isEmpty else {
            rows.remove(at: row)
            return
        }
        rows[row] = string.stripped
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let index = tableView.selectedRow
        guard index != -1 else {
            isRemoveEnabled = false
            deselectionBlock?()
            return
        }
        isRemoveEnabled = true
        selectionBlock?(rows[index])
    }
}
