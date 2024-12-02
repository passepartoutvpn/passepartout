---
name: Test file associations
about: Manual tests.
labels: "testing"
---

- Cold launch
  - [ ] Kill app
  - [ ] Open .ovpn file from Files/Finder
  - [ ] App opens
  - [ ] Passphrase prompt is presented if necessary
  - [ ] Profile is imported

- Hot launch
  - [ ] Launch app and edit some profile (opens modal)
  - [ ] Open .ovpn file from Files/Finder
  - [ ] App opens
  - [ ] Passphrase prompt is presented if necessary
  - [ ] Profile is imported

- App import
  - [ ] Import profile from "+" menu
  - [ ] Passphrase prompt is presented if necessary
  - [ ] Profile is imported
