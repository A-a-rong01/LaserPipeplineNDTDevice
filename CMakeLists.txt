# Requiers CMake version 3.23+
cmake_minimum_required(VERSION 3.23)

# Project metadata
project(NDTImageProcessor LANGUAGES CXX)

# C++ configuration details
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Used for C/C++ IntelliSense
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Dependencies
include(FetchContent)

# Pybind11
FetchContent_Declare(
    pybind11
    GIT_REPOSITORY  https://github.com/pybind/pybind11.git
    GIT_TAG         f5fbe867d2d26e4a0a9177a51f6e568868ad3dc8 # release-3.0.1
)
FetchContent_MakeAvailable(pybind11)

# Google Test
FetchContent_Declare(
    googletest
    GIT_REPOSITORY  https://github.com/google/googletest.git
    GIT_TAG         52eb8108c5bdec04579160ae17225d66034bd723 # release-1.17.0
)

# DO NOT USE STATIC RUNTIME ON WINDOWS
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Python configuration
find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

# OpenCV configuration
find_package(OpenCV REQUIRED)

# Core library - logic that does not contain main
add_library(imgproc_core
    src/cpp_image_processor.cc
    src/py_image_processor.cc
)

# Define include directories for the library
target_include_directories(imgproc_core PUBLIC .) # root for relative imports

# Link Python, Pybind, and OpenCV to the core library
target_link_libraries(imgproc_core PUBLIC pybind11::embed ${OpenCV_LIBS})


# Application
add_executable(imgproc
    src/driver.cc
)

# Link core logic as a library
target_link_libraries(imgproc PRIVATE imgproc_core)

# Testing with Google Test
enable_testing()

add_executable(unit_tests
    tests/name_test.cc
)

target_link_libraries(unit_tests PRIVATE
    imgproc_core
    GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(unit_tests)

# install the main binary
install(TARGETS imgproc DESTINATION bin)


execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import site; print(site.getsitepackages()[0])"
    OUTPUT_VARIABLE PYTHON_SITE_PACKAGES
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

install(DIRECTORY scripts DESTINATION ${PYTHON_SITE_PACKAGES})