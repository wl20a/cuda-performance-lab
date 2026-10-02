#include<iostream>
using namespace std;
#include<algorithm>
#include<vector>
#include<string>
#include<list>
#include<iterator>
#include<fstream>
#include<memory>
class strblob
{
    public:
    typedef vector<string>::size_type size_type;
    strblob();
    strblob(initializer_list<string>il);
    size_type size()const{return data->size();};//返回size函数定义
    bool empty()const{return data->empty();};//返回empty函数定义
    void push_back(const string&s){data->push_back(s);};//返回push_back函数定义
    void push_back(string &s)const{data->push_back(s);};//返回push_back函数定义

    string&front();
    string&back();
    string&pop_back();
    private:
    shared_ptr<vector<string>>data;
    void check(size_type i,const string &msg)const;
};
strblob::strblob():data(make_shared<vector<string>>()){}//默认构造函数定义
strblob::strblob(initializer_list<string>il):data(make_shared<vector<string>>(il)){}//构造函数定义
void strblob::check(size_type i,const string &msg)const//检测函数定义
{
    if(i>=data->size())
    throw out_of_range(msg);
}
string&strblob::front()//返回front函数定义
{
    check(0,"front on empty strblob");
    return data->front();
}
string&strblob::back()//返回、back函数定义
{
    check(0,"back on empty strblob");
    return data->back();
}
string&strblob::pop_back()//返回、pop_back函数定义
{
    check(0,"pop_back on empty strblob");
    string &s=data->back();
    data->pop_back();
    return s;
}
int main()
{
    
    return 0;
}