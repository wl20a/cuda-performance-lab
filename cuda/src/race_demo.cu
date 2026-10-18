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

#define CUDA_CHECK(call)                                                  \
    do {                                                                  \
        cudaError_t err = (call);                                         \
        if (err != cudaSuccess) {                                         \
            fprintf(stderr, "CUDA 错误 %s（%s:%d）\n",                    \
                    cudaGetErrorString(err), __FILE__, __LINE__);         \
            exit(1);                                                      \
        }                                                                 \
    } while (0) 


    __global__ void raceBad(const float* work,int *err) {
    __shared__ float board[BLOCK];
    int t = threadIdx.x;
    float v = 0.0f;                                  
    for (int d = 0; d < t * 8; d++) v += work[d];    // 杂活：拉开各 warp 进度
    board[t] = 1000.0f + t + v;                      // 干完杂活才写黑板
    float got = board[BLOCK - 1 - t];  
    float expected = 1000.0f + BLOCK - 1 - t;
    if(got != expected)
    {
        atomicAdd(err, 1);
    }              // ★ 不等栅栏，直接读对头写的
   
}

__global__ void raceGood(const float* work,int *err) {
    __shared__ float board[BLOCK];
    int t = threadIdx.x;
    float v = 0.0f;
    for (int d = 0; d < t * 8; d++) v += work[d];
    board[t] = 1000.0f + t + v;
    __syncthreads();                                 // ★ 块内栅栏：全员写完才许读
    float got = board[BLOCK - 1 - t];
    float expected = 1000.0f + BLOCK - 1 - t;
   if (got != expected) {
        atomicAdd(err, 1);
}
}


    int main()
    {
     float* dWork;
    int* dErr;

    CUDA_CHECK(cudaMalloc(&dWork, 8192 * sizeof(float)));
    CUDA_CHECK(cudaMemset(dWork, 0, 8192 * sizeof(float)));

    CUDA_CHECK(cudaMalloc(&dErr, sizeof(int)));

    // =========================
    // raceBad
    // =========================

    CUDA_CHECK(cudaMemset(dErr, 0, sizeof(int)));

    raceBad<<<64, BLOCK>>>(dWork, dErr);
    CUDA_CHECK(cudaDeviceSynchronize());

    int hErrBad;
    CUDA_CHECK(cudaMemcpy(
        &hErrBad,
        dErr,
        sizeof(int),
        cudaMemcpyDeviceToHost
    ));

    printf("--- 不加 __syncthreads() ---\n");
    printf("错误次数：%d\n", hErrBad);


    // =========================
    // raceGood
    // =========================

    CUDA_CHECK(cudaMemset(dErr, 0, sizeof(int)));

    raceGood<<<64, BLOCK>>>(dWork, dErr);
    CUDA_CHECK(cudaDeviceSynchronize());

    int hErrGood;
    CUDA_CHECK(cudaMemcpy(
        &hErrGood,
        dErr,
        sizeof(int),
        cudaMemcpyDeviceToHost
    ));

    printf("--- 加 __syncthreads() ---\n");
    printf("错误次数：%d\n", hErrGood);


    CUDA_CHECK(cudaFree(dWork));
    CUDA_CHECK(cudaFree(dErr));

 return 0; 
    }