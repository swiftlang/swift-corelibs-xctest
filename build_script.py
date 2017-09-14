#!/usr/bin/env python
# build_script.py - Build, install, and test XCTest -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import argparse
import fnmatch
import os
import subprocess
import sys
import tempfile
import textwrap
import platform
import errno

SOURCE_DIR = os.path.dirname(os.path.abspath(__file__))


def note(msg):
    print("xctest-build: "+msg)


def run(command):
    note(command)
    subprocess.check_call(command, shell=True)


def _mkdirp(path):
    """
    Creates a directory at the given path if it doesn't already exist.
    """
    if not os.path.exists(path):
        run("mkdir -p {}".format(path))


def _find_files_with_extension(path, extension):
    """
    In Python 3.5 and above, glob supports recursive patterns such as
    '**/*.swift'. This function backports that functionality to Python 3.4
    and below.
    """
    paths = []
    for root, _, file_names in os.walk(path):
        for file_name in fnmatch.filter(file_names, '*.{}'.format(extension)):
            paths.append(os.path.join(root, file_name))
    return paths


def symlink_force(target, link_name):
    if os.path.isdir(link_name):
        link_name = os.path.join(link_name, os.path.basename(target))
    try:
        os.symlink(target, link_name)
    except OSError as e:
        if e.errno == errno.EEXIST:
            os.remove(link_name)
            os.symlink(target, link_name)
        else:
            raise e

class DarwinStrategy:
    @staticmethod
    def requires_foundation_build_dir():
        # The Foundation build directory is not required on Darwin because the
        # Xcode workspace implicitly builds Foundation when building the XCTest
        # schemes.
        return False

    @staticmethod
    def build(args):
        """
        Build XCTest and place the built products in the given 'build_dir'.
        If 'test' is specified, also executes the 'test' subcommand.
        """
        swiftc = os.path.abspath(args.swiftc)
        build_dir = os.path.abspath(args.build_dir)

        if args.build_style == "debug":
            style_options = "Debug"
        else:
            style_options = "Release"

        run("xcodebuild -workspace {source_dir}/XCTest.xcworkspace "
            "-scheme SwiftXCTest "
            "-configuration {style_options} "
            "SWIFT_EXEC=\"{swiftc}\" "
            "SWIFT_LINK_OBJC_RUNTIME=YES "
            "INDEX_ENABLE_DATA_STORE=NO "
            "SYMROOT=\"{build_dir}\" OBJROOT=\"{build_dir}\"".format(
                swiftc=swiftc,
                build_dir=build_dir,
                style_options=style_options,
                source_dir=SOURCE_DIR))

        if args.test:
            # Execute main() using the arguments necessary to run the tests.
            main(args=["test",
                       "--swiftc", swiftc,
                       build_dir])

    @staticmethod
    def test(args):
        """
        Test SwiftXCTest.framework, using the given 'swiftc' compiler, looking
        for it in the given 'build_dir'.
        """
        swiftc = os.path.abspath(args.swiftc)
        build_dir = os.path.abspath(args.build_dir)

        if args.build_style == "debug":
            style_options = "Debug"
        else:
            style_options = "Release"

        run("xcodebuild -workspace {source_dir}/XCTest.xcworkspace "
            "-scheme SwiftXCTestFunctionalTests "
            "-configuration {style_options} "
            "SWIFT_EXEC=\"{swiftc}\" "
            "SWIFT_LINK_OBJC_RUNTIME=YES "
            "INDEX_ENABLE_DATA_STORE=NO "
            "SYMROOT=\"{build_dir}\" OBJROOT=\"{build_dir}\" ".format(
                swiftc=swiftc,
                build_dir=build_dir,
                style_options=style_options,
                source_dir=SOURCE_DIR))

    @staticmethod
    def install(args):
        """
        Installing XCTest is not supported on Darwin.
        """
        note("error: The install command is not supported on this platform")
        exit(1)


