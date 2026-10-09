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
const int n=6;

//宏
#define CUDA_CHECK(call)\                                                            
do{\
    cudaError_t err=(call);\
    if (err != cudaSuccess) { \
        printf("CUDA 错误 %s（%s:%d）\n",cudaGetErrorString(err), __FILE__, __LINE__); \
        exit(1); \
    } \
} while(0)

//映射

__global__ void vecadd(const float* a, const float* b, float* c, int n) 
    {
      int i=blockIdx.x*blockDim.x+threadIdx.x;
      if(i>=n)return;
      c[i]=a[i]+b[i];
      
    }

int main() {
    float a[n]={1,2,3,4,5,6};
    float b[n]={10,20,30,40,50,60};
    float c[n];

    float *da ,*db,*dc;
    CUDA_CHECK(cudaMalloc(&da,n*sizeof(float)));
    CUDA_CHECK(cudaMalloc(&db,n*sizeof(float)));
    CUDA_CHECK(cudaMalloc(&dc,n*sizeof(float)));

    CUDA_CHECK(cudaMemcpy(da,a,n*sizeof(float),cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(db,b,n*sizeof(float),cudaMemcpyHostToDevice));

    vecadd<<<(n+3)/4,4>>>(da,db,dc,n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaMemcpy(c,dc,n*sizeof(float),cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaDeviceSynchronize());

     for (int i = 0; i < n; i++)
        printf("%.0f + %.0f = %.0f\n", a[i], b[i], c[i]);

        
     CUDA_CHECK(cudaFree(da));
     CUDA_CHECK(cudaFree(db));
     CUDA_CHECK(cudaFree(dc));   


    cout<<endl;

    return 0;
}