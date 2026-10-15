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


__global__ void Vecadd(const float* a, const float* b, float* c, int n) 
    {
        int i = blockIdx.x * blockDim.x + threadIdx.x;
        if (i < n)
            c[i] = a[i] + b[i];
    }

int main()
{
    
    cudaDeviceProp prop;
    CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));

    printf("GPU: %s | SM数 %d | 每班sm %.0f KB\n",
           prop.name, prop.multiProcessorCount, prop.sharedMemPerBlock / 1024.0);
    double peak = 2.0 * prop.memoryClockRate * 1e3 * (prop.memoryBusWidth / 8) / 1e9;
    printf("显存位宽 %d bit | 时钟 %.1f GHz | 粗算理论带宽 ≈ %.0f GB/s\n\n",
           prop.memoryBusWidth, prop.memoryClockRate / 1e6, peak);

    const int n = 1 << 25;
    float*hA=(float*)malloc(n*sizeof(float));
    float*hB=(float*)malloc(n*sizeof(float));    
    float*hC=(float*)malloc(n*sizeof(float));

    for(int i=0;i<n;i++)
    {
        hA[i]=1.0f;
        hB[i]=2.0f;
    }

    float *dA,*dB,*dC;
    CUDA_CHECK(cudaMalloc(&dA,n*sizeof(float)));
    CUDA_CHECK(cudaMalloc(&dB,n*sizeof(float)));
    CUDA_CHECK(cudaMalloc(&dC,n*sizeof(float)));
    CUDA_CHECK(cudaMemcpy(dA,hA,n*sizeof(float),cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(dB,hB,n*sizeof(float),cudaMemcpyHostToDevice));


    const int sizes[] = {96,128, 256, 512, 1024};
    const int REPEAT = 20;

      printf("block |  grid  | 平均耗时 | 有效带宽\n");
    printf("------+--------+----------+----------\n");

    for(int k=0;k<5;k++)
    {
        int bs=sizes[k];
        int grid=(n+bs-1)/bs;
        Vecadd<<<grid,bs>>>(dA,dB,dC,n);
        CUDA_CHECK(cudaDeviceSynchronize());
        cudaEvent_t start, stop;
        CUDA_CHECK(cudaEventCreate(&start));
        CUDA_CHECK(cudaEventCreate(&stop));
        CUDA_CHECK(cudaEventRecord(start));
        for(int i=0;i<REPEAT;i++)
        {
            Vecadd<<<grid,bs>>>(dA,dB,dC,n);

        }
        CUDA_CHECK(cudaEventRecord(stop));
        CUDA_CHECK(cudaEventSynchronize(stop));
        float ms = 0;
        CUDA_CHECK(cudaEventElapsedTime(&ms, start, stop));
        ms/=20;
        double bytes = 3.0 * n * sizeof(float);   
        double gbs = bytes / 1e9 / (ms / 1000.0);
        printf("%5d | %6d | %6.3f ms | %5.0f GB/s\n", bs, grid, ms, gbs);

        CUDA_CHECK(cudaEventDestroy(start));
        CUDA_CHECK(cudaEventDestroy(stop));
    }

    CUDA_CHECK(cudaMemcpy(hC, dC, n * sizeof(float), cudaMemcpyDeviceToHost));
    printf("\n抽查: C[0]=%.0f C[N-1]=%.0f（都应为 3）\n", hC[0], hC[n - 1]);

    free(hA); free(hB); free(hC);
    CUDA_CHECK(cudaFree(dA)); CUDA_CHECK(cudaFree(dB)); CUDA_CHECK(cudaFree(dC));
    return 0;
}