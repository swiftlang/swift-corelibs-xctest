# Compile swift sources to a dynamic framework.
# Usage:
# target          # Target name
# name            # Swift Module name
# deps            # Target dependencies
# sources         # List of sources
# additional_args # List of additional args to pass
function(add_swift_module target name deps sources additional_args)
  
  set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})
  
  list(APPEND ARGS -module-name ${name})
  list(APPEND ARGS -incremental -emit-dependencies -emit-module)
  list(APPEND ARGS -emit-module-path ${name}.swiftmodule)
  
  set(FILEMAP ${BUILD_DIR}/output-file-map.json)
  set(OUTPUT_FILE_MAP ${FILEMAP})
  
  # Remove old file and start writing new one.
  file(REMOVE ${FILEMAP})
  file(APPEND ${FILEMAP} "{\n")
  foreach(source ${sources})
    file(APPEND ${FILEMAP} "\"${CMAKE_CURRENT_SOURCE_DIR}/${source}\": {\n")
    file(APPEND ${FILEMAP} "\"dependencies\": \"${BUILD_DIR}/${source}.d\",\n")
    set(OBJECT ${BUILD_DIR}/${source}.o)
    list(APPEND OUTPUTS ${OBJECT})
    file(APPEND ${FILEMAP} "\"object\": \"${OBJECT}\",\n")
    file(APPEND ${FILEMAP} "\"swiftmodule\": \"${BUILD_DIR}/${source}~partial.swiftmodule\",\n")
    file(APPEND ${FILEMAP} "\"swift-dependencies\": \"${BUILD_DIR}/${source}.swiftdeps\"\n},\n")
  endforeach()
  file(APPEND ${FILEMAP} "\"\": {\n")
  file(APPEND ${FILEMAP} "\"swift-dependencies\": \"${BUILD_DIR}/master.swiftdeps\"\n")
  file(APPEND ${FILEMAP} "}\n")
  file(APPEND ${FILEMAP} "}")
    
  list(APPEND ARGS -output-file-map ${OUTPUT_FILE_MAP})
  list(APPEND ARGS -parse-as-library)
  list(APPEND ARGS -c)

  foreach(source ${sources})
      list(APPEND ARGS ${CMAKE_CURRENT_SOURCE_DIR}/${source})
  endforeach()

  # FIXME: Find a better way to handle build types.
  if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    list(APPEND ARGS -g)
  endif()
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND ARGS -Onone -g)    
  else()
    list(APPEND ARGS -O)
  endif()

  foreach(arg ${additional_args})
    list(APPEND ARGS ${arg})
  endforeach()
  
  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    list(APPEND ARGS -sdk ${CMAKE_OSX_SYSROOT})
  endif()
  
  # Compile swiftmodule.
  add_custom_command(
      OUTPUT    ${OUTPUTS}
      COMMAND   ${SWIFTC_EXECUTABLE}
      ARGS      ${ARGS}
      DEPENDS   ${sources}
  )
  
  # Link and create dynamic framework.
  set(LIB_OUTPUT ${CMAKE_INT_LIBDIR}/${target}.so)
  
  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    list(APPEND DYLYB_ARGS -sdk ${CMAKE_OSX_SYSROOT})
  endif()
  
  list(APPEND DYLYB_ARGS -module-name ${name})
  list(APPEND DYLYB_ARGS -o ${LIB_OUTPUT})
  list(APPEND DYLYB_ARGS -emit-library ${OUTPUTS})
  foreach(arg ${additional_args})
    list(APPEND DYLYB_ARGS ${arg})
  endforeach()
  
  add_custom_command(
      OUTPUT    ${LIB_OUTPUT}
      COMMAND   ${SWIFTC_EXECUTABLE}
      ARGS      ${DYLYB_ARGS}
      DEPENDS   ${OUTPUTS}
  )
  
  # Add the target.    
  add_custom_target(${target} ALL DEPENDS ${deps} ${LIB_OUTPUT} ${sources})
endfunction()

