# 第二阶段题册 · 12 关（C++ 收尾 + CMake + GDB）

> 配套《第二阶段手册》（桌面）。做完一关，回到仓库根目录提交一次：
> `cd ~/projects/cuda-performance-lab && git add . && git commit -m "Week2: 第 N 关"`
> 第 1~8 关在 `playground.cpp` 里做（做完一关覆盖下一关，不用留着），
> 第 9~12 关在 include/ src/ CMakeLists.txt 上做。

| 关卡 | 主题 | 对应计划 | 手册章节 |
|---|---|---|---|
| 1~3 | vector / 越界 / iterator | Day 8~9 | 第二部分 |
| 4~6 | algorithm 五件套 | Day 10 | 第三部分 |
| 7 | 裸指针 vs 智能指针 | Day 11 | 第四部分 |
| 8 | lambda 捕获 | Day 12 | 第五部分 |
| 9 | **主项目：填满 stats.cpp** | Day 10+13 | 第八部分 |
| 10 | CMake 三步盲打 | Day 13 | 第六部分 |
| 11 | gdb 抓 segfault | Day 14 | 第七部分 |
| 12 | 全链路验收 | Day 14 | 第十部分 |

---

## 第 1 关 · vector 三板斧

建文件 `playground.cpp`：建一个空 `std::vector<double>`，循环 push_back 存入 10 个数（i * 1.5），
打印 size()，再打印第 1 个和最后一个（用 `v[0]` 和 `v[v.size()-1]`）。

- [ ] 能说出 vector 和数组的两个区别（会不会自己长大 / 会不会记住长度）
- [ ] 程序输出正确

## 第 2 关 · 越界实验（重要！）

接着写：vector 只有 10 个元素，故意访问 `v[100]` 赋值给它，运行看看发生什么；
再换成 `v.at(100)`，用 try/catch 包住，catch 里打印 `越界了`。

- [ ] 亲眼见到：`v[100]` 可能不报错、不崩溃、静默装死（未定义行为——最危险的错是不报错的错）
- [ ] 亲眼见到：`v.at(100)` 抛 `std::out_of_range` 异常被你抓住

## 第 3 关 · iterator 与 range-for 互改

同一份数据（随便 5 个数），写两段遍历：range-for 一段，
`for (auto it = v.begin(); it != v.end(); ++it)` 一段（打印要用 `*it`）。
再用 `v.begin() + 2` 让一个迭代器跳到第 3 个元素，打印它。

- [ ] 两段输出一模一样
- [ ] 能解释：iterator 就是" generalized 的指针"，range-for 是它的语法糖
- [ ] 能说出 `*it` 的 `*` 在干什么（取迭代器位置上的值）

## 第 4 关 · sort 热身（lambda 首次露脸）

vector<int> 存 {5, 2, 9, 1, 7}：先 `sort` 从小到大打印；
再传第三个参数 `[](int a, int b) { return a > b; }` 从大到小打印。

- [ ] 两遍输出正确（1 2 5 7 9 和 9 7 5 2 1）
- [ ] 能猜出那个方括号东西是"告诉 sort 什么叫更大"的函数

## 第 5 关 · accumulate 的 0 陷阱

vector<double> 存 {1.5, 2.5, 3.5, 4.0}（真和 = 11.5）：
分别用 `std::accumulate(v.begin(), v.end(), 0)` 和 `..., 0.0)` 求和，打印两个结果对比。

- [ ] 亲眼看到初值 0 输出 11（整数截断），0.0 输出 11.5
- [ ] 能解释：accumulate 的初值决定了累加过程中"和"是什么类型

## 第 6 关 · min_element / max_element 取值

同一份数据：`std::min_element(v.begin(), v.end())` 直接打印会打出乱码一样的迭代器；
在前面加 `*` 再打印。

- [ ] 亲眼见到不加 `*` 打印的不是数
- [ ] 能解释：这对算法返回的是"位置"，`*` 是去这个位置取货

## 第 7 关 · 裸指针 vs unique_ptr

