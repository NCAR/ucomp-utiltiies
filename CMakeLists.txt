project(ucomp-pipeline)

set(VERSION_MAJOR "0")
set(VERSION_MINOR "1")
set(VERSION_PATCH "1")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

# required version of CMake
cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0017 NEW)
if (POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif ()

set(CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake/Modules
  ${CMAKE_ROOT}/Modules
  ${CMAKE_MODULE_PATH}
)

set(GIT_VERSION "${VERSION}")

find_package(Git 2.7)
if (GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
    OUTPUT_VARIABLE GIT_REVISION
  )

  # append a * to the revision if there are modified files
  execute_process(
    COMMAND ${GIT_EXECUTABLE} diff-index --quiet HEAD --
    RESULT_VARIABLE GIT_CHANGES
  )
  if (${GIT_CHANGES})
    set(GIT_REVISION "${GIT_REVISION}*")
  endif ()

  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE GIT_BRANCH
  )
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%ad --date=short
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE GIT_SHORTDATE
  )
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%ad "--date=format:%a %b %d %H:%M:%S %Y"
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE GIT_LOCALDATE
  )

  # append a -dev to version if it is not the exact tagged version
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE GIT_DESCRIBE
  )
  string(COMPARE NOTEQUAL "${GIT_DESCRIBE}" "v${GIT_VERSION}" GIT_COMMITS)
  if (${GIT_COMMITS})
    set(GIT_VERSION "${GIT_VERSION}-dev")
  endif ()
else ()
  set(GIT_REVISION "")
  set(GIT_BRANCH "")
  set(GIT_SHORTDATE "")
endif ()

message(STATUS "git binary   = ${GIT_EXECUTABLE}")
message(STATUS "git branch   = ${GIT_BRANCH}")
message(STATUS "git version  = ${GIT_VERSION}")
message(STATUS "git revision = ${GIT_REVISION}")

find_package(Python3 COMPONENTS Interpreter Development)

include(${CMAKE_SOURCE_DIR}/cmake/GetDate.cmake)
LONG_TODAY(ucomp_pipeline_BUILD_DATE)
message(STATUS "Build date = ${ucomp_pipeline_BUILD_DATE}")

find_package(IDL REQUIRED)

# always need IDL's include files
include_directories(${IDL_INCLUDE_DIR})

add_subdirectory(lib)
add_subdirectory(src)
add_subdirectory(ssw)

if (WIN32 OR CYGWIN)
  set(SEP_CHAR ";")
else ()
  set(SEP_CHAR ":")
endif ()

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "api-docs")

# setup installer

if (WIN32)
  set(CPACK_GENERATOR ZIP)
else ()
  set(CPACK_GENERATOR TGZ)
endif ()

string(TOLOWER "${CMAKE_SYSTEM_NAME}" UCOMP_UTILITIES_SYSTEM_NAME)
set(UCOMP_UTILITIES_PACKAGE_VERSION "${VERSION}.${GIT_REVISION}")
set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${UCOMP_UTILITIES_PACKAGE_VERSION}-${UCOMP_UTILITIES_SYSTEM_NAME}")

include(CPack)

configure_file(INSTALLATION.in INSTALLATION @ONLY)
install(FILES
          README.md
          ${CMAKE_CURRENT_BINARY_DIR}/INSTALLATION
        DESTINATION .)

add_custom_target(dist
  COMMAND ${CMAKE_MAKE_PROGRAM} package
  COMMENT "custom target to create distribution")

message(STATUS "Installation location = ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Installation version = ${VERSION}")