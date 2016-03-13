# xctest_checker/compare.py - Compares two files line by line -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import re

from xctest_checker.line import replace_offsets


def _actual_lines(path):
    """
    Returns a generator that yields each line in the file at the given path.
    """
    with open(path) as f:
        for line in f:
            yield line


def _expected_lines(path, check_prefix):
    """
    Returns a generator that yields each line in the file at the given path
    that begins with the given prefix.
    """
    with open(path) as f:
        for line_number, line in enumerate(f):
            components = line.split(check_prefix)
            if len(components) == 2:
                # Replace line keywords with line number. Note that line
                # numbers are not zero-indexed, so we add one.
                yield replace_offsets(components[1], line_number + 1)
            elif len(components) > 2:
                raise ValueError(
                    'Usage violation: prefix "{}" appears twice in the same '
                    'line.'.format(check_prefix))


def compare(actual, expected, check_prefix):
    """
    Compares each line in the two given files.
    If any line in the 'actual' file doesn't match the regex in the 'expected'
    file, raises an AssertionError. Also raises an AssertionError if the number
    of lines in the two files differ.
    """
    for actual_line, expected_line in map(
            None,
            _actual_lines(actual),
            _expected_lines(expected, check_prefix)):
        if actual_line is None:
            raise AssertionError('There were more lines expected to appear '
                                 'than there were lines in the actual input.')
        if expected_line is None:
            raise AssertionError('There were more lines than expected to '
                                 'appear.')
        if not re.match(expected_line, actual_line):
            raise AssertionError('Actual line did not match the expected '
                                 'regular expression.\n'
                                 'Actual: {}\n'
                                 'Expected: {}\n'.format(
                                     repr(actual_line), repr(expected_line)))
