//
// MIT License
//
// Copyright (c) 2025 Davide De Rosa
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

function getInfrastructure() {
    const providerId = "mullvad";
    const openVPN = {
        moduleType: "OpenVPN",
        presetIds: {
            recommended: "default",
            dnsOverride: "dns"
        }
    };

    const json = getJSON("https://api.mullvad.net/app/v1/relays");
    if (json.error) {
        return json;
    }

    const locations = json.response.locations;
    const servers = [];
    json.response.openvpn.relays.forEach((relay) => {
        const location = locations[relay.location];
        if (!location) {
            return;
        }

        const id = relay.hostname;
        const hostname = `${id.toLowerCase()}.mullvad.net`;
        const addresses = [relay.ipv4_addr_in].map((a) => ipV4ToBase64(a));

        const code = id.split("-")[0].toUpperCase();
        const area = location.city;
        const num = parseInt(id.split("-").pop(), 10);

        const server = {
            serverId: id,
            hostname: hostname,
            ipAddresses: addresses,
            supportedModuleTypes: [openVPN.moduleType]
        };
        const metadata = {
            providerId: providerId,
            categoryName: "Default",
            countryCode: code
        };
        metadata.area = area;
        metadata.num = num;
        server.metadata = metadata;

        servers.push(server);
    });

    const presets = getOpenVPNPresets(providerId, openVPN.moduleType, openVPN.presetIds, json.response.openvpn.ports);

    return {
        response: {
            presets: presets,
            servers: servers,
            cache: json.cache
        }
    };
}

// MARK: OpenVPN

function getOpenVPNPresets(providerId, moduleType, presetIds, ports) {
    const ca = `
-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----
`;

    const cfg = {
        ca: ca,
        cipher: "AES-256-CBC",
        digest: "SHA1",
        compressionFraming: 0,
        keepAliveInterval: 10,
        keepAliveTimeout: 60,
        renegotiatesAfter: 0,
        checksEKU: true,
    };

    const endpoints = ports.map(p =>
        `${p.protocol.toUpperCase()}:${p.port}`
    );

    const recommended = {
        providerId: providerId,
        presetId: presetIds.recommended,
        description: "Default",
        moduleType: moduleType,
        templateData: jsonToBase64({
            configuration: cfg,
            endpoints: endpoints
        })
    };

    const dnsOverride = {
        providerId: providerId,
        presetId: presetIds.dnsOverride,
        description: "Custom DNS",
        moduleType: moduleType,
        templateData: jsonToBase64({
            configuration: cfg,
            endpoints: ["UDP:1400", "TCP:1401"],
        })
    };

    return [recommended, dnsOverride];
}
