cmake_minimum_required(VERSION 3.21)
project(Partout)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Include headers
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Library versions
set(PARTOUT_SHA1 1875122d)
set(OPENSSL_VERSION 3.5.2)

# Swift static lib
add_library(Partout STATIC IMPORTED)
set_target_properties(Partout PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/libs/${ANDROID_ABI}/libPartout-${PARTOUT_SHA1}.a
)
add_library(PartoutImplementations STATIC IMPORTED)
set_target_properties(PartoutImplementations PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/libs/${ANDROID_ABI}/libPartoutImplementations-${PARTOUT_SHA1}.a
)
add_library(openssl_crypto STATIC IMPORTED)
set_target_properties(openssl_crypto PROPERTIES
        IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/libs/${ANDROID_ABI}/openssl/libcrypto-${OPENSSL_VERSION}.a
)
add_library(openssl_ssl STATIC IMPORTED)
set_target_properties(openssl_ssl PROPERTIES
        IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/libs/${ANDROID_ABI}/openssl/libssl-${OPENSSL_VERSION}.a
)

# Runtime Swift libs (dynamic, will be loaded at runtime)
set(SWIFT_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libs/${ANDROID_ABI}/6.1)
file(GLOB SWIFT_RUNTIME_SOS "${SWIFT_LIB_DIR}/lib*.so")

foreach(SO_FILE ${SWIFT_RUNTIME_SOS})
    get_filename_component(SO_NAME ${SO_FILE} NAME_WE)
    string(REPLACE "lib" "" lib ${SO_NAME})
    add_library(${lib} SHARED IMPORTED)
    set_target_properties(${lib} PROPERTIES
        IMPORTED_LOCATION ${SO_FILE}
    )
    list(APPEND AUTO_SWIFT_LIBS ${lib})
endforeach()

# Native library for JNI
add_library(PassepartoutNative SHARED wrapper.c)
target_link_libraries(
    PassepartoutNative
    Partout
    PartoutImplementations
    openssl_crypto
    openssl_ssl
    ${AUTO_SWIFT_LIBS}
)
