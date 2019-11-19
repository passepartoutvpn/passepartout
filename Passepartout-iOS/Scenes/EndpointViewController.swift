//
//  EndpointViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/25/18.
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

protocol EndpointViewControllerDelegate: class {
    func endpointController(_: EndpointViewController, didUpdateWithNewAddress newAddress: String?, newProtocol: EndpointProtocol?)
}

class EndpointViewController: UIViewController, StrongTableHost {
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var itemRefresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    
    private var endpointAddresses: [String] = []

    private var endpointProtocols: [EndpointProtocol] = []
    
    private var initialAddress: String?
    
    private var initialProtocol: EndpointProtocol?

    private var currentAddress: String?
    
    private var currentProtocol: EndpointProtocol?

    private var currentAddressIndexPath: IndexPath?

    private var currentProtocolIndexPath: IndexPath?
    
    var dataSource: EndpointDataSource!
    
    weak var delegate: EndpointViewControllerDelegate?

    weak var modificationDelegate: ConfigurationModificationDelegate?

    // MARK: StrongTableHost
    
    lazy var model: StrongTableModel<SectionType, RowType> = {
        let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
        
        model.add(.locationAddresses)
        model.add(.locationProtocols)
        
        model.setHeader(L10n.App.Endpoint.Sections.LocationAddresses.header, forSection: .locationAddresses)
        model.setHeader(L10n.App.Endpoint.Sections.LocationProtocols.header, forSection: .locationProtocols)
        
        if dataSource.canCustomizeEndpoint {
            var addressRows: [RowType] = Array(repeating: .availableAddress, count: dataSource.addresses.count)
            addressRows.insert(.anyAddress, at: 0)
            model.set(addressRows, forSection: .locationAddresses)
            
            var protocolRows: [RowType] = Array(repeating: .availableProtocol, count: dataSource.protocols.count)
            protocolRows.insert(.anyProtocol, at: 0)
            model.set(protocolRows, forSection: .locationProtocols)
        } else {
            model.set(.availableAddress, count: dataSource.addresses.count, forSection: .locationAddresses)
            model.set(.availableProtocol, count: dataSource.protocols.count, forSection: .locationProtocols)
        }

        return model
    }()
    
    func reloadModel() {
    }

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Endpoint.title
        guard let _ = dataSource else {
            fatalError("Data source not set")
        }
        endpointAddresses = dataSource.addresses
        endpointProtocols = dataSource.protocols

        guard dataSource.canCustomizeEndpoint else {
            tableView.allowsSelection = false
            return
        }
        itemRefresh.isEnabled = false
        navigationItem.rightBarButtonItem = itemRefresh

        initialAddress = dataSource.customAddress
        initialProtocol = dataSource.customProtocol
        currentAddress = initialAddress
        currentProtocol = initialProtocol

        tableView.reloadData()
        if let ip = selectedIndexPath {
            tableView.scrollToRowAsync(at: ip)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let selected = tableView.indexPathForSelectedRow else {
            return
        }
        tableView.deselectRow(at: selected, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction private func refresh() {
        guard dataSource.canCustomizeEndpoint else {
            return
        }
        initialAddress = dataSource.customAddress
        initialProtocol = dataSource.customProtocol
        itemRefresh.isEnabled = false

        modificationDelegate?.configurationShouldReinstall()
    }
    
    // MARK: Helpers
    
    private func setNeedsRefresh() {
        itemRefresh.isEnabled = (currentAddress != initialAddress) || (currentProtocol != initialProtocol)
    }

    private func commitChanges() {
        guard dataSource.canCustomizeEndpoint else {
            return
        }
        
        delegate?.endpointController(self, didUpdateWithNewAddress: currentAddress, newProtocol: currentProtocol)
    }
}

// MARK: -

extension EndpointViewController: UITableViewDataSource, UITableViewDelegate {
    enum SectionType {
        case locationAddresses
        
        case locationProtocols
    }
    
    enum RowType: Int {
        case anyAddress
        
        case availableAddress
        
        case anyProtocol
        
        case availableProtocol
    }
    
    private var selectedIndexPath: IndexPath? {
        guard let i = endpointAddresses.firstIndex(where: { $0 == currentAddress }) else {
            return nil
        }
        return IndexPath(row: i, section: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = model.row(at: indexPath)
        switch row {
        case .anyAddress:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Core.Endpoint.Cells.AnyAddress.caption
            cell.accessoryType = .none
            cell.isTappable = true
            if let _ = currentAddress {
                cell.applyChecked(false, .current)
            } else {
                cell.applyChecked(true, .current)
                currentAddressIndexPath = indexPath
            }
            return cell

        case .availableAddress:
            let address = endpointAddresses[mappedIndex(indexPath.row)]
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = address
            cell.accessoryType = .none
            cell.isTappable = true
            if address == currentAddress {
                cell.applyChecked(true, .current)
                currentAddressIndexPath = indexPath
            } else {
                cell.applyChecked(false, .current)
            }
            return cell
            
        case .anyProtocol:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Core.Endpoint.Cells.AnyProtocol.caption
            cell.accessoryType = .none
            cell.isTappable = true
            if let _ = currentProtocol {
                cell.applyChecked(false, .current)
            } else {
                cell.applyChecked(true, .current)
                currentProtocolIndexPath = indexPath
            }
            return cell

        case .availableProtocol:
            let proto = endpointProtocols[mappedIndex(indexPath.row)]
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = proto.description
            cell.accessoryType = .none
            cell.isTappable = true
            if proto == currentProtocol {
                cell.applyChecked(true, .current)
                currentProtocolIndexPath = indexPath
            } else {
                cell.applyChecked(false, .current)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = model.row(at: indexPath)
        var updatedIndexPaths: [IndexPath] = [indexPath]
        
        switch row {
        case .anyAddress:
            currentAddress = nil
            if let old = currentAddressIndexPath {
                updatedIndexPaths.append(old)
            }

        case .availableAddress:
            currentAddress = endpointAddresses[mappedIndex(indexPath.row)]
            if let old = currentAddressIndexPath {
                updatedIndexPaths.append(old)
            }

        case .anyProtocol:
            currentProtocol = nil
            if let old = currentProtocolIndexPath {
                updatedIndexPaths.append(old)
            }

        case .availableProtocol:
            currentProtocol = endpointProtocols[mappedIndex(indexPath.row)]
            if let old = currentProtocolIndexPath {
                updatedIndexPaths.append(old)
            }
        }

        setNeedsRefresh()
        commitChanges()
        tableView.reloadRows(at: updatedIndexPaths, with: .none)
    }
    
    // MARK: Helpers
    
    private func mappedIndex(_ i: Int) -> Int {
        if dataSource.canCustomizeEndpoint {
            return i - 1
        }
        return i
    }
}
