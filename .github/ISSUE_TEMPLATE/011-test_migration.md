---
name: Test migration
about: Manual tests.
labels: "testing"
---

- Migration process from v2
  - Install v2
  - Create host/provider profiles
  - Upgrade to v3
  - Migrate profiles
  - Content is expected

- DNS
  - [ ] Set manual
  - [ ] Set DoH/DoT
  - [ ] Set addresses
  - [ ] Set search domains
  - [ ] Migrated profile has DNSModule
  - [ ] Module is enabled

- HTTP proxy
  - [ ] Set manual
  - [ ] Set HTTP proxy
  - [ ] Set HTTPS proxy
  - [ ] Set PAC URL
  - [ ] Set bypass domains
  - [ ] Migrated profile has HTTPProxyModule
  - [ ] Module is enabled

- On-demand
  - [ ] Set rules
  - [ ] Migrated profile has OnDemandModule
  - [ ] Module is enabled if on-demand was enabled

- Default gateway
  - [ ] Set manual
  - [ ] Enable IPv4/IPv6
  - [ ] Migrated profile has IPModule with default IPv4/6 routes

- MTU
  - [ ] Set manual
  - [ ] Set 1300
  - [ ] Migrated profile has IPModule with MTU

- Default gateway + MTU
  - [ ] Migrated profile has single IPModule with merged settings
