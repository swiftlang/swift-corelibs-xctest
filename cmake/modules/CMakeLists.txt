
set(XCTest_EXPORTS_FILE ${CMAKE_CURRENT_BINARY_DIR}/XCTestExports.cmake)
configure_file(XCTestConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/XCTestConfig.cmake)

get_property(XCTest_EXPORTS GLOBAL PROPERTY XCTest_EXPORTS)
export(TARGETS ${XCTest_EXPORTS} FILE ${XCTest_EXPORTS_FILE})
