# xctest_checker/error.py - Errors that display nicely in Xcode -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors


class XCTestCheckerError(Exception):
    """
    An exception that indicates an xctest_checker-based functional test should
    fail. Formats exception messages such that they render inline in Xcode.
    """
    def __init__(self, path, line_number, message):
        super(XCTestCheckerError, self).__init__(
            '\n{}:{}: {}'.format(path, line_number, message))
