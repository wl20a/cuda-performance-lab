# cuda-performance-lab

从零开始的高性能计算训练场——56 天，从 Linux 命令行一路打到 CUDA 性能优化。

## 这是什么

一个按 56 天计划推进的 CUDA 学习仓库：每周一个主题，配套一本手册 + 一份闯关题册（`TASKS.md`），
每个知识点都落成一个能跑的小程序。**git log 就是学习日志**，每一关一个 commit。

## 进度

- [x] **Week 1** — Linux 命令行 + g++ 编译流程 + git 基本操作
- [x] **Week 2** — C++ 收尾（STL 算法 / 智能指针 / lambda）+ CMake 多文件工程 + GDB 调试，
      四步全链路验收通过（写 C++ → CMake 构建 → Git 管理 → GDB 调试）
- [x] **Week 3** — CUDA 编程模型：kernel / Thread-Block-Grid 层级 / host-device 内存搬运 /
      线程映射与越界防护 / 错误检查（CUDA_CHECK 宏 + 双保险）
- [ ] **Week 4** — GPU Memory Hierarchy：block size 计时实验 / warp / coalescing / shared memory

## 目录结构

```
cpp/    第 1~2 周：analyzer 统计工程（include/src 分离 + CMake + GDB 验收）
cuda/   第 3 周起：CUDA 程序群（hello_cuda → vector_add → oob_demo 越界实验 → 错误检查全覆盖）
        每个目录配 TASKS.md 闯关题册（题目 + 参考答案，全部真机验证）
```

## 环境

RTX 5070 Laptop GPU（8GB，Blackwell）· Ubuntu 24.04 · CUDA 12.8 · CMake 3.28 · g++ 13.3

## 构建示例

```bash
cd cuda && mkdir -p build && cd build
cmake .. && make     # 自动收编 src/ 下每个 .cu，各生成一个同名可执行文件
./vector_add_safe
```
