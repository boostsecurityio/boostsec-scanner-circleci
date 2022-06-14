# Boost Security Scanner CircleCI Orb

[![CircleCI Build Status](https://circleci.com/gh/boostsecurityio/boostsec-scanner-circleci.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/boostsecurityio/boostsec-scanner-circleci) [![CircleCI Orb Version](https://badges.circleci.com/orbs/boostsecurityio/scanner.svg)](https://circleci.com/orbs/registry/orb/boostsecurityio/scanner) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/boostsecurityio/boostsec-scanner-circleci/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

Executes the Boost Security Scanner cli tool to scan repositories for
vulnerabilities and uploads results to the Boost API.

## Resources

[CircleCI Orb Registry Page](https://circleci.com/developer/orbs/orb/boostsecurityio/scanner) - The official registry page of this orb for all versions, executors, commands, and jobs described.

### How to Publish

* Create and push a branch with your new features.
* When ready to publish a new production version, create a Pull Request from _feature branch_ to `master`.
* The title of the pull request must contain a special semver tag: `[semver:<segment>]` where `<segment>` is replaced by one of the following values.

| Increment | Description|
| ----------| -----------|
| major     | Issue a 1.0.0 incremented release|
| minor     | Issue a x.1.0 incremented release|
| patch     | Issue a x.x.1 incremented release|
| skip      | Do not issue a release|

Example: `[semver:major]`

* Squash and merge. Ensure the semver tag is preserved and entered as a part of the commit message.
* On merge, after manual approval, the orb will automatically be published to the Orb Registry.