class GenericUnixStrategy:
    @staticmethod
    def requires_foundation_build_dir():
        # This script does not know how to build Foundation in Unix environments,
        # so we need the path to a pre-built Foundation library.
        return True

    @staticmethod
    def build(args):
        """
        Build XCTest and place the built products in the given 'build_dir'.
        If 'test' is specified, also executes the 'test' subcommand.
        """
        swiftc = os.path.abspath(args.swiftc)
        build_dir = os.path.abspath(args.build_dir)
        static_lib_build_dir = GenericUnixStrategy.static_lib_build_dir(build_dir)
        foundation_build_dir = os.path.abspath(args.foundation_build_dir)
        core_foundation_build_dir = GenericUnixStrategy.core_foundation_build_dir(
            foundation_build_dir, args.foundation_install_prefix)
        if args.libdispatch_build_dir:
            libdispatch_build_dir = os.path.abspath(args.libdispatch_build_dir)
        if args.libdispatch_src_dir:
            libdispatch_src_dir = os.path.abspath(args.libdispatch_src_dir)

        _mkdirp(build_dir)

        sourcePaths = _find_files_with_extension(
                os.path.join(SOURCE_DIR, 'Sources', 'XCTest'),
                'swift')

        if args.build_style == "debug":
            style_options = "-g"
        else:
            style_options = "-O"

        # Not incremental..
        # Build library
        if args.libdispatch_build_dir and args.libdispatch_src_dir:
            libdispatch_args = "-I {libdispatch_build_dir}/src -I {libdispatch_src_dir} ".format(
                libdispatch_build_dir=libdispatch_build_dir,
                libdispatch_src_dir=libdispatch_src_dir)
        else:
            libdispatch_args = ""

        # NOTE: Force -swift-version 4 to build XCTest sources.
        run("{swiftc} -Xcc -fblocks -c {style_options} -emit-object -emit-module "
            "-module-name XCTest -module-link-name XCTest -parse-as-library "
            "-emit-module-path {build_dir}/XCTest.swiftmodule "
            "-force-single-frontend-invocation "
            "-swift-version 4 "
            "-I {foundation_build_dir} -I {core_foundation_build_dir} "
            "{libdispatch_args} "
            "{source_paths} -o {build_dir}/XCTest.o".format(
                swiftc=swiftc,
                style_options=style_options,
                build_dir=build_dir,
                foundation_build_dir=foundation_build_dir,
                core_foundation_build_dir=core_foundation_build_dir,
                libdispatch_args=libdispatch_args,
                source_paths=" ".join(sourcePaths)))
        run("{swiftc} -emit-library {build_dir}/XCTest.o "
            "-L {dispatch_build_dir} -L {foundation_build_dir} -lswiftGlibc -lswiftCore -lFoundation -lm "
            # We embed an rpath of `$ORIGIN` to ensure other referenced
            # libraries (like `Foundation`) can be found solely via XCTest.
            "-Xlinker -rpath=\\$ORIGIN "
            "-o {build_dir}/libXCTest.so".format(
                swiftc=swiftc,
                build_dir=build_dir,
                dispatch_build_dir=os.path.join(args.libdispatch_build_dir, 'src', '.libs'),
                foundation_build_dir=foundation_build_dir))

        # Build the static library.
        run("mkdir -p {static_lib_build_dir}".format(static_lib_build_dir=static_lib_build_dir))
        run("ar rcs {static_lib_build_dir}/libXCTest.a {build_dir}/XCTest.o".format(
            static_lib_build_dir=static_lib_build_dir,
            build_dir=build_dir))

        if args.test:
            # Execute main() using the arguments necessary to run the tests.
            main(args=["test",
                       "--swiftc", swiftc,
                       "--foundation-build-dir", foundation_build_dir,
                       build_dir])

        # If --module-install-path and --library-install-path were specified,
        # we also install the built XCTest products.
        if args.module_path is not None and args.lib_path is not None:
            # Execute main() using the arguments necessary for installation.
            install_args = ["install", build_dir,
                       "--module-install-path", args.module_path,
                       "--library-install-path", args.lib_path]
            if args.static_lib_path:
                       install_args += ["--static-library-install-path",
                           args.static_lib_path]
            main(args=install_args)

        note('Done.')

    @staticmethod
    def test(args):
        """
        Test the built XCTest.so library at the given 'build_dir', using the
        given 'swiftc' compiler.
        """
        lit_path = os.path.abspath(args.lit)
        if not os.path.exists(lit_path):
            raise IOError(
                'Could not find lit tester tool at path: "{}". This tool is '
                'requred to run the test suite. Unless you specified a custom '
                'path to the tool using the "--lit" option, the lit tool will be '
                'found in the LLVM source tree, which is expected to be checked '
                'out in the same directory as swift-corelibs-xctest. If you do '
                'not have LLVM checked out at this path, you may follow the '
                'instructions for "Getting Sources for Swift and Related '
                'Projects" from the Swift project README in order to fix this '
                'error.'.format(lit_path))

        # FIXME: Allow these to be specified by the Swift build script.
        lit_flags = "-sv --no-progress-bar"
        tests_path = os.path.join(SOURCE_DIR, "Tests", "Functional")
        foundation_build_dir = os.path.abspath(args.foundation_build_dir)
        core_foundation_build_dir = GenericUnixStrategy.core_foundation_build_dir(
            foundation_build_dir, args.foundation_install_prefix)
        if args.libdispatch_build_dir:
            libdispatch_build_dir = os.path.abspath(args.libdispatch_build_dir)
            symlink_force(os.path.join(args.libdispatch_build_dir, "src", ".libs", "libdispatch.so"),
                foundation_build_dir)
        if args.libdispatch_src_dir and args.libdispatch_build_dir:
            libdispatch_src_args = ( 
               "LIBDISPATCH_SRC_DIR={libdispatch_src_dir} "
               "LIBDISPATCH_BUILD_DIR={libdispatch_build_dir} "
               "LIBDISPATCH_OVERLAY_DIR={libdispatch_overlay_dir}".format(
                   libdispatch_src_dir=os.path.abspath(args.libdispatch_src_dir),
                   libdispatch_build_dir=os.path.join(args.libdispatch_build_dir, 'src', '.libs'),
                   libdispatch_overlay_dir=os.path.join(args.libdispatch_build_dir, 'src', 'swift')))
        else:
            libdispatch_src_args = ""

        run('SWIFT_EXEC={swiftc} '
            'BUILT_PRODUCTS_DIR={built_products_dir} '
            'FOUNDATION_BUILT_PRODUCTS_DIR={foundation_build_dir} '
            'CORE_FOUNDATION_BUILT_PRODUCTS_DIR={core_foundation_build_dir} '
            '{libdispatch_src_args} '
            '{lit_path} {lit_flags} '
            '{tests_path}'.format(
                swiftc=os.path.abspath(args.swiftc),
                built_products_dir=args.build_dir,
                foundation_build_dir=foundation_build_dir,
                core_foundation_build_dir=core_foundation_build_dir,
                libdispatch_src_args=libdispatch_src_args,
                lit_path=lit_path,
                lit_flags=lit_flags,
                tests_path=tests_path))

    @staticmethod
    def install(args):
        """
        Install the XCTest.so, XCTest.swiftmodule, and XCTest.swiftdoc build
        products into the given module and library paths.
        """
        build_dir = os.path.abspath(args.build_dir)
        static_lib_build_dir = GenericUnixStrategy.static_lib_build_dir(build_dir)
        module_install_path = os.path.abspath(args.module_install_path)
        library_install_path = os.path.abspath(args.library_install_path)

        _mkdirp(module_install_path)
        _mkdirp(library_install_path)

        xctest_so = "libXCTest.so"
        run("cp {} {}".format(
            os.path.join(build_dir, xctest_so),
            os.path.join(library_install_path, xctest_so)))

        xctest_swiftmodule = "XCTest.swiftmodule"
        run("cp {} {}".format(
            os.path.join(build_dir, xctest_swiftmodule),
            os.path.join(module_install_path, xctest_swiftmodule)))

        xctest_swiftdoc = "XCTest.swiftdoc"
        run("cp {} {}".format(
            os.path.join(build_dir, xctest_swiftdoc),
            os.path.join(module_install_path, xctest_swiftdoc)))

        if args.static_library_install_path:
               static_library_install_path = os.path.abspath(args.static_library_install_path)
               _mkdirp(static_library_install_path)
               xctest_a = "libXCTest.a"
               run("cp {} {}".format(
                   os.path.join(static_lib_build_dir, xctest_a),
                   os.path.join(static_library_install_path, xctest_a)))

    @staticmethod
    def core_foundation_build_dir(foundation_build_dir, foundation_install_prefix):
        """
        Given the path to a swift-corelibs-foundation built product directory,
        return the path to CoreFoundation built products.

        When specifying a built Foundation dir such as
        '/build/foundation-linux-x86_64/Foundation', CoreFoundation dependencies
        are placed in 'usr/lib/swift'. Note that it's technically not necessary to
        include this extra path when linking the installed Swift's
        'usr/lib/swift/linux/libFoundation.so'.
        """
        return os.path.join(foundation_build_dir,
                            foundation_install_prefix.strip("/"), 'lib', 'swift')

    @staticmethod
    def static_lib_build_dir(build_dir):
        """
        Given the path to the build directory, return the path to be used for
        the static library libXCTest.a. Putting it in a separate directory to
        libXCTest.so simplifies static linking when building a static test
        foundation.
        """
        return os.path.join(build_dir, "static")


