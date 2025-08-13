// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Tunnel_C
#if canImport(TunnelLinux)
import TunnelLinux
#elseif canImport(TunnelWindows)
import TunnelWindows
#else
import TunnelMock_C
#endif

//let daemon = SimpleConnectionDaemon(params: .init(
//    registry: Registry(),
//    connectionParameters: ConnectionParameters(
//        controller: any TunnelController,
//        factory: any NetworkInterfaceFactory,
//        environment: any TunnelEnvironment,
//        options: ConnectionParameters.Options
//    ),
//    reachability: any ReachabilityObserver,
//    messageHandler: any MessageHandler,
//    stopDelay: Int,
//    reconnectionDelay: Int
//))

ppt_start()
