// 故意写崩的程序（Day 14 / TASKS.md 第 11 关）。
// 规则：先直接 ./segfault 看现象，再进 gdb 抓它。
// 任务：说出崩溃发生在第几行、以及 backtrace 里三层函数各自是谁。
#include <iostream>

void level3(int* p) {
    *p = 42;
}

void level2() {
    int* p = nullptr;
    level3(p);
}

void level1() {
    level2();
}

int main() {
    std::cout << "程序开始..." << std::endl;
    level1();
    std::cout << "这行永远执行不到" << std::endl;
    return 0;
}
