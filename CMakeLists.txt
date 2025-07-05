include(CheckIncludeFiles)

cmake_minimum_required(VERSION 3.6)

# OS constraint check - movr only supports Linux and macOS
if(WIN32 AND NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR 
        "movr only supports Linux and macOS. Windows is not supported.\n"
        "If you need to build on Windows, please use Windows Subsystem for Linux (WSL).\n"
        "We have tested on Ubuntu and macOS systems."
    )
endif()

if(NOT APPLE AND NOT UNIX)
    message(FATAL_ERROR 
        "Unsupported operating system. movr only supports Linux and macOS.\n"
        "We have tested on Ubuntu and macOS systems."
    )
endif()

project(movr)

# Global options
set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/")

# Set generator to Unix Makefiles for better portability
if(NOT CMAKE_GENERATOR)
    set(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
endif()

# Add portability settings
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Suppress warnings from R headers
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wno-pedantic -Wno-unknown-pragmas -Wno-unused-parameter)
endif()

# Disable GNU extensions in generated Makefiles
set(CMAKE_MAKE_PROGRAM "make" CACHE INTERNAL "" FORCE)
set(CMAKE_GENERATOR_TOOLSET "" CACHE INTERNAL "" FORCE)
set(CMAKE_MAKE_PROGRAM_FLAGS "" CACHE INTERNAL "" FORCE)

# Source files
set(SOURCES
  src/flowmap.c
  src/order.c
  src/order.h
)

# Find external libraries
find_package(R REQUIRED)
find_package(GLIB REQUIRED)

# Add libraries and include directories
set(LIBS ${R_LIBRARIES} ${GLIB_LIBRARIES})
include_directories(${R_INCLUDE_DIR} ${GLIB_INCLUDE_DIRS})

# Generate shared library
add_library(${CMAKE_PROJECT_NAME} SHARED ${SOURCES})
target_link_libraries(${CMAKE_PROJECT_NAME} ${LIBS})

# Set output properties for R compatibility
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
    PREFIX ""
    SUFFIX ".so"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

# Install target
install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION lib)