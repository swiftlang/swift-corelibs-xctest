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
import sys
import tempfile

SOURCE_DIR = os.path.dirname(os.path.abspath(__file__))

def note(msg):
    print("xctest-build: "+msg)

def run(command):
    note(command)
    subprocess.check_call(command, shell=True)

def library_sources():
    return glob.glob(os.path.join(SOURCE_DIR, 'Sources', 'XCTest', '*.swift'))

def unit_test_sources():
    return glob.glob(os.path.join(SOURCE_DIR, 'Tests', 'Unit', '*.swift'))

def _build(args):
    """
    Build XCTest and place the built products in the given 'build_dir'.
    If 'test' is specified, also executes the 'test' subcommand.
    """
    swiftc = os.path.abspath(args.swiftc)
    build_dir = os.path.abspath(args.build_dir)

    if not os.path.exists(build_dir):
        run("mkdir -p {}".format(build_dir))

    if args.build_style == "debug":
        style_options = "-g"
    else:
        style_options = "-O"

    # Not incremental..
    # Build library
    run("{0} -c {1} -emit-object {2} -module-name XCTest -parse-as-library -emit-module "
        "-emit-module-path {3}/XCTest.swiftmodule -o {3}/XCTest.o -force-single-frontend-invocation "
        "-module-link-name XCTest".format(swiftc, style_options, " ".join(library_sources()), build_dir))
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
        # Execute main() using the arguments necessary to run the tests.
        main(args=["test", "--swiftc", swiftc, build_dir])

    note('Done.')


def run_unit_tests(args):
    note('Building unit tests')
    # FIXME: This rebuilds the library sources into the unit test executable instead
    #        of using the pre-built library in the build_dir, because the unit tests
    #        need access to internal symbols, but the library isn't compiled with testability
    run("{swiftc} -o {build_dir}/SwiftXCTestUnitTests "
        "{sources}".format(swiftc=os.path.abspath(args.swiftc),
                           build_dir=os.path.abspath(args.build_dir),
                           sources=" ".join(unit_test_sources()+library_sources())))

    note('Running unit tests')
    run("{0}/SwiftXCTestUnitTests".format(args.build_dir))

def run_functional_tests(args):
    note('Running functional tests')

    # FIXME: Allow path to lit to be specified as an option, with this
    #        path as a default.
    lit_path = os.path.join(
        os.path.dirname(SOURCE_DIR), "llvm", "utils", "lit", "lit.py")
    # FIXME: Allow these to be specified by the Swift build script.
    lit_flags = "-sv --no-progress-bar"
    tests_path = os.path.join(SOURCE_DIR, "Tests", "Functional")
    run("SWIFT_EXEC={swiftc} "
        "BUILT_PRODUCTS_DIR={build_dir} "
        "{lit_path} {lit_flags} "
        "{tests_path}".format(swiftc=args.swiftc,
                              build_dir=args.build_dir,
                              lit_path=lit_path,
                              lit_flags=lit_flags,
                              tests_path=tests_path))

def _test(args):
    """
    Build and run unit tests, and run functional tests against the built XCTest.so
    library at the given 'build_dir', using the given 'swiftc' compiler.
    """
    run_unit_tests(args)
    run_functional_tests(args)

def main(args=sys.argv[1:]):
    """
    The main entry point for this script. Based on the subcommand given,
    delegates building or testing XCTest to a sub-parser and its corresponding
    function.
    """
    parser = argparse.ArgumentParser(
        description="Builds, tests, and installs XCTest.")
    subparsers = parser.add_subparsers(
        description="Use one of these to specify whether to build, test, "
                    "or install XCTest. If you don't specify any of these, "
                    "'build' is executed as a default. You may also use "
                    "'build' to also test and install the built products. "
                    "Pass the -h or --help option to any of the subcommands "
                    "for more information.")

    build_parser = subparsers.add_parser(
        "build",
        description="Build XCTest.so, XCTest.swiftmodule, and XCTest.swiftdoc "
                    "using the given Swift compiler. This command may also "
                    "test and install the built products.")
    build_parser.set_defaults(func=_build)
    build_parser.add_argument(
        "--swiftc",
        help="Path to the 'swiftc' compiler that will be used to build "
             "XCTest.so, XCTest.swiftmodule, and XCTest.swiftdoc. This will "
             "also be used to build the tests for those built products if the "
             "--test option is specified.",
        metavar="PATH",
        required=True)
    build_parser.add_argument(
        "--build-dir",
        help="Path to the output build directory. If not specified, a "
             "temporary directory is used",
        metavar="PATH",
        default=tempfile.mkdtemp())
    build_parser.add_argument("--swift-build-dir",
                              help="deprecated, do not use")
    build_parser.add_argument("--arch", help="deprecated, do not use")
    build_parser.add_argument(
        "--module-install-path",
        help="Location at which to install XCTest.swiftmodule and "
             "XCTest.swiftdoc. This directory will be created if it doesn't "
             "already exist.",
        dest="module_path")
    build_parser.add_argument(
        "--library-install-path",
        help="Location at which to install XCTest.so. This directory will be "
             "created if it doesn't already exist.",
        dest="lib_path")
    build_parser.add_argument(
        "--release",
        help="builds for release",
        action="store_const",
        dest="build_style",
        const="release",
        default="debug")
    build_parser.add_argument(
        "--debug",
        help="builds for debug (the default)",
        action="store_const",
        dest="build_style",
        const="debug",
        default="debug")
    build_parser.add_argument(
        "--test",
        help="Whether to run tests after building. Note that you must have "
             "cloned https://github.com/apple/swift-llvm at {} in order to "
             "run this command.".format(os.path.join(
                 os.path.dirname(SOURCE_DIR), 'llvm')),
        action="store_true")

    test_parser = subparsers.add_parser(
        "test",
        description="Tests a built XCTest framework at the given path.")
    test_parser.set_defaults(func=_test)
    test_parser.add_argument(
        "build_dir",
        help="An absolute path to a directory containing the built XCTest.so "
             "library.",
        metavar="PATH")
    test_parser.add_argument(
        "--swiftc",
        help="Path to the 'swiftc' compiler used to build and run the tests.",
        required=True)

    # Many versions of Python require a subcommand must be specified.
    # We handle this here: if no known subcommand (or none of the help options)
    # is included in the arguments, then insert the default subcommand
    # argument.
    if any([a in ["build", "test", "-h", "--help"] for a in args]):
        parsed_args = parser.parse_args(args=args)
    else:
        parsed_args = parser.parse_args(args=["build"] + args)

    # Execute the function for the subcommand we've been given.
    parsed_args.func(parsed_args)


if __name__ == '__main__':
    main()
