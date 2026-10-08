#include <cstdio>
#include <cuda_runtime.h>

int main() {
    int count = 0;
    cudaError_t err = cudaGetDeviceCount(&count);
    if (err != cudaSuccess) {
        fprintf(stderr, "CUDA 不可用: %s\n", cudaGetErrorString(err));
        return 1;
    }
    printf("检测到 %d 块 CUDA 设备\n", count);
    printf("Hello, CUDA!\n");
    return 0;
}