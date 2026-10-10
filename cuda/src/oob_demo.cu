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
const int n=1000;
__global__ void vecadd0(const float* a, const float* b, float* c, int n)
{
    int i=blockIdx.x*blockDim.x+threadIdx.x;
    // 故意不写 if(i<n)：4*256=1024 个线程，1000~1023 号越界
    // compute-sanitizer 抓到的第一个越界者: block(3) thread(232)
    // → 全局编号 = 3*256+232 = 1000，正好是数组外第一个下标
    c[i]=a[i]+b[i];
}
int main()
{
    float *a,*b,*c;
    size_t size=n*sizeof(float);
    cudaMalloc(&a,size);
    cudaMalloc(&b,size);
    cudaMalloc(&c,size);
    int block=256;
    int grid=(n+block-1)/block;
    vecadd0<<<grid,block>>>(a,b,c,n);
    cudaError_t err=cudaDeviceSynchronize();
    printf("Error: %s\n",cudaGetErrorString(err));
    cudaFree(a);
    cudaFree(b);
    cudaFree(c);
    return 0;
}