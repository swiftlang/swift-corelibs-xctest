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

    def test_includes_file_name_and_line_of_expected_in_error(self):
        actual = _tmpfile('foo\nbar\nbaz\n')
        expected = _tmpfile('c: foo\nc: baz\nc: bar\n')
        with self.assertRaises(AssertionError) as cm:
            compare.compare(actual, expected, check_prefix='c: ')

        self.assertIn("{}:{}:".format(expected, 2), cm.exception.message)

if __name__ == "__main__":
    unittest.main()
