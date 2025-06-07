//
//  String+QR.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/5/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CoreImage.CIFilterBuiltins
import Foundation

extension String {
    public func qrImage() -> CGImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(utf8)
        filter.setValue(data, forKey: "inputMessage")
        guard let outputImage = filter.outputImage else {
            return nil
        }
        return context.createCGImage(outputImage, from: outputImage.extent)
    }
}
