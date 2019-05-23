
cmake_minimum_required(VERSION 3.14.20190523)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

project(XCTest LANGUAGES Swift)

set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

option(ENABLE_TESTING "Build tests" YES)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

if(ENABLE_TESTING)
  enable_testing()

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

  if(EXISTS ${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py)
    set(LIT_COMMAND "${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py"
        CACHE STRING "command used to spawn llvm-lit")
  else()
    find_program(LIT_COMMAND NAMES llvm-lit lit.py lit)
  endif()
  find_package(PythonInterp)
endif()

# TODO(compnerd) migrate to find_package(dispatch CONFIG)
option(XCTEST_PATH_TO_LIBDISPATCH_SOURCE "Path to libdispatch source" "")
option(XCTEST_PATH_TO_LIBDISPATCH_BUILD "Path to libdispatch build" "")

# TODO(compnerd) migrate to find_package(Foundation CONFIG)
option(XCTEST_PATH_TO_FOUNDATION_BUILD "Path to Foundation build" "")

add_library(XCTest
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
  Sources/XCTest/Public/Asynchronous/XCTestExpectation.swift)

# TODO(compnerd) the following 4 items should go away with export targets
target_compile_options(XCTest PRIVATE
  -Xcc -fblocks)
target_include_directories(XCTest PRIVATE
  # FIXME(compnerd) why is this included into the module search path?
  ${XCTEST_PATH_TO_LIBDISPATCH_SOURCE}
  ${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src/swift)
target_link_directories(XCTest PRIVATE
  ${XCTEST_PATH_TO_LIBDISPATCH_BUILD}
  ${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src)
target_link_libraries(XCTest PRIVATE
  dispatch)

# TODO(compnerd) the following 4 items should go away with export targets
target_compile_options(XCTest PRIVATE
  -F${XCTEST_PATH_TO_FOUNDATION_BUILD})
target_include_directories(XCTest PRIVATE
  ${XCTEST_PATH_TO_FOUNDATION_BUILD}/swift
  # compatibility with Foundation build_script.py
  ${XCTEST_PATH_TO_FOUNDATION_BUILD}/Foundation
  ${XCTEST_PATH_TO_FOUNDATION_BUILD}/Foundation/usr/lib/swift)
target_link_directories(XCTest PRIVATE
  ${XCTEST_PATH_TO_FOUNDATION_BUILD}
  # compatibility with Foundation build_script.py
  ${XCTEST_PATH_TO_FOUNDATION_BUILD}/Foundation)
target_link_libraries(XCTest PRIVATE
  Foundation)

# FIXME(compnerd) SR-9138
if(CMAKE_SYSTEM_NAME STREQUAL Windows)
  target_link_options(XCTest PRIVATE
    -Xlinker -ignore:4217)
endif()


if(ENABLE_TESTING)
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


include(SwiftSupport)
include(GNUInstallDirs)

get_swift_host_arch(swift_host_arch)

install(FILES
          ${CMAKE_Swift_MODULE_DIRECTORY}/XCTest.swiftdoc
          ${CMAKE_Swift_MODULE_DIRECTORY}/XCTest.swiftmodule
        DESTINATION
          ${CMAKE_INSTALL_FULL_LIBDIR}/swift$<$<NOT:$<BOOL:BUILD_SHARED_LIBS>>:_static>/$<LOWER_CASE:CMAKE_SYSTEM_NAME>/${swift_host_arch})
install(TARGETS
          XCTest
        ARCHIVE DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/swift$<$<NOT:$<BOOL:BUILD_SHARED_LIBS>>:_static>/$<LOWER_CASE:CMAKE_SYSTEM_NAME>/${swift_host_arch}
        LIBRARY DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/swift$<$<NOT:$<BOOL:BUILD_SHARED_LIBS>>:_static>/$<LOWER_CASE:CMAKE_SYSTEM_NAME>/${swift_host_arch}
        RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})

