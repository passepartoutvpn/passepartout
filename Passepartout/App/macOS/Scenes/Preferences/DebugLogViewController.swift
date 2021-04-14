//
//  DebugLogViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/31/18.
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

import Cocoa
import PassepartoutCore
import TunnelKit

class DebugLogViewController: NSViewController {
    @IBOutlet private weak var labelExchangedCaption: NSTextField!

    @IBOutlet private weak var labelExchanged: NSTextField!
    
    @IBOutlet private weak var checkMasking: NSButton!

    @IBOutlet private weak var labelLog: NSTextField!

    @IBOutlet private weak var tableTextLog: NSTableView!
    
    @IBOutlet private weak var buttonPrevious: NSButton!

    @IBOutlet private weak var buttonNext: NSButton!
    
    @IBOutlet private weak var buttonCopy: NSButton!

    @IBOutlet private weak var buttonShare: NSButton!

    private let service = TransientStore.shared.service
    
    private let vpn = VPN.shared
    
    private var shouldDeleteLogOnDisconnection = false
    
    private var logLines: [Substring] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Core.Service.Cells.DebugLog.caption

        checkMasking.title = L10n.Core.Service.Cells.MasksPrivateData.caption
        checkMasking.state = (TransientStore.masksPrivateData ? .on : .off)

