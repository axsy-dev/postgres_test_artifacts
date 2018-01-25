# Overview
This repo contains postgres releases for use in integration tests in
bazel. The builds are meant to be run on a mac with the appropriate
native toolchain and docker installed.

# Distribution Description
All contrib modules in a standard postgres release and the following additional modules.

* wal2json

# Additional Tools
For uploading a release the [ghr](https://github.com/tcnksm/ghr) tool.
```
brew tap tcnksm/ghr
brew install ghr
```

# TODO 
The artifacts need some testing, it's likely the build configuration will need some tuning (static linking, etc).