两段程序：
A 段：`int* p = new int(42);` 打印 `*p`（**故意不写 delete**，编译运行毫无异常——这就是问题）；
B 段：`auto p = std::make_unique<int>(42);` 打印 `*p`，用完不写任何释放代码。

- [ ] 亲眼确认：忘写 delete 编译器不报错、运行也不报错（内存悄悄漏了）
- [ ] 能说出 B 段为什么不用手动释放（离开作用域自动 delete —— RAII）
- [ ] 能用一句话说清 RAII：资源获取即初始化，释放交给对象生命周期

## 第 8 关 · lambda 的两种捕获

```cpp
int x = 10;
auto f1 = [=] { return x * 2; };   // [=] 按值捕获：拍照留念
auto f2 = [&] { return x * 2; };   // [&] 按引用捕获：装了摄像头
x = 20;                             // 定义完之后再改 x
// 打印 f1() 和 f2()
```

先在纸上猜两个输出，再运行验证。

- [ ] 猜对：f1() = 20（拍照时的 x 是 10），f2() = 40（实时看到 20）
- [ ] 能解释 [=] 与 [&] 的区别

## 第 9 关 · 主项目：填满 stats.cpp ⭐ 本阶段核心

`src/stats.cpp` 现在是空壳（analyzer 跑出全 0）。把 6 个 TODO 全部用
`<algorithm>` / `<numeric>` 填满（不许手写循环）：
add 用 push_back；count 一行；min/max 用 min_element/max_element 加 `*`；
mean 用 accumulate（初值 0.0！）；median 先复制再 sort 再取中间（偶数个取中间两个的平均）。

完成后（在 cpp/build/ 里）`make && ./analyzer`，对照仓库根的 data.txt 验证：
样本数 6，最小 11.8，中位数 (12.9+13.1)/2 = 13.0（排序后中间两个是 12.9 和 13.1），最大 15.0，平均 ≈ 13.25。

- [ ] 五个数字全部和手算一致
- [ ] `./analyzer 不存在的文件` 打印"打不开"并正常退出（不是崩溃）
- [ ] git commit -m "Week2: analyzer v2 用 STL 算法完成"

## 第 10 关 · CMake 三步盲打 + 触发重新 cmake

在 cpp/ 里把 build 整个删掉（`rm -rf build`），**不看手册**重新三步建出来并编译运行。
然后做个实验：改 stats.cpp 里随便一行 → 只需 `make`（秒编）；
给 CMakeLists.txt 加一个源文件或加一行注释 → make 会提示你重新 cmake。

- [ ] 三步命令（mkdir / cmake / make）盲打完成
- [ ] 能说出规律：**改 .cpp 只需 make；动 CMakeLists.txt 才需要重新 cmake**
- [ ] 体会：所有构建垃圾都被关在 build/ 里，源码目录永远干净（out-of-source）

## 第 11 关 · gdb 抓 segfault

进入 build/：`gdb ./segfault` → `run` → 看到信号后 `bt`（backtrace 全称）→ `quit`。
（第一次进 gdb 问 debuginfod 选 n 就行。）

- [ ] 写出崩溃行号：第 **7** 行（level3 里的 `*p = 42;`）
- [ ] 写出 bt 里从上到下的调用链：level3 ← level2 ← level1 ← main
- [ ] 能解释 bt 第 0 帧里 `p=0x0` 是什么：p 是空指针（nullptr）
- [ ] 修复：把 segfault.cpp 改对，重新 make，程序跑通到底

## 第 12 关 · 全链路验收（做不到不进 CUDA）

故意把 `src/main.cpp` 改出一个编译错误 → make 看报错修回；
再故意改出一个能编译但运行崩溃的错误（提示：想办法对一个坏指针解引用）→
**不许看代码人肉找**，用 gdb run + bt 定位行号 → 修复 → make → 跑通 → commit。

- [ ] make 的编译错误看第一条就能修
- [ ] 崩溃只靠 gdb 定位，说得出文件和行号
- [ ] 最终 commit：`git add . && git commit -m "Week2: 全链路验收通过"`
- [ ] 对照手册第十部分验收清单逐项打勾

---
---

# 参考答案（做完再看！）

## 第 1 关