def main(args=sys.argv[1:]):
    """
    The main entry point for this script. Based on the subcommand given,
    delegates building or testing XCTest to a sub-parser and its corresponding
    function.
    """
    strategy = DarwinStrategy if platform.system() == 'Darwin' else GenericUnixStrategy

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent("""
            Build, test, and install XCTest.

            NOTE: In general this script should not be invoked directly. The
            recommended way to build and test XCTest is via the Swift build
            script. See this project's README for details.

            The Swift build script invokes this %(prog)s script to build,
            test, and install this project. You may invoke it in the same way 
            to build this project directly. For example, if you are in a Linux
            environment, your install of Swift is located at "/swift" and you
            wish to install XCTest into that same location, here is a sample
            invocation of the build script:

            $ %(prog)s \\
                --swiftc="/swift/usr/bin/swiftc" \\
                --build-dir="/tmp/XCTest_build" \\
                --foundation-build-dir "/swift/usr/lib/swift/linux" \\
                --library-install-path="/swift/usr/lib/swift/linux" \\
                --static-library-install-path="/swift/usr/lib/swift_static/linux" \\
                --module-install-path="/swift/usr/lib/swift/linux/x86_64"

            Note that installation is not supported on Darwin as this library
            is only intended to be used as a dependency in environments where
            Apple XCTest is not available.
            """))
    subparsers = parser.add_subparsers(
        description=textwrap.dedent("""
            Use one of these to specify whether to build, test, or install
            XCTest. If you don't specify any of these, 'build' is executed as a
            default. You may also use 'build' to also test and install the
            built products. Pass the -h or --help option to any of the
            subcommands for more information."""))

    build_parser = subparsers.add_parser(
        "build",
        description=textwrap.dedent("""
            Build XCTest.so, XCTest.swiftmodule, and XCTest.swiftdoc using the
            given Swift compiler. This command may also test and install the
            built products."""))
    build_parser.set_defaults(func=strategy.build)
    build_parser.add_argument(
        "--swiftc",
        help="Path to the 'swiftc' compiler that will be used to build "
             "XCTest.so, XCTest.swiftmodule, and XCTest.swiftdoc. This will "
             "also be used to build the tests for those built products if the "
             "--test option is specified.",
        required=True)
    build_parser.add_argument(
        "--build-dir",
        help="Path to the output build directory. If not specified, a "
             "temporary directory is used.",
        default=tempfile.mkdtemp())
    build_parser.add_argument(
        "--foundation-build-dir",
        help="Path to swift-corelibs-foundation build products, which "
             "the built XCTest.so will be linked against.",
        required=strategy.requires_foundation_build_dir())
    build_parser.add_argument(
        "--foundation-install-prefix",
        help="Path to the installation location for swift-corelibs-foundation "
             "build products ('%(default)s' by default); CoreFoundation "
             "dependencies are expected to be found under "
             "FOUNDATION_BUILD_DIR/FOUNDATION_INSTALL_PREFIX.",
        default="/usr")
    build_parser.add_argument(
        "--libdispatch-build-dir",
        help="Path to swift-corelibs-libdispatch build products, which "
             "the built XCTest.so will be linked against.")
    build_parser.add_argument(
        "--libdispatch-src-dir",
        help="Path to swift-corelibs-libdispatch source tree, which "
             "the built XCTest.so will be linked against.")
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
        "--static-library-install-path",
        help="Location at which to install XCTest.a. This directory will be "
             "created if it doesn't already exist.",
        dest="static_lib_path")
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
    test_parser.set_defaults(func=strategy.test)
    test_parser.add_argument(
        "build_dir",
        help="An absolute path to a directory containing the built XCTest.so "
             "library.")
    test_parser.add_argument(
        "--swiftc",
        help="Path to the 'swiftc' compiler used to build and run the tests.",
        required=True)
    test_parser.add_argument(
        "--lit",
        help="Path to the 'lit' tester tool used to run the test suite. "
             "'%(default)s' by default.",
        default=os.path.join(os.path.dirname(SOURCE_DIR),
                             "llvm", "utils", "lit", "lit.py"))
    test_parser.add_argument(
        "--foundation-build-dir",
        help="Path to swift-corelibs-foundation build products, which the "
             "tests will be linked against.",
        required=strategy.requires_foundation_build_dir())
    test_parser.add_argument(
        "--foundation-install-prefix",
        help="Path to the installation location for swift-corelibs-foundation "
             "build products ('%(default)s' by default); CoreFoundation "
             "dependencies are expected to be found under "
             "FOUNDATION_BUILD_DIR/FOUNDATION_INSTALL_PREFIX.",
        default="/usr")
    test_parser.add_argument(
        "--libdispatch-build-dir",
        help="Path to swift-corelibs-libdispatch build products, which "
             "the built XCTest.so will be linked against.")
    test_parser.add_argument(
        "--libdispatch-src-dir",
        help="Path to swift-corelibs-libdispatch source tree, which "
             "the built XCTest.so will be linked against.")
    test_parser.add_argument(
        "--release",
        help="builds the tests for release",
        action="store_const",
        dest="build_style",
        const="release",
        default="debug")
    test_parser.add_argument(
        "--debug",
        help="builds the tests for debug (the default)",
        action="store_const",
        dest="build_style",
        const="debug",
        default="debug")

    install_parser = subparsers.add_parser(
        "install",
        description="Installs a built XCTest framework.")
    install_parser.set_defaults(func=strategy.install)
    install_parser.add_argument(
        "build_dir",
        help="An absolute path to a directory containing a built XCTest.so, "
             "XCTest.swiftmodule, and XCTest.swiftdoc.")
    install_parser.add_argument(
        "-m", "--module-install-path",
        help="Location at which to install XCTest.swiftmodule and "
             "XCTest.swiftdoc. This directory will be created if it doesn't "
             "already exist.")
    install_parser.add_argument(
        "-l", "--library-install-path",
        help="Location at which to install XCTest.so. This directory will be "
             "created if it doesn't already exist.")
    install_parser.add_argument(
        "-s", "--static-library-install-path",
        help="Location at which to install XCTest.a. This directory will be "
             "created if it doesn't already exist.")

    # Many versions of Python require a subcommand must be specified.
    # We handle this here: if no known subcommand (or none of the help options)
    # is included in the arguments, then insert the default subcommand
    # argument: 'build'.
    if any([a in ["build", "test", "install", "-h", "--help"] for a in args]):
        parsed_args = parser.parse_args(args=args)
    else:
        parsed_args = parser.parse_args(args=["build"] + args)

    # Execute the function for the subcommand we've been given.
    parsed_args.func(parsed_args)


if __name__ == '__main__':
    main()
