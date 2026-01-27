##
## This source file is part of the Swift.org open source project
##
## Copyright (c) 2026 Apple Inc. and the Swift project authors
## Licensed under Apache License v2.0 with Runtime Library Exception
##
## See https://swift.org/LICENSE.txt for license information
## See https://swift.org/CONTRIBUTORS.txt for Swift project authors
##

FROM swiftlang/swift:nightly-main-jammy

RUN apt-get -y update && apt-get -y install \
    cmake                 \
    ninja-build           \
    python3               \
    python3-pkg-resources

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

USER build-user

WORKDIR /home/build-user
