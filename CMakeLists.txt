include(CheckIncludeFiles)

cmake_minimum_required(VERSION 2.8.12)

# project name
project(movr)

# global options
set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/")

# source files of this project
set(movr_SRCS
  src/flowmap.c
  src/order.c
  src/order.h
)
set(SOURCES ${movr_SRCS})

# find external libraries
find_package(R REQUIRED)
find_package(GLIB REQUIRED)

# add external libraries
set(LIBS ${LIBS} ${R_LIBRARIES})
set(LIBS ${LIBS} ${GLIB_LIBRARIES})

# add header file dir
include_directories (
    ${R_INCLUDE_DIR}
    ${GLIB_INCLUDE_DIRS}
)

# generate a shared library
add_library(${CMAKE_PROJECT_NAME} SHARED ${SOURCES})
target_link_libraries(${CMAKE_PROJECT_NAME} ${LIBS})

# Set output name and extension for cross-platform R compatibility
if(APPLE)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".so"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/libs"
    )
elseif(UNIX)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".so"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/libs"
    )
elseif(WIN32)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        PREFIX ""
        SUFFIX ".dll"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/libs"
    )
endif()

# install library to custom location
install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION lib)