        labelExchangedCaption.stringValue = L10n.Core.Service.Cells.DataCount.caption.asCaption
        labelLog.stringValue = L10n.Core.Service.Cells.DebugLog.caption.asCaption
        buttonCopy.title = L10n.App.DebugLog.Buttons.copy
        buttonPrevious.image = NSImage(named: NSImage.touchBarRewindTemplateName)
        buttonNext.image = NSImage(named: NSImage.touchBarFastForwardTemplateName)
        buttonShare.image = NSImage(named: NSImage.shareTemplateName)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vpnDidPrepare), name: VPN.didPrepare, object: nil)
        nc.addObserver(self, selector: #selector(vpnDidUpdate), name: VPN.didChangeStatus, object: nil)
        nc.addObserver(self, selector: #selector(serviceDidUpdateDataCount), name: ConnectionService.didUpdateDataCount, object: nil)

        if vpn.isPrepared {
            startRefreshingLog()
        }
        refreshDataCount()
    }

    @IBAction private func toggleMasking(_ sender: Any?) {
        let isOn = (self.checkMasking.state == .on)
        let handler = {
            TransientStore.masksPrivateData = isOn
            self.service.baseConfiguration = TransientStore.baseVPNConfiguration.build()
        }
        
        guard vpn.status == .disconnected else {
            let alert = Macros.warning(
                L10n.Core.Service.Cells.MasksPrivateData.caption,
                L10n.Core.Service.Alerts.MasksPrivateData.Messages.mustReconnect
            )
            alert.present(in: view.window, withOK: L10n.Core.Service.Alerts.Buttons.reconnect, cancel: L10n.Core.Global.cancel, handler: {
                handler()
                self.shouldDeleteLogOnDisconnection = true
                
                do {
                    self.vpn.reconnect(configuration: try self.service.vpnConfiguration(), completionHandler: nil)
                } catch {
                }
            }, cancelHandler: {
                self.checkMasking.state = (isOn ? .off : .on)
            })
            return
        }
        
        handler()
        service.eraseVpnLog()
        shouldDeleteLogOnDisconnection = false
    }

    @IBAction private func copySelection(_ sender: Any?) {
        let rows = tableTextLog.selectedRowIndexes
        let content = logLines.enumerated().filter {
            rows.contains($0.offset)
        }.map {
            $0.element
        }.joined(separator: "\n")

        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(content, forType: .string)
    }

    @IBAction private func share(_ sender: Any?) {
        let text = logLines.joined(separator: "\n")
        guard !text.isEmpty else {
            let alert = Macros.warning(
                L10n.Core.Service.Cells.DebugLog.caption,
                L10n.Core.DebugLog.Alerts.EmptyLog.message
            )
            alert.present(in: view.window, withOK: L10n.Core.Global.ok, handler: nil)
            return
        }
        let log = DebugLog(raw: text)
        let logString = log.decoratedString()
        let picker = NSSharingServicePicker(items: [logString])
        picker.show(relativeTo: buttonShare.bounds, of: buttonShare, preferredEdge: .minY)
    }
    
    @IBAction private func previousSession(_ sender: Any?) {
        let visibleRow = firstVisibleRow()
        let viewport = logLines[0..<visibleRow]
        let row = viewport.lastIndex(of: Substring(GroupConstants.VPN.sessionMarker)) ?? 0
        guard row < visibleRow else {
            return
        }
        tableTextLog.scrollRowToVisible(row)
    }

    @IBAction private func nextSession(_ sender: Any?) {
        let visibleRow = lastVisibleRow()
        guard visibleRow < logLines.count else {
            return
        }
        let viewport = logLines[(visibleRow + 1)..<logLines.count]
        let row = viewport.firstIndex(of: Substring(GroupConstants.VPN.sessionMarker)) ?? (logLines.count - 1)
        guard row > visibleRow else {
            return
        }
        tableTextLog.scrollRowToVisible(row)
    }
    
    private func firstVisibleRow() -> Int {
        let range = tableTextLog.rows(in: tableTextLog.visibleRect)
        return range.location
    }
    
    private func lastVisibleRow() -> Int {
        let range = tableTextLog.rows(in: tableTextLog.visibleRect)
        return range.location + range.length
    }
    
    private func startRefreshingLog() {
        let fallback: () -> String = { self.service.vpnLog }
        
        vpn.requestDebugLog(fallback: fallback) {
            self.logLines = $0.split(separator: "\n")
            
            DispatchQueue.main.async {
                self.tableTextLog.reloadData()
                self.tableTextLog.sizeToFit()
                self.refreshLogInBackground()
            }
        }
    }
    
    private func refreshLogInBackground() {
        let fallback: () -> String = { self.service.vpnLog }
        let updateBlock = {
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Log.viewerRefreshInterval) { [weak self] in
                self?.refreshLogInBackground()
            }
        }
        
        // only update if screen is visible
        guard let _ = view.window else {
            updateBlock()
            return
        }
        
        vpn.requestDebugLog(fallback: fallback) {
            let wasEmpty = self.logLines.isEmpty
            self.logLines = $0.split(separator: "\n")
            updateBlock()
            if wasEmpty {
                self.tableTextLog.reloadData()
                self.tableTextLog.sizeToFit()
            }
        }
    }

    // MARK: Notifications
    
    @objc private func vpnDidPrepare() {
        startRefreshingLog()
    }
    
    @objc private func vpnDidUpdate() {
        switch vpn.status {
        case .disconnected:
            if shouldDeleteLogOnDisconnection {
                service.eraseVpnLog()
                shouldDeleteLogOnDisconnection = false
            }
            
        default:
            break
        }

        refreshDataCount()
    }

    @objc private func serviceDidUpdateDataCount() {
        refreshDataCount()
    }
    
    // MARK: Helpers
    
    private func refreshDataCount() {
        if let count = service.vpnDataCount, vpn.status == .connected {
            let down = count.0.dataUnitDescription
            let up = count.1.dataUnitDescription
            labelExchanged.stringValue = "↓\(down) / ↑\(up)"
        } else {
            labelExchanged.stringValue = L10n.Core.Service.Cells.DataCount.none
        }
    }
}

extension DebugLogViewController: NSTableViewDataSource, NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        guard let cell = cell as? NSTextFieldCell else {
            return
        }
        cell.font = NSFont(name: "Courier New", size: NSFont.systemFontSize(for: .regular))
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return logLines.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return logLines[row]
    }
}
