#pragma once
#include <vector>

// 第二阶段主项目 analyzer v2：
// 第一阶段 final.cpp 的 eternal 类是手写循环版，
// 这一版要求全部换成 <algorithm> / <numeric> 的一行算法（TASKS.md 第 9 关）。
// 头文件只放"声明"：外面世界只需要知道有哪些函数可调，不需要知道怎么实现。
class Stats {
public:
    void   add(double t);      // 记录一次运行时间
    int    count() const;      // 样本数
    double min() const;
    double max() const;
    double mean() const;
    double median() const;     // 新增：中位数（先排序再取中间）
private:
    std::vector<double> times_;
};