```cpp
#include <iostream>
#include <vector>
int main() {
    std::vector<double> v;
    for (int i = 0; i < 10; i++) v.push_back(i * 1.5);
    std::cout << v.size() << "\n";        // 10
    std::cout << v[0] << " " << v[v.size()-1] << "\n";   // 0 13.5
}
```

## 第 2 关

```cpp
// v[100] = 1.0;   // 大概率不崩！未定义行为，最坑的形态就是"看起来没事"
try {
    v.at(100) = 1.0;
} catch (const std::out_of_range& e) {
    std::cout << "越界了: " << e.what() << "\n";
}
```

## 第 3 关

```cpp
for (double x : v) std::cout << x << " ";                       // 写法一
for (auto it = v.begin(); it != v.end(); ++it) std::cout << *it << " ";  // 写法二
auto it3 = v.begin() + 2;   // 跳到第 3 个元素
std::cout << *it3;
```

## 第 4 关

```cpp
#include <algorithm>
std::vector<int> v{5, 2, 9, 1, 7};
std::sort(v.begin(), v.end());                                    // 1 2 5 7 9
std::sort(v.begin(), v.end(), [](int a, int b) { return a > b; }); // 9 7 5 2 1
```

## 第 5 关

```cpp
#include <numeric>
std::cout << std::accumulate(v.begin(), v.end(), 0);    // 11（被 int 初值带偏）
std::cout << std::accumulate(v.begin(), v.end(), 0.0);  // 11.5 ✓
```

## 第 6 关

```cpp
std::cout << *std::min_element(v.begin(), v.end());
std::cout << *std::max_element(v.begin(), v.end());
```

## 第 7 关

```cpp
#include <memory>
int* a = new int(42);          // 裸指针：忘了 delete 就漏了，谁也不提醒你
std::cout << *a << "\n";
// delete a;                   // 这行不写，程序照样正常结束 —— 这正是危险所在

auto b = std::make_unique<int>(42);   // 智能指针：main 结束自动释放
std::cout << *b << "\n";
```

## 第 8 关

f1() = 20，f2() = 40。`[=]` 在定义那一刻把 x 拷了一份（照片）；
`[&]` 只是记住了 x 的地址（摄像头），调用时看现值。

## 第 9 关

```cpp
#include "stats.h"
#include <algorithm>
#include <numeric>

void Stats::add(double t) { times_.push_back(t); }
int Stats::count() const { return (int)times_.size(); }

double Stats::min() const {
    if (times_.empty()) return 0;
    return *std::min_element(times_.begin(), times_.end());
}
double Stats::max() const {
    if (times_.empty()) return 0;
    return *std::max_element(times_.begin(), times_.end());
}
double Stats::mean() const {
    if (times_.empty()) return 0;
    return std::accumulate(times_.begin(), times_.end(), 0.0) / times_.size();
}
double Stats::median() const {
    if (times_.empty()) return 0;
    std::vector<double> s = times_;          // 复制，别动原数据顺序
    std::sort(s.begin(), s.end());
    int n = (int)s.size();
    if (n % 2 == 1) return s[n / 2];
    return (s[n / 2 - 1] + s[n / 2]) / 2.0;
}
```

## 第 10 关

```bash
cd ~/projects/cuda-performance-lab/cpp
rm -rf build
mkdir build && cd build
cmake ..        # 只需一次：读 CMakeLists 生成 Makefile
make            # 之后改 .cpp 反复用这一条就够
./analyzer
```

## 第 11 关

崩溃点 segfault.cpp **第 7 行**。bt 从上到下：#0 level3 ← #1 level2 ← #2 level1 ← #3 main。
`p=0x0` 说明传进来的指针是空指针，解引用空指针 = 段错误。
修复方法：level2 里改成 `int val = 0; level3(&val);`（或把 nullptr 去掉）。

## 第 12 关

编译错误修法：只看 make 输出的**第一条** error，后面的错误多是连锁，改一处重编一次。
运行崩溃示例：在 main.cpp 里 `int* bad = nullptr; *bad = 1;`
→ `gdb ./analyzer` → `run` → `bt` → 看到行号 → 修复 → `make` → 跑通 → commit。
