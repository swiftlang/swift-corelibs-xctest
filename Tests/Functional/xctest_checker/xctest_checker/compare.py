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

from .error import XCTestCheckerError
from .line import replace_offsets


def _actual_lines(file_handle):
    """
    Returns a generator that yields each line in the file.
    """
    for line in file_handle:
        yield line


def _expected_lines_and_line_numbers(path, check_prefix):
    """
    Returns a generator that yields each line in the file at the given path
    that begins with the given prefix.
    """
    with open(path) as f:
        for index, line in enumerate(f):
            if 'RUN:' in line:
                # Ignore lit directives, which may include a call to
                # xctest_checker that specifies a check prefix.
                continue

            # Note that line numbers are not zero-indexed; we must add one to
            # the loop index.
            line_number = index + 1

            components = line.split(check_prefix)
            if len(components) == 2:
                yield (replace_offsets(components[1].strip(), line_number),
                       line_number)
            elif len(components) > 2:
                # Include a newline, then the file name and line number in the
                # exception in order to have it appear as an inline failure in
                # Xcode.
                raise XCTestCheckerError(
                    path, line_number,
                    'Usage violation: prefix "{}" appears twice in the same '
                    'line.'.format(check_prefix))


def _add_whitespace_leniency(original_regex):
    return "^ *" + original_regex + " *$"


def compare(actual, expected, check_prefix):
    """
    Compares each line in the two given files.
    If any line in the 'actual' file doesn't match the regex in the 'expected'
    file, raises an AssertionError. Also raises an AssertionError if the number
    of lines in the two files differ.
    """
    for actual_line, expected_line_and_number in map(
            None,
            _actual_lines(actual),
            _expected_lines_and_line_numbers(expected, check_prefix)):

        if expected_line_and_number is None:
            raise XCTestCheckerError(
                expected, 1,
                'The actual output contained more lines of text than the '
                'expected output. First unexpected line: {}'.format(
                    repr(actual_line)))

        (expected_line, expectation_line_number) = expected_line_and_number

        if actual_line is None:
            raise XCTestCheckerError(
                expected, expectation_line_number,
                'There were more lines expected to appear than there were '
                'lines in the actual input. Unmet expectation: {}'.format(
                    repr(expected_line)))

        if not re.match(_add_whitespace_leniency(expected_line), actual_line):
            raise XCTestCheckerError(
                expected, expectation_line_number,
                'Actual line did not match the expected regular expression.\n'
                'Actual: {}\nExpected: {}'.format(
                    repr(actual_line), repr(expected_line)))
