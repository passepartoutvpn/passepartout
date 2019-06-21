//
//  ProviderPresetViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/2/18.
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
import PassepartoutCore

protocol ProviderPresetViewControllerDelegate: class {
    func providerPresetController(_: ProviderPresetViewController, didSelectPreset preset: InfrastructurePreset)
}

class ProviderPresetViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var presets: [InfrastructurePreset] = []
    
    var currentPresetId: String?
    
    weak var delegate: ProviderPresetViewControllerDelegate?

    // MARK: Table
    
    private let rows: [RowType] = [.presetDescription, .techDetails]

    // MARK: UIViewController
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyDetailTitle(Theme.current)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Service.Cells.Provider.Preset.caption
        tableView.reloadData()
        if let ip = selectedIndexPath {
            tableView.scrollToRowAsync(at: ip)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let ip = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: ip, animated: true)
        }
    }
}

extension ProviderPresetViewController: UITableViewDataSource, UITableViewDelegate {
    enum RowType: Int {
        case presetDescription
        
        case techDetails
    }
    
    private var selectedIndexPath: IndexPath? {
        guard let i = presets.firstIndex(where: { $0.id == currentPresetId }) else {
            return nil
        }
        return IndexPath(row: 0, section: i)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presets.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let preset = presets[section]
        return preset.name
    }
    
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return L10n.Core.Provider.Preset.Sections.Main.footer
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let preset = presets[indexPath.section]
        
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.isTappable = true
        switch rows[indexPath.row] {
        case .presetDescription:
            cell.leftText = preset.comment
            cell.applyChecked(preset.id == currentPresetId, Theme.current)

        case .techDetails:
            cell.applyAction(Theme.current)
            cell.leftText = L10n.App.Provider.Preset.Cells.TechDetails.caption
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preset = presets[indexPath.section]

        switch rows[indexPath.row] {
        case .presetDescription:
            currentPresetId = preset.id
            delegate?.providerPresetController(self, didSelectPreset: preset)
            
        case .techDetails:
            let vc = StoryboardScene.Main.configurationIdentifier.instantiate()
            vc.title = preset.name
            vc.initialConfiguration = preset.configuration.sessionConfiguration
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
