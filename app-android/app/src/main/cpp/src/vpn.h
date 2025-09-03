/*
 * SPDX-FileCopyrightText: 2025 Davide De Rosa
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#pragma once

#include "partout.h"

void vpn_test_callback();
void vpn_test_working_wrapper(void *jniRef);

void *vpn_set_tunnel(void *jniRef, const partout_tun_ctrl_info *info);
void vpn_clear_tunnel(void *jniRef, void *tunImpl);
