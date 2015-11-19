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

import os, subprocess, argparse

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
                        default=None)
    parser.add_argument("--build-dir",
                        help="path to the output build directory",
                        metavar="PATH",
                        action="store",
                        dest="build_dir",
                        default=None)
    parser.add_argument("--swift-build-dir",
                        help="path to the swift build directory",
                        metavar="PATH",
                        action="store",
                        dest="swift_build_dir",
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
    args = parser.parse_args()

    assert args.swiftc is not None
    swiftc = os.path.abspath(args.swiftc)
    
    assert args.build_dir is not None
    build_dir = os.path.abspath(args.build_dir)
    
    assert args.swift_build_dir is not None
    swift_build_dir = os.path.abspath(args.swift_build_dir)
    
    if not os.path.exists(build_dir):
        run("mkdir -p {}".format(build_dir))

    # Not incremental..
    run("{0} -c -O -emit-object {1}/XCTest/XCTest.swift -module-name XCTest -parse-as-library -emit-module "
        "-emit-module-path {2}/XCTest.swiftmodule -o {2}/XCTest.o -force-single-frontend-invocation "
        "-module-link-name XCTest".format(swiftc, os.path.dirname(os.path.abspath(__file__)), build_dir))

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

    
    note('Done.')

if __name__ == '__main__':
    main()
