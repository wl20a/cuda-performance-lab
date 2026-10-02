#include <iostream>
#include <memory>
#include <string>
using namespace std;

// 模拟一个"连接"类（类似 C++ Primer 的例子）
struct connection {
    string addr;
    connection(const string& a) : addr(a) {}
};

connection connect(const string& addr) {
    cout << "[connect] 建立连接到 " << addr << endl;
    return connection(addr);
}

// 连接的专用关闭函数 —— 不能用 delete，必须调用它
void end_connection(connection* p) {
    cout << "[end_connection] 关闭到 " << p->addr << " 的连接" << endl;
}

int main() {
    connection c = connect("192.168.1.1:8080");

    {   // 内层作用域：演示离开作用域时自动调用删除器
        unique_ptr<connection, decltype(end_connection)*> p(&c, end_connection);
        cout << "[main] 正在使用连接: " << p->addr << endl;
    }   // p 在这里析构 → 自动调用 end_connection(&c)

    cout << "[main] 已离开作用域" << endl;
    return 0;
}
