# 第三阶段题册 · 12 关（正式进入 CUDA）

> 配套《第三阶段手册》（桌面）。做完一关，回到仓库根目录提交一次：
> `cd ~/projects/cuda-performance-lab && git add . && git commit -m "Week3: 第 N 关"`
> 所有程序放 `cuda/src/`（一个 .cu = 一个可执行文件，CMake 自动收编）。
> 构建进 `cuda/build/`：`cmake .. && make`，之后改代码只需 `make`。
> 参考答案全部在本机（RTX 5070 / CUDA 12.8）真机跑过，做完再对照。

| 关卡 | 主题 | 对应计划 | 手册章节 |
|---|---|---|---|
| 1~2 | GPU 信息卡 + hello_cuda 两种编译 | Day 15 | 第三部分 |
| 3~4 | 第一个 kernel + 执行配置实验 | Day 16 | 第四部分 |
| 5~6 | 四变量卡 + ⭐Vector Add | Day 17 | 第五部分 |
| 7~8 | ceil div 实验 + 越界实验 | Day 18 | 第六部分 |
| 9~10 | API 默写 + ⭐完整流水线 | Day 19 | 第七部分 |
| 11 | CUDA_CHECK 宏 + 捉非法访问 | Day 20 | 第八部分 |
| 12 | 8 问口试 + 层级图 + 周验收 | Day 21 | 第九部分 |

---

## 第 1 关 · GPU 信息卡（Day 15）

跑两条命令，把三个信息记进 `docs/gpu-info.md`（docs/ 目录今天顺手建出来）：

```bash
nvidia-smi
nvcc --version
ls /usr/local/ | grep cuda
```

- [ ] 记下 GPU 型号、驱动版本、CUDA Toolkit 版本（三样）
- [ ] 能一句话说清：`nvidia-smi` 管的是**驱动**，`nvcc` 管的是**编译器**，两码事
- [ ] `git commit -m "Week3: 第 1 关"`

## 第 2 关 · hello_cuda 两种编译（Day 15）

建 `cuda/src/hello_cuda.cu`：用 `cudaGetDeviceCount` 查设备数 + 打印 Hello, CUDA!（骨架见手册第三部分）。
先用 nvcc 裸编译：`nvcc -arch=native hello_cuda.cu -o hello_cuda && ./hello_cuda`；
再走 CMake 三步：`mkdir -p build && cd build && cmake .. && make`，跑 `./hello_cuda`。

- [ ] 两种方式都编译运行成功
- [ ] 能说出 `nvcc` 和 `g++` 的分工（.cu 里的 GPU 代码只有 nvcc 认识）
- [ ] 故意用 `g++ hello_cuda.cu` 编一次，看看报什么错（见怪不怪即可）
- [ ] `git commit -m "Week3: 第 2 关"`

## 第 3 关 · 第一个 kernel（Day 16）                         OK

写 `cuda/src/hello_kernel.cu`：`__global__ void hello()` 打印自己的 block/thread 编号，
`<<<2, 4>>>` 启动，启动后 `cudaDeviceSynchronize()` 再收尾（完整模板见手册第四部分）。

- [ ] 输出 8 行，每行一个（block, thread）组合且不重复
- [ ] 能解释 `<<<grid, block>>>` 两个参数各是什么
- [ ] 能说出 kernel 体里的代码被"复制执行"了几遍

## 第 4 关 · 执行配置实验（Day 16）                       OK

同一个程序改 4 种启动方式各跑一次：`<<<1,1>>>`、`<<<1,8>>>`、`<<<2,4>>>`、`<<<4,2>>>`。
每种都先在纸上猜输出行数和内容，再跑验证。最后连跑两次 `<<<2,4>>>` 对比输出顺序。

- [ ] 四种配置行数分别为 1 / 8 / 8 / 8，且后两种的编号组合不同
- [ ] 亲眼见到：同样的程序两次运行输出顺序可能不同（并行、乱序、正常）
- [ ] 能心算：总执行次数 = grid × block

## 第 5 关 · 四变量卡（Day 17）                     OK

