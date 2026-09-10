# 共享数据层（common/datastore）的原生实现。
# 数据库是 schedule / tools 等特性模块共用的基础设施，因此原生代码归属
# 数据层 HAR，上层统一通过 @ohos/datastore 入口访问，不在各 feature 模块里链接 .so。
cmake_minimum_required(VERSION 3.5.0)
project(WhutHelperDatastore)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/include
)

find_library(
    # Sets the name of the path variable.
    hilog-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    hilog_ndk.z
)

# NDK 关系型数据库（OH_Rdb_*）。本机 SDK 的 arm64-v8a / x86_64 / arm 均有此库。
find_library(
    rdb-lib
    native_rdb_ndk.z
)

# ---- whutdb（原生数据层）----
add_library(whutdb SHARED whutdb.cpp)
target_link_libraries(whutdb PUBLIC ${hilog-lib} ${rdb-lib} libace_napi.z.so libc++.a)
