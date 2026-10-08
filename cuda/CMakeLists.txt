# ========== 第三阶段（CUDA）构建清单 · 逐行解释（Day 15）==========
# CMake 还是第二周那个"翻译官"：读这份清单 → 生成 Makefile → make 干活。
# 和 cpp/ 唯一的区别：项目语言里多了 CUDA，编译 .cu 的从 g++ 换成了 nvcc。

# 支持的最低 CMake 版本（本机 3.28，富余）
cmake_minimum_required(VERSION 3.24)

# ⚠️ 这三行必须写在 project() 之前！
# CMake 在 project() 那一刻就确定 GPU 架构，写晚了它已经用默认值(sm_52)了，
# 编译时就会冒一串"即将不支持老架构"的警告。
# native = 直接问你这块显卡要什么（RTX 5070 Laptop → sm_120，Blackwell 新架构）
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
  set(CMAKE_CUDA_ARCHITECTURES native)
endif()

# 项目名 + 用的语言：CXX 是 C++（以后 .cpp/.cu 混写用得上），CUDA 是这周的新客人
project(week3_cuda LANGUAGES CXX CUDA)

# 自动收编：src/ 里每放一个自带 main 的 .cu，
# build 时就自动多一个同名可执行文件。
# CONFIGURE_DEPENDS：新增/删除源文件时，make 会自动重新 cmake，不用手动。
file(GLOB DAY_SOURCES CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cu)
foreach(src_file ${DAY_SOURCES})
  get_filename_component(target_name ${src_file} NAME_WE)   # hello_cuda.cu → hello_cuda
  add_executable(${target_name} ${src_file})
endforeach()

# 日常速度循环（在 cuda/build/ 里）：
#   make            改完 .cpp/.cu 之后跑这条（只重编改过的文件，秒级）
#   ./程序名         直接跑（每个 .cu 对应一个同名可执行文件）
# 规律和 cpp/ 完全一样：改源码只需 make，动 CMakeLists.txt 才需要重新 cmake ..
