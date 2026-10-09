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

//线程id
__global__ void showid() 
    {
       printf("我是 %d 班 %d 号（共 %d 班 × 每班 %d 人）| 全局编号 = %d\n",
           blockIdx.x, threadIdx.x, gridDim.x, blockDim.x,
           blockIdx.x * blockDim.x + threadIdx.x);
      
    }

      
int main() {
    showid<<<2,4>>>();
    cudaDeviceSynchronize();  //结束异步
    return 0;
}