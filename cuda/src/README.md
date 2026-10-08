# src/ —— 本周所有 .cu 程序放这里

约定：**一个文件 = 一个自带 main() 的独立小程序 = build 后一个同名可执行文件**。

| 文件 | 哪天写 | 干什么 |
|---|---|---|
| hello_cuda.cu | Day 15 | 第一块敲门砖：确认 CUDA 链路通了 |
| hello_kernel.cu | Day 16 | 第一个 kernel：打印线程信息 |
| variables.cu | Day 17 | 四个内置变量亲眼看一遍 |
| vector_add.cu | Day 17 | ⭐本周主交付：C[i] = A[i] + B[i] |
| oob_demo.cu | Day 18 | 故意越界的实验靶（留着喂 compute-sanitizer） |
| illegal_demo.cu | Day 20 | 故意指到非法显存的实验靶（观察异步报错） |

构建（CMake 已配好，会自动收编这里的每个 .cu）：

```bash
cd ~/projects/cuda-performance-lab/cuda
mkdir -p build && cd build
cmake ..
make            # 之后改完代码反复用这一条
./hello_cuda    # 想跑哪个跑哪个
```

参考答案在 TASKS.md 底部——先自己写，卡住再对照。
