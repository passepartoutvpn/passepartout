//
//  CreditsViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/26/18.
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

class CreditsViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView?

//    @IBOutlet private weak var labelTitle: UILabel?
//
//    @IBOutlet private weak var labelIntro: UILabel?
//
//    @IBOutlet private weak var buttonPassepartout: UIButton?
//
//    @IBOutlet private weak var buttonTunnelKit: UIButton?

    @IBOutlet private weak var labelThirdParties: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        applyDetailTitle(Theme.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Credits.title
//        labelIntro?.text = L10n.Credits.Labels.intro
//        buttonPassepartout?.setTitle(L10n.Credits.Buttons.passepartout, for: .normal)
//        buttonTunnelKit?.setTitle(L10n.Credits.Buttons.tunnelkit, for: .normal)

        var notices = AppConstants.Notices.all
        notices.insert(L10n.Credits.Labels.thirdParties, at: 0)
        labelThirdParties?.text = notices.joined(separator: "\n\n")

        scrollView?.applyPrimaryBackground(Theme.current)
        labelThirdParties?.applyLight(Theme.current)
    }
}
