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
#define BLOCK 256
const int N=1<<24;

#define CUDA_CHECK(call)                                                  \
    do {                                                                  \
        cudaError_t err = (call);                                         \
        if (err != cudaSuccess) {                                         \
            fprintf(stderr, "CUDA 错误 %s（%s:%d）\n",                    \
                    cudaGetErrorString(err), __FILE__, __LINE__);         \
            exit(1);                                                      \
        }                                                                 \
    } while (0)

__global__ void stencilGlobal(const float* in, float* out, int n) //不使用内存共享
{
   int i= blockIdx.x * blockDim.x + threadIdx.x;
   if(i>=n)return;
     if (i == 0 || i == n - 1) { out[i] = in[i]; return; }
   out[i] = (in[i-1] + in[i] + in[i+1]) / 3.0f;
}

__global__ void stencilShared(const float* in, float* out, int n) //使用内存共享
{ 
    __shared__ float s[BLOCK+2];
    int t=threadIdx.x;
    int i= blockIdx.x * blockDim.x + t;
    int me=t+1;
    if(i<n)s[me]=in[i];
    if(t==0)  
    {
        int left=blockIdx.x*blockDim.x-1;
        s[0]=(left>=0)?in[left]:0;
    }
    if(t==BLOCK-1)
    {
        int right=(blockIdx.x+1)*BLOCK;
        s[BLOCK+1]=(right<n)?in[right]:0;
    }
    __syncthreads(); 
    if(i>=n)return;
    if (i == 0 || i == n - 1) { out[i] = in[i]; return; }
    out[i] = (s[me - 1] + s[me] + s[me + 1]) / 3.0f;


}

float bench(bool strided, const float* in, float* out) {
    const int bs = 256, grid = (N + bs - 1) / bs, REPEAT = 20;
    for (int r = 0; r < 2; r++) {                   // 热身 2 次（第 1 步的纪律）
        if (strided) stencilGlobal <<<grid, bs>>>(in, out, N);
        else         stencilShared<<<grid, bs>>>(in, out, N);
    }
    CUDA_CHECK(cudaDeviceSynchronize());
    cudaEvent_t s, e;
    CUDA_CHECK(cudaEventCreate(&s));
    CUDA_CHECK(cudaEventCreate(&e));
    CUDA_CHECK(cudaEventRecord(s));
    for (int r = 0; r < REPEAT; r++) {
        if (strided) stencilGlobal <<<grid, bs>>>(in, out, N);
        else         stencilShared<<<grid, bs>>>(in, out, N);
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
    stencilShared<<<N / BLOCK, BLOCK>>>(dIn, dOut, N);
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaMemcpy(hOut, dOut, N * sizeof(float), cudaMemcpyDeviceToHost));
    int bad = 0;
   for (int i = 0; i < N; i++) {
    float expect = (i == 0 || i == N - 1) ? hIn[i]
                                          : (hIn[i-1] + hIn[i] + hIn[i+1]) / 3.0f;
    if (fabsf(hOut[i] - expect) > 1e-3f) bad++;  
   }
    printf("绕道小黑板抄书: 错 %d 处（应为 0）\n\n", bad);
   
    // --- 性能 ---
    float t1 = bench(false, dIn, dOut);   // stencilShared = 绕黑板
    float t2 = bench(true,  dIn, dOut);   // stencilGlobal    = 直接抄
    printf("直接抄:   %.3f ms\n", t2);
    printf("绕黑板:   %.3f ms  → 比值 %.2f\n", t1, t1 / t2);

    // --- 收尾 ---
    cudaFree(dIn);
    cudaFree(dOut);
    free(hIn);
    free(hOut);
    return 0; 
}