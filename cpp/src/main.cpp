#include "stats.h"
#include <fstream>
#include <iostream>
#include <string>

// 主程序已经写好（这部分你第一阶段已经练过：读文件 + 解析 + 容错）。
// 你的战场在 stats.cpp —— 用 STL 算法把统计部分填满。
// 用法：./analyzer [数据文件]
//       不给参数时默认读 ../../data.txt（从 cpp/build/ 里运行正好指向仓库根）

int main(int argc, char* argv[]) {
    const char* path = argc > 1 ? argv[1] : "../../data.txt";
    std::ifstream in(path);
    if (!in) {
        std::cerr << "打不开文件: " << path << std::endl;
        return 1;
    }

    Stats box;
    std::string line;
    while (std::getline(in, line)) {
        if (line.empty()) continue;
        try {
            box.add(std::stod(line));   // stod 解析失败会抛异常，正好当过滤网
        } catch (...) {
            std::cout << "跳过不是数字的行: " << line << std::endl;
        }
    }

    std::cout << "样本数: " << box.count() << std::endl;
    std::cout << "最小:   " << box.min() << std::endl;
    std::cout << "中位数: " << box.median() << std::endl;
    std::cout << "最大:   " << box.max() << std::endl;
    std::cout << "平均:   " << box.mean() << std::endl;
    return 0;
}
