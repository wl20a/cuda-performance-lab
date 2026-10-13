#include<iostream>
#include<cstdlib>
using namespace std;
#include<algorithm>
#include<vector>
#include<string>
#include<list>
#include<iterator>
#include<fstream>
#include<memory>
#include <cuda_runtime.h>

#define CUDA_CHECK(call)                                                  \
    do {                                                                  \
        cudaError_t err = (call);                                         \
        if (err != cudaSuccess) {                                         \
            fprintf(stderr, "CUDA 错误 %s（%s:%d）\n",                    \
                    cudaGetErrorString(err), __FILE__, __LINE__);         \
            exit(1);                                                      \
        }                                                                 \
    } while (0) 
    const int N = 1<<25;
    const int M=N/32;

__global__ void copyCoalesced(const float* in, float* out, int m)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= m) return;
    out[i] = in[i];
}

__global__ void copyStrided(const float* in, float* out, int m)
 {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= m) return;
    out[i*32] = in[i ];
}//每128b浪费120b

float bench(bool strided, const float* in, float* out) {
    const int bs = 256, grid = (M + bs - 1) / bs, REPEAT = 20;
    for (int r = 0; r < 2; r++) {                   // 热身 2 次（第 1 步的纪律）
        if (strided) copyStrided <<<grid, bs>>>(in, out, M);
        else         copyCoalesced<<<grid, bs>>>(in, out, M);
    }
    CUDA_CHECK(cudaDeviceSynchronize());
    cudaEvent_t s, e;
    CUDA_CHECK(cudaEventCreate(&s));
    CUDA_CHECK(cudaEventCreate(&e));
    CUDA_CHECK(cudaEventRecord(s));
    for (int r = 0; r < REPEAT; r++) {
        if (strided) copyStrided <<<grid, bs>>>(in, out, M);
        else         copyCoalesced<<<grid, bs>>>(in, out, M);
    }
    CUDA_CHECK(cudaEventRecord(e));
    CUDA_CHECK(cudaEventSynchronize(e));
    float ms;
    CUDA_CHECK(cudaEventElapsedTime(&ms, s, e));
    CUDA_CHECK(cudaEventDestroy(s));
    CUDA_CHECK(cudaEventDestroy(e));
    return ms / REPEAT;
}



int main()
{
    float* hIn  = (float*)malloc(N * sizeof(float));
    float* hOut = (float*)malloc(N* sizeof(float));
    for (int i = 0; i < N; i++) hIn[i] = (float)(i & 1023);   // 小整数，float 精确存

    float *dIn, *dOut;
    CUDA_CHECK(cudaMalloc(&dIn,  N * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&dOut, N * sizeof(float)));
    CUDA_CHECK(cudaMemcpy(dIn, hIn, N * sizeof(float), cudaMemcpyHostToDevice));

     copyStrided<<<(M + 255) / 256, 256>>>(dIn, dOut, M);
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaMemcpy(hOut, dOut, M * sizeof(float), cudaMemcpyDeviceToHost));
    int bad = 0;
    for (int i = 0; i < 1000; i++)
        if (hOut[i * 32] != hIn[i]) bad++;
    printf("乱序版抽查: 错 %d 处（应为 0）\n\n", bad);

    float t1 = bench(false, dIn, dOut);
    float t2 = bench(true,  dIn, dOut);
    printf("合并访问（连着搬）: %.3f ms\n", t1);
    printf("跳着搬（隔 31 箱）: %.3f ms  → 慢 %.1f 倍\n", t2, t2 / t1);

    free(hIn); free(hOut);
    CUDA_CHECK(cudaFree(dIn)); CUDA_CHECK(cudaFree(dOut));

    return 0;
}