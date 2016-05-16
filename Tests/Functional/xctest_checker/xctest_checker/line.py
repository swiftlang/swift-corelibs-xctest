# xctest_checker/line.py - Replaces [[@LINE]] with line numbers -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import re


def replace_offsets(line, line_number):
    """
    Replace all line directives in the given line with the given line number.

    Line directives come in two forms:
    1. "[[@LINE]]", with no offset.
    2. "[[@LINE+10]]" or "[[@LINE-3]]", with a positive or negative offset.
    """
    pattern = re.compile(r'\[\[@LINE(?P<offset>[+-]\d+)?\]\]')

    result = line
    for match in pattern.finditer(line):
        offset_string = match.groupdict()['offset']
        if offset_string is None:
            offset_string = '0'
        try:
            offset = int(offset_string)
        except ValueError:
            # Re-raise the error, but with a friendlier explanation of what
            # went wrong.
            raise ValueError(
                'Invalid line offset: "{}". Line offsets must be numerical, '
                'such as "[[@LINE+10]]" or "[[@LINE-2]]"'.format(
                    match.group()))
        result = result.replace(match.group(), str(line_number + offset))

    return result

