#include<iostream>
using namespace std;
#include<algorithm>
#include<vector>
#include<string>
#include<list>
#include<iterator>
#include<fstream>
#include<memory>
#include <cuda_runtime.h>
   __global__ void hello() 
    {
       printf("Hello, World from GPU!");
      
    }

int main() {
    ostream &a=cout;
    int count = 0;
    cudaError_t err = cudaGetDeviceCount(&count);
    if (err != cudaSuccess) {
        fprintf(stderr, "CUDA 不可用: %s\n", cudaGetErrorString(err));
        return 1;
    }
    printf("检测到 %d 块 CUDA 设备\n", count);
    printf("Hello, CUDA!\n");
    a<<endl;
    a<<"hi"<<endl;
    hello<<<1,3>>>();
    cudaDeviceSynchronize();
    a<<endl;
    a<<"你好";

 

    return 0;
}