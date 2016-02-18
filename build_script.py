#!/usr/bin/env python

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

import os, subprocess, argparse

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
                        action="store_true",
                        dest="test",
                        default=False)
    parser.add_argument("--arch",
                        help="target architecture",
                        action="store",
                        dest="arch",
                        default=None)
    args = parser.parse_args()

    swiftc = os.path.abspath(args.swiftc)
    build_dir = os.path.abspath(args.build_dir)
    swift_build_dir = os.path.abspath(args.swift_build_dir)
    arch = args.arch

    if not os.path.exists(build_dir):
        run("mkdir -p {}".format(build_dir))

    sourceFiles = [
                   "XCTAssert.swift",
                   "XCTestCaseProvider.swift",
                   "XCTestCase.swift",
                   "XCTimeUtilities.swift",
                   "XCTestMain.swift",
                  ]
    sourcePaths = []
    for file in sourceFiles:
        sourcePaths.append("{0}/Sources/XCTest/{1}".format(SOURCE_DIR, file))


    if args.build_style == "debug":
        style_options = "-g"
    else:
        style_options = "-O"

    # Not incremental..
    # Build library
    run("{0} -c {1} -emit-object {2} -module-name XCTest -parse-as-library -emit-module "
        "-emit-module-path {3}/XCTest.swiftmodule -o {3}/XCTest.o -force-single-frontend-invocation "
        "-module-link-name XCTest".format(swiftc, style_options, " ".join(sourcePaths), build_dir))
    run("clang {1}/lib/swift/linux/{2}/swift_begin.o {0}/XCTest.o {1}/lib/swift/linux/{2}/swift_end.o -shared -o {0}/libXCTest.so -Wl,--no-undefined -Wl,-soname,libXCTest.so -L{1}/lib/swift/linux/ -lswiftGlibc -lswiftCore -lm".format(build_dir, swift_build_dir, arch))

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
