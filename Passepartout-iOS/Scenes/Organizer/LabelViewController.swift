//
//  LabelViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/26/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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

class LabelViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView?

    @IBOutlet private weak var label: UILabel?
    
    var text: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        applyDetailTitle(Theme.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Credits.title
        label?.text = text

        scrollView?.applyPrimaryBackground(Theme.current)
        label?.applyLight(Theme.current)
    }
}
