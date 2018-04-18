file(GLOB_RECURSE SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.swift)
add_swift_module(xctest xctest "" "${SOURCES}" "")

