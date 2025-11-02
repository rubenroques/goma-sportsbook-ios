fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Print environment variables and arguments

### ios sync_version

```sh
[bundle exec] fastlane ios sync_version
```

Update build number to match Betsson France

### ios version_bump

```sh
[bundle exec] fastlane ios version_bump
```

Update build number

### ios marketing_version_bump

```sh
[bundle exec] fastlane ios marketing_version_bump
```

Update marketing version

### ios certificates

```sh
[bundle exec] fastlane ios certificates
```

Setup certificates and provisioning profiles

### ios distribute_to_firebase

```sh
[bundle exec] fastlane ios distribute_to_firebase
```

Build and distribute to Firebase

### ios staging

```sh
[bundle exec] fastlane ios staging
```

Deploy to Staging environment

### ios production

```sh
[bundle exec] fastlane ios production
```

Deploy to Production environment

### ios deploy_all

```sh
[bundle exec] fastlane ios deploy_all
```

Deploy to both Staging and Production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
