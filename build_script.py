#!/usr/bin/python

# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#

# Here is a nice way to invoke this script if you are building locally, and Swift is installed at /, and you want to install XCTest back there
# sudo ./build_script.py --swiftc="/usr/bin/swiftc" --build-dir="/tmp/XCTest_build" --swift-build-dir="/usr" --library-install-path="/usr/lib/swift/linux" --module-install-path="/usr/lib/swift/linux/x86_64"

import argparse
import glob
import os
import subprocess

SOURCE_DIR = os.path.dirname(os.path.abspath(__file__))

def note(msg):
    print("xctest-build: "+msg)

def run(command):
    note(command)
    subprocess.check_call(command, shell=True)

def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="""Builds XCTest using a swift compiler.""")
    parser.add_argument("--swiftc",
                        help="path to the swift compiler",
                        metavar="PATH",
                        action="store",
                        dest="swiftc",
                        required=True,
                        default=None)
    parser.add_argument("--build-dir",
                        help="path to the output build directory",
                        metavar="PATH",
                        action="store",
                        dest="build_dir",
                        required=True,
                        default=None)
    parser.add_argument("--swift-build-dir",
                        help="path to the swift build directory",
                        metavar="PATH",
                        action="store",
                        dest="swift_build_dir",
                        required=True,
                        default=None)
    parser.add_argument("--module-install-path",
                        help="location to install module files",
                        metavar="PATH",
                        action="store",
                        dest="module_path",
                        default=None)
    parser.add_argument("--library-install-path",
                        help="location to install shared library files",
                        metavar="PATH",
                        action="store",
                        dest="lib_path",
                        default=None)
    parser.add_argument("--test",
                        help="whether to run tests after building",
                        action="store_true",
                        dest="test",
                        default=False)
    args = parser.parse_args()

    swiftc = os.path.abspath(args.swiftc)
    build_dir = os.path.abspath(args.build_dir)
    swift_build_dir = os.path.abspath(args.swift_build_dir)
    
    if not os.path.exists(build_dir):
        run("mkdir -p {}".format(build_dir))

    # Not incremental..
    run("{0} -c -O -emit-object {1}/XCTest/XCTest.swift -module-name XCTest -parse-as-library -emit-module "
        "-emit-module-path {2}/XCTest.swiftmodule -o {2}/XCTest.o -force-single-frontend-invocation "
        "-module-link-name XCTest".format(swiftc, SOURCE_DIR, build_dir))

    run("clang {0}/XCTest.o -shared -o {0}/libXCTest.so -Wl,--no-undefined -Wl,-soname,libXCTest.so -L{1}/lib/swift/linux/ -lswiftGlibc -lswiftCore -lm".format(build_dir, swift_build_dir))

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
        # 1. We first compile every test fixture in Tests/Fixtures/Sources/.
        #    The compiled executables are stored in Tests/Fixtures/Products/.
        fixtures_dir = os.path.join(SOURCE_DIR, 'Tests', 'Fixtures')
        fixture_products_dir = os.path.join(fixtures_dir, 'Products')
        fixture_sources_glob_dir = os.path.join(fixtures_dir, 'Sources', '*')
        for fixture_source_dir in glob.glob(fixture_sources_glob_dir):
            # Loop over every main.swift file in Tests/Fixtures/Sources/
            # and compile it using swiftc. The executables are output to
            # Tests/Fixtures/Products/.
            fixture_source = os.path.join(fixture_source_dir, 'main.swift')
            dest = os.path.join(
                fixture_products_dir,
                os.path.basename(fixture_source_dir))
            run("{0} {1} -o {2}".format(swiftc, fixture_source, dest))

        # 2. Tests/test.py is used across all platforms. It runs each
        #    executable in Tests/Fixtures/Products/, comparing their
        #    output to the annotated main.swift files.
        run(os.path.join(SOURCE_DIR, 'Tests', 'test.py'))

    note('Done.')

if __name__ == '__main__':
    main()