写 `cuda/src/variables.cu`：`<<<3, 4>>>` 启动一个 kernel，
打印 `threadIdx.x / blockIdx.x / blockDim.x / gridDim.x` 四个值，并加一列"我的全局编号"。
（格式参考手册第五部分，公式自己写。）

- [ ] 12 行输出，全局编号 0~11 恰好各出现一次
- [ ] 四个变量各用一句话解释（说得出，别背错）
- [ ] 能解释"全局编号"那一列的公式是怎么来的

## 第 6 关 · ⭐Vector Add（Day 17，本周主交付）

写 `cuda/src/vector_add.cu`：host 骨架照抄手册第五部分（Day 19 才讲透，先照抄），
**kernel 里的三个 TODO 必须自己写**：算全局编号 → 判越界 → 写结果。N = 1000，block = 256。

- [ ] 输出 `校验通过：全部 1000 个元素正确`
- [ ] 能口述：4 个内置变量在这个 kernel 里各自扮演什么角色
- [ ] `git commit -m "Week3: vector_add 完成（本周主交付）"`

## 第 7 关 · ceil div 实验（Day 18）               OK

把 vector_add 的 N 改三次跑三次：1000、1001、1024（block 恒为 256）。
每次先在纸上算 grid = (N + 256 - 1) / 256 和"总线程数 - N = 多少个闲线程"，再跑验证。

- [ ] 三种 N 全部校验通过，grid 分别为 4 / 4 / 4
- [ ] 能解释：为什么不能写 `grid = N / block`（拿 N=1000 算给我看）
- [ ] 闲线程数分别为 24 / 23 / 0，你的纸面答案和事实一致

## 第 8 关 · 越界实验（Day 18）

写 `cuda/src/oob_demo.cu`（代码 10 行，手册第六部分有模板）：kernel 里**故意不写 if**，
`<<<4, 256>>>` 处理 N=1000 的数据。裸跑观察同步返回的错误，
再用 `compute-sanitizer ./oob_demo` 抓真凶。

- [ ] 亲眼见到：裸跑可能显示 `no error`——未定义行为最危险的形态是"看起来没事"
- [ ] sanitizer 输出里找到第一个越界线程：block (3,0,0) 中 thread (232,0,0)，算出它的全局编号
- [ ] 能说出 compute-sanitizer 是干嘛的、什么时候用

## 第 9 关 · API 默写 + 事故现场（Day 19）

**纸上**默写三个 API 的完整签名和 `cudaMemcpyKind` 四个枚举（不看任何资料）；
然后做事故实验：把 vector_add 里某条 cudaMemcpy 的源和目标**故意写反**，
跑一次，观察现象，再改回来。

- [ ] `cudaMalloc(void** devPtr, size_t size)` 一字不差（注意是二级指针！）
- [ ] `cudaMemcpy(dst, src, count, kind)` —— 记住目标永远在前（和 memcpy 一样）
- [ ] 四个 kind 说得出方向：HostToDevice / DeviceToHost / HostToHost / DeviceToDevice
- [ ] 事故现场亲眼看过了，能解释为什么写反后"校验失败"而不是崩溃

## 第 10 关 · ⭐完整流水线默写（Day 19）

新建 `cuda/src/vector_add_v2.cu`，**合上所有资料**，从空文件写出完整六步：
分配显存 → 数据拷上 GPU → 启动 kernel → 结果拷回 → 校验 → 全部释放。
（vector 第 2 周学过：`h_a.data()` 拿首地址。）

- [ ] 一次编译通过、校验通过（错了就当场搞懂，这关的价值就在错的过程）
- [ ] 在纸上画出数据流图：两个 vector + 三块显存 + 六个箭头
- [ ] `git commit -m "Week3: 完整流水线默写通过"`

## 第 11 关 · CUDA_CHECK 宏 + 捉非法访问（Day 20）

1. 建 `cuda/src/common.cuh`，封装 CUDA_CHECK 宏（手册第八部分有完整代码）；
   给 `vector_add.cu` 全部 CUDA 调用套上宏，kernel 启动后补 `cudaGetLastError()` + `cudaDeviceSynchronize()` 双保险。
