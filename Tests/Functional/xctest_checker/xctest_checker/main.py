#!/usr/bin/env python

from __future__ import absolute_import

import argparse

from . import compare


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('actual', help='A path to a file containing the '
                                       'actual output of an XCTest run.')
    parser.add_argument('expected', help='A path to a file containing the '
                                         'expected output of an XCTest run.')
    parser.add_argument('-p', '--check-prefix',
                        default='// CHECK: ',
                        help='{prog} checks actual output against expected '
                             'output. By default, {prog} only checks lines '
                             'that are prefixed with "// CHECK: ". This '
                             'option can be used to change that '
                             'prefix.'.format(prog=parser.prog))
    args = parser.parse_args()
    compare.compare(args.actual, args.expected, args.check_prefix)


if __name__ == '__main__':
    main()
