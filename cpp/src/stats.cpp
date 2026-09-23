#include "stats.h"

// ============================================================
// 现在这份文件是"空壳"：全部返回 0，能编译能运行，
// 但 analyzer 跑出来全是 0 —— 这正是起点。
// 第 9 关（TASKS.md）按顺序把它们填满，规则：
//   每个函数用 <algorithm> / <numeric> 的算法写成，不用手写循环。
// 需要的算法：std::min_element / std::max_element /
//             std::accumulate / std::sort
// 提示：min_element 返回的是"位置"（迭代器），取值要在前面加 *
// ============================================================

void Stats::add(double t) {
    // TODO(第9关)：一行
}

int Stats::count() const {
    // TODO(第9关)：一行
    return 0;
}

double Stats::min() const {
    // TODO(第9关)：空容器时返回 0，其余用算法一行
    return 0;
}

double Stats::max() const {
    // TODO(第9关)：同上
    return 0;
}

double Stats::mean() const {
    // TODO(第9关)：accumulate 求和。小心：初值必须写 0.0，写 0 会掉进整数陷阱
    return 0;
}

double Stats::median() const {
    // TODO(第9关)：
    //   1. 复制一份 times_（median 不能改动原始数据的顺序）
    //   2. sort 副本
    //   3. n 为奇数 -> sorted[n/2]
    //      n 为偶数 -> (sorted[n/2 - 1] + sorted[n/2]) / 2
    return 0;
}
