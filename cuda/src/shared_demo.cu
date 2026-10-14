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

#define BLOCK 256
const int N=1<<22;
const int M=N/32;

__global__ void copyDirect(const float* in, float* out, int n) 
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) out[i] = in[i];
}

__global__ void copyViaShared(const float* in, float* out, int n)
{
    __shared__ float board[BLOCK];
    int t=threadIdx.x;
    int i = blockIdx.x * blockDim.x + t;

    if (i < n) board[t] = in[i];         
    __syncthreads();                        
    if (i < n)
        out[i] = board[(t + 1) % BLOCK];    

}

float bench(bool strided, const float* in, float* out) {
    const int bs = 256, grid = (M + bs - 1) / bs, REPEAT = 20;
    for (int r = 0; r < 2; r++) {                   // 热身 2 次（第 1 步的纪律）
        if (strided) copyDirect <<<grid, bs>>>(in, out, M);
        else         copyViaShared<<<grid, bs>>>(in, out, M);
    }
    CUDA_CHECK(cudaDeviceSynchronize());
    cudaEvent_t s, e;
    CUDA_CHECK(cudaEventCreate(&s));
    CUDA_CHECK(cudaEventCreate(&e));
    CUDA_CHECK(cudaEventRecord(s));
    for (int r = 0; r < REPEAT; r++) {
        if (strided) copyDirect <<<grid, bs>>>(in, out, M);
        else         copyViaShared<<<grid, bs>>>(in, out, M);
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
    float* hOut = (float*)malloc(N * sizeof(float));
    for (int i = 0; i < N; i++) hIn[i] = (float)i;

    float *dIn, *dOut;
    CUDA_CHECK(cudaMalloc(&dIn,  N * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&dOut, N * sizeof(float)));
    CUDA_CHECK(cudaMemcpy(dIn, hIn, N * sizeof(float), cudaMemcpyHostToDevice));

    // --- 正确性验证 ---
    copyViaShared<<<N / BLOCK, BLOCK>>>(dIn, dOut, N);
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaMemcpy(hOut, dOut, N * sizeof(float), cudaMemcpyDeviceToHost));
    int bad = 0;
    for (int i = 0; i < N; i++) {
        int src = (int)((i / BLOCK) * BLOCK + (i % BLOCK + 1) % BLOCK);
        if (hOut[i] != hIn[src]) bad++;
    }
    printf("绕道小黑板抄书: 错 %d 处（应为 0）\n\n", bad);

    // --- 性能 ---
    float t1 = bench(false, dIn, dOut);   // copyViaShared = 绕黑板
    float t2 = bench(true,  dIn, dOut);   // copyDirect    = 直接抄
    printf("直接抄:   %.3f ms\n", t2);
    printf("绕黑板:   %.3f ms  → 比值 %.2f（注意：没有变快！）\n", t1, t1 / t2);

    // --- 收尾 ---
    cudaFree(dIn);
    cudaFree(dOut);
    free(hIn);
    free(hOut);
    return 0;
}       