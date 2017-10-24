cmake_minimum_required(VERSION 3.4.3)

# Sanity check our source directory to make sure that we are not trying to
# generate an in-tree build (it pollutes the source tree with a lot of CMake
# related files).
if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed.")
endif()

# Default to building the Debug configuration.
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
      "Build type [Debug, RelWithDebInfo, Release, MinSizeRel]"
      FORCE)
  message(STATUS "No build type was specified, will default to ${CMAKE_BUILD_TYPE}")
endif()

# Set the project name.
project(XCTest)

# Add path for custom CMake modules.
list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

set(CMAKE_INT_LIBDIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})


include(GNUInstallDirs)
# Include custom modules.
include(Utility)

find_package(swiftc)

message("source dir: ${CMAKE_CURRENT_SOURCE_DIR}")
message("binary dir: ${CMAKE_CURRENT_BINARY_DIR}")
message("files dir: ${CMAKE_FILES_DIRECTORY}")
message("bindir: ${CMAKE_INSTALL_BINDIR} ${CMAKE_INSTALL_FULL_BINDIR}")
message("libdir: ${CMAKE_INSTALL_LIBDIR} ${CMAKE_INSTALL_FULL_LIBDIR}")
message("includedir: ${CMAKE_INSTALL_INCLUDEDIR} ${CMAKE_INSTALL_FULL_INCLUDEDIR}")
message("int libdir: ${CMAKE_INT_LIBDIR}")


# Process CMakeLists files for our subdirectories.
add_subdirectory(Sources/XCTest)
