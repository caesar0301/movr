include(CheckIncludeFiles)

cmake_minimum_required(VERSION 3.6)

project(movr)

# Global options
set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/")

# Set generator appropriately for each platform
if(WIN32)
    # Use appropriate generator for Windows
    if(NOT CMAKE_GENERATOR MATCHES "Visual Studio" AND NOT CMAKE_GENERATOR MATCHES "MinGW Makefiles")
        set(CMAKE_GENERATOR "MinGW Makefiles" CACHE INTERNAL "" FORCE)
    endif()
else()
    # Set generator to Unix Makefiles for Linux/macOS
    if(NOT CMAKE_GENERATOR)
        set(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
    endif()
endif()

# Add portability settings
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Platform-specific compiler settings
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wno-pedantic -Wno-unknown-pragmas -Wno-unused-parameter)
elseif(MSVC)
    # MSVC-specific settings for Windows
    add_compile_options(/W3)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

# Windows-specific settings
if(WIN32)
    # Ensure proper Windows API definitions
    add_definitions(-DWIN32_LEAN_AND_MEAN)
    # Handle MinGW vs MSVC differences
    if(MINGW)
        # MinGW specific settings
        set(CMAKE_SHARED_LIBRARY_PREFIX "")
        set(CMAKE_SHARED_LIBRARY_SUFFIX ".dll")
    endif()
endif()

# Disable GNU extensions in generated Makefiles for non-Windows platforms
if(NOT WIN32)
    set(CMAKE_MAKE_PROGRAM "make" CACHE INTERNAL "" FORCE)
    set(CMAKE_GENERATOR_TOOLSET "" CACHE INTERNAL "" FORCE)
    set(CMAKE_MAKE_PROGRAM_FLAGS "" CACHE INTERNAL "" FORCE)
endif()

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

# Set output properties for R compatibility - platform specific
if(WIN32)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".dll"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
    )
else()
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".so"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
    )
endif()

# Install target
install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION lib)