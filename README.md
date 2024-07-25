# actions

> a personalized github-actions toolbox

- [actions](#actions)
  - [Stages](#stages)
    - [CI](#ci)
    - [CD](#cd)
    - [Failed](#failed)
    - [Debug](#debug)

## Stages

### CI

- [setup](/setup/action.yml)
  - [identity](/setup/identity/action.yml)
  - [semver](/setup/semver/action.yml)
- update manifests
- [commit-merge](/commit-merge/action.yml)

### CD

- [setup](/setup/action.yml)
  - [release](/setup/release/action.yml)
- build
  - [dotnet-build](/dotnet-build/action.yml)
- code sign
- [compress-assets](/compress-assets/action.yml)
- publish
  - [github-release](/github-release/action.yml)
  - [npm-publish](/npm-publish/action.yml)

### Failed

- [create-issue](/create-issue/action.yml)

### Debug

- [dump-context](/dump-context/action.yml)
