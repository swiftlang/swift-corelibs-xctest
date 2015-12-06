#!/usr/bin/python

import glob
import os
import re
import subprocess
import unittest


# swift-corelibs-xctest/Tests/
TESTS_DIR = os.path.dirname(__file__)
# swift-corelibs-xctest/Tests/Fixtures/
FIXTURES_DIR = os.path.join(TESTS_DIR, 'Fixtures')
# swift-corelibs-xctest/Tests/Fixtures/Products/
PRODUCTS_DIR = os.path.join(FIXTURES_DIR, 'Products')
# swift-corelibs-xctest/Tests/Fixtures/Sources/
SOURCES_DIR = os.path.join(FIXTURES_DIR, 'Sources')

# The failure message template for fixture test exit status.
FIXTURE_TEST_CASE_EXIT_FAILURE_MESSAGE = "Executing the test '{0}' was expected to return exit status '{1}', but actually returned '{2}'."

# The failure message template for fixture test output.
FIXTURE_TEST_CASE_OUTPUT_FAILURE_MESSAGE = """Executing the test '{0}' did not produce the expected output.

EXPECTED
--------
{1}

ACTUAL
------
{2}
"""


def replace_decimals_with_ignored(string):
    """
    Replaces all decimal numbers in the input string with a
    token signifying they should be ignored.
    """
    return re.sub(r'\d+\.\d+', '%ignored-time-duration', string)


def read_expected_output(source_file):
    """
    Opens a Swift file at the given path and concatenates all
    source code comments. Tokens in the file, such as '%file',
    are replaced with substitution values.
    """
    expected_exit_status = 0
    expected_output_string = ""
    with open(source_file) as f:
        for line in f:
            if line.startswith('// %exit-status: '):
                expected_exit_status = int(line[17:])
            elif line.startswith('// '):
                line = line[3:]
                line = line.replace('%file', os.path.abspath(source_file))
                expected_output_string += line

    return (expected_exit_status, expected_output_string)


class FixtureTestCase(unittest.TestCase):
    """
    A parameterized test case for XCTest output. It takes the name of an
    XCTest functional test fixture as its argument, and verifies the output
    of running that fixture.
    """
    def __init__(self, fixture_name):
        """
        Initializes a parameterized test case for XCTest output, using the
        given fixture name.
        """
        super(FixtureTestCase, self).__init__('compare_stdout_to_source')
        self.fixture_name = fixture_name

    def compare_stdout_to_source(self):
        """
        This test method compares the output of an XCTest run to the expected
        output, which is to be encoded within the source file of the XCTest
        fixture as a source code comment.
        """
        # Execute the test fixture.
        # For example, if the fixture is named 'SingleFailingTestCase',
        # this executes Fixtures/Products/SingleFailingTestCase.
        executable_path = os.path.abspath(
            os.path.join(PRODUCTS_DIR, self.fixture_name))
        process = subprocess.Popen(
            [executable_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        # We capture both stdout and stderr, but we're only interested
        # in stdout.
        out, _ = process.communicate()

        # Read the expected output from the source file.
        # For example, if the fixture is named 'SingleFailingTestCase',
        # this reads Fixtures/Sources/SingleFailingTestCase/main.swift.
        source_file = os.path.join(
            SOURCES_DIR,
            self.fixture_name,
            'main.swift')
        expected_exit, expected_out = read_expected_output(source_file)

        # Compare the actual exit status to the expected status.
        # If no expected exit status is specified, assert the actual
        # status is '0'.
        self.assertEqual(
            process.returncode,
            expected_exit,
            msg=FIXTURE_TEST_CASE_EXIT_FAILURE_MESSAGE.format(
                executable_path,
                expected_exit,
                process.returncode))
        # Compare the actual execution to the expected output.
        # Convert all decimal numbers in the XCTest output to a token.
        sanitized_out = replace_decimals_with_ignored(out)
        self.assertEqual(
            sanitized_out,
            expected_out,
            msg=FIXTURE_TEST_CASE_OUTPUT_FAILURE_MESSAGE.format(
                executable_path,
                expected_out,
                sanitized_out))


# Conform to the load_tests protocol to customize which tests are run.
# See: https://docs.python.org/2/library/unittest.html#load-tests-protocol
#
# This function executes a FixtureTestCase for each executable in
# Tests/Fixtures/Products/. As such, those products need to be built prior
# to running the tests.
def load_tests(loader, tests, pattern):
    suite = unittest.TestSuite()
    products_glob_path = os.path.join(PRODUCTS_DIR, '*')
    product_path = None
    for product_path in glob.glob(products_glob_path):
        fixture_name = os.path.basename(product_path)
        test_case = FixtureTestCase(fixture_name)
        suite.addTest(test_case)

    if product_path is None:
        # If there are no files in Tests/Fixtures/Products/, something
        # is wrong.
        assert False, "{} does not contain any files.".format(
            products_glob_path)
    return suite


if __name__ == '__main__':
    unittest.main()
