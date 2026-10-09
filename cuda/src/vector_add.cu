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
    cudaMalloc(&da,n*sizeof(float));
    cudaMalloc(&db,n*sizeof(float));
    cudaMalloc(&dc,n*sizeof(float));

    cudaMemcpy(da,a,n*sizeof(float),cudaMemcpyHostToDevice);
    cudaMemcpy(db,b,n*sizeof(float),cudaMemcpyHostToDevice);

    vecadd<<<(n+3)/4,4>>>(da,db,dc,n);
    cudaMemcpy(c,dc,n*sizeof(float),cudaMemcpyDeviceToHost);

     for (int i = 0; i < n; i++)
        printf("%.0f + %.0f = %.0f\n", a[i], b[i], c[i]);

        
     cudaFree(da);
     cudaFree(db);
     cudaFree(dc);   


    cudaDeviceSynchronize();  //结束异步
    return 0;
}