2. 写 `cuda/src/illegal_demo.cu`：kernel 里故意 `i = threadIdx.x + 99999999`，
   观察启动后 `getLastError` 和 `synchronize` 各报告什么。

- [ ] 所有本周程序都带错误检查（lab.pdf 红线：**CUDA 程序不检查 error = 没写完**）
- [ ] 亲眼见到：launch 后是 `no error`，同步时才爆 `an illegal memory access was encountered`
- [ ] 能解释为什么必须"双保险"（启动错误当场查，执行错误异步爆）
- [ ] `git commit -m "Week3: 错误检查全覆盖"`

## 第 12 关 · 8 问口试 + 层级图 + 周验收（Day 21，不写新 kernel）

1. **手绘两张图**（纸上）：
   图 A 层级图：Grid → 4 个 Block → 每 Block 256 Thread，标上公式；
   图 B 数据流图：host 三个 vector ↔ device 三块显存，六步流水线。
2. **8 问全部口头回答清楚**（题目见手册第九部分，录音自查最有效）。
3. 对照手册第十一部分验收清单逐项打勾。

- [ ] 两张图画完并拍照（可存 `docs/week3/`）
- [ ] 8 问全部能脱稿回答
- [ ] `git log` 里本周 12 关每关至少一条记录
- [ ] 验收清单全部打勾 → 有资格进第 4 周（GPU Memory Hierarchy）

---
---

# 参考答案（做完再看！）

## 第 2 关 · hello_cuda.cu

```cpp
#include <cstdio>
#include <cuda_runtime.h>

int main() {
    int count = 0;
    cudaError_t err = cudaGetDeviceCount(&count);
    if (err != cudaSuccess) {
        fprintf(stderr, "CUDA 不可用: %s\n", cudaGetErrorString(err));
        return 1;
    }
    printf("检测到 %d 块 CUDA 设备\n", count);   // 本机输出：检测到 1 块 CUDA 设备
    printf("Hello, CUDA!\n");
    return 0;
}
```

```bash
# 方式一：nvcc 裸编译（-arch=native：按本机 GPU 生成代码，无警告）
nvcc -arch=native hello_cuda.cu -o hello_cuda && ./hello_cuda

# 方式二：CMake 三步（cuda/ 已配好自动收编）
cd ~/projects/cuda-performance-lab/cuda
mkdir -p build && cd build && cmake .. && make && ./hello_cuda
```

## 第 3 关 · hello_kernel.cu

```cpp
#include <cstdio>

__global__ void hello() {   // __global__ = "这段代码在 GPU 上跑，由 CPU 启动"
    printf("Hello from block %d / thread %d\n", blockIdx.x, threadIdx.x);
}

int main() {
    hello<<<2, 4>>>();          // 2 个 block × 每 block 4 个 thread = 这段代码跑 8 遍
    cudaDeviceSynchronize();    // 等 GPU 把话说完再关灯（Day 20 讲透为什么）
    printf("host: kernel 已启动并执行完毕\n");
    return 0;
}
```

本机真实输出（跑两次对比，注意顺序变了——并行没有排队叫号）：

```text
第一次：block 0 的 4 行在前，block 1 的 4 行在后
第二次：block 1 的 4 行在前，block 0 的 4 行在后
两次的 host 行都在最后 ✓
```

## 第 4 关

`<<<1,1>>>` 1 行；`<<<1,8>>>` 8 行（block 恒为 0，thread 0~7）；
`<<<2,4>>>` 8 行（block 0/1 各 thread 0~3）；`<<<4,2>>>` 8 行（block 0~3 各 thread 0/1）。
总次数 = grid × block：1、8、8、8。顺序随机 = 并行执行的自然结果。

## 第 5 关 · variables.cu

```cpp
#include <cstdio>

__global__ void whereAmI() {
    printf("block %d / thread %d | threadIdx=%d blockIdx=%d blockDim=%d gridDim=%d | 全局编号 = %d\n",
           blockIdx.x, threadIdx.x,
           threadIdx.x, blockIdx.x, blockDim.x, gridDim.x,
           blockIdx.x * blockDim.x + threadIdx.x);
}

int main() {
    whereAmI<<<3, 4>>>();
    cudaDeviceSynchronize();
    return 0;
}
```

