//
//  VersionViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/27/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

class VersionViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView?

    @IBOutlet private weak var labelTitle: UILabel?
    
    @IBOutlet private weak var labelVersion: UILabel?
    
    @IBOutlet private weak var labelCopyright: UILabel?
    
    @IBOutlet private weak var labelIntro: UILabel?
    
    @IBOutlet private weak var buttonChangelog: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyDetailTitle(Theme.current)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle?.text = GroupConstants.App.name
        labelVersion?.text = Utils.versionString()
        labelCopyright?.text = GroupConstants.App.name
        labelIntro?.text = L10n.Version.Labels.intro
        buttonChangelog?.setTitle(L10n.Version.Buttons.changelog, for: .normal)
        
        scrollView?.applyPrimaryBackground(Theme.current)
        for label in [labelTitle, labelVersion, labelCopyright, labelIntro] {
            label?.applyLight(Theme.current)
        }
        buttonChangelog?.apply(Theme.current)
    }

    @IBAction private func visitChangelog() {
        UIApplication.shared.open(AppConstants.URLs.changelog, options: [:], completionHandler: nil)
    }
}
