//
//  Crypto.m
//  PassepartoutKit
//
//  Created by Davide De Rosa on 1/10/25.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

#import "Crypto.h"

#define MAX_BLOCK_SIZE  16  // AES only, block is 128-bit

size_t pp_alloc_crypto_capacity(size_t size, size_t overhead) {

    // encryption, byte-alignment, overhead (e.g. IV, digest)
    return 2 * size + MAX_BLOCK_SIZE + overhead;
}
