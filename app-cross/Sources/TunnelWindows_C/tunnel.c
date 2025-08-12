// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#include <stdio.h>
#include <stdlib.h>
#include "partout.h"
#include "passepartout/tunnel.h"

void ppt_start() {
    puts("PPT Windows here");
    const char *ver = partout_version();
    printf(">>> %s\n", ver);
    free((char *)ver);
}
