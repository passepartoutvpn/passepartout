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

    @IBOutlet private weak var activity: UIActivityIndicatorView?
    
    @IBOutlet private weak var label: UILabel?
    
    var text: String?
    
    var url: URL?

    override func awakeFromNib() {
        super.awakeFromNib()

        applyDetailTitle(Theme.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        activity?.hidesWhenStopped = true
        activity?.applyAccent(Theme.current)

        if let url = url {
            label?.text = nil
            activity?.startAnimating()

            DispatchQueue(label: LabelViewController.description(), qos: .background).async { [weak self] in
                let urlText = try? String(contentsOf: url)
                DispatchQueue.main.async {
                    self?.label?.text = urlText
                    self?.activity?.stopAnimating()
                }
            }
        } else {
            label?.text = text
        }

        scrollView?.applyPrimaryBackground(Theme.current)
        label?.applyLight(Theme.current)
    }
}
