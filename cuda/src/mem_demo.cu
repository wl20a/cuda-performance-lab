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
int main()
{
    float h[4]={1.0f,2.0f,3.0f,4.0f};
    float *dh;
    float back[4];
    cudaMalloc(&dh,4*sizeof(float));
    cudaMemcpy(dh,h,4*sizeof(float),cudaMemcpyHostToDevice);
    cudaMemcpy(back,dh,4*sizeof(float),cudaMemcpyDeviceToHost);
    cudaFree(dh);
    cudaDeviceSynchronize();
    for(int i=0;i<4;i++)
    {
        cout<<back[i]<<" ";
    }
    cout<<endl;

    return 0;
}