本机真实输出（节选，顺序每次可能不同）：

```text
block 2 / thread 0 | threadIdx=0 blockIdx=2 blockDim=4 gridDim=3 | 全局编号 = 8
block 2 / thread 1 | threadIdx=1 blockIdx=2 blockDim=4 gridDim=3 | 全局编号 = 9
...
block 0 / thread 3 | threadIdx=3 blockIdx=0 blockDim=4 gridDim=3 | 全局编号 = 3
```

## 第 6 关 · vector_add.cu（Day 17 版，先照抄 host、自写 kernel）

```cpp
#include <cstdio>
#include <vector>
#include <cuda_runtime.h>

__global__ void vecAdd(const float* a, const float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;   // ① 算出我的全局编号
    if (i < n) c[i] = a[i] + b[i];                   // ② 越界挡板（为什么需要？第 7/8 关见分晓）
}

int main() {
    const int N = 1000;
    size_t bytes = N * sizeof(float);

    // host 端数据（第 2 周的老朋友 vector）
    std::vector<float> h_a(N), h_b(N), h_c(N);
    for (int i = 0; i < N; ++i) { h_a[i] = i * 1.0f; h_b[i] = i * 2.0f; }

    // device 端分配显存
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    // 数据拷上 GPU
    cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyHostToDevice);

    // 启动：grid × block = 4 × 256 = 1024 个线程 >= 1000，多余靠 if 挡
    int block = 256;
    int grid = (N + block - 1) / block;
    vecAdd<<<grid, block>>>(d_a, d_b, d_c, N);
    cudaDeviceSynchronize();

    // 结果拷回 + 校验
    cudaMemcpy(h_c.data(), d_c, bytes, cudaMemcpyDeviceToHost);
    int bad = 0;
    for (int i = 0; i < N; ++i)
        if (h_c[i] != h_a[i] + h_b[i]) ++bad;
    if (bad == 0) printf("校验通过：全部 %d 个元素正确\n", N);
    else          printf("校验失败：%d 个元素错误\n", bad);

    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
    return 0;
}
```

本机真实输出：`校验通过：全部 1000 个元素正确`

## 第 7 关

| N | grid = (N+255)/256 | 总线程 | 闲线程 | 校验 |
|---|---|---|---|---|
| 1000 | 4 | 1024 | 24 | ✓ |
| 1001 | 4 | 1024 | 23 | ✓ |
| 1024 | 4 | 1024 | 0 | ✓ |

`N / block` 为什么不行：1000 / 256 整除 = 3 个 block = 768 线程 < 1000，**末尾 232 个元素没人算**，
校验直接失败——而且失败得很"安静"，只体现在 bad 计数上。

## 第 8 关 · oob_demo.cu（故意写错的教学靶）

```cpp
#include <cstdio>
#include <cuda_runtime.h>

__global__ void vecAddNoGuard(const float* a, const float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    c[i] = a[i] + b[i];          // 故意不写 if (i < n)
}

int main() {
    const int N = 1000;
    size_t bytes = N * sizeof(float);
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes); cudaMalloc(&d_b, bytes); cudaMalloc(&d_c, bytes);
    int block = 256, grid = (N + block - 1) / block;    // 4 个 block = 1024 个线程
    vecAddNoGuard<<<grid, block>>>(d_a, d_b, d_c, N);   // 第 1000~1023 号线程越界！
    cudaError_t err = cudaDeviceSynchronize();
    printf("同步后收到的错误: %s\n", cudaGetErrorString(err));
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
    return 0;
}
```

本机真实现象（这个结果比报错更震撼）：

```text
裸跑:            同步后收到的错误: no error     ← 1000~1023 号线程越界读写，系统一声不吭！
compute-sanitizer:
  ========= Invalid __global__ read of size 4 bytes
  =========     by thread (232,0,0) in block (3,0,0)      ← 全局编号 3×256+232 = 1000，一个不差
  =========     Address ... is 1 bytes after the nearest allocation ... of size 4,000 bytes
```

