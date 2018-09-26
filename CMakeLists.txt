
cmake_minimum_required(VERSION 3.4.3)

list(APPEND CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

project(XCTest
        LANGUAGES
          C)

option(XCTEST_PATH_TO_LIBDISPATCH_SOURCE "Path to libdispatch source" "")
option(XCTEST_PATH_TO_LIBDISPATCH_BUILD "Path to libdispatch build" "")

option(XCTEST_PATH_TO_FOUNDATION_BUILD "Path to Foundation build" "")

option(XCTEST_PATH_TO_COREFOUNDATION_BUILD "Path to CoreFoundation build" "")

find_package(LLVM CONFIG)
if(NOT LLVM_FOUND)
  message(SEND_ERROR "Could not find LLVM; configure with -DCMAKE_PREFIX_PATH=/path/to/llvm/install")
endif()
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

include(${LLVM_DIR}/LLVMConfig.cmake)

list(APPEND CMAKE_MODULE_PATH ${LLVM_DIR})
include(AddLLVM)

include(SwiftSupport)
include(GNUInstallDirs)

set(swift_optimization_flags)
if(CMAKE_BUILD_TYPE MATCHES Release)
  set(swift_optimization_flags -O)
endif()

add_swift_library(XCTest
                  MODULE_NAME
                    XCTest
                  MODULE_LINK_NAME
                    XCTest
                  MODULE_PATH
                    ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftmodule
                  OUTPUT
                    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}XCTest${CMAKE_SHARED_LIBRARY_SUFFIX}
                  LINK_FLAGS
                    -L${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src -ldispatch
                    -L${XCTEST_PATH_TO_FOUNDATION_BUILD} -lFoundation

                    # compatibility with Foundation build_script.py
                    -L${XCTEST_PATH_TO_FOUNDATION_BUILD}/Foundation
                  SOURCES
                    Sources/XCTest/Private/WallClockTimeMetric.swift
                    Sources/XCTest/Private/TestListing.swift
                    Sources/XCTest/Private/XCTestCaseSuite.swift
                    Sources/XCTest/Private/TestFiltering.swift
                    Sources/XCTest/Private/XCTestInternalObservation.swift
                    Sources/XCTest/Private/ObjectWrapper.swift
                    Sources/XCTest/Private/PerformanceMeter.swift
                    Sources/XCTest/Private/PrintObserver.swift
                    Sources/XCTest/Private/ArgumentParser.swift
                    Sources/XCTest/Private/SourceLocation.swift
                    Sources/XCTest/Private/WaiterManager.swift
                    Sources/XCTest/Public/XCTestRun.swift
                    Sources/XCTest/Public/XCTestMain.swift
                    Sources/XCTest/Public/XCTestCase.swift
                    Sources/XCTest/Public/XCTestSuite.swift
                    Sources/XCTest/Public/XCTestSuiteRun.swift
                    Sources/XCTest/Public/XCTestErrors.swift
                    Sources/XCTest/Public/XCTestObservation.swift
                    Sources/XCTest/Public/XCTestCaseRun.swift
                    Sources/XCTest/Public/XCAbstractTest.swift
                    Sources/XCTest/Public/XCTestObservationCenter.swift
                    Sources/XCTest/Public/XCTestCase+Performance.swift
                    Sources/XCTest/Public/XCTAssert.swift
                    Sources/XCTest/Public/Asynchronous/XCTNSNotificationExpectation.swift
                    Sources/XCTest/Public/Asynchronous/XCTNSPredicateExpectation.swift
                    Sources/XCTest/Public/Asynchronous/XCTWaiter+Validation.swift
                    Sources/XCTest/Public/Asynchronous/XCTWaiter.swift
                    Sources/XCTest/Public/Asynchronous/XCTestCase+Asynchronous.swift
                    Sources/XCTest/Public/Asynchronous/XCTestExpectation.swift
                  SWIFT_FLAGS
                    ${swift_optimization_flags}

                    -I${XCTEST_PATH_TO_LIBDISPATCH_SOURCE}
                    -I${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src/swift
                    -Xcc -fblocks

                    -I${XCTEST_PATH_TO_FOUNDATION_BUILD}/swift
                    -Fsystem ${XCTEST_PATH_TO_COREFOUNDATION_BUILD}/System/Library/Frameworks

                    # compatibility with Foundation build_script.py
                    -I${XCTEST_PATH_TO_FOUNDATION_BUILD}/Foundation
                    -I${XCTEST_PATH_TO_FOUNDATION_BUILD}/Foundation/usr/lib/swift)

# Temporary staging; the various swift projects that depend on XCTest all expect
# the swiftdoc and swiftmodule to be in the top level.
# So for now, make a copy so we don't have to do a coordinated commit across
# all the swift projects to change this assumption.
add_custom_command(TARGET
                    XCTest
                  POST_BUILD
                  COMMAND
                    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftdoc ${CMAKE_CURRENT_BINARY_DIR}
                  COMMAND
                    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftmodule ${CMAKE_CURRENT_BINARY_DIR}
                  COMMENT
                    "Copying swiftmodule/swiftdoc to build directory")

if(EXISTS ${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py)
  set(LIT_COMMAND "${PYTHON_EXECUTABLE};${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py"
      CACHE STRING "command used to spawn llvm-lit")
else()
  find_program(LIT_COMMAND NAMES llvm-lit lit.py lit)
endif()
add_custom_target(check-xctest
                  COMMAND
                  ${CMAKE_COMMAND} -E env
                    BUILT_PRODUCTS_DIR=${CMAKE_BINARY_DIR}
                    CORE_FOUNDATION_BUILT_PRODUCTS_DIR=${XCTEST_PATH_TO_COREFOUNDATION_BUILD}
                    FOUNDATION_BUILT_PRODUCTS_DIR=${XCTEST_PATH_TO_FOUNDATION_BUILD}
                    LIBDISPATCH_SRC_DIR=${XCTEST_PATH_TO_LIBDISPATCH_SOURCE}
                    LIBDISPATCH_BUILD_DIR=${XCTEST_PATH_TO_LIBDISPATCH_BUILD}
                    LIBDISPATCH_OVERLAY_DIR=${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/swift
                    SWIFT_EXEC=${CMAKE_SWIFT_COMPILER}
                    ${LIT_COMMAND} -sv ${CMAKE_SOURCE_DIR}/Tests/Functional
                  COMMENT
                    "Running XCTest functional test suite"
                  DEPENDS
                    XCTest
                  USES_TERMINAL)

string(TOLOWER ${CMAKE_SYSTEM_NAME} swift_os)
get_swift_host_arch(swift_host_arch)

install(FILES
          ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftdoc
          ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftmodule
        DESTINATION
          ${CMAKE_INSTALL_FULL_LIBDIR}/swift/${swift_os}/${swift_host_arch})
install(FILES
          ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}XCTest${CMAKE_SHARED_LIBRARY_SUFFIX}
        DESTINATION
          ${CMAKE_INSTALL_FULL_LIBDIR})
# NOTE(compnerd) stage a compatibility copy in the swift resource dir
install(FILES
          ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}XCTest${CMAKE_SHARED_LIBRARY_SUFFIX}
        DESTINATION
          ${CMAKE_INSTALL_FULL_LIBDIR}/swift/${swift_os})
if(NOT CMAKE_SYSTEM_NAME STREQUAL Darwin)
  install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}XCTest${CMAKE_SHARED_LIBRARY_SUFFIX}
          DESTINATION
            ${CMAKE_INSTALL_FULL_LIBDIR}/swift/${swift_os}/${swift_host_arch})
endif()
