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

### ios setup_api_key

```sh
[bundle exec] fastlane ios setup_api_key
```



### ios test

```sh
[bundle exec] fastlane ios test
```

Print environment variables and arguments

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

### ios distribute_staging

```sh
[bundle exec] fastlane ios distribute_staging
```

Distribute to Staging (increments build, registers devices, distributes)

### ios distribute_uat

```sh
[bundle exec] fastlane ios distribute_uat
```

Distribute to UAT (increments build, registers devices, distributes)

### ios distribute_all

```sh
[bundle exec] fastlane ios distribute_all
```

Distribute to both Staging and UAT (increments build once)

### ios fetch_firebase_devices

```sh
[bundle exec] fastlane ios fetch_firebase_devices
```

Fetch device UDIDs from Firebase App Distribution

### ios register_new_devices

```sh
[bundle exec] fastlane ios register_new_devices
```

Register new devices from local devices.txt and update provisioning profiles

### ios keep_version_distribute_staging

```sh
[bundle exec] fastlane ios keep_version_distribute_staging
```

Keep version and distribute to Staging (SAME build, registers devices, distributes)

### ios keep_version_distribute_uat

```sh
[bundle exec] fastlane ios keep_version_distribute_uat
```

Keep version and distribute to UAT (SAME build, registers devices, distributes)

### ios keep_version_distribute_all

```sh
[bundle exec] fastlane ios keep_version_distribute_all
```

Keep version and distribute to both Staging and UAT (SAME build)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