第一个越界的正是 1000 号线程；裸跑不报错是因为越界落在显存分配的"缓冲地皮"上——
**未定义行为最危险的形态就是看起来没事**，和第 2 周 `v[100]` 一个道理，GPU 上还更隐蔽。

## 第 9 关

```c
cudaError_t cudaMalloc(void** devPtr, size_t size);
//                        ↑ 二级指针：CUDA 要往"你那个指针变量"里写地址，得给它变量的地址
cudaError_t cudaMemcpy(void* dst, const void* src, size_t count, cudaMemcpyKind kind);
//                     目标在前，源在后——和 C 的 memcpy 完全同款
cudaError_t cudaFree(void* devPtr);

cudaMemcpyHostToDevice   // 内存 → 显存（上传）
cudaMemcpyDeviceToHost   // 显存 → 内存（下载）
cudaMemcpyHostToHost     // 内存 → 内存
cudaMemcpyDeviceToDevice // 显存 → 显存
```

事故现场：`cudaMemcpy(h_a.data(), d_a, ...)`（方向写反）不会崩溃，
而是把显存里的垃圾当"数据"抄进 h_a、再把 h_a 的首地址当"显存地址"传给驱动——
校验失败、数字全乱，但程序脸不红心不跳。方向要靠 kind 和参数顺序共同讲清楚。

## 第 10 关 · vector_add_v2.cu（六步流水线，结构同第 6 关但必须默写）

分配（cudaMalloc ×3）→ 上传（cudaMemcpy HtoD ×2）→ 启动（<<<>>>）→
同步（cudaDeviceSynchronize）→ 下载校验（cudaMemcpy DtoH + 循环比对）→ 释放（cudaFree ×3）。
画图模板：

```text
  host (内存)                PCIe 总线               device (显存)
h_a[N] ──────────── cudaMemcpy HtoD ───────────▶ d_a
h_b[N] ──────────── cudaMemcpy HtoD ───────────▶ d_b
                                                ▼
                                          vecAdd<<<4,256>>>
                                                ▼
h_c[N] ◀──────────── cudaMemcpy DtoH ─────────── d_c
```

## 第 11 关 · common.cuh + illegal_demo.cu

`cuda/src/common.cuh`：

```cpp
#pragma once
#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

// 任何 CUDA 调用都从这走：出事立刻打印文件、行号、错误原因并退出
#define CUDA_CHECK(call)                                                  \
    do {                                                                  \
        cudaError_t err__ = (call);                                       \
        if (err__ != cudaSuccess) {                                       \
            fprintf(stderr, "CUDA 错误 %s:%d: %s\n",                      \
                    __FILE__, __LINE__, cudaGetErrorString(err__));       \
            exit(EXIT_FAILURE);                                           \
        }                                                                 \
    } while (0)
```

给 vector_add 用法：`CUDA_CHECK(cudaMalloc(&d_a, bytes));`；
kernel 启动后补双保险：

```cpp
vecAdd<<<grid, block>>>(d_a, d_b, d_c, N);
CUDA_CHECK(cudaGetLastError());        // ① 查启动（配置）错误
CUDA_CHECK(cudaDeviceSynchronize());   // ② 查执行错误（异步爆雷在这里现形）
```

`cuda/src/illegal_demo.cu`：

```cpp
#include <cstdio>
#include <cuda_runtime.h>

__global__ void oops(float* c) {
    int i = threadIdx.x + 99999999;   // 故意指到远处的非法显存
    c[i] = 1.0f;
}

int main() {
    float* d_c;
    CUDA_CHECK(cudaMalloc(&d_c, 1000 * sizeof(float)));
    oops<<<1, 32>>>(d_c);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaFree(d_c));
    return 0;
}
```

本机真实输出（双保险价值的铁证）：

```text
launch 后 getLastError : no error                              ← 启动本身没问题
同步返回值              : an illegal memory access was encountered   ← 执行错误，异步爆雷
```

（第 10 行 `printf` 那句换成你自己的打印即可，核心是两行报错对照。）

## 第 12 关

两张图 + 8 问，答案要点全在手册第九部分，无需参考代码。
自查标准：8 问每一问都能**先说结论、再给一句理由**，卡壳超 10 秒就回去翻对应手册部分。
