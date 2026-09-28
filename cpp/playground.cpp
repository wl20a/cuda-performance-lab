#include<iostream>
#include<vector>
#include<string>
#include<list>
using namespace std;
int main()
{
    vector<double>s;
    for(int i=0;i<10;i++)
    {
        s.push_back(i*1.5);
    }
    s.reserve(99);
    cout<<s.capacity()<<endl;
    cout<<s.size()<<endl;
    cout<<*s.begin()<<endl;
    cout<<*(s.end()-1)<<endl;

    
    return 0;
}