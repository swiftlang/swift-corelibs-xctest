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
        with self.assertRaises(AssertionError):
            compare.compare(actual, expected, check_prefix='c: ')

    def test_too_few_expected_raises(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c: foo\nc: bar\n')
        with self.assertRaises(AssertionError):
            compare.compare(actual, expected, check_prefix='c: ')

    def test_too_many_expected_raises(self):
        actual = _tmpfile('foo\nbar\n')
        expected = _tmpfile('c: foo\nc: bar\nc: baz\n')
        with self.assertRaises(AssertionError):
            compare.compare(actual, expected, check_prefix='c: ')

    def test_match_does_not_raise(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c: foo\nc: bar\nc: baz\n')
        compare.compare(actual, expected, check_prefix='c: ')

    def test_match_with_inline_check_does_not_raise(self):
        actual = _tmpfile('bling\nblong\n')
        expected = _tmpfile('meep meep // c: bling\nmeep\n// c: blong\n')
        compare.compare(actual, expected, check_prefix='// c: ')

    def test_check_prefix_twice_in_the_same_line_raises(self):
        actual = _tmpfile('blorp\n')
        expected = _tmpfile('c: blorp c: blammo\n')
        with self.assertRaises(ValueError):
            compare.compare(actual, expected, check_prefix='c: ')


if __name__ == "__main__":
    unittest.main()
