// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <linux/if_tun.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/unistd.h>
#include "passepartout/tunnel.h"

int tun_alloc(const char *devname) {
    struct ifreq ifr = {};
    int fd = open("/dev/net/tun", O_RDWR);
    if (fd < 0) {
        perror("open /dev/net/tun");
        return -1;
    }

    ifr.ifr_flags = IFF_TUN | IFF_NO_PI;
    strncpy(ifr.ifr_name, devname, IFNAMSIZ);

    if (ioctl(fd, TUNSETIFF, (void *)&ifr) < 0) {
        perror("ioctl TUNSETIFF");
        close(fd);
        return -1;
    }

    printf("Created TUN device: %s\n", ifr.ifr_name);
    return fd;
}

void ppt_start() {
    puts("PPT Linux here");
    int fd0 = tun_alloc("tun0");
    if (system("ip addr add 10.100.2.3/24 dev tun0") != 0) {
        perror("ip addr");
        close(fd0);
        return;
    }
    if (system("ip link set tun0 up") != 0) {
        perror("ip link");
        close(fd0);
        return;
    }
    sleep(100000);
}
