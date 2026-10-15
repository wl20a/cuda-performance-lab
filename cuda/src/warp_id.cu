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

__global__ void squadLeader()
{
    int t=threadIdx.x;
    if(t%32!=0)return;
    int warp=t/32;
    int i=blockIdx.x*blockDim.x+t;
    int globalwarp=i/32;
      printf("班 %d · 班内第 %d 组 · 全局第 %d 组（管辖座位 %d~%d）\n",
           blockIdx.x, warp, globalwarp, globalwarp * 32, globalwarp * 32 + 31);
}

int main()
{
    cudaEvent_t a, b;
    cudaEventCreate(&a);
    cudaEventCreate(&b);
    cudaEventRecord(a);
    for(int i=0;i<20;i++)
    {
       squadLeader<<<4, 128>>>();
    }
    cudaEventRecord(b);
    cudaEventSynchronize(b);
    float ms;
    cudaEventElapsedTime(&ms, a, b);
    printf("总耗时 %.2f ms\n", ms/20.0f);

    CUDA_CHECK(cudaDeviceSynchronize());
    return 0; 
}