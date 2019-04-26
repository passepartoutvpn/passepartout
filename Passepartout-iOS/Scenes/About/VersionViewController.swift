//
//  VersionViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/27/18.
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
import Passepartout_Core

class VersionViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView?

    @IBOutlet private weak var labelTitle: UILabel?
    
    @IBOutlet private weak var labelVersion: UILabel?
    
    @IBOutlet private weak var labelIntro: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyDetailTitle(Theme.current)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Version.title
        labelTitle?.text = GroupConstants.App.name
        labelVersion?.text = Utils.versionString()
        labelIntro?.text = L10n.Version.Labels.intro

        scrollView?.applyPrimaryBackground(Theme.current)
        for label in [labelTitle, labelVersion, labelIntro] {
            label?.applyLight(Theme.current)
        }
    }
}
