//
//  MSS.m
//  Partout
//
//  Created by Davide De Rosa on 2/7/17.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//      Copyright (c) 2018-Present Private Internet Access
//
//      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <arpa/inet.h>

#import "MSS.h"

const int FLAG_SYN      = 2;
const int PROTO_TCP     = 6;
const int OPT_END       = 0;
const int OPT_NOP       = 1;
const int OPT_MSS       = 2;
const int MSS_VAL       = 1250;

typedef struct {
    uint8_t hdr_len:4, ver:4, x[8], proto;
} ip_hdr_t;

typedef struct {
    uint8_t x1[12];
    uint8_t x2:4, hdr_len:4, flags;
    uint16_t x3, sum, x4;
} tcp_hdr_t;

typedef struct {
    uint8_t opt, size;
    uint16_t mss;
} tcp_opt_t;

static inline void MSSUpdateSum(uint16_t* sum_ptr, uint16_t* val_ptr, uint16_t new_val)
{
    uint32_t sum = (~ntohs(*sum_ptr) & 0xffff) + (~ntohs(*val_ptr) & 0xffff) + new_val;
    sum = (sum >> 16) + (sum & 0xffff);
    sum += (sum >> 16);
    *sum_ptr = htons(~sum & 0xffff);
    *val_ptr = htons(new_val);
}

void MSSFix(uint8_t *data, NSInteger data_len)
{
    /* XXX Prevent buffer overread */
    if (data_len < sizeof(ip_hdr_t)) {
        return;
    }
    ip_hdr_t *iph = (ip_hdr_t *)data;
    if (iph->proto != PROTO_TCP) {
        return;
    }
    uint32_t iph_size = iph->hdr_len * 4;
    if (iph_size + sizeof(tcp_hdr_t) > data_len) {
        return;
    }
    
    tcp_hdr_t *tcph = (tcp_hdr_t *)(data + iph_size);
    if (!(tcph->flags & FLAG_SYN)) {
        return;
    }
    uint8_t *opts = data + iph_size + sizeof(tcp_hdr_t);

    uint32_t tcph_len = tcph->hdr_len * 4, optlen = tcph_len-sizeof(tcp_hdr_t);
    if (iph_size + sizeof(tcp_hdr_t) + optlen > data_len) {
        return;
    }

    for (uint32_t i = 0; i < optlen;) {
        tcp_opt_t *o = (tcp_opt_t *)&opts[i];

        /* XXX Prevent buffer overread */
        if ((void *)(o + sizeof(tcp_opt_t)) > (void *)(data + data_len)) {
            return;
        }

        if (o->opt == OPT_END) {
            return;
        }
        if (o->opt == OPT_MSS) {
            if (i + o->size > optlen) {
                return;
            }
            if (ntohs(o->mss) <= MSS_VAL) {
                return;
            }
            MSSUpdateSum(&tcph->sum, &o->mss, MSS_VAL);
            return;
        }

        /* XXX Prevent infinite loop */
        i += (o->opt == OPT_NOP) ? 1 : (o->size ? o->size : 1);
//        i += (o->opt == OPT_NOP) ? 1 : o->size;
    }
}
