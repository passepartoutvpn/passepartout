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
    
    var license: AppConstants.License?

    override func awakeFromNib() {
        super.awakeFromNib()

        applyDetailTitle(Theme.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        activity?.hidesWhenStopped = true
        activity?.applyAccent(Theme.current)
        scrollView?.applyPrimaryBackground(Theme.current)
        label?.applyLight(Theme.current)

        if let license = license {
            
            // try cache first
            if let cachedContent = AppConstants.License.cachedContent[license.name] {
                label?.text = cachedContent
                return
            }
            
            label?.text = nil
            activity?.startAnimating()

            DispatchQueue(label: LabelViewController.description(), qos: .background).async { [weak self] in
                let content: String
                let couldFetch: Bool
                do {
                    content = try String(contentsOf: license.url)
                    couldFetch = true
                } catch {
                    content = L10n.Label.License.error
                    couldFetch = false
                }
                DispatchQueue.main.async {
                    self?.label?.text = content
                    self?.activity?.stopAnimating()
                    
                    if couldFetch {
                        AppConstants.License.cachedContent[license.name] = content
                    }
                }
            }
        } else {
            label?.text = text
        }
    }
}
