# ================= CMake 入门逐行解释（Day 13）=================
# CMake 不编译代码，它是个"翻译官"：读这份清单，生成 Makefile，
# 真正干活的是 make。好处：换个电脑、换个目录结构，只改这份文件。

# 声明支持的 CMake 最低版本（低于它直接报错，防止老语法）
cmake_minimum_required(VERSION 3.16)

# 项目名 + 用的语言（CXX = C++）
project(cuda_lab_cpp CXX)

# 全项目统一用 C++17（lambda/auto/智能指针都稳）
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)   # 编译器不支持就直接报错，别悄悄降级

# 没指定构建类型时默认 Debug：带 -g 调试信息，给 gdb 用（Day 14 关键）
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif()

# 生成可执行文件 analyzer，由 data.cpp 编译而来（add_executable(名字 参与编译的文件...))
add_executable(analyzer data.cpp)

# 练习专用：故意写崩的程序，Day 14 用 gdb 抓它
add_executable(segfault src/segfault.cpp)
#我在学习cmake

