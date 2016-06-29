#!/usr/bin/env python
# xctest_checker/main.py - Entry point for xctest_checker -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

from __future__ import absolute_import

import argparse
import textwrap

from . import compare


def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent("""
            Compare the text output of an XCTest executable with the text
            that's expected."""),
        epilog=textwrap.dedent("""
            In general, %(prog)s should not be invoked directly. Instead,
            use the Swift built script to build swift-corelibs-xctest and run
            its tests, which in turn use %(prog)s.

            However, you may find it useful to run %(prog)s directly when
            debugging the test suite. To compare the actual output of an
            executable against the expected output, you may run the following:

                Tests/Functional/MyTestCase/Output/MyTestCase | \\
                    %(prog)s - Tests/Functional/MyTestCase/main.swift

            This pipes the output from the "MyTestCase" executable into
            %(prog)s, which compares that output to the expected output from
            "MyTestCase/main.swift".
            """))
    parser.add_argument(
        'actual',
        type=argparse.FileType('r'),
        default='-',
        help='A path to a file containing the actual output of an XCTest '
             'run, or an input stream of the output. If no argument is '
             'specified, reads from stdin by default.')
    parser.add_argument('expected', help='A path to a file containing the '
                                         'expected output of an XCTest run.')
    parser.add_argument('-p', '--check-prefix',
                        default='// CHECK: ',
                        help='%(prog)s checks actual output against expected '
                             'output. By default, %(prog)s only checks lines '
                             'that are prefixed with "%(default)s". This '
                             'option can be used to change that '
                             'prefix. Leading and trailing whitespace is '
                             'ignored unless the check line contains explicit '
                             '^ or $ characters.')
    args = parser.parse_args()
    compare.compare(args.actual, args.expected, args.check_prefix)


if __name__ == '__main__':
    main()
