include(CheckIncludeFiles)

cmake_minimum_required(VERSION 3.6)

# project name
project(movr)

# global options
set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/")

# Set generator to Unix Makefiles for better portability
if(NOT CMAKE_GENERATOR)
    set(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
endif()

# Add portability settings to avoid GNU extensions
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Suppress warnings from R headers that we can't control
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wno-pedantic -Wno-unknown-pragmas -Wno-unused-parameter)
endif()

# Disable GNU extensions in generated Makefiles
set(CMAKE_MAKE_PROGRAM "make" CACHE INTERNAL "" FORCE)
set(CMAKE_GENERATOR_TOOLSET "" CACHE INTERNAL "" FORCE)

# Use portable make settings
set(CMAKE_MAKE_PROGRAM_FLAGS "" CACHE INTERNAL "" FORCE)

# source files of this project
set(movr_SRCS
  src/flowmap.c
  src/order.c
  src/order.h
)
set(SOURCES ${movr_SRCS})

# find external libraries with better error handling
message(STATUS "Finding R...")
find_package(R REQUIRED)
if(NOT R_FOUND)
    message(FATAL_ERROR "R not found. Please ensure R is installed and R_HOME is set.")
endif()
message(STATUS "R found: ${R_HOME}")

message(STATUS "Finding GLIB...")
find_package(GLIB REQUIRED)
if(NOT GLIB_FOUND)
    message(FATAL_ERROR "GLIB not found. Please install glib2 development libraries.")
endif()
message(STATUS "GLIB found: ${GLIB_INCLUDE_DIRS}")

# add external libraries
set(LIBS ${LIBS} ${R_LIBRARIES})
set(LIBS ${LIBS} ${GLIB_LIBRARIES})

# add header file dir
include_directories (
    ${R_INCLUDE_DIR}
    ${GLIB_INCLUDE_DIRS}
)

message(STATUS "R include dir: ${R_INCLUDE_DIR}")
message(STATUS "GLIB include dirs: ${GLIB_INCLUDE_DIRS}")
message(STATUS "Libraries: ${LIBS}")

# generate a shared library
add_library(${CMAKE_PROJECT_NAME} SHARED ${SOURCES})
target_link_libraries(${CMAKE_PROJECT_NAME} ${LIBS})

# Set output name and extension for cross-platform R compatibility
# Build directly to src directory to avoid copying
if(APPLE)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".so"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
    )
    message(STATUS "Building for macOS")
elseif(UNIX)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".so"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
    )
    message(STATUS "Building for Linux")
elseif(WIN32)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".dll"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
    )
    message(STATUS "Building for Windows")
endif()

message(STATUS "Library will be built to: ${CMAKE_CURRENT_SOURCE_DIR}/src")

# install library to custom location
install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION lib)