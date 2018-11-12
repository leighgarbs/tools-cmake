cmake_minimum_required(VERSION 3.0.2)

# This is meant to be included as part of the definition of a CMake project.  It
# is not intended to be used by itself.

# We want to explicitly define some kind of build type.  CMake defines the debug
# and release build types.  If neither is defined by the user then define
# release by default.  CMake will build with additional appropriate compiler
# flags depending on which build type is set; we leave the choice of most
# meaningful debug and release compiler flags to CMake and do not explicitly
# specify them here.  Specification of compiler flags that are explicitly
# specified in this file (not specified by CMake) happens just below.

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif(NOT CMAKE_BUILD_TYPE)

# Flags used for all builds
set(${PROJECT_NAME}_FLAGS "-Wall")

# Flags used for all builds for specific platforms
set(${PROJECT_NAME}_LINUX_FLAGS   "-DLINUX")
set(${PROJECT_NAME}_WINDOWS_FLAGS "-DWINDOWS")
set(${PROJECT_NAME}_MACOS_FLAGS   "-DMACOS")

# Flags used for specific build types
set(${PROJECT_NAME}_DEBUG_FLAGS   "-DDEBUG")
set(${PROJECT_NAME}_RELEASE_FLAGS "-DRELEASE")

# Generate the LINUX variable
if(UNIX AND NOT APPLE)
  set(LINUX 1)
else(UNIX AND NOT APPLE)
  set(LINUX 0)
endif(UNIX AND NOT APPLE)

# Generate the MACOS variable.  Could just use APPLE but MACOS is the name of a
# platform, whereas APPLE is the name of a brand.
if(APPLE)
  set(MACOS 1)
else(APPLE)
  set(MACOS 0)
endif(APPLE)

# Request that all C++ builds are done with C++11 support enabled.  To my
# knowledge this doesn't guarantee C++11 build support.  May move to newer C++
# standards as needed.
set(CMAKE_CXX_STANDARD 11)

# Add the common flags and user-defined debug flags to the existing set of debug
# flags
string(CONCAT CMAKE_CXX_FLAGS_DEBUG
  "${CMAKE_CXX_FLAGS_DEBUG} "
  "${${PROJECT_NAME}_FLAGS} "
  "${${PROJECT_NAME}_DEBUG_FLAGS}")

# Add the common flags and user-defined release flags to the existing set of
# release flags
string(CONCAT CMAKE_CXX_FLAGS_RELEASE
  "${CMAKE_CXX_FLAGS_RELEASE} "
  "${${PROJECT_NAME}_FLAGS} "
  "${${PROJECT_NAME}_RELEASE_FLAGS}")

if(LINUX)

  # Add Linux-specific debug flags
  string(CONCAT CMAKE_CXX_FLAGS_DEBUG
    "${CMAKE_CXX_FLAGS_DEBUG} "
    "${${PROJECT_NAME}_LINUX_FLAGS}")

  # Add Linux-specific release flags
  string(CONCAT CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} "
    "${${PROJECT_NAME}_LINUX_FLAGS}")

elseif(WIN32)

  # Add Windows-specific debug flags
  string(CONCAT CMAKE_CXX_FLAGS_DEBUG
    "${CMAKE_CXX_FLAGS_DEBUG} "
    "${${PROJECT_NAME}_WINDOWS_FLAGS}")

  # Add Windows-specific release flags
  string(CONCAT CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} "
    "${${PROJECT_NAME}_WINDOWS_FLAGS}")

elseif(APPLE)

  # Add macOS-specific debug flags
  string(CONCAT CMAKE_CXX_FLAGS_DEBUG
    "${CMAKE_CXX_FLAGS_DEBUG} "
    "${${PROJECT_NAME}_MACOS_FLAGS}")

  # Add macOS-specific release flags
  string(CONCAT CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} "
    "${${PROJECT_NAME}_MACOS_FLAGS}")

endif(LINUX)

# All projects append their unit test dependencies to this
if(NOT TARGET tests)
  add_custom_target(tests)
endif(NOT TARGET tests)

# We always want testing enabled
enable_testing()

#===============================================================================
# Define a function for prepending a string to each element of a list of strings
#===============================================================================
function(list_prepend_to_each LIST PREFIX)

  set(LIST_DREF ${${LIST}})

  foreach(I IN LISTS LIST_DREF)

    string(CONCAT J ${PREFIX} ${I})
    list(APPEND LIST_DREF ${J})
    list(REMOVE_AT LIST_DREF 0)

  endforeach(I)

  set(${LIST} ${LIST_DREF} PARENT_SCOPE)

endfunction(list_prepend_to_each)

#===============================================================================
# Adds a test that builds from a single source file
#===============================================================================
function(add_test_executable_simple TEST_NAME INCLUDE_DIRS LINK_LIBRARIES)

  add_test_executable_complex(${TEST_NAME}
    ${CMAKE_CURRENT_LIST_DIR}/${TEST_NAME}.cpp
    "${INCLUDE_DIRS}"
    "${LINK_LIBRARIES}")

endfunction(add_test_executable_simple)

#===============================================================================
# Adds a test that builds from multiple source files
#===============================================================================
function(add_test_executable_complex
    TEST_NAME SOURCE_FILES INCLUDE_DIRS LINK_LIBRARIES)

  add_executable(${TEST_NAME} ${SOURCE_FILES})

  add_test(NAME ${TEST_NAME}
    COMMAND ${TEST_NAME}
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

  add_dependencies(tests ${TEST_NAME})
  add_dependencies(${PROJECT_NAME}-tests ${TEST_NAME})

  target_include_directories(${TEST_NAME} PUBLIC ${INCLUDE_DIRS})
  target_link_libraries(${TEST_NAME} ${LINK_LIBRARIES})

  set_property(TEST ${TEST_NAME} PROPERTY SKIP_RETURN_CODE 2)

endfunction(add_test_executable_complex)

#===============================================================================
# Useful for shortening calls to add_test_executable_simple
#===============================================================================
macro(test_simple TEST_NAME)
  add_test_executable_simple(${TEST_NAME} "${INC}" "${LIB}")
endmacro(test_simple)

#===============================================================================
# Useful for shortening calls to add_test_executable_complex
#===============================================================================
macro(test_complex TEST_NAME SRC)
  list_prepend_to_each(SRC ${CMAKE_CURRENT_LIST_DIR}/)
  add_test_executable_complex(${TEST_NAME} "${SRC}" "${INC}" "${LIB}")
endmacro(test_complex)
