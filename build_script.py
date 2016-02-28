#!/usr/bin/env python

# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#

import argparse
import glob
import os
import subprocess
import tempfile

SOURCE_DIR = os.path.dirname(os.path.abspath(__file__))

def note(msg):
    print("xctest-build: "+msg)

def run(command):
    note(command)
    subprocess.check_call(command, shell=True)

def main():
    parser = argparse.ArgumentParser(
        description="Builds XCTest using a Swift compiler.")
    parser.add_argument("--swiftc",
                        help="path to the swift compiler",
                        metavar="PATH",
                        required=True)
    parser.add_argument("--build-dir",
                        help="path to the output build directory. If not "
                             "specified, a temporary directory is used",
                        metavar="PATH",
                        default=tempfile.mkdtemp())
    parser.add_argument("--swift-build-dir", help="deprecated, do not use")
    parser.add_argument("--arch", help="deprecated, do not use")
    parser.add_argument("--module-install-path",
                        help="location to install module files",
                        metavar="PATH",
                        dest="module_path")
    parser.add_argument("--library-install-path",
                        help="location to install shared library files",
                        metavar="PATH",
                        dest="lib_path")
    parser.add_argument("--release",
                        help="builds for release",
                        action="store_const",
                        dest="build_style",
                        const="release",
                        default="debug")
    parser.add_argument("--debug",
                        help="builds for debug (the default)",
                        action="store_const",
                        dest="build_style",
                        const="debug",
                        default="debug")
    parser.add_argument("--test",
                        help="Whether to run tests after building. "
                             "Note that you must have cloned "
                             "https://github.com/apple/swift-llvm "
                             "at {} in order to run this command. ".format(
                                 os.path.join(
                                     os.path.dirname(SOURCE_DIR), 'llvm')),
                        action="store_true")
    args = parser.parse_args()

    swiftc = os.path.abspath(args.swiftc)
    build_dir = os.path.abspath(args.build_dir)

    if not os.path.exists(build_dir):
        run("mkdir -p {}".format(build_dir))

    sourcePaths = glob.glob(os.path.join(
        SOURCE_DIR, 'Sources', 'XCTest', '*.swift'))

    if args.build_style == "debug":
        style_options = "-g"
    else:
        style_options = "-O"

    # Not incremental..
    # Build library
    run("{0} -c {1} -emit-object {2} -module-name XCTest -parse-as-library -emit-module "
        "-emit-module-path {3}/XCTest.swiftmodule -o {3}/XCTest.o -force-single-frontend-invocation "
        "-module-link-name XCTest".format(swiftc, style_options, " ".join(sourcePaths), build_dir))
    run("{0} -emit-library {1}/XCTest.o -o {1}/libXCTest.so -lswiftGlibc -lswiftCore -lm".format(swiftc, build_dir))

    # If we were given an install directive, perform installation
    if args.module_path is not None and args.lib_path is not None:
        module_path = os.path.abspath(args.module_path)
        lib_path = os.path.abspath(args.lib_path)
        run("mkdir -p {}".format(module_path))
        run("mkdir -p {}".format(lib_path))

        note("Performing installation into {} and {}".format(module_path, lib_path))

        install_lib = "libXCTest.so"
        install_mod_doc = "XCTest.swiftdoc"
        install_mod = "XCTest.swiftmodule"

        # These paths should have been created for us, unless we need to create new substructure.
        cmd = ['cp', os.path.join(build_dir, install_lib), os.path.join(lib_path, install_lib)]
        subprocess.check_call(cmd)

        cmd = ['cp', os.path.join(build_dir, install_mod), os.path.join(module_path, install_mod)]
        subprocess.check_call(cmd)
        cmd = ['cp', os.path.join(build_dir, install_mod_doc), os.path.join(module_path, install_mod_doc)]
        subprocess.check_call(cmd)

    if args.test:
        lit_path = os.path.join(
            os.path.dirname(SOURCE_DIR), 'llvm', 'utils', 'lit', 'lit.py')
        lit_flags = '-sv --no-progress-bar'
        tests_path = os.path.join(SOURCE_DIR, 'Tests', 'Functional')
        run('SWIFT_EXEC={swiftc} '
            'BUILT_PRODUCTS_DIR={built_products_dir} '
            '{lit_path} {lit_flags} '
            '{tests_path}'.format(swiftc=swiftc,
                                  built_products_dir=build_dir,
                                  lit_path=lit_path,
                                  lit_flags=lit_flags,
                                  tests_path=tests_path))

    note('Done.')

if __name__ == '__main__':
    main()
