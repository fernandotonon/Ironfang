# Ironfang: First Siege — a micro-RTS built with Clayground, forged with QtMeshEditor.
# MIT License, see LICENSE.
cmake_minimum_required(VERSION 3.21)

project(Ironfang
        VERSION 0.1.0
        DESCRIPTION "Ironfang: First Siege - micro-RTS built with Clayground"
        HOMEPAGE_URL "https://github.com/fernandotonon/Ironfang"
        LANGUAGES CXX)

# Clayground is consumed in-tree (it has no install/export step): the framework
# lives in external/clayground as a git submodule and is added as a subdirectory.
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/clayground/CMakeLists.txt")
    message(FATAL_ERROR
        "Clayground submodule missing. Run: git submodule update --init --recursive")
endif()

# Only the plugins are needed - Clayground's own tools/examples/tests would double the
# build time. Switch them on when hacking on the framework itself.
option(IRONFANG_WITH_CLAY_TOOLS "Build Clayground tools (claydojo, clayrender)" OFF)
set(CLAYGROUND_WITH_TOOLS ${IRONFANG_WITH_CLAY_TOOLS} CACHE BOOL "" FORCE)
set(CLAYGROUND_WITH_EXAMPLES OFF CACHE BOOL "" FORCE)

enable_testing()
add_subdirectory(external/clayground)

# Clayground's CMake helpers (clay_app, clay_add_qml_test ...) live in its cmake/ dir. It
# appends that to CMAKE_MODULE_PATH inside its own directory scope, so we add it here too.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/clayground/cmake")
# Likewise clayinit.cmake sets the output directories in Clayground's scope only; clay_app()
# relies on them (it copies bin/qml into the macOS bundle after linking), so mirror them here.
# (Candidate upstream fix: make clayinit's settings CACHE INTERNAL or use CMAKE_BINARY_DIR.)
if(NOT (ANDROID OR IOS OR EMSCRIPTEN))
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
elseif(EMSCRIPTEN)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
endif()
add_subdirectory(app)

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
