# test_compare.py - Unit tests for xctest_checker.compare -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import tempfile
import unittest

from xctest_checker import compare
from xctest_checker.error import XCTestCheckerError


def _tmpfile(content):
    """Returns the path to a temp file with the given contents."""
    tmp = tempfile.mkstemp()[1]
    with open(tmp, 'w') as f:
        f.write(content)
    return tmp


class CompareTestCase(unittest.TestCase):
    def test_no_match_raises(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c: foo\nc: baz\nc: bar\n')
        with self.assertRaises(XCTestCheckerError):
            compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

    def test_too_few_expected_raises_and_first_line_in_error(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c: foo\nc: bar\n')
        with self.assertRaises(XCTestCheckerError) as cm:
            compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

        self.assertIn('{}:{}'.format(expected, 1), cm.exception.message)

    def test_too_many_expected_raises_and_excess_check_line_in_error(self):
        actual = _tmpfile('foo\nbar\n')
        expected = _tmpfile('c: foo\nc: bar\nc: baz\n')
        with self.assertRaises(XCTestCheckerError) as cm:
            compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

        self.assertIn('{}:{}'.format(expected, 3), cm.exception.message)

    def test_match_does_not_raise(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c: foo\nc: bar\nc: baz\n')
        compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

    def test_match_with_inline_check_does_not_raise(self):
        actual = _tmpfile('bling\nblong\n')
        expected = _tmpfile('meep meep // c: bling\nmeep\n// c: blong\n')
        compare.compare(open(actual, 'r'), expected, check_prefix='// c: ')

    def test_check_prefix_twice_in_the_same_line_raises_with_line(self):
        actual = _tmpfile('blorp\nbleep\n')
        expected = _tmpfile('c: blorp\nc: bleep c: blammo\n')
        with self.assertRaises(XCTestCheckerError) as cm:
            compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

        self.assertIn('{}:{}'.format(expected, 2), cm.exception.message)

    def test_check_prefix_in_run_line_ignored(self):
        actual = _tmpfile('flim\n')
        expected = _tmpfile('// RUN: xctest_checker --prefix "c: "\nc: flim\n')
        compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

    def test_includes_file_name_and_line_of_expected_in_error(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c: foo\nc: baz\nc: bar\n')
        with self.assertRaises(XCTestCheckerError) as cm:
            compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

        self.assertIn("{}:{}:".format(expected, 2), cm.exception.message)

    def test_matching_ignores_leading_and_trailing_whitespace(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c:  foo\nc: bar \nc: baz\n')
        compare.compare(open(actual, 'r'), expected, check_prefix='c:')

    def test_can_explicitly_match_leading_and_trailing_whitespace(self):
        actual = _tmpfile('foo\n bar\nbaz \n')
        expected = _tmpfile('c: foo\nc: ^ bar \nc: baz $\n')
        compare.compare(open(actual, 'r'), expected, check_prefix='c:')

    def test_line_number_substitution(self):
        actual = _tmpfile('beep 1\nboop 5\n')
        expected = _tmpfile('c: beep [[@LINE]]\nc: boop [[@LINE+3]]')
        compare.compare(open(actual, 'r'), expected, check_prefix='c: ')

if __name__ == "__main__":
    unittest.main()
