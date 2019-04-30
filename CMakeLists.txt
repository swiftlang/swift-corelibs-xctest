
cmake_minimum_required(VERSION 3.4.3)

list(APPEND CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

project(XCTest
        LANGUAGES
          C)

enable_testing()
option(ENABLE_TESTING "Build tests" YES)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

option(XCTEST_PATH_TO_LIBDISPATCH_SOURCE "Path to libdispatch source" "")
option(XCTEST_PATH_TO_LIBDISPATCH_BUILD "Path to libdispatch build" "")

option(XCTEST_PATH_TO_FOUNDATION_BUILD "Path to Foundation build" "")

if(ENABLE_TESTING)
  find_package(LLVM CONFIG)
  if(LLVM_FOUND)
    message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
    message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

    include(${LLVM_DIR}/LLVMConfig.cmake)

    list(APPEND CMAKE_MODULE_PATH ${LLVM_DIR})
    include(AddLLVM)
  elseif(NOT DEFINED LLVM_MAIN_SRC_DIR OR NOT EXISTS ${LLVM_MAIN_SRC_DIR})
    message(SEND_ERROR "LLVM not found and LLVM_MAIN_SRC_DIR not defined - required for testing")
  endif()
endif()

include(SwiftSupport)
include(GNUInstallDirs)

set(swift_optimization_flags)
if(CMAKE_BUILD_TYPE MATCHES Release)
  set(swift_optimization_flags -O)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL Android OR CMAKE_SYSTEM_NAME STREQUAL Linux)
  set(deployment_target -DDEPLOYMENT_TARGET_LINUX)
elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
  set(deployment_target -DDEPLOYMENT_TARGET_MACOSX)
elseif(CMAKE_SYSTEM_NAME STREQUAL FreeBSD)
  set(deployment_target -DDEPLOYMENT_TARGET_FREEBSD)
elseif(CMAKE_SYSTEM_NAME STREQUAL Windows)
  set(deployment_target -DDEPLOYMENT_TARGET_WINDOWS)
  set(WORKAROUND_SR9138 -Xlinker;-ignore:4217)
  set(WORKAROUND_SR9995 -Xlinker;-nodefaultlib:libcmt)
endif()

add_swift_library(XCTest
                  MODULE_NAME
                    XCTest
                  MODULE_LINK_NAME
                    XCTest
                  MODULE_PATH
                    ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftmodule
                  LINK_FLAGS
                    -L${XCTEST_PATH_TO_LIBDISPATCH_BUILD}
                    -L${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src -ldispatch
                    -L${XCTEST_PATH_TO_FOUNDATION_BUILD} -lFoundation

                    # compatibility with Foundation build_script.py
                    -L${XCTEST_PATH_TO_FOUNDATION_BUILD}/Foundation

                    ${WORKAROUND_SR9138}
                    ${WORKAROUND_SR9995}
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
                  CFLAGS
                    ${deployment_target}
                  SWIFT_FLAGS
                    ${swift_optimization_flags}

                    -I${XCTEST_PATH_TO_LIBDISPATCH_SOURCE}
                    -I${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src/swift
                    -Xcc -fblocks

                    -I${XCTEST_PATH_TO_FOUNDATION_BUILD}/swift
                    -Fsystem ${XCTEST_PATH_TO_FOUNDATION_BUILD}

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

if(ENABLE_TESTING)
  if(EXISTS ${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py)
    set(LIT_COMMAND "${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py"
        CACHE STRING "command used to spawn llvm-lit")
  else()
    find_program(LIT_COMMAND NAMES llvm-lit lit.py lit)
  endif()
  find_package(PythonInterp)
  add_custom_target(check-xctest
                    COMMAND
                    ${CMAKE_COMMAND} -E env
                      BUILT_PRODUCTS_DIR=${CMAKE_BINARY_DIR}
                      FOUNDATION_BUILT_PRODUCTS_DIR=${XCTEST_PATH_TO_FOUNDATION_BUILD}
                      LIBDISPATCH_SRC_DIR=${XCTEST_PATH_TO_LIBDISPATCH_SOURCE}
                      LIBDISPATCH_BUILD_DIR=${XCTEST_PATH_TO_LIBDISPATCH_BUILD}
                      LIBDISPATCH_OVERLAY_DIR=${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src/swift
                      SWIFT_EXEC=${CMAKE_SWIFT_COMPILER}
                      ${PYTHON_EXECUTABLE} ${LIT_COMMAND} -sv ${CMAKE_SOURCE_DIR}/Tests/Functional
                    COMMENT
                      "Running XCTest functional test suite"
                    DEPENDS
                      XCTest
                    USES_TERMINAL)
endif()

string(TOLOWER ${CMAKE_SYSTEM_NAME} swift_os)
get_swift_host_arch(swift_host_arch)

install(FILES
          ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftdoc
          ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftmodule
        DESTINATION
          ${CMAKE_INSTALL_FULL_LIBDIR}/swift/${swift_os}/${swift_host_arch})

if(BUILD_SHARED_LIBS)
  set(library_kind SHARED)
  set(swift_dir swift)
else()
  set(library_kind STATIC)
  set(swift_dir swift_static)
endif()

set(XCTest_OUTPUT_FILE
    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_${library_kind}_LIBRARY_PREFIX}XCTest${CMAKE_${library_kind}_LIBRARY_SUFFIX})

if(CMAKE_SYSTEM_NAME STREQUAL Windows AND BUILD_SHARED_LIBS)
  install(FILES
            ${XCTest_OUTPUT_FILE}
          DESTINATION
            ${CMAKE_INSTALL_FULL_BINDIR})
  install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_IMPORT_LIBRARY_PREFIX}XCTest${CMAKE_IMPORT_LIBRARY_SUFFIX}
          DESTINATION
            ${CMAKE_INSTALL_FULL_LIBDIR}/${swift_dir}/${swift_os})
else()
  # NOTE(compnerd) stage a compatibility copy in the swift resource dir
  install(FILES
            ${XCTest_OUTPUT_FILE}
          DESTINATION
            ${CMAKE_INSTALL_FULL_LIBDIR}/${swift_dir}/${swift_os})
endif()
